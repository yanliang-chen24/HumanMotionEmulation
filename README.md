This repository contains the MATLAB implementation and data for the paper:


Chen, Y, Srivastava, A., and Park, C., Statistical Emulations of Human Operational Motions in Industrial Environments


 ## **Prerequisites** 


1.MATLAB

-  Tested on version R2024a 
-  Required Toolboxes: Deep Learning, Statistics and Machine Learning, Econometrics, Communication              

2.This project uses the MATLAB\-to\-Python interface for the baseline method implementation.

-  Python Version: 3.9  
-  Required Packages: 'numpy: 1.24.3' , 'torch: 2.7.0', 'gpflow: 2.9.0', 'tensorflow: 2.13.0' 

External Dependencies:


The following packages and functions must be downloaded and added to the MATLAB path. They are required by the internal script *`PCA_Result_Figure6_7_10.m`* called during the execution of the **Master Script 3**, *`generate_figures.m`*

1.  tensor\_toolbox\-v3.6: [Tensor Toolbox Version 3.6 (R2023b) 28\-Sep\-2023 · tensors / tensor\_toolbox · GitLab](https://gitlab.com/tensors/tensor_toolbox/-/releases/v3.6)
2. MPCA function: [Multilinear Principal Component Analysis (MPCA) \- File Exchange \- MATLAB Central](https://www.mathworks.com/matlabcentral/fileexchange/26168-multilinear-principal-component-analysis-mpca)


## **Project Structure:**

-  *`run_all_simulations.m`* - **Master Script 1** : Contains the full simulation pipeline that processes the inputs from `01_data/` and exports the raw outputs into `06_results/`.
    - Note: This script handles the heavy computation only; it does not generate individual tables or figures directly.  
-  *`generate_all_results.m`* - **Master Script 2**: Aggregates data and generates all evaluation tables.
    -  Main Manuscript: Table 2, 3, 4, 5, 6, and 7.
    -  Supplementary Material: Table S1 to S12.
-  *`generate_figures.m`* - **Master Script 3**: Aggregates data and generates figures and tables.
    -  Tables: Table 1.
    -  Figures & Panels: 1c, 2, 5d-e, 6-11, 12b-c, 13.
    -  Note 1: Main manuscript Figure 6a and 6c are identical to Supplementary Figure S3a and S3b.
    -  Note 2: Remaining panels for Figures 1, 5, and 12 are conceptual diagrams and generated using external tools (e.g., Microsoft PowerPoint).
-  *`generate_two_level_simulation_results.m`* - **Master Script 4**: Aggregates results for table 7.
-  *`01_data/`* - Contains preprocessed raw data used as simulation input. 
-  *`02_functions/`* - Core utility and processing functions. 
-  *`03_metrics/`* - Evaluation metrics and pre-computed model (e.g., clustering results and kernel density). 
-  *`04_simulation_scripts/`* - Individual simulation execution scripts for different datasets.
-  *`05_figure_scripts/`* - Individual execution scripts to generate figures and tables.
-  *`06_results/`* - [Empty]Output directory for `.mat` files and generated figures.
    - `/WorkerData/`: Subfolder for `.mat` files of the Worker dataset results.
    - `/exerciseData/`: Subfolder for `.mat` files of the Exercise dataset results.
    - `/TwoLevelSimulation/`: Subfolder for `.mat` files of the two level simulation results.
    - `/figures/`: Subfolder for exported `.pdf` visualizations.
-  *`07_baselinemethod/`* - Implementations and wrappers for comparison methods. 
-  *`08_supplementary/`* - Scripts for figures and tables in the Supplementary Information.
    -  *`PCA_Details_Figure_S1_S2.m`* to generate Figure S1 to S2 in the Supplementary Material
    -  *`Intermediate_Steps_Figure_S4_S5.m`* to generate Figure S4 and S5 in the Supplementary Material
    -  *`Sensitivity_Analysis_Result_Table_S13.m`* to generate Table S13 in the Supplementary Material

-  *`CreateVideos.m`* - Additional tool for creating videos from the skeleton data. 

## **Data Summary**
The provided data consists of pre-processed skeleton sequences stored in *`.mat`* files. All data is preprocessed, including normalization and temporal registration, as described in Sec. 3.
-  Worker Motion:
    -    5 Motion class stored in a standalone *`.mat`* file with filename *`RWP_[ClassID]_Outcome_300.mat`*. For example, *'RWP_1_Outcome_300.mat`* is the first motion class.
    -    In each *`.mat`* file, *`aligned`* is the preprocessed posture data and *`tree`* is the hierarchy tree of the landmarks
-  Exercise Motion:
    -    1 Motion class stored in a *`.mat`* file with filename *`MotionNew_Outcome_800.mat`*
    -    In each *`.mat`* file, *`X`* is the preprocessed posture data and *`tree`* is the hierarchy tree of the landmarks

## **Setup**

Clone the repository and add all subfolders to your MATLAB path: *`addpath(genpath(pwd));`*

## **Reproducing Results**

To maintain a lightweight repository, this package contains the **Raw Data** and **Initialization Seeds** only. 
The intermediate results and processed output variables are **not included** due to their significant file size (>2GB). 
To reproduce the results presented in the paper, the full simulation pipeline must be executed locally using the following steps.

### Step 1: Execute the Core Simulation Pipeline
-  Run *`run_all_simulations.m.`*
-  Generate the raw simulation outputs, including baseline methods, and save them as `.mat` files into the subfolder `06_results/`.
### Step 2: Generate the Figures and Tables in the Main Manuscript
-  Run *`generate_all_results.m`* to generate Table 2-6 in the main manuscript and Table S1 to S12 in Supplementary Material.
-  Run *`generate_figures.m`* to generate Table 1, Figure 1c, 2, 5d-e, 6 (panels a/c are identical to Supplementary Material Figure S3a/b), 7-11, 12b-c, 13 in the main manuscript
    -  Note: The figures are saved in subfolder `06_results/figures/`.
-  Run *`generate_two_level_simulation_results.m`* to generate Table 7 in the main manuscript
### Step 3: Generate the Results in the Supplementary Material
- Run *`PCA_Details_Figure_S1_S2.m`* to generate Figure S1 to S2 in the Supplementary Material
- Run *`Intermediate_Steps_Figure_S4_S5.m`* to generate Figure S4 and S5 in the Supplementary Material
- Run *`Sensitivity_Analysis_Result_Table_S13.m`* to generate Table S13 in the Supplementary Material

## **Estimated Runtime**

-  The simulation of each dataset is expected to take upwards of 8–12 hours.
-  Running the full pipeline consecutively may require 24 hours of uninterrupted computation.

**Academic Credit & Collaborations**

-  The clustering method is based on the work by Deng et al. (2022) 
-  The geometry operations were re\-implemented by the author for this pipeline; the original logic remains the intellectual property of the original authors.
-  The visualization functions were modified by the author for this pipeline; the original logic remains the intellectual property of the original authors.
