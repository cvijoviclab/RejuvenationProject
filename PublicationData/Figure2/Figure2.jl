using Printf

include("../population.jl") # or where file lies

################################################################################
# Initialization
################################################################################

@printf("Initialize ... \n")

# fixed parameters
s = 0.6370
Q = 2.5526
g = 1.05
maxTime = 1000.0

# parameter grid
k1 = collect(0.25 : 0.005 : 1.5)
k2 = collect(0.005 : 0.005: 1.5)
R = [10^3, 1/pi]
reMax = 0.2957

# wanted rls
wantedRls = 24
deviation = 0

# damage threshold for bad cell
damageThreshold = 0.5

# constant initial conditions
initialState = [1 - s, 0.0]

# file where results will be saved
# corresponds to Figure2.txt
filename = "wtSurface.txt"



################################################################################
# Experiment: find re for each combination that results in the wanted RLS
################################################################################

@printf("find re values ...\n")

results = zeros(Float64, length(k1) * length(k2) * length(R), 8)
idx = 1

for i in k1

    @printf("k1 %.3f\n", i)

    for j in k2, c in R

        global idx
        delta = 0.02
        re = reMax + delta
        rls = 0
        lifetime = 0.0
        tau = 0.0
        eta = 0.0

        # coarse search for right re value
        # by constant steps until the rls is too high
        while true
            re -= delta
            re = max(0.0, re)
            global globalRetention = re
            parameters = [g, i, j, c, Q, s]
            cell = singleCell(initialState, parameters)
            rls = cell.rls

            if rls > wantedRls + deviation || re <= 0.0
                break
            end
        end

        # fine search for right re value
        # by decreasing steps and adpation of the direction
        # until the correct rls is found
        # or the step size is too small
        while abs(rls - wantedRls) > deviation && delta > 0.00005 && re >= 0.0 && re <= reMax

            delta /= 2
            if rls - wantedRls > 0
                re += delta
            else
                re -= delta
            end

            global globalRetention = re
            parameters = [g, i, j, c, Q, s]
            cell = singleCell(initialState, parameters)
            rls = cell.rls
            lifetime = cell.life[end, 1] - cell.life[1, 1]
            if cell.life[end, 3] >= 1.0
                tauIdx = findfirst(x -> x >= damageThreshold, cell.life[:, 3])
                tau = cell.life[tauIdx, 1] / lifetime
                eta = length(findall(x -> x <= tauIdx, cell.divisionIdxs)) / rls
                if isnan(eta)
                    eta = 0
                end
            end

        end

        # only add to results if a reasonable value could be found
        if abs(rls - wantedRls) <= deviation && re <= reMax && re >= 0.0
            results[idx, :] = [i, j, c, re, rls, lifetime, tau, eta]
            idx += 1
        end

    end
end

results = results[1 : idx - 1, :]


################################################################################
# Save output
################################################################################

@printf("save ... \n")

open(filename, "w") do file
    write(file, "# =============================================\n")
    write(file, "# WT SURFACES\n")
    write(file, "# =============================================\n")
    write(file, "# Q $Q \n")
    write(file, "# s $s \n")
    write(file, "# g $g \n")
    write(file, "# maximal time $maxTime \n")
    write(file, "# expected RLS $wantedRls pm $deviation \n")
    write(file, "# =============================================\n")
    write(file, "# k1\tk2\tR\tre\tRLS\tlifetime\ttau\teta\n")
    for l = 1 : size(results, 1)
        for k = 1 : size(results, 2) - 1
            write(file, @sprintf("%.6f\t", results[l, k]))
        end
        write(file, @sprintf("%.6f\n", results[l, end]))
    end
end

@printf("done!\n")
