# RejuvenationProject

## Publication
These files and simulations are the basis for "The Synergy of Damage Repair and Retention Promotes Rejuvenation and Prolongs Healthy Lifespans in Cell Lineages", Schnitzer et al., 2020 (https://doi.org/10.1101/2020.03.24.005116). 

## Model
population.jl (Julia file, https://julialang.org) is the main file that includes all functions needed to simulate populations.

The most important functions for simulating single-cells are:

> **damageAccumulation** defines the model.<br/><br/>
> **division** defines the distribution of proteins between mother and daughter.<br/><br/>
> **retention** defines the retention factor, potentially dynamically.<br/><br/>
> **singleCell** solves the single-cell model for given parameters and initial conditions.
  
The most important functions for creating populations are:

> **initializeEmptyPopulation** creates a population structure with population parameters.<br/><br/>
> **setResources** sets the start value for the resources (currently the resources do not change over time, but a constant should be set in the beginning).<br/><br/>
> **addCell** adds a cell with certain initial conditions to a population.<br/><br/>
> **evolvePopulation** solves the population model that grows in size with each cell division until a certain time point.<br/><br/>
> **evolveUncoupledPopulation** solves the population model and creates the lineage until a certain generation.<br/><br/>
> **analyse** produces statistics of cell properties in populations that were created by the evolveUncoupledPopulation function.

## Examples
In all folders there are examples how to use the model. Results are typically saved in txt files and visualised with gnuplot (gnu file, http://www.gnuplot.info).

> **CompareDynamics** shows how to generate single-cell dynamics with manually set parameters (compareDynamics.jl).<br/><br/>
> **WtSurface** shows how to find parameters for cells with a specific replicative lifespan (wtSurface.jl).<br/><br/>
> **RetentionPopulation** shows how to find parameters (findParamters.jl) and generate populations for different retention factors and analyse the population-based behaviour (comparePopulations.jl). <br/><br/>
> **WtPopulations** shows how to generate cell lineages up to a few generations given a parameter set with focus on all individual cells (populationAnalysis.jl), and how to use the data for analysis and plotting (generatePlotData.jl). It is divided into the four data sets corresponding to four parameter sets representing unlimited repair capacity (UnlimCap) vs decline in repair capacity (DecCap) both in combination with retention (HighRe) vs no retention (NoRe), as focus of the publication. <br/><br/>
> **GrowthRate** shows an example of solving the dynamically growing system until a certain time point (growthRate.jl). In this particular case the funciton uses a file that defines the distribution of the initial conditions of the population's founder cells, which could have also been defined manually. Again the four cases (UnlimCap, DecCap * HighRe, NoRe) are used.

## Data of Publication Figures
The folder **publicationData** includes the data underlying the figures in the publication in txt files as well as Julia functions that generate the data (note that there is stochasticity in the model, so that it is not possible to generate exactly the same data set used in the publication again, however the conclusions stay the same).

