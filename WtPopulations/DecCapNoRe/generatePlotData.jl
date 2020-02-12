
using Printf
using DelimitedFiles
using Statistics
using StatsBase


@printf("Create data for plots ...\n")

s = 0.6370
Q = 2.5526
re = 0.0

filename ="wt_decCap_noRe_3gen.txt"
path = "Data/"

data = readdlm(filename, '\t', Float64, '\n', skipstart = 16)
dataNoFounders = data[findall(x -> x > 0, data[:, 3]), :]

motherIdx = unique(data[:, 3])
motherIdx = motherIdx[2:end]
nMothers = length(motherIdx)

maxDaughter = Int(maximum(dataNoFounders[:, 4]))


################################################################################
# 1 BOXPLOT OF INITIAL CONTENT OF DAUGTHER CELL
################################################################################
@printf("1. Boxplot of initial content of daughter cell ... ")
output = path * "initsDaughter_boxplot.txt"
boxplot = zeros(Float64, maxDaughter, 13)
moreThan5 = zeros(Bool, maxDaughter)
for i = 1 : maxDaughter
    tmpIdx = findall(x -> x == i, dataNoFounders[:, 4])
    statP = summarystats(dataNoFounders[tmpIdx, 19])
    statD = summarystats(dataNoFounders[tmpIdx, 20])
    boxplot[i, :] = [i, statP.min, statP.q25, statP.median, statP.q75,
                    statP.max, statP.mean, statD.min, statD.q25,
                    statD.median, statD.q75, statD.max, statD.mean]
    if length(tmpIdx) > 10
        moreThan5[i] = true
    end
end

open(output, "w") do file
    write(file, "# BOXPLOT OF INITIAL CONTENT OF DAUGTHER CELL\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# stats: min, q25, q50, q75, max, mean \n")
    write(file, "# daughter\tstatsP(6)\tstatsD(6)\n")
    writedlm(file, boxplot[moreThan5, :], "\t")
end

@printf("done!\n")




################################################################################
# 2 BOXPLOT OF INITIAL CONTENT OF MOTHER CELL
################################################################################
@printf("2. Boxplot of initial content of mother cell ... ")
output = path * "initsMother_boxplot.txt"
boxplot = zeros(Float64, maxDaughter, 13)
moreThan5 = zeros(Bool, maxDaughter)
for i = 1 : maxDaughter
    tmpIdx = findall(x -> x == i, dataNoFounders[:, 4])
    dMom = dataNoFounders[tmpIdx, 11]
    statP = summarystats(s .- re .* (1 - s) .* Q .* dMom)
    statD = summarystats((s .+ re .* (1 - s)) .* dMom)
    boxplot[i, :] = [i, statP.min, statP.q25, statP.median, statP.q75,
                    statP.max, statP.mean, statD.min, statD.q25,
                    statD.median, statD.q75, statD.max, statD.mean]
    if length(tmpIdx) > 10
        moreThan5[i] = true
    end
end

open(output, "w") do file
    write(file, "# BOXPLOT OF INITIAL CONTENT OF MOTHER CELL\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# stats: min, q25, q50, q75, max, mean \n")
    write(file, "# daughter\tstatsP(6)\tstatsD(6)\n")
    writedlm(file, boxplot[moreThan5, :], "\t")
end

@printf("done!\n")



################################################################################
# 3 DAUGHTER VS RLS BY REJUVENATION
################################################################################
@printf("3. Daughter vs rls by rejuvenation index ... ")
output = path * "daughterVsRls_rej.txt"
orderIdx = sortperm(dataNoFounders[:, 7], rev = true)
specData = dataNoFounders[orderIdx, [4, 6, 7]]

