# RejuvenationProject

population.jl (Julia file, https://julialang.org) is the main file that includes all functions needed to simulate populations.

The most important functions for simulating single-cells are:

**damageAccumulation**: defines the model
**division**: defines the distribution of proteins between mother and daughter
**retention**: defines the retention factor, potentially dynamically
**singleCell**: solves the single-cell model for given parameters and initial conditions ,

and for creating populations:

**initializeEmptyPopulation**: creates a population structure with population parameters
setResources: set the start value for the resources (currently the resources do not change over time, but a constant needs to be set in the beginning)
**addCell**: adds a cell with certain initial conditions to a population
**evolvePopulation**: solves the population model that grows in size with each cell division until a certain time point
**evolveUncoupledPopulation**: solves the population model and creates the lineage until a certain generation
**analyse**: produces statistics of cell properties in populations that were created by the evolveUncoupledPopulation function


In all folders there are examples how to use the model. Plots are created with gnuplot (http://www.gnuplot.info).

**CompareDynamics** shows how to generate single-cell dynamics with manually set parameters
**WtSurface** shows how to find parameters for cells with a specific replicative lifespan
**RetentionPopulation** shows how to find parameters and generate populations for different retention factors and analyse the population-based behaviour 
**WtPopulations** shows how to generate cell lineages up to a few generations with focus on all individual cells, and how to use the data for analysis and plotting
**GrowthRate** shows an example of solving the dynamically growing system until a certain time point

