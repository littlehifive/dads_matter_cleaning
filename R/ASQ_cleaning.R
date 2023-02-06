# library(tidyverse)
# tar_load(ASQ_raw)

clean_ASQ <- function(ASQ_raw, ASQ_norm){
  # tar_load(ASQ_raw)
  
  ASQ_cleaned <- ASQ_raw |> 
    # remove rows that should be dropped
    filter(!id %in% c(2, 8, 21, 23, 92, 329)) |>
    # convert dates to R date format
    mutate(
      interview_date = ifelse(interview_date == "999", NA_character_, interview_date),
      interview_date = ifelse(interview_date == "9/2/1015", "9/2/2015", interview_date),
      interview_date = openxlsx::convertToDate(interview_date)) |> 
    # clean interview dates before removing 999s
    mutate(interview_type = case_when(
      id == 30 ~ 2, 
      id %in% c(41, 47, 38, 48, 49, 51, 33, 59, 28) ~ 1,
      TRUE ~ interview_type
    )) |> 
    identify_NA() 

  # small fixes
  ASQ_cleaned <- ASQ_cleaned |> mutate(
      c1 = ifelse(c1 == 20, 2, c1),
      gm6 = case_when(gm6 == "3-- yes, but falls" ~ "3",
                      gm6 == "11" ~ "1",
                      TRUE ~ gm6) |> as.numeric(),
      fm6 = ifelse(fm6 == "2 --- with help", "2", fm6) |> as.numeric()
    ) |> 
    mutate_at(vars(o1,o2,o3,o4,o5,o6,o7,o8,o9,o10), 
              function(x){ifelse(x == 3, 2, x)}) |> 
    mutate_at(vars(pers4, ps6, o1, o7, o8, o9), as.numeric)
  
  # clean main questions according to multiple choices questions
  ASQ_cleaned <- ASQ_cleaned |> 
    clean_column(column = c1, valid_values = c(2,3), mc_column = c1_mc, min_nchar = 3) |> 
    clean_column(column = c2, valid_values = c(2,3), mc_column = c2_mc, min_nchar = 3) |> 
    clean_column(column = c3, valid_values = c(2,3), mc_column = c3_mc, min_nchar = 3) |> 
    clean_column(column = c4, valid_values = c(2,3), mc_column = c4_mc, min_nchar = 3) |> 
    clean_column(column = c5, valid_values = c(2,3), mc_column = c5_mc, min_nchar = 3) |>   
    clean_column(column = pers2, valid_values = c(2,3), mc_column = pers2_mc, min_nchar = 4)
    
  # clean conditional sentences
  ASQ_cleaned <- ASQ_cleaned |> 
    mutate(
      fm1 = ifelse(age_form == 2 & fm5 == 1, 1, fm1),
      fm2 = case_when(
        age_form == 8 & fm6 %in% c(1,2)  ~ 1,
        age_form == 9 & fm5 %in% c(1,2)  ~ 1,
        age_form == 10 & fm5 %in% c(1,2)  ~ 1,
        age_form == 12 & fm4 %in% c(1,2)  ~ 1,
        TRUE ~ fm2),
      gm1 = case_when(
        age_form == 8 & gm5 %in% c(1,2)  ~ 1,
        age_form == 22 & gm6 %in% c(1,2)  ~ 1,
        age_form == 27 & gm6 %in% c(1,2)  ~ 1,
        TRUE ~ gm1),
      gm2 = case_when(
        age_form == 24 & gm6 %in% c(1,2)  ~ 1,
        age_form == 30 & gm5 %in% c(1,2)  ~ 1,
        TRUE ~ gm2),
      ps1 = case_when(
        age_form == 14 & ps2 %in% c(1,2)  ~ 1,
        age_form == 16 & ps5 == 1  ~ 1,
        TRUE ~ ps1),
      ps3 = ifelse(age_form == 18 & ps6 %in% c(1,2), 1, ps3),
      ps4 = ifelse(age_form == 12 & ps5 %in% c(1,2), 1, ps4)
      )
  
  # relabel yes/sometimes/not yet
  ASQ_cleaned <- ASQ_cleaned |> 
    mutate_at(vars(c1, c2, c3, c4, c5, c6,
                   gm1, gm2, gm3, gm4, gm5, gm6,
                   fm1, fm2, fm3, fm4, fm5, fm6,
                   ps1, ps2, ps3, ps4, ps5, ps6,
                   pers1, pers2, pers3, pers4, pers5, pers6),
              function(x){case_when(
                x == 1 ~ 10,
                x == 2 ~ 5,
                x == 3 ~ 0
              )}) |> 
    mutate_at(vars(o1, o2, o3, o4, o5, o6, o7, o8, o9, o10),
              function(x){ifelse(x == 1, "Yes", "No")})
  
  # create area scores
  ASQ_cleaned <- ASQ_cleaned |> 
    rowwise() |> 
    mutate(c_overall = sum(c1, c2, c3, c4, c5, c6),
           gm_overall = sum(gm1, gm2, gm3, gm4, gm5, gm6),
           fm_overall = sum(fm1, fm2, fm3, fm4, fm5, fm6),
           ps_overall = sum(ps1, ps2, ps3, ps4, ps5, ps6),
           pers_overall = sum(pers1, pers2, pers3, pers4, pers5, pers6)) |> 
    ungroup()
  
  # create area Z scores based on ASQ norm scores
  ASQ_cleaned <- ASQ_cleaned |> 
    left_join(ASQ_norm, by = "age_form") |> 
    mutate(c_overall_z = zscore(c_overall, c_overall_m, c_overall_sd),
           gm_overall_z = zscore(gm_overall, gm_overall_m, gm_overall_sd),
           fm_overall_z = zscore(fm_overall, fm_overall_m, fm_overall_sd),
           ps_overall_z = zscore(ps_overall, ps_overall_m, ps_overall_sd),
           pers_overall_z = zscore(pers_overall, pers_overall_m, pers_overall_sd)) |> 
    select(-c(c_overall_m:pers_overall_sd))
  
  # order by survey id and interview type
  ASQ_cleaned <- ASQ_cleaned |> 
    arrange(survey_id, interview_type)
  
  return(ASQ_cleaned)       

}
