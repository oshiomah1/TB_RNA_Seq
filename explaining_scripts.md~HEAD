---
editor_options: 
  markdown: 
    wrap: 72
---

# **Case Decision Tree**

-   Assigns cases from NCR_redcap database ONLY

-   Criteria: Adult patient, TB symptoms, less than 15 days of starting
    medication, less than 1 month between TB diagnosis date and lab
    receive date, HIV negative, patient can have flu or previous
    episodes of TB

-   Variables used:

    -   Key: Revised_name = Redcap Variable name

    -   current_other_inf="Do.you.currently.have.an.infection.such.as.a.cold.or.the.flu.....not.TB,

    -   tb_status = "Do.you.currently.have.TB........",

    -   lab_receive_date = "Date.PBMC.received.in.the.Lab",

    -   HIV_status="What.is.your.HIV.status." ,

    -   treatment_srt_date = "TB.treatment.start.date." ,

    -   TB_Diag_Date ="Date.of.TB.diagnosis."

# Control Decision Tree:

-   This combs through NCR database for contemporary info and NCTB for
    lifetime medical records

-   Criteria: Adult patient, no TB symptoms, HIV negative, CANNOT have
    had a previous case of TB in their lifetime

-   It uses two functions; medical validator and self_report_validator
    for pre-assignments and then combines the two results into the final
    assignment

#### **medical_validator**

-   Preliminary assignment as case, control or unknown using the
    clinical variables *tb_test_rest, tb_nonsmear and treat_or_drug*.

-   tb_test_result = insert redcap definition

-   *tb_nonsmear = composite variable that pre assigns case, control or
    unknown. It is created from the file nonsmearkey.csv. This file was
    created originally in 2021 manually with Justin, Brenna & Oshi.*
    insert more background\*

-   treat_or_drug = composite variable that assigns: yes, no, unknwn,
    based on if patient has received TB medication, antibiotic
    resistance etc. It uses the following NCTB variables:

    -   frst_pst_tb_test_date =

    -   treat_reg_select = Treatment Regimen Selection

    -   cmpltd_trtmnt =

    -   drug_taken\_\_1 ...15 =

#### **self_report_validator:**

Preliminary assigns individuals as case, control or unknown using the
following self report_variables: prior_tb_self_reported: Have you had TB
in the past? (Self-reported) prior_tb_n\_self_reported: How many prior
TB episodes, self-reported rst_pst_tb_test_date:

#### validated_study_for_merge:

Combines The pre-assignments of medical_validator and
self_report_validator to assign patients as case, control or unknown.
This now accounts for situations where patients only have self report or
only have medical data.

# generate_key.r:

This script generates a an NCTB-NCR key. It uses a combination of fuzzy name matching, saliva barcodes and manual matching.
