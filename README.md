# MINERVA: script to calculate simple quantitative metadata from multiple Common Data Models

To develop and test a script that could retrieve quantitative metadata from any of four supported common data models (CDMs), the case of age and gender distribution of the underlying population of a data source was chosen.

In this script, the following steps are enacted

1. In (the folder i_ETL_mock_data)[https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_ETL_mock_data] a data set of mock population data is loaded and converted to four Common Data Models; the output of each conversion is saved to the corresponding folder: [ConcePTION](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_ConcePTION), [OMOP](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_OMOP), [Nordic](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_Nordic), [TheShinISS](https://github.com/ARS-toscana/MINERVA_samplescript/tree/main/i_input_TheShinISS)
2. In the main page, the script (T2.R)[https://github.com/ARS-toscana/MINERVA_samplescript/blob/main/T2.R] executes the creation of study variables; the script includes a parameter "CDM" that can be set to any of the four values "ConcePTION", "OMOP", "Nordic", "TheShinISS", and searches for input in the corresponding input folder; regarless of the parameter, the output is stored in the folder [g_output](https://github.com/ARS-toscana/MINERVA_samplescript/blob/main/g_output/) with name D3.csv
3. The script (T3.R)[https://github.com/ARS-toscana/MINERVA_samplescript/blob/main/T3.R] takes as input the D3.csv file and executes the analysis to produce the datasets of results in [g_output](https://github.com/ARS-toscana/MINERVA_samplescript/blob/main/g_output/), named RES_ageband.csv, RES_gender.csv, and RES_ageband_by_gender.csv

