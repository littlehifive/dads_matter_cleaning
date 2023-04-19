identify_NA <- function(dat){
  dat <- dat |> 
    mutate(across(
      where(is.character), # A predicate function that selects the columns wrapped in `where()`
      function(x) ifelse(x %in% c("", ".","\n", ". ", " ","-","NA","n/a","#VALUE!",
                                   "999", "n/a", "n./a", "Doesn't know", "N/A"),
                          NA_character_, x) # Function to run on the selected columns
    )) |>
    mutate(across(
      where(is.numeric),
      function(x) ifelse(x %in% c(999),
                          NA_integer_, x)
    ))
  
  return(dat)
}

# get the number of characters in each open response (to be checked against numeric answer)
get_nchar <- function(var){
  return(ifelse(is.na(var), 
                0, 
                nchar(gsub("[^a-zA-Z]", "", var)))
         )
}

# clean main questions according to multiple choices questions
clean_column <- function(data, 
                         column, 
                         valid_values, 
                         mc_column,
                         min_nchar) {
  data |>  
    mutate({{ column }} := ifelse({{ column }} %in% valid_values, 
                             {{ column }}, 
                             ifelse(get_nchar({{ mc_column }}) %in% seq(length.out = min_nchar - 1), 
                                    2, 
                                    {{ column }})))
}

# calculate z score
zscore <- function(x, norm_m, norm_sd){
  zscore <- (x - norm_m) / norm_sd
}

# clean LENA interview dates using fuzzy matching (< 30 days gap with the dates in ID_list)
clean_LENA_dates <- function(LENA_cleaned, LENA_log_cleaned_long, ID_list){
  
  x <- LENA_cleaned |> select(survey_id, date_of_interview) |> distinct() |> 
    group_by(survey_id) |> arrange(survey_id, date_of_interview)
  
  x <- x |> mutate(interview_sequence = 1:n())
  
  y <- ID_list |> rename(survey_id = client_id) |> select(survey_id, date_of_interview, interview_type) |> 
    distinct() |> group_by(survey_id) |> arrange(survey_id, date_of_interview) |> mutate(date_of_interview = lubridate::mdy(date_of_interview))
  
  test <- x |> left_join(y, by = c("survey_id"), relationship = "many-to-many")
  
  test <- test |> 
    mutate(date_gap = date_of_interview.x - date_of_interview.y,
           type_match = interview_sequence == interview_type) |> 
    mutate(date_gap_under_60 = abs(date_gap) <= 60)
  # test <- test |> filter(abs(date_gap) <= 60)
  
  test <- test |> 
    mutate(interview_type_new = ifelse(
      date_gap_under_60 == FALSE,
      "Not matched",
      as.character(interview_type)
    ))
  
  # manually clean the interview_type and date_of_interview for cases that do not have a match with
  # the master ID list after the 60-day fuzzy matching
  test <- test |> 
    mutate(interview_type_new = case_when( 
      survey_id == 33202101 & date_of_interview.x %in% lubridate::as_date(c("2015-11-24", "2015-11-25")) & interview_type == 2 ~ "2",
      survey_id == 41102501 & date_of_interview.x %in% lubridate::as_date(c("2015-06-10", "2015-06-11")) & interview_type == 1 ~ "1",
      survey_id == 42101601 & date_of_interview.x == lubridate::as_date("2015-11-13") & interview_type == 2 ~ "2",
      survey_id == 51018701 & date_of_interview.x %in% lubridate::as_date(c("2018-02-06", "2018-02-07")) & interview_type == 3 ~ "3",
      survey_id == 55418101 & date_of_interview.x %in% lubridate::as_date(c("2017-03-16", "2017-03-20", "2017-03-21")) & interview_type == 2 ~ "2",
      survey_id == 42007001 & date_of_interview.x %in% lubridate::as_date(c("2015-09-03", "2015-09-04")) & interview_type == 1 ~ "1",
      survey_id == 50810901 & date_of_interview.x %in% lubridate::as_date(c("2016-04-20", "2016-04-21")) & interview_type == 1 ~ "1",
      TRUE ~ interview_type_new 
    ))
  
  test_s <- test |> 
    select(survey_id, date_of_interview.x, date_of_interview.y, date_gap, interview_type_new) |>
    filter(interview_type_new != "Not matched")
  
  test_s <- test_s |> 
    arrange(survey_id, date_of_interview.x, interview_type_new) |> 
    group_by(survey_id, interview_type_new) |> 
    mutate(same_interview_date_sequence = paste("day", 1:n())) |> 
    rename(date_of_interview = date_of_interview.x, date_of_interview_new = date_of_interview.y) |> 
    select(-date_gap)

return(test_s)
}
  