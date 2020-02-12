using DifferentialEquations
using Statistics
using StatsBase

################################################################################
# global parameters
################################################################################
# intact and damaged proteins
# OBS: if nEquations is not 2 the last two equations should determine
#      division and death
nEquations = 2
# parameters (in that order) g, k1, k2, R, Q, s
nParameters = 6
constantParametersIdxs = [1, 4, 5, 6]
variableParametersIdxs = [2, 3]
# define the number of variables that are analyzed:
#   rls, rejuvenation, generation time, rel. growth per cell cycle,
#   rel. growth, absolute lifetime, health span (4 cases),
#   initial state, NLME parameters
nStatistics = 10 + nEquations + length(variableParametersIdxs)
# set some parameters for algorithm
solverError = 0.000001
initialsError = 0.001
maxDataPoints = 10000
maxCellNumber = 300000
maxTime = 500.0
rlsThreashold = 80
nTrials = 20
globalRetention = -1
damageThreshold = 0.5


mutable struct Cell
    id::Int

    motherId::Int
    generation::Int
    daughter::Int

    parameters::Array{Float64,1}
    life::Array{Float64,2}

    generationTimes::Array{Float64,1}
    growth::Array{Float64,2}
    divisionIdxs:: Array{Int,1}
    rls::Int
    rejuvenation::Float64

end

mutable struct Population
    id::Int

    constantParameters::Array{Float64,1}
    variableParametersFixedEffect::Array{Float64,1}
    variableParametersRandomEffect::Array{Float64,1}

    size::Int
    aliveCells::Array{Cell,1}
    aliveCellIdxs::BitArray
    deadCells::Array{Cell,1}

    time::Float64
    state::Array{Float64,1}
    parameters::Array{Float64,2}
    indices::Array{Int,2}

    statistics::Array{Float64,2}
end



################################################################################
# define model
################################################################################
function damageAccumulationModel!(Dstate, state, parameters, t)

    # plus two equations per cell : intact (p) and damaged (d) proteins
    for i in 2 : 2 : length(state)

        # state variables
        p, d = state[i:i + 1]

        # parameters
        g, k1, k2, R, Q = parameters[1:5, i÷2]

        # ODEs
        Dstate[i] = p * (g - d) - k1 * p + k2 * R * Q * sin(d / R)
        Dstate[i+1] = k1 / Q * p - k2 * R * sin(d / R)

        # update the food with the consumption of the cells

    end

    # coupling by food equation
    Dstate[1] = 0.0

    nothing

end



################################################################################
# define event condition : division at p >= 1 and death at d >= 1
################################################################################
function condition(state, t, integrator)

    1 - maximum(state[2:end])

end



################################################################################
# define what to do when event condition is fulfilled : stop
################################################################################
affect!(integrator) = terminate!(integrator)



################################################################################
# define retention function
################################################################################
function retention(parameters, damage = 1)

    Q, s = parameters[5:6]

    1 / Q * (2 * s - 1) / (1 - s) * 1 / damage

end



################################################################################
# check if a single cell is ageing : appropriate parameters
################################################################################
function isAgeing(parameters)

    # initialization
    prematurelyOld = false
    immortal = false
    Q, s = parameters[5:6]
    if globalRetention == -1
        re = retention(parameters)
    else
        re = globalRetention
    end
    cb = ContinuousCallback(condition, affect!)


    # 1: set state to the healthiest possible daughter and solve until event
    best = [1.0, 1 - s, 0.0]
    model = ODEProblem(damageAccumulationModel!, best,
                       (0.0, maxTime), parameters)
    solution = solve(model, Tsit5(), reltol = solverError, callback = cb)
    idx = findmax(solution[end][2:end])[2] + 1
    type = idx % nEquations

    # if this cell dies before it divides
    # the parameter set leads to a premature old cell
    if type == 1
        prematurelyOld = true
    end

    # 2: set state to the worst possible mother and solve until event
    worst = [1.0, s - re * Q * (1 - s), s + (1 - s) * re]
    model = ODEProblem(damageAccumulationModel!, worst,
                       (0.0, maxTime), parameters)
    solution = solve(model, Tsit5(), reltol = solverError, callback = cb)
    idx = findmax(solution[end][2:end])[2] + 1
    type = idx % nEquations

    # if this cell still divides
    # the parameter set leads to an immortal cell
    if type == 0
        immortal = true
    end

    # 3: there could still be some infinite loop where in one cell cycle the
    #    cell grows exactly as much as it buds off at division
    if immortal == false
        tmpCell = singleCell([1 - s, 0.0], parameters)
        if tmpCell.rls == rlsThreashold
            immortal = true
        end
    end

    !immortal & !prematurelyOld

