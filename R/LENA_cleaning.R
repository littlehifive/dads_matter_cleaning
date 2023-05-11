# clean ID list
clean_ID_list <- function(ID_list){

  ID_list_cleaned <- ID_list |> 
    mutate(date_of_interview = case_when(
      client_id == 55312301 & date_of_interview == "3/30/15" ~ "3/30/16",
      client_id == 55418101 & date_of_interview == "3/9/07" ~ "3/9/17",
      TRUE ~ date_of_interview))
  
  return(ID_list_cleaned)
}

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
  
  # clean LENA log ids (pending further checks from Aaron)
  LENA_log_cleaned <- LENA_log_cleaned |> 
    mutate(
      survey_id = case_when(
        survey_id == 53906401 ~ 53906901,
        survey_id == 11513901 ~ 51513901,
        survey_id == 32011901 ~ 32011701,
        survey_id == 50810801 ~ 50810701,
        TRUE ~ survey_id))
  
  # remove rows that are likely non-consented cases
  LENA_log_cleaned <- LENA_log_cleaned |> 
    filter(!survey_id %in% c(18914801, 55212601, 56416401, 22110101))
  
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
                  x %in% c(12, 3) ~ "Mother and father",
                  x == 4 ~ "Other person",
                  x %in% c(123, 34) ~ "Mother, father, and other person",
                  x %in% c(23, 24) ~ "Father and other person",
                  x %in% c(13, 14) ~ "Mother and other person",
                  TRUE ~ NA_character_
                )
              }) |> 
    mutate(p17 = case_when(
      p17 == "0" ~ NA_character_,
      p17 == "1" ~ "Mother",
      p17 == "2" ~ "Father",
      p17 %in% c("3", "1, 2", "1,2") ~ "Mother and father",
      p17 == "4" ~ "Other person",
      p17 %in% c("1,2,3") ~ "Mother, father, and other person",
      p17 %in% c("1,3", "1,4") ~ "Mother and other person",
      TRUE ~ NA_character_
    )) |> 
    mutate(typical = case_when(typical == 1 ~ "Speak equal to a typical day",
                               typical == 2 ~ "Speak more than typical day",
                               typical == 3 ~ "Speak less than typical day",
                               TRUE ~ NA_character_)
                               )
  
  # filter out forms that have not been returned
  LENA_log_cleaned <- LENA_log_cleaned |> 
    filter(form != "Not returned")
  
  return(LENA_log_cleaned)
}

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
  
  # if only other person is present also indicate to drop
  LENA_log_cleaned_long <- LENA_log_cleaned_long |> 
    mutate(e = ifelse(p == "Other person", 1, e))
  
  return(LENA_log_cleaned_long)
}

