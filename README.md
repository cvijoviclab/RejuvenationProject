# RejuvenationProject

## Publication
These files and simulations are the basis for "The Synergy of Damage Repair and Retention Promotes Rejuvenation and Prolongs Healthy Lifespans in Cell Lineages", Schnitzer et al., 2020 (https://doi.org/10.1101/2020.03.24.005116). 

## Model
population.jl (Julia file, https://julialang.org) is the main file that includes all functions needed to simulate populations.

The most important functions for simulating single-cells are:

> **damageAccumulation** defines the model.<br/>
> **division** defines the distribution of proteins between mother and daughter.<br/>
> **retention** defines the retention factor, potentially dynamically.<br/>
> **singleCell** solves the single-cell model for given parameters and initial conditions.

The most important functions for creating populations are:

> **initializeEmptyPopulation** creates a population structure with population parameters.<br/>
> **setResources** sets the start value for the resources (currently the resources do not change over time, but a constant should be set in the beginning).<br/>
> **addCell** adds a cell with certain initial conditions to a population.<br/>
> **evolvePopulation** solves the population model that grows in size with each cell division until a certain time point.<br/>
> **evolveUncoupledPopulation** solves the population model and creates the lineage until a certain generation.<br/>
> **analyse** produces statistics of cell properties in populations that were created by the evolveUncoupledPopulation function.

## Examples
In all folders there are examples how to use the model. Plots are created with gnuplot (http://www.gnuplot.info).

> **CompareDynamics** shows how to generate single-cell dynamics with manually set parameters (compareDynamics.jl).<br/>
> **WtSurface** shows how to find parameters for cells with a specific replicative lifespan.<br/>
> **RetentionPopulation** shows how to find parameters and generate populations for different retention factors and analyse the population-based behaviour. <br/>
> **WtPopulations** shows how to generate cell lineages up to a few generations with focus on all individual cells, and how to use the data for analysis and plotting.<br/>
> **GrowthRate** shows an example of solving the dynamically growing system until a certain time point.

## Data of Publication Figures
The folder **Data** includes the data underlying the figures in the publication.