end


################################################################################
# define distribution of proteins at division
################################################################################
function division!(state, parameters, cellId)

    idx = nEquations * cellId
    currentD = state[idx + 1]

    Q, s = parameters[5:6, cellId]

    # chose if retention is calcuated by formula and dependent on damage or
    # just set by a global value
    if globalRetention == -1
        re = retention(parameters)
    else
        re = globalRetention
    end

    # update state for mother cell
    state[idx] = s - re * ( 1 - s) * Q * currentD
    state[idx+1] = (s + (1 - s) * re) * currentD

    # new state for daughter cell
    newState = [(1 - s) + re * ( 1 - s) * Q * currentD,
                (1 - s) * (1 - re) * currentD]

    newState

end



################################################################################
# calculate single cell
################################################################################
function singleCell(initialState, parameters, startTime = 0.0, maxTime = maxTime)

    # initialization and predeclaration of some variables
    currentTime = startTime
    tmpRls = 0
    l = 1
    nData = maxDataPoints
    data = zeros(Float64, maxDataPoints, nEquations + 1)
    tmpGenerationTimes = zeros(Float64, rlsThreashold)
    tmpGrowth = zeros(Float64, rlsThreashold, 2)
    tmpDivisionIdxs = zeros(Int, rlsThreashold)
    initialSize = initialState[1] + Q * initialState[2]
    state = cat([1.0], initialState, dims = 1)
    cb = ContinuousCallback(condition, affect!)

    # solve time evolution of states
    # OBS: there is a maximal number of division
    while tmpRls < rlsThreashold

        # solve until next event (defined by Callback function)
        model = ODEProblem(damageAccumulationModel!, state,
                           (0.0, maxTime - currentTime), parameters)
        cellCycle = solve(model, Tsit5(), reltol = solverError, callback = cb)

        # process and save output
        tmpTimes = (currentTime .+ cellCycle.t)
        currentTime = tmpTimes[end]
        cellSize = cellCycle[2, :] .+ Q .* cellCycle[3, :]
        nData = length(tmpTimes)
        data[l:(l + nData - 1), :] = [tmpTimes cellCycle[2:end, :]']
        l += nData

        # update state
        state[2:end] = cellCycle[2:end, end]

        # find out if cell divides or dies
        idx = findmax(cellCycle[end][2:end])[2] + 1
        type = idx % nEquations

        # stop if death or time out
        (type == 1 || currentTime >= maxTime) && break

        # update
        tmpRls += 1
        tmpGenerationTimes[tmpRls] = tmpTimes[end] - tmpTimes[1]
        tmpGrowth[tmpRls, :] = [cellSize[end] / cellSize[1],
                                cellSize[end] / initialSize]
        tmpDivisionIdxs[tmpRls] = l - 1

        # let cell divide and reinitialize
        division!(state, parameters, 1)

    end

    # if the division happens in the very last timestep, also
    # include the new state after division
    if tmpDivisionIdxs[end] == l - 1
        data[l, :] = state
        data[l, 1] = currentTime
        l += 1
    end

    # output
    lifespan = collect(1 : tmpRls)
    Cell(0, 0, 0, 0, parameters, data[1:(l - 1), :],
         tmpGenerationTimes[lifespan], tmpGrowth[lifespan, :],
         tmpDivisionIdxs[lifespan], tmpRls, 0.0)

end



################################################################################
# define how parameters are constructed for a new cell
################################################################################
function inheritance(constants, fixedEffects, randomEffects)

    newParameters = zeros(Float64, nParameters)

    # set constant parameters
    newParameters[constantParametersIdxs] = constants

    # set variable parameters with NLME
    # if it has not been possible after a certain number of times
    # accept the parameters that are not in the ageing region
    count = 1
    ageing = false
    while !ageing && count < nTrials
        for i = 1:length(variableParametersIdxs)
            j = variableParametersIdxs[i]
            newParameters[j] = fixedEffects[i] * exp(randn() * randomEffects[i])
        end
        ageing = isAgeing(newParameters)
        count += 1
    end

    newParameters

end



################################################################################
# initialize an empty population
################################################################################
function initializeEmptyPopulation(id, constantParameters,
                                   variableParametersFixedEffect,
                                   variableParametersRandomEffect)

    size = 0
    time = 0.0
    aliveCells = Array{Cell,1}(undef, 0);
    aliveCellIdxs = falses(maxCellNumber);
    deadCells = Array{Cell,1}(undef, 0);
    state = zeros(Float64, 1 + nEquations * maxCellNumber)
    parameters = zeros(Float64, nParameters, maxCellNumber)
    indices = zeros(Int, 3, maxCellNumber)
    statistics = zeros(Float64, 7, nStatistics)

    Population(id, constantParameters, variableParametersFixedEffect,
               variableParametersRandomEffect, size, aliveCells, aliveCellIdxs,
               deadCells, time, state, parameters, indices, statistics)

end



################################################################################
# set intial value for food
################################################################################
function setResources!(population, value)

    population.state[1] = value

    nothing
end



################################################################################
# add a cell to a population
################################################################################
function addCell!(population, initialState, parameters = [])

    # if parameters are not given they are taken from the population
    if parameters == []
        newParameters = inheritance(population.constantParameters,
                                    population.variableParametersFixedEffect,
                                    population.variableParametersRandomEffect)
    else
        newParameters = parameters
    end

    # increase the population size
    population.size += 1
    s = population.size

    # add state and parameters to the running parameters
    population.aliveCellIdxs[s] = true
    population.state[idxChange(s)] = initialState
    population.parameters[:, s] = newParameters
    population.indices[:, s] = zeros(Int, 3)

end



################################################################################
# let coupled population evolve in time
################################################################################
function evolvePopulation!(population, endTime)

    # initialization and predeclaration of some variables
    currentTime = population.time
    l = 1
    nData = maxDataPoints
    timePoints = zeros(Float64, maxDataPoints)
    data = zeros(Float64, maxDataPoints, nEquations * maxCellNumber + 1)
    tmpGenerationTimes = zeros(Float64, rlsThreashold, maxCellNumber)
    tmpSizeStart = zeros(Float64, rlsThreashold, maxCellNumber)
    tmpSizeEnd = zeros(Float64, rlsThreashold, maxCellNumber)
    tmpDivisionIdxs = zeros(Int, rlsThreashold + 1, maxCellNumber)
    tmpRls = zeros(Int, maxCellNumber)

    # reference the population properties
    activeCells = population.aliveCellIdxs
    state = population.state
    parameters = population.parameters
    indices = population.indices

    # get two new vectors that define the active entries in the state vector
    # plus the corresponding cell id
    activeStates = pushfirst!(repeat(activeCells, 1, nEquations)'[:], true)
    cellIds = pushfirst!(repeat(1:maxCellNumber, 1, nEquations)'[:], 0)

    # define the stopping criterium for the ODE solver
    cb = ContinuousCallback(condition, affect!)

    # solve time evolution of states until time is over
    while true

        # if population got extinct stop
        if length(state[activeStates]) == 1
            println("Population got extinct.")
            break
        end

        # solve until next event (defined by Callback function)
        model = ODEProblem(damageAccumulationModel!, state[activeStates],
                            (0, endTime - currentTime),
                            parameters[:, activeCells])
        solution = solve(model, Tsit5(), reltol = solverError, callback = cb)

        # process data from ODE solver
        # and update important variables
        tmpTimes = (currentTime .+ solution.t)
        currentTime = tmpTimes[end]
        nData = length(tmpTimes)
        timePoints[l:(l + nData - 1)] = tmpTimes
        data[l:(l + nData - 1), activeStates] = copy(solution')
        l += nData
        state[activeStates] = solution[:, end]

        # only add or remove cells before the end time
        (currentTime >= endTime) && break

        # find out if cell divides or dies
        idx = findmax(solution[end][2:end])[2] + 1
        id = cellIds[activeStates][idx]
        idxState = idxChange(id)
        type = idx % nEquations

        # death
        if type == 1

            # get right positions of the cell's life in the data
            birthIdx = tmpDivisionIdxs[1, id] + 1
            deathIdx = l - 1
            lifespan = collect(1:tmpRls[id])

            # calculate growth curves for cell that dies
            relGrowthCycle = tmpSizeEnd[lifespan, id] ./
                             tmpSizeStart[lifespan, id]
            growthTotal = tmpSizeEnd[lifespan, id] ./
                          tmpSizeStart[1, id]
            cellGrowth = [relGrowthCycle growthTotal]

            # add cell to the deadCells array
            push!(population.deadCells,
                  Cell(id, indices[1, id],
                       indices[2, id], indices[3, id],
                       parameters[:, id],
                       [timePoints[birthIdx:deathIdx] data[birthIdx:deathIdx,
                            idxState]],
                       tmpGenerationTimes[lifespan, id],
                       cellGrowth,
                       tmpDivisionIdxs[lifespan .+ 1, id] .- (birthIdx - 1),
                       tmpRls[id], 0.0))

            # update state: set cell to inactive
            activeStates[idxState] = falses(nEquations)
            activeCells[id] = false


        # divison
        elseif type == 0

            # update rls, generation time and the index at division
            tmpRls[id] += 1
            rls = tmpRls[id]
            tmpGenerationTimes[rls, id] = tmpTimes[end] - tmpTimes[1]
            dataAtStart = data[tmpDivisionIdxs[rls, id] + 1, idxState]
            dataAtEnd = state[idxState]
            tmpSizeStart[rls, id] = dataAtStart[1] + Q * dataAtStart[2]
            tmpSizeEnd[rls, id] = dataAtEnd[1] + Q * dataAtEnd[2]
            tmpDivisionIdxs[rls + 1, id] = l - 1

            # let cell divide
            stateDaughter = division!(state, parameters, id)
            
            # create a new daughter cell and set it to active
            addCell!(population, stateDaughter)
            activeStates[idxChange(population.size)] = trues(nEquations)
            tmpDivisionIdxs[1, population.size] = l - 1

            # set the indices for the new cell depending on its mother
            indices[:, population.size] = [id, indices[2, id] + 1, rls]

        end
    end

    # clear aliveCells array and add current still alive cells
    empty!(population.aliveCells)
    for i = 1:population.size
        if activeCells[i]

            # get right positions of the life in the data
            birthIdx = tmpDivisionIdxs[1, i] + 1
            lifespan = collect(1:tmpRls[i])

            # add cell to the aliveCells array
            relGrowthCycle = tmpSizeEnd[lifespan, i] ./
                             tmpSizeStart[lifespan, i]
            growthTotal = tmpSizeEnd[lifespan, i] /
                          tmpSizeStart[1, i]
            cellGrowth = [relGrowthCycle growthTotal]

            push!(population.aliveCells,
                  Cell(i, indices[1, i],
                       indices[2, i], indices[3, i],
                       parameters[:, i],
                       [timePoints[birthIdx:(l - 1)] data[birthIdx:(l - 1),
                            idxChange(i)]],
                       tmpGenerationTimes[lifespan, i],
                       cellGrowth,
                       tmpDivisionIdxs[lifespan .+ 1, i] .- (birthIdx - 1),
                       tmpRls[i], 0.0))
        end
    end

    # println("Population consists of ", population.size, " cells and ",
    #         l - 1, " data points were needed.")
    # println(length(population.aliveCells), " of them are alive and ",
    #         length(population.deadCells), " dead cells.")

    nothing

end



################################################################################
# let uncoupled population evolve in time
# -> single cells can be solved individually
################################################################################
function evolveUncoupledPopulation!(population, maxGeneration, endTime)

    # initialization and predeclaration of some variables
    birthTimes = zeros(Float64, maxCellNumber)
    state = population.state
    parameters = population.parameters
    indices = population.indices
    size = population.size
    id = 1
    sumRls = 0

    # go through all cells in the population
    # OBS: size is growing as more and more daughter cells are added
    while id <= size

        # ignore generations that are higher than maxGeneration
        if indices[2, id] <= maxGeneration

            # get the right indices for the cell in the state variable
            idxs = idxChange(id)

            # calculate the life
            tmpCell = singleCell(state[idxs], parameters[:, id], birthTimes[id],
                                 endTime)

            # adapt the indices to the current cell
            tmpCell.id = id
            tmpCell.motherId = indices[1, id]
            tmpCell.generation = indices[2, id]
            tmpCell.daughter = indices[3, id]

            # add daughter cells for all cells with lower generation
            # than the maximal
            if indices[2,id] < maxGeneration
                for d = 1:tmpCell.rls
                    divIdx = tmpCell.divisionIdxs[d]
                    newState = tmpCell.life[divIdx, 2:end] -
                               tmpCell.life[(divIdx + 1), 2:end]
                    addCell!(population, newState)
                    size += 1
                    birthTimes[size] = tmpCell.life[divIdx, 1]
                    indices[:, size] = [id, indices[2, id] + 1, d]
                end
            end

            # add difference to mother's rls as rejuvenation
            # but it has to be scaled in the end
            # OBS: the index of the mother is only right, considering that all
            #      cells die
            if tmpCell.motherId > 0
                motherRls = population.deadCells[tmpCell.motherId].rls
                tmpCell.rejuvenation = tmpCell.rls - motherRls
            end
            sumRls += tmpCell.rls

            # add cell to aliveCells/deadCells array
            if tmpCell.life[end, end] < 1.0 - solverError
                push!(population.aliveCells, tmpCell)
                println("Cell ", tmpCell.id, " is still alive.")
            else
                push!(population.deadCells, tmpCell)
            end

            # update time in population
            population.time = max(population.time, tmpCell.life[end, 1])

            # go to next cell
            id += 1
        end
    end

    # update rejuvenation indices
    # scale by the population average rls
    for cell in population.deadCells
        cell.rejuvenation *= population.size / sumRls
    end

    nothing

end



################################################################################
# get the indices
################################################################################
function idxChange(id)

    collect((1 + nEquations * (id - 1) + 1) : (1 + nEquations * id))

end



################################################################################
# analyse population data from an uncoupled population
# - calculate rejuvenation index for all cells
# - output contains sample mean, sample std and boxplot information for:
#   rls, rejuvenation, generation time, rel. growth per cell cycle,
#   rel. growth, absolute lifetime, health span (4 cases), initial state,
#   NLME parameters
################################################################################
function analyse!(population)

    # initialization and predeclaration of some variables
    cells = population.deadCells
    statistics = zeros(Float64, 7, nStatistics)
    nDeadCells = length(cells)
    data = zeros(Float64, nDeadCells, nStatistics)

    # go through all cells and collect important variables
    for i = 1 : nDeadCells
        cell = cells[i]

        # neglect the time for the first division
        # (usually much longer than the others)
        if cell.rls < 2
            meanGenTime = 0.0
            growth = [0.0, 0.0]
        else
            meanGenTime = mean(cell.generationTimes[2:end])
            growth = [mean(cell.growth[2:end, 1]) cell.growth[end, 2]]
        end
        
        # get health span
        tauIdx = findfirst(x -> x >= damageThreshold, cell.life[:, 3])
        tau = (cell.life[tauIdx, 1] - cell.life[1, 1]) /
              (cell.life[end, 1] - cell.life[1, 1])
        eta = length(findall(x -> x <= tauIdx, cell.divisionIdxs)) / cell.rls
        if isnan(eta)
            eta = 0
        end

        # save in data matrix
        data[i, 1:6] = [cell.rls, cell.rejuvenation, meanGenTime, growth[1],
                        growth[2], cell.life[end, 1] - cell.life[1, 1]]
        data[i, 7] = tau * eta
        data[i, 8] = 0.1 * tau + 0.9 * eta
        data[i, 9] = 0.5 * tau + 0.5 * eta
        data[i, 10] = 0.9 * tau + 0.1 * eta
        data[i, 11:(11 + nEquations - 1)] = cell.life[1, 2:end]
        data[i, (11 + nEquations):end] = cell.parameters[variableParametersIdxs]

    end

    # calculate summary statistics for all cells for each variable
    for i = 1 : nStatistics
        s = summarystats(data[:, i])
        sdev = std(data[:, i], mean = s.mean)
        statistics[:, i] = [s.mean, sdev, s.min, s.q25, s.median, s.q75, s.max]
    end
    population.statistics = statistics

    nothing
end



################################################################################
# average initial cell
################################################################################
function averageInitialCell(constantParameters, variableParametersFixedEffect,
                            variableParametersRandomEffect, maxGeneration,
                            born = -1)

    # initialization and predeclaration of some variables
    change = ones(Float64, nEquations)
    maxDeviations = ones(Float64, nEquations) .* initialsError

    state =  [1.0 - constantParameters[end], 0.0]
    oldState = [1.0 - constantParameters[end], 0.0]

    while change > maxDeviations

        # create population
        tmpPop = initializeEmptyPopulation(1, constantParameters,
                                           variableParametersFixedEffect,
                                           variableParametersRandomEffect)
        setResources!(tmpPop, 1.0)

        # add a starting Cell
        addCell!(tmpPop, state)

        # evolve for a few generations
        evolveUncoupledPopulation!(tmpPop, maxGeneration, maxTime)

        # set the new initial state for the beginning cell to the average
        # initial conditions in the population
        # if born == 0 then the initial condition of the whole population
        # is considered,
        # otherwise of the x th child where x is the value of born
        oldState = state
        state = zeros(Float64, nEquations)
        n = 0
        for k = 1 : length(tmpPop.deadCells)
            if born == -1
                state += tmpPop.deadCells[k].life[1,2:end]
                n += 1
            else
                if tmpPop.deadCells[k].daughter == born
                    state += tmpPop.deadCells[k].life[1,2:end]
                    n += 1
                end
            end
        end
        state /= n

        change = abs.(state - oldState)

    end

    state

end
