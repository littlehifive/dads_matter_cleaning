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
  
  return(ADEX_cleaned)
}