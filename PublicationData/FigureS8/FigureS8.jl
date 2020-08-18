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

# NLME variation
sigma1 = 0.00
sigma2 = 0.00

# file where parameters to use are saved
parameterFile = "reK2Surface.txt"
# file where results will be saved
filename = "wtPopulations.txt"



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

output = zeros(Float64, 32, nPopulations)
for i = 1 : nPopulations

    # get mean values for variable parameters
    meanK1 = parameters[i, 1]
    meanK2 = parameters[i, 2]
    R = parameters[i, 3]
    re = parameters[i, 4]
    global globalRetention = re

    @printf("%i : k1 = %.2f, k2 = %.2f, R = %.2f, re = %.2f ... ", i,
            meanK1, meanK2, R, re)

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
    #   mean k2, R, re, mean rls + std, mean rejuvenation index + std,
    #   mean generation time + std, mean cycle growth + std,
    #   mean total growth + std, mean lifetime + std,
    #   mean health + std, mean initial state + std,
    #   fraction of rejuvenated cells
    output[1:3, i] = [tmpPop.size, length(tmpPop.aliveCells), tmpPop.time]
    output[4:7, i] = [meanK1, meanK2, R, re]
    output[8:end - 1, i] = stat[1:2, 1:12][:]

    nRej = 0
    for j = 1 : length(tmpPop.deadCells)
        if (tmpPop.deadCells[j].rejuvenation > 0)
            nRej += 1
        end
    end
    fraction = nRej / length(tmpPop.deadCells)

    output[end, i] = fraction

    @printf("population analysed.\n")

end



################################################################################
# Save
################################################################################

@printf("save ... ")

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
    write(file, "# size(1)\talive(2)\ttime(3)\tk1(4)\tk2(5)\tR(6)\tre(7)\trls(8)")
    write(file, "\t±(9)\trej(10)\t±(11)\tgen(12)\t±(13)\tgrowthCycle(14)\t±(15)")
    write(file, "\tgrowth(16)\t±(17)\tlifetime(18)\t±(19)\thealth(20,22,24,26)")
    write(file, "\t±(21,23,25,27)\tinitState(28,30)")
    write(file, "\t±(29,31)\trejFrac(32)\n")
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

@printf("done!\n")
