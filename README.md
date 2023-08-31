# TB_RNA_Seq: Merging Datasets + Decision Trees

## There are three R scripts in this project

#### case_decision_tree.R: Assigns individuals as cases or other based on initial self-report and clinical syptoms and verified with current medical data

#### control_decision_tree.R :Assigns individuals as controls based on PRIOR medical records. Searches a wide range of variables for TB evidence in their lifetime. \*\**raw_NCTB_TB_test_vars*

#### updated_data_merge.R: It merges the smaller RNA seq study with the larger GWAS study using fuzzy name matching, saliva barcodes and manual matching. It automatically calls case_decision_tree.R and control_decision_tree.R

#### \*\*raw_NCTB_data & raw_NCR_data 

*#to do: make another script from updated data_merge to check for missing demographic data*
