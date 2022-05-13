# Levodopa Model
Final project for Systems Pharmacology and Personalized Medicine Spring 2022

Procedure for running the files:
1. Code for model analysis including dosing regimen and parameters sensitivity analysis can be found in the folder "src"
    a. Inside the folder, you will find several .mat files as the results to our simulations.
2. The file "westin_etal_eqns_levodopa.m" contains a system of ODEs representing the PK portion of our model. As a side note, our PD measures effect level using the concentration of levodopa in the effect compartment. So, PD equation is included in the driver file instead.
3. Run "levodopa_driver.m" to run general simulations on our system. You can vary dosing regimen to a single bolus + double maintance dose etc to see how does varying these regimen will effect concentration of levodopa in each compartment. We have exported some datasets we used in the report and they are labeled as "pkpd_SpecificDosingRegimen.mat".
4. Run "levodopa_sensitivity_analysis.m" for sensitivity analysis.

5. Navigate to the "Population Variability" folder to run code files for PopPK and PopPD analysis
    a. Run "population_variability.m" to get PopPK and PopPD results.
    b. "Assignment4Starter2022.m", "levodopa.m", and "westin_etal_eqns_levodopa.m" serves as function files
    
6. Navigate to the "miss_dose" folder to run code files for miss dose analysis
    a. Run "miss_dose_driver.m" for the miss dose simulation.
    b. User can manually change the variable sim_num to run different simulations.
    
7. Navigate to the "Interactive Visualization" folder
    a. Each subfolder contains an app to visualize results to the simulation notes by subfolder name
    b. Run the "app.R" in each subfolder to access R code and local interactive visualization. 
