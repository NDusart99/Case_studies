REANALYSING EEG DATA OF ALZHEIMER AND FRONTAL TEMPORAL DEMENTIA PATIENTS 

This repository contains the scripts for the reanalysis of resting state EEF data of 
Miltiadous et al. (2023), 'A dataset of EEG recordings from: Alzheimer's disease, Frontotemporal 
dementia and Healthy subjects', carried out for the course 'Case Studies of Experimental 
Psychology' of Ghent University. In this project, the mean alpha wave power was extracted and 
compared between participants with Alzheimer's disease (AD), Frontotemporal dementia (FTD) and 
healthy controls (CON) for five predetermined ROI's. 

The preprocessed data is available in the folder 'original_data', or can be downloaded here from
OpenNeuro, in the folder 'derivatives': https://openneuro.org/datasets/ds004504/versions/1.0.5


This repositry contains: 

-Code_For_CAED_Project(2).m: The Matlab script for the extraction of the mean alpha wave power 
per channel, with the use of EEGLab. The EEGLab toolbox can be downloaded here: 
https://sccn.ucsd.edu/eeglab/index.php
Files generated with this script can be found in the folder 'mean_psd_values'

-EEG-analysis_dementia_dataset.r: The R-script for the further statistical analyses of the data, including
calculating means per ROI, hypothesis testing and visualisation. 
The dataset with the mean values per ROI generated with this script can found in the file 'ROIs.csv'

-demographics_dementia_dataset.r: The R-script for the descriptive measures of the demographics
per group. 
The dataset with the demographics can be found in the folder 'demographics' or can be downloaded from
OpenNeuro: https://openneuro.org/datasets/ds004504/versions/1.0.5

Authors:
Louise De Meulenaer 
Inne De Backer 
Nathalie Dusart 
Zita Meijer 
