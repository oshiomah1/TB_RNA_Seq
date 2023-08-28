#case decision tree
library(tidyverse)
#vector to rename columns later
NCR_new_name <- c(Surname = "Participant.Surname", First.Name = "Participant.first.name", NCR_Age = "Age.of.participant", NCR_Gender = "Sex..gender..of.participant.", NCR_Phleb_date ="Date.and.Time.of.Phlebotomy", NCR_Saliva = "Participant.study.saliva.ID", current_other_inf ="Do.you.currently.have.an.infection.such.as.a.cold.or.the.flu.....not.TB.", tb_status = "Do.you.currently.have.TB........", lab_receive_date = "Date.PBMC.received.in.the.Lab", HIV_status="What.is.your.HIV.status." , treatment_srt_date =  "TB.treatment.start.date." , TB_Diag_Date ="Date.of.TB.diagnosis.")

#read in data
#/Users/oshi/Downloads/InvestigationOfAnces-ThinReport_DATA_LABELS_2023-08-23_2240.csv

raw_NCR_data_ <- read.csv(
  "/Users/oshi/Downloads/InvestigationOfAnces-ThinReport_DATA_LABELS_2023-08-25_0120.csv",
  header = TRUE,
  sep = ";",
  na.strings = c("", " ", "NA", "N/A"),
  colClasses = c("Participant.study.saliva.ID" = "character")
) %>%
  rename(all_of(NCR_new_name)) %>%
  unite("NCR.Name", Surname, First.Name, sep = " ", remove = FALSE, na.rm = TRUE) %>%
  mutate(treatment_srt_date = as.Date(treatment_srt_date),
         lab_receive_date = as.Date(lab_receive_date), TB_Diag_Date= as.Date(as.Date(TB_Diag_Date)))

pre_cases <- raw_NCR_data_ %>%
  filter(tb_status == "Yes")

# Extract the sample_id values from the filtered data into a list
pre_cases_list <- pre_cases$Participant.study.ID
#Date PBMC received in lab [NCR], TB test result [NCR], TB lab diagnosis date [NCR], treatment start date [NCR], HIV status self-report [NCR]


case_function <- function(TB_Diag_Date, tb_status, HIV_status, treatment_srt_date, lab_receive_date) {
  result <- case_when(
    tb_status == "Yes"  ~
      case_when(
        lab_receive_date - TB_Diag_Date < 30 ~
          case_when(
            HIV_status == "Negative" ~
              case_when(
                !is.na(treatment_srt_date) &
                  lab_receive_date - treatment_srt_date < 15 ~ "2weekCase",
                !is.na(lab_receive_date) &
                  lab_receive_date - TB_Diag_Date < 15 ~ "2weekCase",
                TRUE ~ "STOP"
              ),
            TRUE ~ "STOP"
          ),
        TRUE ~ "STOP"
      ),
    TRUE ~ "STOP"
  )
  
  return(result)
}

Validated_Cases <- raw_NCR_data_ %>%
  mutate(case_status = case_function(TB_Diag_Date, tb_status, HIV_status, treatment_srt_date, lab_receive_date)) %>% filter(tb_status =="Yes") %>% mutate(validated_case_status = case_when(current_other_inf =="No" & case_status == "2weekCase" ~ "2weekCase", current_other_inf =="Yes" & case_status =="2weekCase" ~"2weekCasewithflu", TRUE ~"notcase_other"))

final_case_key <- Validated_Cases %>% select(Participant.study.ID,validated_case_status)
# Now Validated_Cases dataframe will have a new column called "val_cases" with the function results
count_table <- as.data.frame(table(Validated_Cases$validated_case_status))


# Rename the columns for clarity
colnames(count_table) <- c("Validated_Case_Status", "Count")

# Print the new dataframe with counts
print(count_table)
#write_csv(Validated_Cases,"/Users/oshi/Desktop/TB/Validated_Cases.csv")



#sanity check
# Validated_Cases2 <- raw_NCR_data_ %>%
#   mutate(
#     subtraction1 = lab_receive_date - TB_Diag_Date,
#     subtraction2 = lab_receive_date - treatment_srt_date,
#     intermediate1 = lab_receive_date - TB_Diag_Date < 30,
#     intermediate2 = tb_status == "Yes",
#     intermediate3 = HIV_status == "Negative",
#     val_cases = my_function(TB_Diag_Date, tb_status, HIV_status, treatment_srt_date, lab_receive_date)
#   ) %>% select(Participant.study.ID, tb_status,HIV_status,treatment_srt_date,lab_receive_date,TB_Diag_Date,val_cases,subtraction1:val_cases)
