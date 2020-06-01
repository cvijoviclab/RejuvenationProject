using Printf
using DelimitedFiles

include("../population.jl") # or where file lies

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
nCases = 4

# define grid for
damageThreshold = collect(0.1:0.1:0.9)

# founder cells for populations
nStartCells = 10
initialState = [0.4847 0.1135; 0.3630 0.1688; 0.5150 0.1419; 0.3630 0.1745]

# NLME fixed effects for the 4 cases
meanK1 = [0.4, 0.4, 0.4, 0.4]
meanK2 = [0.1375, 0.03125, 0.09219, 0.02438]
R = [1/pi, 1/pi, 1000.0, 1000.0]
re = [0.2957, 0.0, 0.2957, 0.0]

# NLME variation
sigma1 = 0.005
sigma2 = 0.005

# file where results will be saved
# corresponds to FigureS2_decCapHighRe.txt, FigureS2_decCapNoRe.txt,
# FigureS2_unlimCapHighRe.txt, FigureS2_unlimCapNoRe.txt
filename = "healthThreshold.txt"



################################################################################
# Generate populations for all cases and investigate the health parameter
################################################################################

@printf("Generate populations ... \n")

for i = 1 : nCases

    global globalRetention

    @printf("case %i ... ", i)

    constantParameters = [g, R[i], Q, s]
    variablesFixedEffect = [meanK1[i], meanK2[i]]
    variablesRandomEffect = [sigma1, sigma2]
    globalRetention = re[i]

    # create a population and add nCells virgin cells
    pop = initializeEmptyPopulation(i, constantParameters,
                                       variablesFixedEffect,
                                       variablesRandomEffect)
    setResources!(pop, 1.0)

    for n = 1:nStartCells
        addCell!(pop, initialState[i, :])
    end

    # evolve population in time and analyse cells
    evolveUncoupledPopulation!(pop, maxGeneration, maxTime)

    @printf("populations generated ... get tau and eta for each cell ... ")

    # go through all daughters and get the mean health parameter + std
    # for all the damage thresholds
    cellData = zeros(Float64, length(pop.deadCells), 1 + length(damageThreshold))
    for j = 1 : length(pop.deadCells)
        cell = pop.deadCells[j]
        d = cell.daughter
        cellData[j, 1] = d
        for k = 1 : length(damageThreshold)
            tauIdx = findfirst(x -> x >= damageThreshold[k], cell.life[:, 3])
            tau = (cell.life[tauIdx, 1] - cell.life[1, 1]) /
                  (cell.life[end, 1] - cell.life[1, 1])
            eta = length(findall(x -> x <= tauIdx, cell.divisionIdxs)) /
                  cell.rls
            if isnan(eta)
                eta = 0
            end
            cellData[j, 1 + k] = tau * eta
        end
    end

    @printf("calculate statistics ... ")

    # get statistics for daughters
    sortedData = sortslices(cellData, dims = 1, by = x -> x[1])
    output = zeros(Float64, Int(sortedData[end, 1]),
                   1 + 2 * length(damageThreshold))

    for l = 1 : Int(sortedData[end, 1])
        tmpData = sortedData[findall(x -> x == l, sortedData[:, 1]), :]
        nCells = size(tmpData, 1)
        if nCells == 1
            output[l, 1] = l
            output[l, 2:end] = fill(NaN, 2 * length(damageThreshold))
        else
            m = mean(tmpData, dims = 1)
            s = std(tmpData, dims = 1)
            stats = [m[2:end]'; s[2:end]']
            output[l, 1] = l
            output[l, 2:end] = stats[:]
        end
    end


    @printf("save ... ")
    savename = @sprintf("%i_", i) * filename
    open(savename, "w") do file
        write(file, "# HEALTH IN LINEAGE\n")
        write(file, "# Q $Q \n")
        write(file, "# s $s \n")
        write(file, "# k1 $(meanK1[i]) ± $sigma1 \n")
        write(file, "# k2 $(meanK2[i]) ± $sigma2 \n")
        write(file, "# R $(R[i]) \n")
        write(file, "# re $globalRetention \n")
        write(file, "# maximal time $maxTime \n")
        write(file, "# maximal generation $maxGeneration \n")
        write(file, "# start with $nStartCells cells \n")
        write(file, "# damage threshold $damageThreshold \n")
        write(file, "# daughter\thealth\thealthStd\n")
        writedlm(file, output, "\t")
    end

    @printf("done! \n")

end
