using Printf

include("../population.jl")



################################################################################
# Initialization
################################################################################
@printf("Initialization ... ")
Q = 2.5526
s = 0.6370
g = 1.05
k1 = 0.4
wt = [g g;
      k1 k1;
      0.09218750 0.1375;
      1000.0 0.31830989;
      Q Q;
      s s]

output = zeros(Float64, 500, 12)
maxIdx = zeros(Float64, 12)

filename = "dynamics.txt"
filename2 = "repairTerms.txt"



################################################################################
# Go through parameters and save data of P and D over time
################################################################################
@printf("produce singel cell data ... ")

for i = 1:2
    parameters = wt[:, i]
    initialState = [1.0 - parameters[6], 0.0]

    cell = singleCell(initialState, parameters)
    idx = collect(1:size(cell.life, 1))
    output[idx, 3 * (i - 1) + 1] = cell.life[:, 1]
    output[idx, 3 * (i - 1) + 2] = cell.life[:, 2]
    output[idx, 3 * (i - 1) + 3] = cell.life[:, 3]

    maxIdx[3 * (i - 1) + 1 : 3 * (i - 1) + 3] = idx[end] .* ones(Float64, 3)
end



################################################################################
# Save
################################################################################
@printf("save ... \n")

open(filename, "w") do file
    write(file, "# WT DYNAMICS FOR DIFFERENT REPAIR MECHANISMS\n")
    write(file, "# Q $Q\n")
    write(file, "# s $s\n")
    write(file, "# g $g\n")
    write(file, @sprintf("# k1 = [%.2f %.2f]\n", wt[2, 1], wt[2, 2]))
    write(file, @sprintf("# k2 = [%.2f %.2f]\n", wt[3, 1], wt[3, 2]))
    write(file, @sprintf("# k3 = [%.2f %.2f]\n", wt[4, 1], wt[4, 2]))
    write(file, "# t\tP\tD\n")
    for i = 1 : 500
        for j = 1 : 12
            if i > maxIdx[j]
                write(file, ".")
            else
                write(file, @sprintf("%.4f", output[i, j]))
            end
            if j < 12
                write(file, "\t")
            else
                write(file, "\n")
            end
        end
    end
end


@printf("done!\n")
