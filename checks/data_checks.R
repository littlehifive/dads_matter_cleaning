hist(ASQ_cleaned$interview_date, breaks = 10)
table(ASQ_cleaned$interview_type)
table(ASQ_cleaned$age_form)
table(ASQ_cleaned$c1)
table(ASQ_cleaned$c1_mc)
table(ASQ_cleaned$c2_mc)
table(ASQ_cleaned$c3_mc)
table(ASQ_cleaned$c4_mc)
table(ASQ_cleaned$c5_mc)
table(ASQ_cleaned$c6_explain)
table(ASQ_cleaned$gm1)
table(ASQ_cleaned$gm2)
table(ASQ_cleaned$gm3)
table(ASQ_cleaned$gm4)
table(ASQ_cleaned$gm5)
table(ASQ_cleaned$gm6)
table(ASQ_cleaned$fm1)
table(ASQ_cleaned$fm2)
table(ASQ_cleaned$fm3)
table(ASQ_cleaned$fm4)
table(ASQ_cleaned$fm5)
table(ASQ_cleaned$fm6)
table(ASQ_cleaned$ps1_mc)
table(ASQ_cleaned$ps3_mc)
table(ASQ_cleaned$ps4_mc)
table(ASQ_cleaned$ps6_mc)

table(ASQ_cleaned$pers1)
table(ASQ_cleaned$pers2)
table(ASQ_cleaned$pers3)
table(ASQ_cleaned$pers4)
table(ASQ_cleaned$pers5)
table(ASQ_cleaned$pers6)
table(ASQ_cleaned$pers2_mc)

table(ASQ_cleaned$o1)
table(ASQ_cleaned$o2)
table(ASQ_cleaned$o3)
table(ASQ_cleaned$o4)
table(ASQ_cleaned$o5)
table(ASQ_cleaned$o6)

unique(ASQ_cleaned$o1_explain)
unique(ASQ_cleaned$o2_explain)
unique(ASQ_cleaned$o3_explain)
unique(ASQ_cleaned$o4_explain)
unique(ASQ_cleaned$o5_explain)
unique(ASQ_cleaned$o6_explain)

ASQ_cleaned |> select(age_form, o1, o1_explain) |> filter(o1 == 3)
ASQ_cleaned |> select(age_form, o2, o2_explain) |> filter(o2 == 3)
ASQ_cleaned |> select(age_form, o3, o3_explain) |> filter(o3 == 3)
ASQ_cleaned |> select(age_form, o4, o4_explain) |> filter(o4 == 3)
ASQ_cleaned |> select(age_form, o5, o5_explain) |> filter(o5 == 3)
ASQ_cleaned |> select(age_form, o5, o5_explain) |> filter(o5 == 3)
ASQ_cleaned |> select(age_form, o6, o6_explain) |> filter(o6 == 3)
ASQ_cleaned |> select(age_form, o7, o7_explain) |> filter(o7 == 3)
ASQ_cleaned |> select(age_form, o8, o8_explain) |> filter(o8 == 3)
ASQ_cleaned |> select(age_form, o9, o9_explain) |> filter(o9 == 3)
ASQ_cleaned |> select(age_form, o10, o10_explain) |> filter(o10 == 3)

# check ASQ IDs
ASQ_id <- sort(unique(ASQ_cleaned$survey_id))
master_id <- sort(unique(ID_list$client_id))
ASQ_id[!ASQ_id %in% master_id]
# 11508401 may be 11508901 because there is only one value starting with 11508
# 11714801 (11717201, 11717401, 11717501?)
# 11717001 ?
# 15413801 ?
# 18914801 ?
# 23103401 ?
# 33106101 ?
# 33309901 (33300901?)
# 35609701 (35609401?)
# 35618901 (35613501?)
# 36616601 (36619301?)
# 37111901 (37119901?)
# 50810801 (50810701, 50800901?)
# 53619801 ?
# 53620101 ?
# 54913501 (54913001, 54913601?)
# 55212601 ?

ASQ_check <- ASQ_cleaned |> 
  select(survey_id, interview_date, interview_type) |> 
  left_join(ID_list |> select(client_id, date_of_interview, interview_type) |>
              rename(interview_type_master = interview_type) |> 
              mutate(date_of_interview = lubridate::mdy(date_of_interview)), 
            by = c("survey_id" = "client_id", "interview_date" = "date_of_interview"))

ASQ_check |> filter(interview_type != interview_type_master)

# survey_id interview_date interview_typ…¹ inter…²
# 1  10800201 2014-12-05                   2       1
# 2  20900401 2015-05-06                   1       2
# 3  21300601 2015-01-27                   2       1
# 4  32403901 2016-04-29                   1       3
# 5  34206001 2015-06-14                   2       1
# 6  35105801 2015-10-11                   2       1

# For 34206001, there are two 2015-06-14s in the ASQ dataset, so I guess if interview_type 999
# is set to 1, then the 2015-06-14 for interview_type == 2 should be 2015-10-11. 

# None of the other interview_type that have been changed to 1 has this issue.
# [1] 32103301 32104501 32402901 33705501 34205601
# [6] 34206001 34401401 42006301 42101001


# LENA log checks
x <- unique(LENA_log_cleaned$survey_id)
y <- unique(ID_list$client_id)
x[!x%in%y]

unique(LENA_log_cleaned$status)
class(LENA_log_cleaned$child_dob)
unique(LENA_log_cleaned$lena_id) # not sure what this sis
table(LENA_log_cleaned$interview_type)
table(LENA_log_cleaned$form)
table(LENA_log_cleaned$gender)
table(LENA_log_cleaned$return)

sapply(LENA_log_cleaned |> select(w5:w22), table)
sapply(LENA_log_cleaned |> select(p5:p22), table)
sapply(LENA_log_cleaned |> select(e5:e22), table)

# issues with non-matching dates between master id list and lena data

x <- LENA_cleaned |> select(survey_id, date_of_interview) |> distinct()
y <- ID_list |> select(client_id, date_of_interview) |> rename(survey_id = client_id) |> 
  mutate(date_of_interview = mdy(date_of_interview)) |> distinct()

same_rows <- semi_join(x, y, by = c("survey_id", "date_of_interview"))
diff_rows <- anti_join(x, y, by = c("survey_id", "date_of_interview"))

# only 98 rows match, 531 rows do not match

# check interview place
sapply(LENA_log_cleaned |> select(w5:w22), table)
sapply(LENA_log_cleaned |> select(p5:p22), table)
