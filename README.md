---
title: "ReadME file for Bor & Littvay: Putin's Performance Dilemma..."
author: Alexander Bor & Levente Littvay
date: 2016.08.17.
---


The data management and analysis for this paper were conducted with R version 3.3.0 (2016-05-03 -- "Supposedly Educational") and with Mplus version 7.4. 

__Required packages:__

Install these with dependencies first in order for the code to run properly. 

- *car* version 2.1-3
- *foreign* version 0.8-66
- *gdata* version 2.17.0
- *ggplot2* version 2.1.0
- *stargazer* version 5.2 

The documentation provided hereis stored in folders that are organized as illustrated below: 

- An electronic copy of the complete final paper: Bor_Littvay_Putins_Performance_dilemma.pdf 
- This `README.md` file for your repository
- Original Data and Metadata - `original-data-and-metadata`
    + Original Data - `original-data`
        * ESS5RU.sav
    + Metadata - `metadata`
        * Metadata Guide - `metadata_guide.md`
        * Supplements - `supplements`
            - ESS5_data_protocol.pdf
            - ESS5_main_and_supplementary_a_questionnaires_RU.pdf
            - ESS5_source_main_questionnaire_EN.pdf
- Processing and Analysis - `processing-and-analysis`
    + Importable Data - `importable-data`
        * ESS5RU.sav
    + Command Files - `command-files`
        * ess_mplus_2wayint.inp
        * ess_mplus_2wayint.out
        * ess_mplus_3wayint.inp
        * ess_mplus_3wayint.out
        * ess_mplus_model1.inp
        * ess_mplus_model1.out
        * ess_mplus_model2.inp
        * ess_mplus_model2.out
        * ess_mplus_model3.inp
        * ess_mplus_model3.out
        * ess5ru_analysis.R
        * ess5ru_importing.R
        * ess5ru_processing.R  
        * README.md  
    + Analysis Data - `analysis-data`
        * data_appendix.pdf
        * data_appendix.Rmd
        * datamplus.dat
        * datamplus.var
        * ESS5RU_clean.Rdata
        * ESS5RU_final.Rdata
        * ess5ru_from_mplus.txt
        * README.md


## To reproduce the tables, figures and statistical results reported in the text of the paper:

1. Copy the “Processing and Analysis” folder, and all of its contents, on to the hard disk of the computer you are working on.

1. Launch R and set the working directory to the “Command Files” folder in each time you see `setwd("<PATH TO 'Command files' DIRECTORY>”)`. 

1. Execute the *ess5ru_importing.R* file.  
This will load the data file and save it as *ESS5RU.Rdata* to the "Command Files" folder. 

2. Execute the *ess5ru_processing.R* command file.  
This subsets the relevant data and recodes some of the variables. It has two outputs. 
    - First the data is exported in formats compatible with Mplus to the files *datamplus.var* and *datamplus.dat*. Both of these are saved in the "Analysis Data" folder. 
    - Second in order to ensure that most of the analysis could be run without an Mplus licence, the Mplus data output is imported and exported as *ESS5RU_clean.Rdata*. This is also saved in the "Analysis Data" folder. 
    - Finally this command will erase *ESS5RU.Rdata* from the "Command files" folder. 

3. There are five pairs of Mplus files. 
Three models reported in the paper and two additional robustness checks (referenced in footnote 6.). The .inp files specify the models, the .out files contain results. 
    - *ess_mplus_model1.inp* is a model with no latent classes
    - *ess_mplus_model2.inp* is a model with two latent classes but no predictors
    - *ess_mplus_model3.inp* is a model with two latent classes and predictors. 
    - *ess_mplus_2wayint.inp* is a model checking robustness with all relevant two-way interactions specified and included in the model. 
    - *ess_mplus_3wayint.inp* is a model checking robustness with a three-way interaction, but it's results should be ignored because of data limitation issues. 
Model fit statistics for the 3 models are reported in Table 2. 

4. Execute the command file *ess5ru_analysis.R* 
This import the data including latent class information from the Mplus model and produces all statistical tables and models. 

5. Finally,  run *data_appendix.Rmd* which contains a brief explanation and descriptive statistics on all variables used in the data. 
