using Printf

include("../population.jl")

################################################################################
# Initialization
################################################################################

@printf("Initialize ... \n")

# fixed parameters
s = 0.6370
Q = 2.5526
g = 1.05

# set retention
re = 0.0

# parameter grid
decline = [1/pi, 1000.0]
formation = collect(0.38 : 0.02 : 0.5) #should start where there is no immortality for k2->0
deltaK2 = 0.01
minDeltaK2 = 0.00001

# wanted rls
wantedRls = 24
deviation = 1

# NLME variation
sigma1 = 0.005
sigma2 = 0.005

# number of cells per parameter set
nCells = 200

# file where results will be saved
filename = "possibleWTParameters_noRe.txt"



################################################################################
# Experiment : find possible parameters for given lifespan
################################################################################
nR = length(decline)
nK1 = length(formation)
output = zeros(Float64, 5, nR * nK1)
nDeadCells = 0

for i = 1 : nR, j = 1 : nK1

    # get parameters
    global globalRetention = re
    global nDeadCells
    delta = deltaK2
    k1 = formation[j]
    R = decline[i]

    @printf("%i : k1 = %.2f, R = %.2f ... ", (i - 1) * nK1 + j, k1, R)

    # start k2 from very low
    k2 = 0.0

    # do coarse search for k2 parameter
    # adding a bit until the rls exceeded the wanted rls
    @printf("coarse search ... ")

    tmpRls = 0.0
    nDeadCells = 0
    while tmpRls < wantedRls

        # update k2
        k2 += delta;

        # if parameters are still in premature death region continue
        if !isAgeing([g, k1, k2, R, Q, s]) && tmpRls == 0
            continue
        end

        # create a population and add nCells virgin cells
        tmpPop = initializeEmptyPopulation(1, [g, R, Q, s], [k1, k2],
                                           [sigma1, sigma2])
        setResources!(tmpPop, 1.0)

        for n = 1:nCells
            addCell!(tmpPop, [1.0 - s, 0.0])
        end

        # evolve population in time and analyse cells
        evolveUncoupledPopulation!(tmpPop, 0, maxTime)
        analyse!(tmpPop)

        # extract average rls of all cells
        tmpRls = tmpPop.statistics[1, 1]
        cells = tmpPop.deadCells
        nDeadCells = length(cells)

        if isnan(tmpRls)
            tmpRls = 2 * wantedRls
        end

    end

    # continue with a finer search
    @printf("fine search ... ")
    while abs(tmpRls - wantedRls) > deviation && delta > minDeltaK2

        # decrease delta in each step
        delta /= 2

        # if the current rls is bigger than the wanted increase k1
        # otherwise decrease
        if tmpRls - wantedRls > 0
            k2 -= delta
        else
            k2 += delta
        end

        # create a population and add nCells virgin cells
        tmpPop = initializeEmptyPopulation(1, [g, R, Q, s], [k1, k2],
                                           [sigma1, sigma2])
        setResources!(tmpPop, 1.0)

        for n = 1:nCells
            addCell!(tmpPop, [1.0 - s, 0.0])
        end

        # evolve population in time and analyse cells
        evolveUncoupledPopulation!(tmpPop, 0, maxTime)
        analyse!(tmpPop)

        # extract average rls of all cells
        tmpRls = tmpPop.statistics[1, 1]
        cells = tmpPop.deadCells
        nDeadCells = length(cells)

        if isnan(tmpRls)
            tmpRls = 2 * wantedRls
        end

    end

    @printf("k2 = %.2f found.\n", k2)

    output[:, (i - 1) * nK1 + j] = [k1, k2, R, tmpRls, nDeadCells]

end



################################################################################
# Save output
################################################################################

@printf("save ... ")

open(filename, "w") do file
    write(file, "# =============================================\n")
    write(file, "# POSSIBLE PARAMETERS\n")
    write(file, "# =============================================\n")
    write(file, "# Q $Q \n")
    write(file, "# s $s \n")
    write(file, "# g $g \n")
    write(file, "# k1 variation $sigma1 \n")
    write(file, "# k2 variation $sigma2 \n")
    write(file, "# maximal time $maxTime \n")
    write(file, "# expected RLS $wantedRls pm $deviation \n")
    write(file, "# mean of $nCells cells \n")
    write(file, "# =============================================\n")
    write(file, "# k1\tk2\tR\tRLS\tnDead\n")
    for l = 1 : size(output, 2)
        for k = 1 : size(output, 1) - 1
            write(file, @sprintf("%.8f\t", output[k, l],))
        end
        write(file, @sprintf("%.8f\n", output[end, l],))
    end
end

@printf("done!")
