# ![Microgrids.m](https://github.com/Microgrids-X/Microgrids-artwork/raw/main/svg/Microgrids-m.svg)

The Microgrids.m package allows simulating the energetic operation of an isolated microgrid,
returning economic and operation indicators.

Repository structure:
- [engine](engine) folder: all the application-independant code
- [application](application) folder: one Microgrid project example, to be adapted by the user to its own application case

Running the example scripts in the `application` folder (or any other) requires having the `engine` folder in the [Matlab search path](https://www.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html). For convenience, this is done a the beginning of each `main_*.m` script by calling `addpath`, but this can be removed once/if it's already done.


## Description of Microgrids.m

<img alt="Microgrid sizing illustration" src="https://github.com/Microgrids-X/Microgrids-artwork/raw/main/svg/microgrid_sizing.svg" width="250px">

`Microgrids.m` can model a microgrid project consisting of:
- One load (described by a time series)
- One dispatchable generator (e.g. Diesel or hydrogen-powered)
- One energy storage (battery)
- One non-dispatchable solar source also modeled from a time series (wind not yet supported)

The energy dispatch at each instant of the simulated operation is a simple
“load following” rule-based control.
The load is power in priority from the dispatchable sources,
then the battery, and only using the dispatchable generator as a last recourse.

`Microgrids.m` is part of the [Microgrids.X](https://github.com/Microgrids-X/) project
which provides sibling packages in other languages (e.g. in Python)
to better serve the need of different users.

Compared to Python and Julia packages, the Matlab version `Microgrids.m` is a bit behind.
For example, it cannot (yet) simulate multiple non-dispatchable sources (e.g wind AND solar power).

## Documentation

See the [application](application) folder for an example which walks through:
1. the data structure to describe a Microgrid project: `define_mg.m` function
2. simulate the micgrid and display the results: `main_sim.m` script which calls `sim_mg` function
3. optimize the sizing: `main_optim.m` script (and variants `main_optim_*.m`)


## Matlab/Octave compatibility

The code is meant to run both on Matlab and Octave, under Windows and Linux.

The bash script [Matlab_code_check.sh](Matlab_code_check.sh) can search for some incompatible code patterns.

### Warning on performance difference

For *simulating* a Microgrid project, either Matlab or Octave can be be used. However, for *optimization*, which requires evaluating many sizings, Matlab is preferable because Octave is about 400× slower to run the simulator. This translates in the same relative difference for optimization, but amplified by the number of iterations. Simply said, a sizing optimization using 1000 iterations should take:
- about 0.5 s with Matlab → allows quick trial and error, iterative changes...
- about 200 s with Octave → can only be run a few times a day

People who want high performance and an open source toolchain should look at the Julia sibling package [Microgrids.jl](https://github.com/Microgrids-X/Microgrids.jl)).

### Matlab specific code

Writing cost factors in an Excel table with `xlswrite` requires Matlab.

Also, the multiobjective sizing optimizations currently require Matlab (muliobjective optimization algorithm to be found for Octave).


## Acknowledgements

The development of Microgrids.jl (sibling package in Julia) was first led by
Evelise de Godoy Antunes. She was financed in part by
the Coordenação de Aperfeiçoamento de Pessoal de Nı́vel Superior - Brasil (CAPES) – Finance Code 001,
by Conselho Nacional de Desenvolvimento Cientı́fico e Tecnológico - Brasil (CNPq)
and by the grant “Accélérer le dimensionnement des systèmes énergétiques avec
la différentiation automatique” from [GdR SEEDS (CNRS, France)](https://seeds.cnrs.fr/).
