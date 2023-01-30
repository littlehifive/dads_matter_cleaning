# library(tidyverse)
# tar_load(ASQ_raw)

clean_ASQ <- function(ASQ_raw){
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
    # ASQ_cleaned <- ASQ_cleaned |> 
    #   group_by(survey_id) |> 
    #   mutate(interview_type = ifelse(!interview_type %in% 999,
    #                                  interview_type,
    #                                  
    #                                  )
    #          )
    #   
    # identify NA
    identify_NA() 

  # small fixes
  ASQ_cleaned <- ASQ_cleaned |> mutate(
      c1 = ifelse(c1 == 20, 2, c1),
      gm6 = case_when(gm6 == "3-- yes, but falls" ~ "3",
                      gm6 == "11" ~ "1",
                      TRUE ~ gm6) |> as.numeric(),
      fm6 = ifelse(fm6 == "2 --- with help", "2", fm6) |> as.numeric(),
      pers6 = ifelse(pers6 == 4, 3, pers6),
      o2 = ifelse(o2 == 3, 2, o2),
      o3 = ifelse(o3 == 3, 2, o3),
      o4 = ifelse(o4 == 3, 2, o4),
      o5 = ifelse(o5 == 3, 2, o5),
      o6 = ifelse(o6 == 3, 2, o6)
    ) |> 
    mutate_at(vars(pers4, o1, o7, o8, o9), as.numeric)
  
  # clean main questions according to multiple choices questions
  ASQ_cleaned <- ASQ_cleaned |> 
    clean_column(column = c1, valid_values = c(2,3), mc_column = c1_mc, min_nchar = 3) |> 
    clean_column(column = c2, valid_values = c(2,3), mc_column = c2_mc, min_nchar = 3) |> 
    clean_column(column = c3, valid_values = c(2,3), mc_column = c3_mc, min_nchar = 3) |> 
    clean_column(column = c4, valid_values = c(2,3), mc_column = c4_mc, min_nchar = 3) |> 
    clean_column(column = c5, valid_values = c(2,3), mc_column = c5_mc, min_nchar = 3) |>   
    clean_column(column = pers2, valid_values = c(2,3), mc_column = pers2_mc, min_nchar = 4)
    
  
  return(ASQ_cleaned)       

}