open(output, "w") do file
    write(file, "# DAUGHTER VS RLS BY REJUVENATION\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# daughter\trls\trejuvenation\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 4 GENERATION TIME VS GROWTH BY REJUVENATION
################################################################################
@printf("4. Generation time vs growth by rejuvenation index ... ")
output = path * "genTVsGrowth_rej.txt"
orderIdx = sortperm(dataNoFounders[:, 7], rev = true)
specData = dataNoFounders[orderIdx, [14, 15, 7]]

open(output, "w") do file
    write(file, "# DAUGHTER VS RLS BY REJUVENATION\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# genT\tcycleGrowth\trejuvenation\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 5 INITIAL SIZE VS GROWTH BY REJUVENATION
################################################################################
@printf("5. Initial size vs growth by rejuvenation index ... ")
output = path * "initSizeVsGrowth_rej.txt"
orderIdx = sortperm(dataNoFounders[:, 7], rev = true)
specData = dataNoFounders[orderIdx, [19, 16, 7]]
specData[:, 1] += Q .* dataNoFounders[orderIdx, 20]

open(output, "w") do file
    write(file, "# DAUGHTER VS RLS BY REJUVENATION\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# initSize\ttotGrowth\trejuvenation\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 6 MEAN REJUVENATION INDEX IN LINEAGE
################################################################################
@printf("6. Mean rejuvenation index in lineage ... ")
output = path * "rejIdx_lineage.txt"
lineageData = zeros(Float64, size(data, 1), 12)

for i = 1 : size(data, 1)
    child = data[i, 4]

    motherIdx = Int(data[i, 3])
    if motherIdx > 0
        motherChild = data[motherIdx, 4]
    else
        motherChild = 0
    end

    lineageData[i, :] = [data[i, 1], motherChild, child, data[i, 6], data[i, 7],
                         data[i, 9] - data[i, 8], data[i, 14], data[i, 15],
                         data[i, 17], data[i, 18], data[i, 19], data[i, 20]]
end

# sort by mother and daughter such that we can cluster data from lineage positions
sortedLineageData = sortslices(lineageData, dims = 1, by = x->(x[2],x[3]))

# get the cuts between the lineage positions in data
x = sortedLineageData[1, 2]
y = sortedLineageData[1, 3]
n = [0]
k = 1
for i = 2 : size(sortedLineageData, 1)
    global k, x, y

    if x == sortedLineageData[i, 2] && y == sortedLineageData[i, 3]
        k += 1
    else
        push!(n, k)
        k = 1
    end

    x = sortedLineageData[i, 2]
    y = sortedLineageData[i, 3]
end
nCum = cumsum(n)

specData = zeros(Float64, length(n) - 1, 4)
for i = 2 : length(n)
    tmpData = sortedLineageData[nCum[i-1] + 1 : nCum[i], :]
    if n[i] == 1
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], NaN, NaN]
    else
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], mean(tmpData[:, 5]),
                              std(tmpData[:, 5])]
    end
end

open(output, "w") do file
    write(file, "# REJUVENATION INDEX IN LINEAGE\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# mother\tdaughter\trejMean\trejStd\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 7 MEAN RLS IN LINEAGE
################################################################################
@printf("7. Mean rls in lineage ... ")
output = path * "rls_lineage.txt"

specData = zeros(Float64, length(n) - 1, 4)
for i = 2 : length(n)
    tmpData = sortedLineageData[nCum[i-1] + 1 : nCum[i], :]
    if n[i] == 1
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], NaN, NaN]
    else
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], mean(tmpData[:, 4]),
                              std(tmpData[:, 4])]
    end
end

open(output, "w") do file
    write(file, "# RLS IN LINEAGE\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# mother\tdaughter\trlsMean\trlsStd\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 8 MEAN GENERATION TIME IN LINEAGE
################################################################################
@printf("8. Mean generation time in lineage ... ")
output = path * "genT_lineage.txt"

specData = zeros(Float64, length(n) - 1, 4)
for i = 2 : length(n)
    tmpData = sortedLineageData[nCum[i-1] + 1 : nCum[i], :]
    if n[i] == 1
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], NaN, NaN]
    else
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], mean(tmpData[:, 7]),
                              std(tmpData[:, 7])]
    end
end

open(output, "w") do file
    write(file, "# GENERATION TIME IN LINEAGE\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# mother\tdaughter\tgenTMean\tgenTStd\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 9 MEAN GROWTH PER CELL CYCLE IN LINEAGE
################################################################################
@printf("9. Mean growth per cell cycle in lineage ... ")
output = path * "growthCycle_lineage.txt"

specData = zeros(Float64, length(n) - 1, 4)
for i = 2 : length(n)
    tmpData = sortedLineageData[nCum[i-1] + 1 : nCum[i], :]
    if n[i] == 1
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], NaN, NaN]
    else
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], mean(tmpData[:, 8]),
                              std(tmpData[:, 8])]
    end
end

open(output, "w") do file
    write(file, "# GROWTH PER CELL CYCLE IN LINEAGE\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# mother\tdaughter\tgrowthCycleMean\tgrowthCycleStd\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 10 MEAN INITIAL SIZE IN LINEAGE
################################################################################
@printf("10. Mean initial size in lineage ... ")
output = path * "initSize_lineage.txt"

specData = zeros(Float64, length(n) - 1, 4)
for i = 2 : length(n)
    tmpData = sortedLineageData[nCum[i-1] + 1 : nCum[i], :]
    if n[i] == 1
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], NaN, NaN]
    else
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], mean(tmpData[:, 11] .+
                              Q .* tmpData[:, 12]), std(tmpData[:, 11] .+
                              Q .* tmpData[:, 12])]
    end
end

