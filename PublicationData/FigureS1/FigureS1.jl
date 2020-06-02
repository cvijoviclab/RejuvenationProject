using Printf
using DelimitedFiles

include("../population.jl")

################################################################################
# Initialization
################################################################################

@printf("Initialization ... \n")

# fixed parameters
s = 0.6370
Q = 2.5526
g = 1.05
maxGeneration = 3
maxTime = 1000.0
nStartCells = 5

# set retention
re = 0.2957

# NLME variation
sigma1 = 0.005
sigma2 = 0.005

# file where parameters to use are saved
parameterFile = "possibleWTParameters.txt"
# file where results will be saved
filename = "WTPopulations.txt"



################################################################################
# Read possible parameters
################################################################################
@printf("read \"%s\" ... \n", parameterFile)

parameters = readdlm(parameterFile, '\t', Float64, '\n', skipstart = 13)
nPopulations = size(parameters, 1)



################################################################################
# Go through all parameters and create populations
################################################################################

@printf("generate populations ... \n")

output = zeros(Float64, 22, nPopulations)
for i = 1 : nPopulations

    # get mean values for variable parameters
    meanK1 = parameters[i, 1]
    meanK2 = parameters[i, 2]
    R = parameters[i, 3]
    global globalRetention = re

    @printf("%i : k1 = %.2f, k2 = %.2f, R = %.2f ... ", i, meanK1, meanK2, R)

    constantParameters = [g, R, Q, s]
    variablesFixedEffect = [meanK1, meanK2]
    variablesRandomEffect = [sigma2, sigma2]

    # find the average intitial state for that parameter set
    initialState = averageInitialCell(constantParameters, variablesFixedEffect,
                                      variablesRandomEffect, maxGeneration - 1)

    @printf("average initial conditions found ... ")

    # create a population and add nCells virgin cells
    tmpPop = initializeEmptyPopulation(1, constantParameters,
                                       variablesFixedEffect,
                                       variablesRandomEffect)
    setResources!(tmpPop, 1.0)

    for n = 1:nStartCells
        addCell!(tmpPop, initialState)
    end

    # evolve population in time and analyse cells
    evolveUncoupledPopulation!(tmpPop, maxGeneration, maxTime)
    analyse!(tmpPop)
    stat = tmpPop.statistics

    # save in output array:
    #   population size, number of alive cells, current time, mean k1,
    #   mean k2, R, mean rls + std, mean rejuvenation index + std,
    #   mean generation time + std, rel. growth per cell cycle + std,
    #   rel. cumulative growth + std, lifetime + std, mean health span + std,
    #   mean initial state + std
    output[1:3, i] = [tmpPop.size, length(tmpPop.aliveCells), tmpPop.time]
    output[4:6, i] = [meanK1 meanK2 R]
    output[7:end, i] = stat[1:2, [1, 2, 3, 4, 5, 6, 7, 12]][:]

    @printf("population analysed.\n")

end



################################################################################
# Save
################################################################################

@printf("save ... \n")

open(filename, "w") do file
    write(file, "# =============================================\n")
    write(file, "# POPULATIONS\n")
    write(file, "# =============================================\n")
    write(file, "# Q $Q \n")
    write(file, "# s $s \n")
    write(file, "# g $g \n")
    write(file, "# k1 variation $sigma1 \n")
    write(file, "# k2 variation $sigma2 \n")
    write(file, "# maximal time $maxTime \n")
    write(file, "# maximal generation $maxGeneration \n")
    write(file, "# start with $nStartCells cells \n")
    write(file, "# =============================================\n")
    write(file, "# size\talive\ttime\tk1\tk2\tR\trls\t±\trej\t±")
    write(file, "\t±\tgen\t±\tgrowthCycle\t±")
    write(file, "\tgrowth\t±\tlifetime\t±\th")
    write(file, "\tinitState\t±\n")
    for l = 1 : size(output, 2)
        for k = 1 : 2
            write(file, @sprintf("%i\t", output[k, l]))
        end
        for k = 3 : size(output, 1) - 1
            write(file, @sprintf("%.4f\t", output[k, l]))
        end
        write(file, @sprintf("%.4f\n", output[end, l]))
    end
end

@printf("done!")
