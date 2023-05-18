# clean ADEX data
clean_ADEX <- function(ADEX_raw, LENA_cleaned, LENA_log_cleaned_long, ID_list){
  
  # clean variable names
  ADEX_cleaned <- ADEX_raw |> 
    janitor::clean_names() |> 
    rename(id = child_child_id, 
           timestamp = clock_time_tz_adj) |> 
    mutate(timestamp = lubridate::mdy_hms(timestamp)) |> 
    mutate(date_of_interview = lubridate::date(timestamp)) |> 
    rename(age = child_age, sex = child_gender)
  
  # some LENA ids are different for the same survey_id
  ADEX_cleaned <- ADEX_cleaned |> 
    mutate(id = case_when(
      id == "C085" ~ "C066",
      id == "C011" ~ "C010",
      TRUE ~ id
    ))
  
  # add survey_id to ADEX dataset from LENA dataset
  temp <- LENA_cleaned |> select(id, survey_id) |> distinct() |> na.omit()
  
  ADEX_cleaned <- ADEX_cleaned |> 
    left_join(temp, by = "id") |> 
    filter(!is.na(survey_id))
  
  # clean LENA ids
  ADEX_cleaned <- ADEX_cleaned |>
    mutate(
      survey_id = case_when(
        survey_id == 11513901 ~ 51513901,
        survey_id == 33202201 ~ 33202101,
        survey_id == 33302002 ~ 33302001,
        survey_id == 36107101 ~ 31607101,
        TRUE ~ survey_id))
  
  # remove rows that are likely non-consented cases
  ADEX_cleaned <- ADEX_cleaned |> 
    filter(!survey_id %in% c(112415, 16201, 18914801, 36612701, 55212601, 7000101)) |> 
    filter(!(survey_id == 35105801 & date_of_interview == "2015-06-12"))
  
  # fix birth dates using the cleaned dates from  the cleaned LENA dataset
  temp <- LENA_cleaned |> select(survey_id, birthdate) |> distinct() |> na.omit()

  ADEX_cleaned <- ADEX_cleaned |> 
    left_join(temp, by = "survey_id")
  
  # correct the date_of_interview in ADEX using information from the cleaned LENA dataset
  temp <- clean_LENA_dates(ADEX_cleaned, LENA_log_cleaned_long, ID_list)
  
  ADEX_cleaned <- ADEX_cleaned |> 
    left_join(
      temp,
      by = c("survey_id", "date_of_interview"),
      relationship = "many-to-many"
    )
  
  # additional manual cleaning
  ADEX_cleaned <- ADEX_cleaned |> 
    mutate(date_of_interview = if_else(
      survey_id == 33420701 & date_of_interview == lubridate::as_date("2018-05-01"),
      lubridate::as_date("2018-04-10"),
      date_of_interview
    )) |> 
    mutate(date_of_interview_new = if_else(
      survey_id == 33420701 & date_of_interview == lubridate::as_date("2018-04-10"),
      lubridate::as_date("2018-04-10"),
      date_of_interview_new
    )) |> 
    mutate(interview_type_new = if_else(
      survey_id == 33420701 & date_of_interview == lubridate::as_date("2018-04-10"),
      "3",
      interview_type_new
    )) |> 
    mutate(same_interview_date_sequence = if_else(
      survey_id == 33420701 & date_of_interview == lubridate::as_date("2018-04-10"),
      "day 1",
      same_interview_date_sequence
    ))
  
  # create updated timestamp
  ADEX_cleaned <- ADEX_cleaned |>
    mutate(timestamp_new = paste0(date_of_interview_new,
                                  gsub(".*\\s(.*)", "\\1", timestamp))
           ) |>
    mutate(timestamp_new = lubridate::ymd_hms(timestamp_new))
  
  # timestamp from LENA log
  LENA_log_cleaned_long_subset <- LENA_log_cleaned_long |> 
    select(survey_id, date_of_interview, timestamp, e) |>
    filter(e == 1) |> 
    mutate(timestamp_end = timestamp + lubridate::hours(1)) |> 
    rename(timestamp_start = timestamp)
  
  # remove time periods indicated by parents to drop
  ADEX_cleaned <- ADEX_cleaned |>
    left_join(LENA_log_cleaned_long_subset |> rename(date_of_interview_new = date_of_interview),
              by = c("survey_id", "date_of_interview_new"),
              relationship = "many-to-many") |>
    filter(
      is.na(e) | 
        is.na(timestamp_new) | 
        is.na(timestamp_start) | 
        is.na(timestamp_end) | 
        !(e == 1 & timestamp_new > timestamp_start & timestamp_new < timestamp_end))
  
  # reorder variables
  ADEX_cleaned <- ADEX_cleaned |> 
    mutate(timestamp = timestamp_new,
           date_of_interview = date_of_interview_new,
           interview_type = interview_type_new) |> 
    select(-c(child_dob, timestamp_new, interview_type_new, date_of_interview_new, timestamp_start, timestamp_end, e)) |> 
    select(index:its_version, survey_id, birthdate, timestamp, 
           date_of_interview, interview_type, same_interview_date_sequence,
           awc:peak_signal_level) |> 
    distinct() # remove the duplicates craeted in the multiway matching in the previous step
  
  # filter out incomplete non-5-min segments
  ADEX_cleaned <- ADEX_cleaned |> 
    filter(lubridate::second(timestamp) == 0)
  
  # certain numeric variables are coded as character
  ADEX_cleaned <- ADEX_cleaned |> 
    mutate_at(vars(ava_ss, emlu, ava_da),
              function(x){
                ifelse(x == "ORL",
                       NA,
                       x)}
              ) |> 
    mutate_at(vars(ava_ss, emlu, ava_da),
              as.numeric)
  
  # calculate the average of the indices for families with multiple recordings across consecutive days
  temp <- ADEX_cleaned |> 
    group_by(survey_id, timestamp) |> 
    summarise_at(vars(awc:peak_signal_level),
                 function(x){mean(x, na.rm = T)})
  
  temp1 <- temp |> mutate(date_of_interview = as.Date(timestamp))
  
  temp2 <- ADEX_cleaned |> 
    select(id, survey_id, birthdate, date_of_interview, interview_type) |> 
    distinct()
  
  ADEX_cleaned <- temp1 |> left_join(temp2, by = c("survey_id", "date_of_interview"))
  
  # rearrange variable order
  ADEX_cleaned <- ADEX_cleaned |> 
    select(survey_id, id, birthdate, timestamp, date_of_interview, interview_type,
           awc:peak_signal_level)
  
  return(ADEX_cleaned)
}