open(output, "w") do file
    write(file, "# INITIAL SIZE IN LINEAGE\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# mother\tdaughter\tinitSizeMean\tinitSizeStd\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 11 MEAN INITIAL DAMAGE IN LINEAGE
################################################################################
@printf("11. Mean initial damage in lineage ... ")
output = path * "initD_lineage.txt"

specData = zeros(Float64, length(n) - 1, 4)
for i = 2 : length(n)
    tmpData = sortedLineageData[nCum[i-1] + 1 : nCum[i], :]
    if n[i] == 1
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], NaN, NaN]
    else
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], mean(tmpData[:, 12]),
                              std(tmpData[:, 12])]
    end
end

open(output, "w") do file
    write(file, "# INITIAL DAMAGE IN LINEAGE\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# mother\tdaughter\tinitDMean\tinitDStd\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 12 REJUVENATION FRACTION IN LINEAGE
################################################################################
@printf("12. Rejuvenation fraction in lineage ... ")
output = path * "rejFraction_lineage.txt"

specData = zeros(Float64, length(n) - 1, 7)
for i = 2 : length(n)
    tmpData = sortedLineageData[nCum[i-1] + 1 : nCum[i], :]
    nCells = size(tmpData, 1)
    rejData = tmpData[findall(x -> x > 0.0, tmpData[:, 5]), :]
    fraction1 = size(rejData, 1) / nCells
    rejData = tmpData[findall(x -> x > 0.2, tmpData[:, 5]), :]
    fraction2 = size(rejData, 1) / nCells
    rejData = tmpData[findall(x -> x > 0.5, tmpData[:, 5]), :]
    fraction3 = size(rejData, 1) / nCells
    rejData = tmpData[findall(x -> x > 1.0, tmpData[:, 5]), :]
    fraction4 = size(rejData, 1) / nCells
    
    if nCells == 1
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], nCells, NaN, NaN,
                              NaN, NaN]
    else
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], nCells, fraction1,
                              fraction2, fraction3, fraction4]
    end
end

open(output, "w") do file
    write(file, "# REJUVENATION FRACTION IN LINEAGE\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# mother\tdaughter\tnCells\trej>0\trej>0.2\trej>0.5\trej>1\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 13 MEAN HEALTH SPAN
################################################################################
@printf("13. Mean health span in lineage ... ")
output = path * "health_lineage.txt"

specData = zeros(Float64, length(n) - 1, 10)
for i = 2 : length(n)
    tmpData = sortedLineageData[nCum[i-1] + 1 : nCum[i], :]
    tau = tmpData[:, 9] ./ tmpData[:, 6]
    eta = tmpData[:, 10] ./ tmpData[:, 4]
    replace!(eta, NaN => 0)
    
    health1 = tau .* eta
    health2 = 0.1 * tau .+ 0.9 * eta
    health3 = 0.5 * tau .+ 0.5 * eta
    health4 = 0.9 * tau .+ 0.1 * eta
    
    if n[i] == 1
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], NaN, NaN, NaN, NaN,
                              NaN, NaN, NaN, NaN]
    else
        specData[i - 1, :] = [tmpData[1, 2], tmpData[1, 3], mean(health1),
                              std(health1), mean(health2), std(health2),
                              mean(health3), std(health3), mean(health4),
                              std(health4)]
    end
end

