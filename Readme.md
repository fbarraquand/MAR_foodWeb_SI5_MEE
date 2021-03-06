
[![DOI](https://zenodo.org/badge/102585091.svg)](https://zenodo.org/badge/latestdoi/102585091)

###  MAR(1) models fitted to discrete-time Lotka-Volterra (Ricker) food web 
This repository contains code associated with **Supporting Information S2 - Lotka-Volterra food web dynamics with moderately complex structure** of Certain et al. MEE 2018 [How do MAR(1) models cope with hidden nonlinearities in ecological dynamics? Methods in Ecology and Evolution, by G. Certain, F. Barraquand and A. Gårdmark]. 

### Contents

* __Simulation of **k=100** food webs with the same topology__ and a randomly drawn set of interaction strengths and environmental effects values.  Output of simulations (simulated and expected interaction matrices, time series, ...) and expected effects of a PRESS perturbation are produced by `` LVR_foodWeb_simulation.R ``

* __MAR(1) model fitting__, both with 
  1. Unknown topology, i.e., no prior knowledge on the **B** and **C** matrices in ``MAR_modelFitting_loop.R``
  2. Known topology in `` MAR_modelFitting_loop_knownTopology.R``(similar to our 2x2 simulations in the main text)

* __Evaluation of MAR model (x<sub>t+1</sub> = B x<sub>t</sub> + C u<sub>t</sub> + e<sub>t</sub>) performance__
  1. Recovery of **B** elements (net intersp. interaction strength and intrasp. regulation) in ``MAR_BvsJ.R`` or ``MAR_BvsJ_knownTopo.R``
  2. Recovery of **C** environmental effects in ``MAR_CvsQ_knownTopo.R``
  3. Quality of PRESS predictions ``MAR_PRESS_knownTopo.R``

[Note the code would also allow, with small modifications, to check the quality of short-term forecasts]

### Architecture 

The codes and data files are separated in two main folders

* ``LVR_foodWeb_partiallyTunedParameters`` uses the Lotka-Volterra-Ricker model for simulation, with parameters tuned to produce realistic-looking species abundance distribution and patterns of interaction strengths. 

* ``Gompertz_foodWeb`` uses as a basis a Gompertz model whose interaction matrix is the Jacobian of the abovementioned LVR model, for the same parameter values. It is intended to provide a benchmark for the MAR(1) model fit. 

Within each folder, one finds subfolders for 
  1. Simulation (e.g., ``LVR_simulation``)
  2. Estimation (``MAR_estimation``)
  3. Evaluation (``MAR_evaluation``, plots of results and summary tables of model performance) 
  
The suffix ``_800`` refers to the final results with 800 timesteps reported in SI2 of Certain et al, that provide reasonable estimates. Other folders use *t<sub>max</sub>=100* for model fitting, as in the main text, which is insufficient for 12-species food web considered here. 




