using Printf
using DelimitedFiles

include("../population.jl")

################################################################################
# Initialization
################################################################################

@printf("Initialize ... \n")

# file with parameters
parameterFile = "wtSurface.txt"

# output file with gradients
filename = "gradients.txt"



################################################################################
# Read data
################################################################################

@printf("read data ...\n")

data = readdlm(parameterFile, '\t', Float64, '\n', skipstart = 10)
Rs = unique(data[:, 3])


################################################################################
# Get gradients
################################################################################

@printf("get gradients ...\n")

data = data[:, 1:4]
gradients = zeros(Float64, size(data, 1) * 3, 5)
idx = 1

for c in Rs
	
	global idx
	
    tmpData = data[findall(x -> x == c, data[:, 3]), :]
	k1s = unique(tmpData[:, 1])
	
	for i in k1s	
		tmpData2 = tmpData[findall(x -> x == i, tmpData[:, 1]), :]
		sortslices(tmpData2, dims = 1, by = x -> x[2])
		diffK2 = tmpData2[2:end, 2] - tmpData2[1:end-1, 2]
		diffRe = tmpData2[2:end, 4] - tmpData2[1:end-1, 4]
		
		m = mean(diffK2 ./ diffRe)
		s = std(diffK2 ./ diffRe)
		
		if !isnan(m) 
			gradients[idx, :] = [1, c, i, m, s]
			idx += 1
		end
	end

	k2s = unique(tmpData[:, 2])

	for i in k2s
		tmpData2 = tmpData[findall(x -> x == i, tmpData[:, 2]), :]
		sortslices(tmpData2, dims = 1, by = x -> x[1])
		diffK1 = tmpData2[2:end, 1] - tmpData2[1:end-1, 1]
		diffRe = tmpData2[2:end, 4] - tmpData2[1:end-1, 4]
		
		m = mean(diffK1 ./ diffRe)
		s = std(diffK1 ./ diffRe)
		
		if !isnan(m)
			gradients[idx, :] = [2, c, i, m, s]
			idx += 1
		end
	end

    tmpData[:, 4] = map(x -> round(x * 100) / 100, tmpData[:, 4])
	res = sort(unique(tmpData[:, 4]))
	for i in res
		tmpData2 = tmpData[findall(x -> x == i, tmpData[:, 4]), :]
		sortslices(tmpData2, dims = 1, by = x -> x[2])
		diffK2 = tmpData2[2:end, 2] - tmpData2[1:end-1, 2]
		diffK1 = tmpData2[2:end, 1] - tmpData2[1:end-1, 1]
		
		m = mean(diffK2 ./ diffK1)
		s = std(diffK2 ./ diffK1)
		
		if !isnan(m)
			gradients[idx, :] = [3, c, i, m, s]
			idx += 1
		end
	end

end

gradients = gradients[1:idx-1, :]



################################################################################
# Save output
################################################################################

@printf("save ... \n")

open(filename, "w") do file
    write(file, "# =============================================\n")
    write(file, "# GRADIENTS\n")
    write(file, "# =============================================\n")
    write(file, "# original file $parameterFile \n")
    write(file, "# =============================================\n")
    write(file, "# type\tR\tparam\tgradientMean\tgradientStd\n")
    for l = 1 : size(gradients, 1)
        for k = 1 : size(gradients, 2) - 1
            write(file, @sprintf("%.4f\t", gradients[l, k]))
        end
        write(file, @sprintf("%.4f\n", gradients[l, end]))
    end
end

@printf("done!\n")