open(output, "w") do file
    write(file, "# HEALTH SPAN IN LINEAGE\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# four measures for health with tau and eta: \n")
    write(file, "# product, weighted sum 0.1-0.9, 0.5-0.5, 0.9-0.1 \n")
    write(file, "# mother\tdaughter\thealth\thealthStd\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 14 REJUVENATION FRACTIONS DEPENDING ON AGE OF MOTHER CELL
################################################################################
@printf("14. Rejuvenation fraction depending on sublineage ... ")
output = path * "rejFraction_mother.txt"

specData = zeros(Float64, Int(sortedLineageData[end, 2]), 6)
for i = 1 : Int(sortedLineageData[end, 2])
    tmpData = sortedLineageData[findall(x -> x == i, sortedLineageData[:, 2]), :]
    nCells = size(tmpData, 1)
    rejData = tmpData[findall(x -> x > 0.0, tmpData[:, 5]), :]
    fraction1 = size(rejData, 1) / nCells
    rejData = tmpData[findall(x -> x > 0.2, tmpData[:, 5]), :]
    fraction2 = size(rejData, 1) / nCells
    rejData = tmpData[findall(x -> x > 0.5, tmpData[:, 5]), :]
    fraction3 = size(rejData, 1) / nCells
    rejData = tmpData[findall(x -> x > 1.0, tmpData[:, 5]), :]
    fraction4 = size(rejData, 1) / nCells
    
    if nCells <= 5
        specData[i, :] = [tmpData[1, 2], nCells, NaN, NaN, NaN, NaN]
    else
        specData[i, :] = [tmpData[1, 2], nCells, fraction1, fraction2, fraction3,
                          fraction4]
    end
end

open(output, "w") do file
    write(file, "# REJUVENATION FRACTION DEPENDING ON AGE OF MOTHER CELL\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# mother\tnCells\tfraction\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")




################################################################################
# 15 HEALTH SPAN FRACTIONS DEPENDING ON MOTHER
################################################################################
@printf("15. Health span fraction depending on mother ... ")
output = path * "healthFraction_mother.txt"

specData = zeros(Float64, Int(sortedLineageData[end, 2]), 14)
for i = 1 : Int(sortedLineageData[end, 2])
    tmpData = sortedLineageData[findall(x -> x == i, sortedLineageData[:, 2]), :]
    nCells = size(tmpData, 1)
    
    tau = tmpData[:, 9] ./ tmpData[:, 6]
    eta = tmpData[:, 10] ./ tmpData[:, 4]
    replace!(eta, NaN => 0)
    
    health = eta .* tau
    
    healthData = findall(x -> x > 0.3, health)
    fraction1 = length(healthData) / nCells
    healthData = findall(x -> x > 0.5, health)
    fraction2 = length(healthData) / nCells
    healthData = findall(x -> x > 0.7, health)
    fraction3 = length(healthData) / nCells
    
    health = 0.1 * tau .+ 0.9 * eta
    
    healthData = findall(x -> x > 0.3, health)
    fraction4 = length(healthData) / nCells
    healthData = findall(x -> x > 0.5, health)
    fraction5 = length(healthData) / nCells
    healthData = findall(x -> x > 0.7, health)
    fraction6 = length(healthData) / nCells
    
    health = 0.5 * tau .+ 0.5 * eta
    
    healthData = findall(x -> x > 0.3, health)
    fraction7 = length(healthData) / nCells
    healthData = findall(x -> x > 0.5, health)
    fraction8 = length(healthData) / nCells
    healthData = findall(x -> x > 0.7, health)
    fraction9 = length(healthData) / nCells
    
    health = 0.9 * tau .+ 0.1 * eta
    
    healthData = findall(x -> x > 0.3, health)
    fraction10 = length(healthData) / nCells
    healthData = findall(x -> x > 0.5, health)
    fraction11 = length(healthData) / nCells
    healthData = findall(x -> x > 0.7, health)
    fraction12 = length(healthData) / nCells

    if nCells <= 5
        specData[i, :] = [tmpData[1, 2], nCells, NaN, NaN, NaN, NaN, NaN, NaN,
                          NaN, NaN, NaN, NaN, NaN, NaN]
    else
        specData[i, :] = [tmpData[1, 2], nCells, fraction1, fraction2, fraction3,
                         fraction4, fraction5, fraction6, fraction7, fraction8,
                         fraction9, fraction10, fraction11, fraction12]
    end
end

open(output, "w") do file
    write(file, "# HEALTH SPAN FRACTION DEPENDING ON AGE OF MOTHER CELL\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# four measures for health with tau and eta: \n")
    write(file, "# product, weighted sum 0.1-0.9, 0.5-0.5, 0.9-0.1 \n")
    write(file, "# mother\tnCells\tfraction\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")


################################################################################
# 16 DAUGHTER VS INITIAL DAMAGE BY REJUVENATION
################################################################################
@printf("16. Daughter vs initial damage by rejuvenation index ... ")
output = path * "daughterVsDinit_rej.txt"
orderIdx = sortperm(dataNoFounders[:, 7], rev = true)
specData = dataNoFounders[orderIdx, [4, 20, 7]]

open(output, "w") do file
    write(file, "# DAUGHTER VS D BY REJUVENATION\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# daughter\tinitD\trejuvenation\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")



################################################################################
# 17 HEALTHSPAN VS RLS BY REJUVENATION
################################################################################
@printf("17. Health span vs rls by rejuvenation index ... ")
output = path * "healthVsRls_rej.txt"
orderIdx = sortperm(dataNoFounders[:, 7], rev = true)
specData = dataNoFounders[orderIdx, [1, 6, 7]]
specData[:, 1] = dataNoFounders[orderIdx, 17] ./ (dataNoFounders[orderIdx, 9] - dataNoFounders[orderIdx, 8]) .* dataNoFounders[orderIdx, 18] ./ dataNoFounders[orderIdx, 6]

open(output, "w") do file
    write(file, "# HEALTHSPAN VS RLS BY REJUVENATION\n")
    write(file, "# original file \"$filename\" \n")
    write(file, "# h\trls\trejuvenation\n")
    writedlm(file, specData, "\t")
end

@printf("done!\n")
