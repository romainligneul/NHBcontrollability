# NHBcontrollability

This repository contains the code used to generate the main figure of the paper Stress-sensitive inference of task controllability by Romain Ligneul, Zachary Mainen, Verena Ly* and Roshan Cools*.
In order to run the scripts contained in the StatsFigures folder, you need to clone/download the repository and download the anonymized data by logging with your ORCID at the following address: https://data.donders.ru.nl/collections/di/dccn/DSC_3017049.01_905
The data folder must be placed into the same folder as this repository and named AnonymizedData.

Note that the AnalysisFunctions folders contains also the code used for computational modeling which is not necessary to generate the figures. The code used to analyze the fMRI data (from preprocessing to second-level analyses) is provided as is. In order to run it, it is necessary to download the anonymized data. Please get in touch if you are interested.

The scripts rely on several external toolboxes which can be found in ExternalTools. The main ones are:
- the VBA toolbox (for VB model fitting): https://mbb-team.github.io/VBA-toolbox/
- the gramm toolbox (for plotting): https://github.com/piermorel/gramm
- the MI toolbox (for information theoretic computations): https://github.com/Craigacp/MIToolbox