# create useful ADEX indices for different time cutoffs
clean_ADEX_indices <- function(ADEX_cleaned){
  
  ADEX_indices_cleaned <- ADEX_cleaned |> 
    mutate(timestamp_hour = lubridate::hour(timestamp),
           .after = timestamp) |> 
    mutate(timestamp_11_to_6 = ifelse(timestamp_hour %in% c(23, 0:6),
                                      1, 0),
           timestamp_0_to_6 = ifelse(timestamp_hour %in% c(0:6),
                                     1, 0),
           timestamp_1_to_6 = ifelse(timestamp_hour %in% c(1:6),
                                     1, 0),
           .after = timestamp_hour
    )
  

  temp1 <- ADEX_indices_cleaned |> 
    group_by(survey_id, date_of_interview, timestamp_11_to_6) |> 
    summarise(total_recording_hours = n() * 5 / 60)
  
  ADEX_indices_cleaned_11_to_6 <- ADEX_indices_cleaned |> 
    group_by(survey_id, id, birthdate, date_of_interview, interview_type,
             timestamp_11_to_6) |> 
    summarise_at(vars(awc:peak_signal_level),
                 mean, na.rm = T) |> 
    left_join(temp1, by = c("survey_id", "date_of_interview", "timestamp_11_to_6"))
  
  temp2 <- ADEX_indices_cleaned |> 
    group_by(survey_id, date_of_interview, timestamp_0_to_6) |> 
    summarise(total_recording_hours = n() * 5 / 60)
  
  ADEX_indices_cleaned_0_to_6 <- ADEX_indices_cleaned |> 
    group_by(survey_id, id, birthdate, date_of_interview, interview_type,
             timestamp_0_to_6) |> 
    summarise_at(vars(awc:peak_signal_level),
                 mean, na.rm = T) |> 
    left_join(temp2, by = c("survey_id", "date_of_interview", "timestamp_0_to_6"))

  temp3 <- ADEX_indices_cleaned |> 
    group_by(survey_id, date_of_interview, timestamp_1_to_6) |> 
    summarise(total_recording_hours = n() * 5 / 60)
  
  ADEX_indices_cleaned_1_to_6 <- ADEX_indices_cleaned |> 
    group_by(survey_id, id, birthdate, date_of_interview, interview_type,
             timestamp_1_to_6) |> 
    summarise_at(vars(awc:peak_signal_level),
                 mean, na.rm = T) |> 
    left_join(temp3, by = c("survey_id", "date_of_interview", "timestamp_1_to_6"))
  
  return(list(ADEX_indices_cleaned_11_to_6,
              ADEX_indices_cleaned_0_to_6,
              ADEX_indices_cleaned_1_to_6))
  
}