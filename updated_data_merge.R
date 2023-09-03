#combine both studies
#manually install these packages if you don't have 'em'
library(stringr)
library(tidyverse)
library(stringdist)
library(fuzzyjoin)
library(writexl)
source("/Users/oshi/Desktop/TB/case_decision_tree.R")
source("/Users/oshi/Desktop/TB/control_decision_tree.R")

#make a vector of column names to rename NCTB columns downstream
NCTB_new_name <- c(NCTB_Age = "Age.", NCTB_Saliva = "Saliva.Kit.Barcode.Number", NCTB_Gender = "Gender", NCTB_Recruitment_date = "Date.of.Recruitment")

#upload NCTB thinned from Redcap (datalabels) #  (Last downloaded aug 31         
raw_NCTB_data <- read.csv(
  "/Users/oshi/Downloads/NorthernCapeTBCaseCo-Thinned_DATA_LABELS_2023-08-31_0738.csv",
  sep = ";",
  header = TRUE,
  na.strings = c("", " ", "NA", "N/A"),
  colClasses = c("Saliva.Kit.Barcode.Number" = "character")
) %>%
  unite("NCTB.Name", Surname, First.Name, sep = " ", remove = FALSE, na.rm = TRUE) %>% rename(all_of(NCTB_new_name)) 

NCR_new_name <- c(Surname = "Participant.Surname", First.Name = "Participant.first.name", NCR_Age = "Age.of.participant", NCR_Gender = "Sex..gender..of.participant.", NCR_Phleb_date ="Date.and.Time.of.Phlebotomy", NCR_Saliva = "Participant.study.saliva.ID", NCR_current_other_inf ="Do.you.currently.have.an.infection.such.as.a.cold.or.the.flu.....not.TB.",  ncr_sr_tb_status = "Do.you.currently.have.TB........" )

#upload Thin Report from NCR dataset in redcap, Aug 30
raw_NCR_data <- read.csv(
  "/Users/oshi/Downloads/InvestigationOfAnces-ThinReport_DATA_LABELS_2023-08-31_0744.csv",
  header = TRUE,
  sep = ";",
  na.strings = c("", " ", "NA", "N/A"),
  colClasses = c("Participant.study.saliva.ID" = "character")
) %>%
  rename(all_of(NCR_new_name)) %>%
  unite("NCR.Name", Surname, First.Name, sep = " ", remove = FALSE, na.rm = TRUE)  

#Thin out NCR dataset to contain relevant columns, remove NCR093 because of missingness issues
raw_NCR_data3 <- raw_NCR_data %>%  select(-contains(c("average","Have","Maternal","circum","pigment","you", "Complete","eight","Researcher","anguage","child", "Phone","Participant.s.S")))%>% select(contains(c("Participant","Full.Name", "Age","Sex","cell","Date", "NCR","pre_status", "IGRA", "ncr_sr_tb_status", "NCR_current_other_inf")))%>%  filter(!(Participant.study.ID == "NCR093"))

########################################################################
################ Merge NCR and NCTB using Saliva Barcode ###############
########################################################################

# Filter out rows with NA values in Saliva Barcode Column in the matching columns of NCTB dataset

filtered_NCTB_data <- raw_NCTB_data %>%
  filter(!is.na(NCTB_Saliva)) 

# Filter out rows with NA values in Saliva Barcode Column in the matching columns of NCR dataset
 
filtered_NCR_data3 <- raw_NCR_data3 %>%
  filter(!is.na(NCR_Saliva)) 

# Perform the stringdist_inner_join on the filtered data frames
# I am using EXACT matches for this criteria
# ALSO use relocate function so that its easy to compare  matching columns from both studies as a sanity check 
merged_study_saliva <- stringdist_inner_join(filtered_NCTB_data, filtered_NCR_data3, by = c("NCTB_Saliva" = "NCR_Saliva"), max_dist = 0, distance_col = NULL) %>%
  relocate("Participant.study.ID", .after = Sample.ID) %>%
  relocate("NCR_Age", .after = NCTB_Age)%>%
  relocate("NCR_Gender", .after = NCTB_Gender)%>%
  relocate("NCR_Saliva", .after = NCTB_Saliva)%>%
  relocate("NCR.Name", .after = NCTB.Name)%>%
  relocate("Date.of.recruitment", .after = NCTB_Recruitment_date)

#view(merged_study_saliva)

