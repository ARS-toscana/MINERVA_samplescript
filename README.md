# MINERVA: script to calculate simple quantitative metadata from multiple Common Data Models

## Validation

In the MINERVA Proof-Of-Concept Catalogue we planned to develop and test a script that could retrieve quantitative metadata from any of four supported common data models (CDMs). As a proof of concept, the case of age and gender distribution of the underlying population of a data source was chosen.

In the script stored in this repository, the following steps are enacted

1. In [the folder i_ETL_mock_data](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_ETL_mock_data) a data set of mock population data is loaded and converted to four Common Data Models; the output of each conversion is saved to the corresponding folder: [ConcePTION](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_ConcePTION), [OMOP](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_OMOP), [Nordic](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_Nordic), [TheShinISS](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_TheShinISS)
2. In the main page, the script [to_run.R](https://github.com/ARS-toscana/MINERVA_samplescript/blob/main/to_run.R) executes the creation of study variables for the 4 CDMs, checks that they are all equal, and the executes the analysis. The output is stored in the folder [g_output](https://github.com/ARS-toscana/MINERVA_samplescript/blob/main/g_output/) in three files with names RES_ageband.csv, RES_gender.csv, RES_ageband_by_gender.csv.

## Use of the script

The latter script has a second purpose: it can nbe used to compute age and gender distribution of a data source converted to one of the four CDMs.

In order to use such script, the following instructions need to 
