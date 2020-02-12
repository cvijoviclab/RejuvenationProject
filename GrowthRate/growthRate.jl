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
R = 1 / pi
endTime = 8.0
maxDiv = 40
globalRetention = 0.2957

# founder cell for population
nPopulations = 20

# NLME fixed effect
meanK1 = 0.4
meanK2 = 0.1375

# NLME variation
sigma1 = 0.005
sigma2 = 0.005

# file that contains the average intial values
fileInits = "decCapHighRe.txt"

# file where results will be saved
filename = "decCapHighRe_t8.txt"




################################################################################
# Read initial conditions for different buds
# take meean and estimate sigma by IQR/1.35 (normality assumption)
################################################################################
data = readdlm(fileInits, '\t', Float64, '\n', skipstart = 4)
initialP = [data[:, 7] ((data[:, 5] - data[:, 2]) / 1.349)]
initialD = [data[:, 13] ((data[:, 11] - data[:, 8]) / 1.349)]

nDiv = size(initialP, 1)



################################################################################
# Go through all parameters and create populations
################################################################################

@printf("generate populations ... \n")

constantParameters = [g, R, Q, s]
variablesFixedEffect = [meanK1, meanK2]
variablesRandomEffect = [sigma2, sigma2]

statsOutput = zeros(Float64, min(nDiv, maxDiv), 17)

for i = 1 : min(nDiv, maxDiv)

    @printf("Bud %i, initial P %.4f ± %.4f, initial D %.4f ± %.4f... \n", i,
             initialP[i, 1], initialP[i, 2], initialD[i, 1], initialD[i, 2])
             
    output = zeros(Float64, nPopulations, 2)

    for n = 1 : nPopulations

        # create a population and add nCells virgin cells
        pop = initializeEmptyPopulation(i, constantParameters,
                                           variablesFixedEffect,
                                           variablesRandomEffect)
        setResources!(pop, 1.0)
        p0 = max(0.0, randn() * initialP[i, 2] + initialP[i, 1])
        d0 = max(0.0, randn() * initialD[i, 2] + initialD[i, 1])
        addCell!(pop, [p0, d0])

        # evolve population in time and analyse cells
        evolvePopulation!(pop, endTime)

        # save in output array
        output[n, :] = [length(pop.aliveCells), log(length(pop.aliveCells))/endTime]
        
        # print
        @printf("\t%i has %i cells \n", n, length(pop.aliveCells))
    end
    
    stats1 = summarystats(output[:, 1])
    stats2 = summarystats(output[:, 2])
    statsOutput[i, :] = [i, initialP[i, 1], initialP[i, 2], initialD[i, 1],
                        initialD[i, 2], stats1.min, stats1.q25, stats1.median,
                        stats1.q75, stats1.max, stats1.mean, stats2.min, stats2.q25,
                        stats2.median, stats2.q75, stats2.max, stats2.mean]

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
    write(file, "# k1 $meanK1 ± $sigma1 \n")
    write(file, "# k2 $meanK2 ± $sigma2 \n")
    write(file, "# R $R\n")
    write(file, "# maximal time $endTime \n")
    write(file, "# $nPopulations independent populations \n")
    write(file, "# =============================================\n")
    write(file, "# bud\tPinit\t±\tDinit\t±\tstats(6)\n")
    for l = 1 : size(statsOutput, 1)
        for k = 1 : size(statsOutput, 2) - 1
            write(file, @sprintf("%.4f\t", statsOutput[l, k]))
        end
        write(file, @sprintf("%.4f\n", statsOutput[l, end]))
    end
end

@printf("done!")