########################################################################
############ Merge NCR and NCTB using manualmatch Names Column ####
########################################################################
manual_match_NCTB <- raw_NCTB_data %>%
  filter(!is.na(NCTB_Saliva)) %>%
  mutate(manual_match = ifelse(Sample.ID == "NC1359", "JH_MANUAL", NA)) %>%
  filter(!is.na(manual_match))

manual_match_NCR <- raw_NCR_data3 %>%
  filter(!is.na(NCR_Saliva)) %>%
  mutate(manual_match = ifelse(Participant.study.ID == "NCR023", "JH_MANUAL", NA)) %>%
  filter(!is.na(manual_match))

merged_study_manual_match <- stringdist_inner_join(manual_match_NCTB, manual_match_NCR, by = "manual_match", max_dist = 0, distance_col = NULL) %>%
  relocate("Participant.study.ID", .after = Sample.ID) %>%
  relocate("NCR_Age", .after = NCTB_Age)%>%
  relocate("NCR_Gender", .after = NCTB_Gender)%>%
  relocate("NCR_Saliva", .after = NCTB_Saliva)%>%
  relocate("NCR.Name", .after = NCTB.Name)%>%
  relocate("Date.of.recruitment", .after = NCTB_Recruitment_date)
#%>%
 # relocate("manual_match", .after = Participant.study.ID)

########################################################################
################ Merge NCR and NCTB using Names Column #################
########################################################################

#Use Fuzzy joining method because of human error in name capturing, I allow
#name characters between studies to differ by two characters (max_dist = 2)
merged_study_name  <- stringdist_inner_join(raw_NCTB_data, raw_NCR_data3, by = c("NCTB.Name" = "NCR.Name"),max_dist = 2, distance_col = NULL) %>%
  mutate(Age_Difference = abs(NCTB_Age - NCR_Age)) %>%
  relocate("Participant.study.ID", .after = Sample.ID) %>%
  relocate("NCR_Age", .after = NCTB_Age)%>%
  relocate("NCR_Gender", .after = NCTB_Gender)%>%
  relocate("NCR_Saliva", .after = NCTB_Saliva)%>%
  relocate("NCR.Name", .after = NCTB.Name)%>%
  relocate("Date.of.recruitment", .after = NCTB_Recruitment_date)


merged_study_name <- stringdist_inner_join(
  raw_NCTB_data, 
  raw_NCR_data3, 
  by = c("NCTB.Name" = "NCR.Name"),
  max_dist = 2, 
  distance_col = NULL
) %>%
  mutate(Age_Difference = abs(NCTB_Age - NCR_Age)) %>%
  filter(Age_Difference < 5) %>%
  relocate("Participant.study.ID", .after = Sample.ID) %>%
  relocate("NCR_Age", .after = NCTB_Age) %>%
  relocate("NCR_Gender", .after = NCTB_Gender) %>%
  relocate("NCR_Saliva", .after = NCTB_Saliva) %>%
  relocate("NCR.Name", .after = NCTB.Name) %>%
  relocate("Date.of.recruitment", .after = NCTB_Recruitment_date) %>%
  select(-Age_Difference)
#view(merged_study_name)

# Reorder columns in merged_study_saliva to match merged_study_name
merged_study_saliva <- merged_study_saliva %>%
  select(names(merged_study_name))
#Reorse columns in merged_study_manual match to match merged_study_name
merged_study_manual_match <- merged_study_manual_match %>%
  select(names(merged_study_name))
########################################################################
################ Now combine Name Merge and Saliva Merge datasets######
########################################################################
# Combine both data frames
combined_merged_study <- bind_rows(merged_study_saliva, merged_study_name,merged_study_manual_match )

# Remove duplicate rows
combined_merged_study <- distinct(combined_merged_study, .keep_all = TRUE)

# miscellaneous cleaning and and rearranging and renaming of columns
combined_merged_study <- combined_merged_study %>% rename(Drnk_Alcohol = "Do.you.drink.Alcohol.", Smoker = "Do.you.smoke.") %>% select(-c(First.Name,Surname,Final.IGRA.Result,Treatment.Regimen.Selection,Rifampicin.result))

###########################################################################
# Now get a list of participant IDs who have are in NCR dataset bit are missing
# NCTB data (i.e demographic data )###########################################

raw_NCR1_ids <- raw_NCR_data$Participant.study.ID

combined_merged_study_ids <- combined_merged_study$Participant.study.ID