# clean LENA data
clean_LENA <- function(LENA_raw, LENA_log_cleaned_long, ID_list){
  
  # timestamp from LENA log
  LENA_log_cleaned_long_subset <- LENA_log_cleaned_long |> 
    select(survey_id, date_of_interview, timestamp, e) |>
    filter(e == 1) |> 
    mutate(timestamp_end = timestamp + lubridate::hours(1)) |> 
    rename(timestamp_start = timestamp)
  
  # clean variable names and create dates from timestamp
  LENA_cleaned <- LENA_raw |> 
    janitor::clean_names() |> 
    mutate(date_of_interview = lubridate::date(lubridate::mdy_hm(timestamp)),
           timestamp = lubridate::mdy_hm(timestamp)) |> 
    select(-lastname) |> 
    rename(survey_id = firstname)
  
  # clean LENA ids
  LENA_cleaned <- LENA_cleaned |>
    mutate(
      survey_id = case_when(
        survey_id == 11513901 ~ 51513901,
        survey_id == 33202201 ~ 33202101,
        survey_id == 33302002 ~ 33302001,
        survey_id == 36107101 ~ 31607101,
        TRUE ~ survey_id))
  
  # remove rows that are likely non-consented cases
  LENA_cleaned <- LENA_cleaned |> 
    filter(!survey_id %in% c(112415, 16201, 18914801, 36612701, 55212601, 7000101)) |> 
    filter(!(survey_id == 35105801 & date_of_interview == "2015-06-12")) |> 
    filter(!is.na(survey_id))
  
  # use birth dates from ID list (assuming some of them are incorrect in the LENA data)
  LENA_cleaned <- LENA_cleaned |> 
    mutate(birthdate = case_when(
      survey_id == 53404401 & birthdate == "4/12/2013" ~  "3/12/2013",
      survey_id == 33317701 & birthdate == "10/25/2014" ~  "5/16/2014",
      survey_id == 41116501 & birthdate == "10/14/2014" ~ 	"10/13/2014",
      survey_id == 35609401 & birthdate == "3/11/2015"	 ~ "11/24/2014",
      survey_id == 33420701 & birthdate == "11/1/2015" ~  "1/1/2015",
      survey_id == 33601301 & birthdate == "3/26/2015"	 ~ "3/16/2015",
      survey_id == 34205601 & birthdate == "5/18/2015" ~  "4/7/2015",
      survey_id == 56017101 & birthdate == "5/17/2015"	 ~ "5/7/2015",
      survey_id == 52905301 & birthdate == "6/14/2015" ~  "6/4/2015",
      survey_id == 41005401 & birthdate == "8/22/2015"	 ~ "7/21/2015",
      survey_id == 53103201 & birthdate == "7/19/2015" ~  "7/29/2015",
      survey_id == 36612201 & birthdate == "7/2/2015"	 ~ "9/2/2015",
      survey_id == 33509901 & birthdate == "11/2/2015" ~  "11/30/2015",
      survey_id == 33309501 & birthdate == "3/31/2016"	 ~ "4/2/2016",
      survey_id == 51018701 & birthdate == "11/15/2016"~ "9/2/2016",
      TRUE ~ birthdate)
      ) |> 
    # fix cases with multiple birthdates
    mutate(birthdate = case_when(
      survey_id == 31607101 ~ "7/21/2015",
      survey_id == 33202101 ~ "12/4/2012",
      survey_id == 33601301 ~ "3/16/2015",
      survey_id == 41005401 ~ "7/21/2015",
      survey_id == 53103201 ~ "7/29/2015",
      TRUE ~ birthdate
    )) |> 
    mutate(birthdate = lubridate::mdy(birthdate))
  
  # replace LENA interview dates (which is completely unreliable) with interview_type and date_of_interview 
  # in ID_list using 60-day fuzzy matching
  temp <- clean_LENA_dates(LENA_cleaned, LENA_log_cleaned_long, ID_list)
  
  LENA_cleaned <- LENA_cleaned |> 
    left_join(
      temp,
      by = c("survey_id", "date_of_interview"),
      relationship = "many-to-many"
    )
  
  # additional manual cleaning
  LENA_cleaned <- LENA_cleaned |> 
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
  LENA_cleaned <- LENA_cleaned |>
    mutate(timestamp_new = paste0(date_of_interview_new,
                              " ",
                              lubridate::hour(timestamp), ":",
                              lubridate::minute(timestamp), ":",
                              lubridate::second(timestamp), "0"
                              )) |>
    mutate(timestamp_new = lubridate::ymd_hms(timestamp_new))
  
  # remove time periods indicated by parents to drop
  LENA_cleaned <- LENA_cleaned |>
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
  LENA_cleaned <- LENA_cleaned |> 
    mutate(timestamp = timestamp_new,
           date_of_interview = date_of_interview_new,
           interview_type = interview_type_new) |> 
    select(-c(timestamp_new, interview_type_new, date_of_interview_new, timestamp_start, timestamp_end, e)) |> 
    select(type:timestamp, date_of_interview, interview_type, same_interview_date_sequence,
           duration:ava_avg_score_pct) |> 
    distinct() # remove the duplicates created in the multi-way matching in the previous step
  
  # filter out incomplete non-5-min segments
  LENA_cleaned <- LENA_cleaned |> 
    filter(duration == as.difftime("00:05:00"))
  
  # some LENA ids are different for the same survey_id
  LENA_cleaned <- LENA_cleaned |> 
    mutate(id = case_when(
      id == "C085" ~ "C066",
      id == "C011" ~ "C010",
      TRUE ~ id
    ))
  
  # calculate the average of the indices for families with multiple recordings across consecutive days
  temp <- LENA_cleaned |> 
    group_by(survey_id, timestamp) |> 
    summarise_at(vars(duration, meaningful, distant, tv, noise, silence, awc_actual, 
                      ctc_actual, cvc_actual, ava_std_score),
                 function(x){mean(x, na.rm = T)})
  
  temp1 <- temp |> mutate(date_of_interview = as.Date(timestamp))
  
  temp2 <- LENA_cleaned |> 
    select(id, survey_id, birthdate, date_of_interview, interview_type) |> 
    distinct()
  
  LENA_cleaned <- temp1 |> left_join(temp2, by = c("survey_id", "date_of_interview"))
  
  # change seconds back to hms and rearrange variable order
  LENA_cleaned <- LENA_cleaned |> 
    mutate_at(vars(duration:silence),
              hms::as_hms) |> 
    select(survey_id, id, birthdate, timestamp, date_of_interview, interview_type,
           duration:ava_std_score)
    
  return(LENA_cleaned)
}

# create useful LENA indices for different time cutoffs
clean_LENA_indices <- function(LENA_cleaned){
  
  LENA_indices_cleaned <- LENA_cleaned |> 
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
  
  LENA_indices_cleaned_11_to_6 <- LENA_indices_cleaned |> 
    group_by(survey_id, id, birthdate, date_of_interview, interview_type,
             timestamp_11_to_6) |> 
    summarise_at(vars(meaningful:ava_std_score),
                 mean, na.rm = T)
  
  LENA_indices_cleaned_0_to_6 <- LENA_indices_cleaned |> 
    group_by(survey_id, id, birthdate, date_of_interview, interview_type,
             timestamp_0_to_6) |> 
    summarise_at(vars(meaningful:ava_std_score),
                 mean, na.rm = T)
  
  LENA_indices_cleaned_1_to_6 <- LENA_indices_cleaned |> 
    group_by(survey_id, id, birthdate, date_of_interview, interview_type,
             timestamp_1_to_6) |> 
    summarise_at(vars(meaningful:ava_std_score),
                 mean, na.rm = T)
  
  return(list(LENA_indices_cleaned_11_to_6,
              LENA_indices_cleaned_0_to_6,
              LENA_indices_cleaned_1_to_6))
  
}