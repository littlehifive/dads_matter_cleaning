# clean LENA log data
clean_LENA_log <- function(LENA_log_raw){
  
  LENA_log_cleaned <- LENA_log_raw |> 
    janitor::clean_names() |> 
    rename(survey_id = mom_id, interview_type = type, child_bd = child_dob)
  
  LENA_log_cleaned <- LENA_log_cleaned |> 
    # remove rows that should be dropped
    filter(!id %in% c(126, 16, 27, 122, 138)) |> 
    identify_NA() |> 
    select(-c(status))
  
  LENA_log_cleaned <- LENA_log_cleaned |> 
    mutate(child_bd = lubridate::mdy(child_bd)) |> 
    mutate(interview_type = as.character(interview_type)) |> 
    mutate(form = case_when(
      form == 1 ~ "Complete",
      form == 2 ~ "Incomplete",
      form == 3 ~ "Returned blank",
      form == 4 ~ "Not returned",
      TRUE ~ NA_character_
    ),
    gender = case_when(
      gender == 1 ~ "Girl", 
      gender == 2 ~ "Boy",
      TRUE ~ NA_character_),
    return = case_when(
      return == 1 ~ "Mother",
      return == 2 ~ "Father",
      return == 3 ~ "Mother and father",
      TRUE ~ NA_character_
    ))
  
  LENA_log_cleaned <- LENA_log_cleaned |> 
    mutate_at(vars(w5:w22), 
              function(x){
                case_when(
                  x == 0 ~ NA_character_,
                  x == 1 ~ "Home",
                  x == 2 ~ "Daycare",
                  x == 3 ~ "Another building",
                  x == 4 ~ "Outside",
                  TRUE ~ NA_character_
                )
              }) |> 
    mutate_at(vars(p5:p22, -p17),
              function(x){
                case_when(
                  x == 0 ~ NA_character_,
                  x == 1 ~ "Mother",
                  x == 2 ~ "Father",
                  x %in% c(3, 123, 13, 23, 12) ~ "Mother and father",
                  x == 4 ~ "Other person",
                  x == 34 ~ "Mother, father, and other person",
                  x == 24 ~ "Father and other person",
                  x == 14 ~ "Mother and other person",
                  TRUE ~ NA_character_
                )
              }) |> 
    mutate(p17 = case_when(
      p17 == "0" ~ NA_character_,
      p17 == "1" ~ "Mother",
      p17 == "2" ~ "Father",
      p17 %in% c("3", "1, 2", "1,2", "1,2,3", "1,3") ~ "Mother and father",
      p17 == "4" ~ "Other person",
      p17 == "1,4" ~ "Mother and other person",
      TRUE ~ NA_character_
    )) |> 
    mutate(typical = case_when(typical == 1 ~ "Speak equal to a typical day",
                               typical == 2 ~ "Speak more than typical day",
                               typical == 3 ~ "Speak less than typical day",
                               TRUE ~ NA_character_)
                               )
  
  return(LENA_log_cleaned)
}

# clean LENA data
clean_LENA_log_long <- function(LENA_log_cleaned, ID_list){
  
  # merge with master id list to get the dates
  LENA_log_cleaned_long <- LENA_log_cleaned |> 
    select(survey_id, interview_type, w5:e22) |> 
    filter(!is.na(survey_id)) |> 
    left_join(ID_list |> select(client_id, interview_type, date_of_interview) |> 
                mutate(interview_type = as.character(interview_type),
                       date_of_interview = lubridate::mdy(date_of_interview)) |> 
                         rename(survey_id = client_id),
              by = c("survey_id", "interview_type"))

  # pivot longer to get the hour label (5:00 - 22:00) from variable name
  LENA_log_cleaned_long <- LENA_log_cleaned_long |> 
    pivot_longer(cols = w5:e22,
                 names_to = c(".value", "time"),
                 names_pattern = "(.)(\\d+)"
                 ) |> 
    mutate(time = paste0(time, ":00:00")) 
  
  # create datetime combining dates and hours
  LENA_log_cleaned_long <- LENA_log_cleaned_long |> 
    mutate(timestamp = lubridate::ymd_hms(paste(date_of_interview, time, sep = " ")))
  
  return(LENA_log_cleaned_long)
}

clean_LENA <- function(LENA_raw, LENA_log_cleaned_long){
  
  LENA_log_cleaned_long_subset <- LENA_log_cleaned_long |> 
    select(survey_id, date_of_interview, timestamp, e) |>
    filter(e == 1) |> 
    mutate(timestamp_end = timestamp + lubridate::hours(1)) |> 
    rename(timestamp_start = timestamp)
  
  LENA_cleaned <- LENA_raw |> 
    janitor::clean_names() |> 
    mutate(date_of_interview = lubridate::date(lubridate::mdy_hm(timestamp)),
           timestamp = lubridate::mdy_hm(timestamp)) |> 
    select(-lastname) |> 
    rename(survey_id = firstname)
  
  LENA_cleaned <- LENA_cleaned |> 
    left_join(LENA_log_cleaned_long_subset,
              by = c("survey_id", "date_of_interview")) |> 
    filter(e == 1 & timestamp > timestamp_start & timestamp < timestamp_end)
    
  # issues with non-matching dates between master id list and lena data
  
}