# Get the unique values in raw_NCR1 that are not in combined_merged_study
#these are the IDs with no name match or saliva match to NCTB, presumably because they have not been shipped from Upington to Capetown
values_not_in_combined <- setdiff(raw_NCR1_ids, combined_merged_study_ids)


# Now Get the values from "values_not_in_combined" that are not in "cases". this # is a subset of above for only cases
pre_cases_list #source it from case_decison tree
values_not_in_cases <- setdiff(values_not_in_combined, pre_cases_list)
# Print the resulting vector
print(values_not_in_cases)

#convert the vector above to an NCR dataframe
unmatched_NCRs <- raw_NCR_data3 %>%
  filter(Participant.study.ID %in% values_not_in_combined)

# Print the unmatched_data frame
print(unmatched_NCRs)

#Now combine this individuals with missing demo data to main merged dataset
Prelim_Merged_Dataset <- bind_rows(combined_merged_study, unmatched_NCRs)


#we will now merge the EPI case-control status to the prelim_merged_dataset
####Source 1 
# source("/Users/oshi/Desktop/TB/update _decision tree.R")
#first rename . 

#ignore warning
Prelim_Merged_Dataset_beta <- left_join(Prelim_Merged_Dataset,control_validated_tb, 
                 by = c("Record.ID"="record_id"  )) %>%
  select(Participant.study.ID, Sample.ID,ncr_sr_tb_status, TB_diagnosis,  TB.test.result, everything()) %>%
  mutate(Date.of.recruitment = as.Date(Date.of.recruitment))


#now remove duplicates

#list of record IDs(nctb) from Brenna's email that are duplicates 
IDs_to_remove <- c(795,1446,383,569,678,917,1230)

#list of NCR IDs from Brenna's email TO REMOVE
NCR_to_remove <- c("NCR017") 

#from the dataframe Prelim_Merged_Dataset_beta2 , remove all rows where the Record.ID column matches one of the values in IDs_to_remove
#ere artifically assigning NAs to situations that are cases (should be validated by case decision tree)
final_control_assignments <- Prelim_Merged_Dataset_beta %>% 
  filter(!Record.ID %in% IDs_to_remove) %>% 
  filter(!Participant.study.ID %in% NCR_to_remove) %>% distinct(.keep_all = TRUE) %>% mutate(validated_control_status = case_when(TB_diagnosis=="control" & NCR_current_other_inf == "Yes" ~ "ctrl_flu", TB_diagnosis == "control"& NCR_current_other_inf == "No" ~ "ctrl", TB_diagnosis =="control" & is.na(NCR_current_other_inf) ~ "ctrl_unkwn_flu",  ncr_sr_tb_status == "No" & TB_diagnosis =="case" ~ "notctrl_other" , ncr_sr_tb_status == "Yes" & TB_diagnosis =="case" ~ NA ,is.na( ncr_sr_tb_status ) & TB_diagnosis =="case" ~ NA ,TRUE ~ TB_diagnosis)) %>% relocate(validated_control_status , .after = TB_diagnosis)%>% relocate("NCR_current_other_inf", .after = TB_diagnosis)


final_tb_status_table <- left_join(final_control_assignments, final_case_key, by = "Participant.study.ID") %>% relocate("validated_case_status", .after = "validated_control_status") %>% mutate(FINAL_STATUS = case_when(is.na(validated_case_status) & is.na(validated_control_status) ~ "missing",is.na(validated_case_status) & !is.na(validated_control_status) ~ validated_control_status,!is.na(validated_case_status) & is.na(validated_control_status) ~ validated_case_status )) %>% relocate("FINAL_STATUS", .after = "validated_case_status")
#include cases with flu
final_tb_status_table2 <- final_tb_status_table %>% mutate(FINAL_STATUS = case_when(FINAL_STATUS == "2weekCasewithflu" ~ "2weekCase", FINAL_STATUS =="2weekCaseunknwnflu" ~ "2weekCase",TRUE ~ FINAL_STATUS))

final_counts <- table(final_tb_status_table$FINAL_STATUS)
#view(final_counts)

#include cases with flu

final_counts2 <- table(final_tb_status_table2$FINAL_STATUS)
view(final_counts2)


output_path <- "/Users/oshi/Library/CloudStorage/Dropbox/NCR Study" #EDITABLE

#write.csv(final_tb_status_table2 , file.path(output_path, "final__tb_assignments.csv"), row.names = FALSE)


# Generate a timestamp for the file name
timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M")

# Specify the output file name with the timestamp
output_file <- paste0("final_tb_assignments_", timestamp, ".csv")

