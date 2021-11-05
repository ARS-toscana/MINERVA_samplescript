# MINERVA: script to calculate simple quantitative metadata from multiple Common Data Models

In the MINERVA Proof-Of-Concept Catalogue we planned to develop and test a script that could retrieve quantitative metadata from any of four supported common data models (CDMs). As a proof of concept, the case of annual age and gender distribution of the underlying population of a data source was chosen.

## Validation

In the script stored in this repository, the following steps are enacted

1. In [the folder i_ETL_mock_data](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_ETL_mock_data) a data set of mock population data is loaded and converted to four Common Data Models; the output of each conversion is saved to the corresponding folder: [ConcePTION](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_ConcePTION), [OMOP](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_OMOP), [Nordic](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_Nordic), [TheShinISS](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_TheShinISS)
2. In the main page, the script [to_run.R](https://github.com/ARS-toscana/MINERVA_samplescript/blob/main/to_run.R) executes the creation of study variables for the 4 CDMs, checks that they are all equal, and the executes the analysis. The output is stored in the folder [g_output](https://github.com/ARS-toscana/MINERVA_samplescript/blob/main/g_output/) in three files named RES_ageband.csv, RES_gender.csv, RES_ageband_by_gender.csv.

To prove that the script can run on the four supported CDMs and produce the same results, run the script to_run.R, as it is provided in the repository. 

## Use of the script to generate annual age and gender distribution from your data source

The script of the main page is what can be used to compute age and gender distribution of a data source converted to one of the four CDMs.

In order to use such script, please follows the next steps:

1) Download the script in a computer where your data source converted to a CDM is stored
2) In the file to_run.R, set the parameter 'CDMs' to the value of the CDM your data is converted to
4) Save your data in the corresponding input folder
5) In the file to_run.R, set the parameter 'years' to the list of years documented in your data
6) In the file to_run.R, set the parameter 'years' to the list of years documented in your data
7) Run the script to_run.R, set the parameters Agebands and the corresponding Labels
8) At the end of the script, the annual distribution of age and gender is saved in csv in the folder g_output in three files named RES_ageband.csv, RES_gender.csv, RES_ageband_by_gender.csv.
