using Printf
using DelimitedFiles

include("../../population.jl")

################################################################################
# Initialization
################################################################################

@printf("Initialization ... \n")

# fixed parameters
s = 0.6370
Q = 2.5526
g = 1.05
R = 1000.0
maxGeneration = 3
maxTime = 1000.0
globalRetention = 0.2957
damageThreshold = 0.5

# founder cell for population
nStartCells = 1
initialState = [0.5150 0.1419]

# NLME fixed effect
meanK1 = 0.4
meanK2 = 0.09219

# NLME variation
sigma1 = 0.005
sigma2 = 0.005

# number of repetitions
nPopulations = 10

# file where results will be saved
filename = "wt_unlimCap_highRe_3gen.txt"




################################################################################
# Create populations with given parameters
################################################################################

@printf("generate populations ... \n")

constantParameters = [g, R, Q, s]
variablesFixedEffect = [meanK1, meanK2]
variablesRandomEffect = [sigma2, sigma2]

output = zeros(Float64, 22, nPopulations * maxCellNumber)
idx = 1
for i = 1 : nPopulations

    # create a population and add nCells virgin cells
    pop = initializeEmptyPopulation(i, constantParameters,
                                       variablesFixedEffect,
                                       variablesRandomEffect)
    setResources!(pop, 1.0)

    for n = 1:nStartCells
        addCell!(pop, initialState)
    end

    # evolve population in time and analyse cells
    evolveUncoupledPopulation!(pop, maxGeneration, maxTime)
    analyse!(pop)
    stat = pop.statistics

    # save cells in output array:
    # OBS: it is assumed that all cells died, otherwise all values that are
    #      dependent on the mother are wrong as the index is wrong
    oldIdx = idx
    for k = 1 : length(pop.deadCells)

        global idx

        cell = pop.deadCells[k]

        #   population id, id, mother id, child, generation, rls, rejuvenation
        #   index, birth time, death time
        output[1:9, idx] = [i, cell.id, cell.motherId, cell.daughter,
                          cell.generation, cell.rls, cell.rejuvenation,
                          cell.life[1, 1], cell.life[end, 1]]
         
        if cell.rls > 1
            #   mean generation time
            output[14, idx] = mean(cell.generationTimes[2:end])
        
               #   mean rel. growth per cell cycle
            output[15, idx] = mean(cell.growth[2:end, 1])
        
            #   rel. total growth since start
            output[16, idx] = cell.growth[end, 2]
        end
 
           #   time with D <= threshold
        tauIdx = findfirst(x -> x >= damageThreshold, cell.life[:, 3])
        output[17, idx] = cell.life[tauIdx, 1] - cell.life[1, 1]

        # number of divisions with D <= threshold
        output[18, idx] = length(findall(x -> x <= tauIdx, cell.divisionIdxs))
            
        #   initial state
        output[19:20, idx] = cell.life[1, 2:end]
        
        # k1, k2 parameter values
        output[21:22, idx] = cell.parameters[variableParametersIdxs]

        # exclude the founder cells for properties that need the mother
        if cell.motherId > 0
            mother = pop.deadCells[cell.motherId]
            child = cell.daughter
            divIdx = mother.divisionIdxs[child]
            
            #   generation time of mother at birth of this cell, damage of
            #   mother before birth of this cell, rel. growth in cell cycle
            #   of mother at birth of this cell, rel. growth of mother since
            #   start at birth of this cell
            output[10:13, idx] = [mother.generationTimes[child],
                                  mother.life[divIdx, end],
                                  mother.growth[child, 1], mother.growth[child, 2]]
        end

        idx += 1

    end

    # update the indices such that different population do not have the same
    output[2, oldIdx:idx - 1] .+= oldIdx - 1
    output[3, oldIdx + nStartCells:idx - 1] .+= oldIdx - 1

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
    write(file, "# k1 $meanK1 ± $sigma1 \n")
    write(file, "# k2 $meanK2 ± $sigma2 \n")
    write(file, "# R $R \n")
    write(file, "# re $globalRetention \n")
    write(file, "# damage threshold $damageThreshold \n")
    write(file, "# maximal time $maxTime \n")
    write(file, "# maximal generation $maxGeneration \n")
    write(file, "# start with $nStartCells cells \n")
    write(file, "# $nPopulations independent populations \n")
    write(file, "# =============================================\n")
    write(file, "# pop(1)\tid(2)\tmomId(3)\tchildId(4)\tgen(5)\trls(6)\t")
    write(file, "rej(7)\tbirthT(8)\tdeathT(9)\tgenTMom(10)\tDMom(11)\t")
    write(file, "cycleGrowthMom(12)\ttotGrowthMom(13)\tmeanGenT(14)\t")
    write(file, "meanCycleGrowth(15)\ttotGrowth(16)\ttau(17)\tnHealthy(18)\t")
    write(file, "initState(19-20)\tparams(21-22)\n")
    for l = 1 : idx - 1
        for k = 1 : 6
            write(file, @sprintf("%i\t", output[k, l]))
        end
        for k = 7 : size(output, 1) - 1
            write(file, @sprintf("%.4f\t", output[k, l]))
        end
        write(file, @sprintf("%.4f\n", output[end, l]))
    end
end

@printf("done!")