# Write the data to a timestamped CSV file
write.csv(final_tb_status_table2, file.path(output_path, output_file), row.names = FALSE)






missing_participant_ids <- final_tb_status_table2 %>%
  filter(FINAL_STATUS == "missing") %>%
  pull(Participant.study.ID) %>%
  unique()






# 
# 
# 
# case_to_previous_case <- final_assignments %>%
#   filter(pre_status == "case" & TB_status == "previous_case")
# 
# previous_case <- final_assignments %>%
#   filter(TB_status == "previous_case")
# 
# fresh_case <- final_assignments %>%
#   filter(TB_status == "fresh_case")
# 
# old_case <- final_assignments %>%
#   filter(TB_status == "old_case")


# Define the path
# output_path <- "/Users/oshi/Library/CloudStorage/Dropbox/NCR Study/Case_decision_tree"
# 
# write.csv(final_assignments, file.path(output_path, "final_assignments.csv"), row.names = FALSE)
# write.csv(case_to_previous_case, file.path(output_path, "case_to_previous_case.csv"), row.names = FALSE)
# write.csv(previous_case, file.path(output_path, "previous_case.csv"), row.names = FALSE)
# write.csv(fresh_case, file.path(output_path, "fresh_case.csv"), row.names = FALSE)
# write.csv(old_case, file.path(output_path, "old_case.csv"), row.names = FALSE)
# 
# 
# # Then save these to excel files
# write_xlsx(Prelim_Merged_Dataset_beta2, path = "/Users/oshi/Desktop/TB/Updated_DATASET_15Aug.xlsx")
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#                             #STOP HERE#
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# 
# 
# #Find values that appear more than once in the NCR.Name column
# #duplicates <- Prelim_Merged_Dataset_beta2 %>%
# #  group_by(NCR.Name) %>%
# #  filter(n() > 1)
# # Print the filtered_data dataframe
# #view(duplicates)
# #write to xlsx file
# #write_xlsx(duplicates,"/Users/oshi/Desktop/TB/duplicates.xlsx")
# 
# 
# # Columns to check for misisngess
# columns_of_interest <- c("NCTB_Gender", "NCR_Gender", "Clinic.Sampling.Location",
#                          "Drnk_Alcohol", "Smoker", "Highest.Qualification",
#                          "NCTB_Age", "NCR_Age", "NCTB_Recruitment_date",
#                          "Date.of.recruitment", "NCTB_Saliva", "NCR_Saliva",
#                          "Cell.Viability", "Live.Cell.Count", "NCR_Phleb_date",
#                          "Date.of.IGRA.blood.draw", "Final.IGRA.results")
# 
# # Create a dataframe to record missingness and Participant.study.ID values
# missingness_data <- data.frame(Column = character(),
#                                Missingness = integer(),
#                                Participant.ID_Values = character(),
#                                stringsAsFactors = FALSE)
# 
# # Loop through each column
# for (col in columns_of_interest) {
#   missing_rows <- Prelim_Merged_Dataset_beta2 %>%
#     filter(is.na(!!sym(col))) %>%
#     pull(Participant.study.ID) %>%
#     unique() %>%
#     toString()
#   
#   missing_count <- sum(is.na(combined_merged_study[[col]]))
#   
#   missingness_data <- bind_rows(missingness_data, data.frame(Column = col,
#                                                              Missingness = missing_count,
#                                                              Participant.ID_Values = missing_rows))
# }
# 
# 
# 
# 
# 
# # Print the missingness_data dataframe
# view(missingness_data)
# 
# write_xlsx(missingness_data, "/Users/oshi/Desktop/TB/missingness_data.xlsx")
# #beta mode ignore below
# # Split and convert the Participant.ID_Values to a list of vectors
# id_values_list <- strsplit(missingness_data$Participant.ID_Values, ", ")
# 
# # Get the unique Participant.study.ID values across all columns
# unique_ids <- unique(unlist(id_values_list))
# 
# # Print the list of unique Participant.study.ID values
# print(unique_ids)
# 
# 
# 
# 
# ####    #### #### ####    #### 
# ####  SANITY CHECKS; IGNORE BELOW #####
# 
# # Group by "Participant.study.ID" and count the occurrences
# id_counts <- as.data.frame( xxx %>%
#                               group_by(Participant.study.ID) %>%
#                               tally(name = "Count") %>%
#                               filter(Count > 1))
# 
# # Display the counts of repeated characters
# print(id_counts)
# 
# 
# 
# #
# 



