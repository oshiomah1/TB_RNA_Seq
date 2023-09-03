Case Decision Tree: Assigns casers from NCR_redcap database ONLY

Criteria: Adult patient, TB symptoms, less than 15 days of starting medication, less than 1 month between TB diagnmosis date and lasb receive date, HIV negative, patient can have flu or previous episodes of TRB

Variables used: 
Key: Revised_name = Redcap Variable name
current_other_inf ="Do.you.currently.have.an.infection.such.as.a.cold.or.the.flu.....not.TB.",
tb_status = "Do.you.currently.have.TB........", 
lab_receive_date = "Date.PBMC.received.in.the.Lab", 
HIV_status="What.is.your.HIV.status." ,
treatment_srt_date =  "TB.treatment.start.date." , 
TB_Diag_Date ="Date.of.TB.diagnosis."


Control Decision Tree: This is a bit meatier than the control decision tree. It combs through NCR databse for contemporary info and NCTB for lifetime medical records
Criteria: Adult patient, no TB symptoms, HIV negative, CANNOT have had a previous case of TB in their lifetime 

Variables used:
Key: Revised_name = Redcap Variable name

medical_validator : Preliminary assignment as case, control or unknown using the clinical variables tb_test_rest, tb_nonsmear and treat_or_drug.
tb_test_result = insert redcap definition*
tb_nonsmear = composite variable that pre assigns case, control or unknown. It is created from the file nonsmearkey.csv. This file was created originally in 2021 manually with Justin, Brenna & Oshi. *insert more background*
treat_or_drug + composite variable that assigns: yes, no, unknwn, based on if patient has received TB medication, antibiotic resistance etc. It uses the following  NCTB variables:
frst_pst_tb_test_date =    
      treat_reg_selec =  
      cmpltd_trtmnt  =
      drug_taken__1 ...15 =

self_report_validator: Preliminary assignment as case, control or unknown using the following self report_variables:
prior_tb_self_reported, prior_tb_n_self_reported, frst_pst_tb_test_date

validated_study_for_merge: Combines The pre-assignments of medical_validator and self_report_validator to assign patients as case, control or unknown. This now accounts for situations where patients only have self report or only have medical data.


Updated merge: 

The final control assignemnts are done in updated_merge.r. First the NCR and NCTB datasets are combined using saliva barcode, names and manual matches. Then controls are stratified into their flu status. Flu status isn't a criteria for assigning cases (but recorded nonthele3ss). In the final output table, FINAL_STATUS  records case-control definition,
TB_Diagnosis  is control_dec_tree, 
#insert nonsmear csv file to github