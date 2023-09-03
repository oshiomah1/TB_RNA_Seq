# TB_RNA_Seq: Merging Datasets + Decision Trees

## There are three R scripts in this project

#### case_decision_tree.R: Assigns individuals as cases or other based on initial self-report and clinical syptoms and verified with current medical data

#### control_decision_tree.R :Assigns individuals as controls based on PRIOR medical records. Searches a wide range of variables for TB evidence in their lifetime.

#### updated_data_merge.R: It merges the smaller RNA seq study with the larger GWAS study using fuzzy name matching, saliva barcodes and manual matching. It automatically calls case_decision_tree.R and control_decision_tree.R

#### \*\*raw_NCTB_data & raw_NCR_data

# Before ruunning Scripts:

## Before running, you must

### 1) In each script manually check that the datafile is the most recent from REDCAP, if not redownload. The variables where you edit these are

#### a) control_decision_tree.R : raw_NCTB_TB_test_vars

#### b) updated_data_merge.R: raw_NCTB_data & raw_NCR_data

#### c) case_decision_tree.R: raw_NCR_data\_

### 2) In updated_data_merge.R you must change output_path to your actual desired path on dropbox or your desktop (it's Oshi's by default)

# Running Scripts:

### There are 2 options to run the scripts

### 1) Quick'n'easy mode: Only Run updated_data_merge.R. This script actually automatically sources both decision tree scripts. You should get an output pop up on your rstudio with final case/control counts

### 2) Investigator mode: First you can run case_decision_tree and control_decision_tree in any order, then updated data merge. You would do this when trying to find cracks in the system. 

##### An important thing to track here is why some cases fall of the assignment tree. After running case_decision_tree , view(Validatedcases2) and check out these columns for individuals that have become notcase_other

1.  lab_date_2\_diag_date = lab_receive_date - TB_Diag_Date,

2.  lab_date_2\_trtment_strt = lab_receive_date - treatment_srt_date,

3.  less_than_thirty = lab_receive_date - TB_Diag_Date \< 30,

4.  intermediate2 = tb_status == "Yes",

5.   intermediate3 = HIV_status == "Negative",

### 

*#to do: make another script from updated data_merge to check for missing demographic data*
