## TB_RNA_Seq

#There are three R scripts in this project
# case_decision_tree.R: Assigns individuals as cases or other based on initial self-report  and clinical syptoms and verified with current medical data
# control_decision_tree.R :Assigns individuals as controls based onn PRIOR medical records. Searches a wide range of varaibles for TB evidienve in their lifetime

# updated_data_merge.R: It merges the smaller RNA seq study with the larger GWAS study using  fuzzy name matching, saliva barcodes and manu8al matching. It automatically calls case_decision_tree.R and control_decision_tree.R
