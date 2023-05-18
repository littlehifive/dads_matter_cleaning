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
y <- LENA_log_cleaned_long |> select(survey_id, date_of_interview) |> distinct()

same_rows <- semi_join(x, y, by = c("survey_id", "date_of_interview"))
diff_rows <- anti_join(x, y, by = c("survey_id", "date_of_interview"))


a <- unique(x$survey_id)
b <- unique(y$survey_id)
b[!b %in% a]
a[!a %in% b]

# only 98 rows match, 531 rows do not match

# check interview place
sapply(LENA_log_cleaned |> select(w5:w22), table)
sapply(LENA_log_cleaned |> select(p5:p22), table)


# check dates in LENA pro data
x <- LENA_cleaned |> select(survey_id, date_of_interview) |> distinct() |> 
  group_by(survey_id) |> arrange(survey_id, date_of_interview)

x <- x |> mutate(interview_sequence = 1:n())

y <- ID_list |> rename(survey_id = client_id) |> select(survey_id, date_of_interview, interview_type) |> 
  distinct() |> group_by(survey_id) |> arrange(survey_id, date_of_interview) |> mutate(date_of_interview = lubridate::mdy(date_of_interview))

test <- x |> left_join(y, by = c("survey_id"))

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

test_s <- test |> 
  select(survey_id, date_of_interview.x, date_of_interview.y, date_gap, interview_type_new) |>
  filter(interview_type_new != "Not matched")

test_s <- test_s |> 
  arrange(survey_id, date_of_interview.x, interview_type_new) |> 
  group_by(survey_id, interview_type_new) |> 
  mutate(same_interview_date_sequence = paste("day", 1:n()))

a <- unique(test_s$survey_id)
b <- unique(LENA_cleaned$survey_id)
b[! b%in% a]

# check cases with no match with any of the interview types in ID_list
temp1 <- test |>
  filter(interview_type_new == "Not matched") %>%
  group_by(survey_id, date_of_interview.x) %>%
  summarise(count_not_matched = n()) |> 
  filter(count_not_matched == 3)

temp2 <- test |> filter(survey_id %in% temp1$survey_id & date_of_interview.x %in% temp1$date_of_interview.x)
unique(temp2$survey_id)

# 30 as the threshold
# [1] 21300601 22111901 22117301 31607101 32103301 32400101 32402901 33200801
# [9] 33202101 33209201 33504801 35105801 35418201 37218501 41102501 41111501
# [17] 41415201 42101601 51018701 53106701 53110101 53514301 55114001 55418101

# 60 as the threshold
# [1] 33202101 35105801 41102501 42101601 51018701 55418101

# check how many survey_ids need to drop certain time periods

test <- LENA_cleaned |> filter(survey_id %in% unique(LENA_log_cleaned_long_subset$survey_id))

unique(LENA_log_cleaned_long_subset$survey_id)


# ADEX cleaning checks
a <- sort(unique(ADEX_cleaned$child_child_id))
b <- sort(unique(LENA_raw$Id))
a == b

a <- ADEX_cleaned |> filter(child_child_id == "C016")
b <- LENA_raw |> filter(Id == "C016")
View(a)
View(b)

test <- LENA_cleaned |> 
  select(id, survey_id, timestamp, date_of_interview, 
         interview_type, same_interview_date_sequence) |> 
  rename(lena_id = id) |> 
  select(-timestamp) |> 
  distinct()

test2 <- ADEX_cleaned |> 
  rename(lena_id = child_child_id, 
         timestamp = clock_time_utc) |> 
  mutate(timestamp = lubridate::mdy_hms(timestamp)) |> 
  mutate(date_of_interview = lubridate::date(timestamp)) |> 
  left_join(
    test, 
    by = c("lena_id", "date_of_interview"),
    relationship = "many-to-many"
  )

x <- test2 |> select(date_of_interview:interview_type_new)
x |> distinct() |> View()

# visualize who is in the household during the interview
ggplot(LENA_log_cleaned_long) +
  aes(x = timestamp, y = p, fill = p, colour = p) +
  geom_tile() +
  scale_fill_hue(direction = 1) +
  scale_color_hue(direction = 1) +
  labs(x = "Timestamp", y = "Who is present in household?") +
  theme_minimal()

prop.table(table(LENA_log_cleaned_long$p)) |> round(3)

# get average word count across timestamps (regardless of actual date), grouped by interview_type
temp <- LENA_cleaned |> select(survey_id, timestamp, interview_type,
                               meaningful:silence, awc_actual, ctc_actual, cvc_actual)

temp <- temp |> 
  mutate_at(vars(meaningful, distant, tv, noise, silence), 
            function(x){
              as.numeric(lubridate::minute(x)) * 60 + 
                as.numeric(lubridate::second(x))
            }) |> 
  mutate(timestamp_s = data.table::as.ITime(timestamp))

temp_s <- temp |> group_by(interview_type, timestamp_s) |> 
  summarise_at(vars(meaningful, distant, tv, noise, silence, 
                    awc_actual, ctc_actual, cvc_actual),
               function(x){mean(x, na.rm = T)})

temp_s$timestamp_s <- as.POSIXct(temp_s$timestamp_s)
temp_s$interview_type <- paste0("Interview Type ", temp_s$interview_type)

temp_s1 <- temp_s |> select(-c(awc_actual, ctc_actual, cvc_actual)) |> 
  pivot_longer(meaningful:silence, names_to = "type", values_to = "seconds")

ggplot(temp_s1, aes(x = timestamp_s, y = seconds, color = type)) +
  geom_point(alpha = 0.2) + 
  geom_smooth(fill = NA) +
  scale_x_datetime(labels = scales::time_format("%H:%M:%S")) +
  facet_wrap(~ interview_type, nrow = 3) + 
  scale_color_brewer(palette = "Set1") + 
  theme_bw() + 
  labs(x = "Time during the day", y = "Number of seconds in a 5-min segment",
       color = "Segment Type")

temp_s2 <- temp_s |> select(interview_type, timestamp_s, awc_actual, ctc_actual, cvc_actual)

p1 <- ggplot(temp_s2, aes(x = timestamp_s, y = awc_actual, color = interview_type)) +
  geom_point(alpha = 0.2) + 
  geom_smooth(fill = NA) +
  scale_x_datetime(labels = scales::time_format("%H:%M:%S")) +
  scale_color_brewer(palette = "Set2") + 
  theme_bw() + 
  labs(x = "Time during the day", y = "", title = "Average count of adult words in a 5-min segment",
       color = "Interview Time");p1

p2 <- ggplot(temp_s2, aes(x = timestamp_s, y = ctc_actual, color = interview_type)) +
  geom_point(alpha = 0.2) + 
  geom_smooth(fill = NA) +
  scale_x_datetime(labels = scales::time_format("%H:%M:%S")) +
  scale_color_brewer(palette = "Set2") + 
  theme_bw() + 
  labs(x = "Time during the day", y = "", title = "Average count of conversational turns in a 5-min segment",
       color = "Interview Time");p2

p3 <- ggplot(temp_s2, aes(x = timestamp_s, y = cvc_actual, color = interview_type)) +
  geom_point(alpha = 0.2) + 
  geom_smooth(fill = NA) +
  scale_x_datetime(labels = scales::time_format("%H:%M:%S")) +
  scale_color_brewer(palette = "Set2") + 
  theme_bw() + 
  labs(x = "Time during the day", y = "", title = "Average count of child vocalizations in a 5-min segment",
       color = "Interview Time");p3

gridExtra::grid.arrange(p1, p2, p3, nrow = 3)

# check consecutive no-meaningful categories (>= 15 mins)
temp <- temp |> 
  group_by(survey_id) |> 
  mutate(no_meaningful_noninteraction = case_when(
    # Check if the current row and the previous two rows have duration 0
    meaningful == 0 & lag(meaningful) == 0 & lag(meaningful, 2) == 0 ~ 1,
    
    # Check if the current row and the next two rows have duration 0
    meaningful == 0 & lead(meaningful) == 0 & lead(meaningful, 2) == 0 ~ 1,
    
    # Check if the current row and the previous and next rows have duration 0
    meaningful == 0 & lag(meaningful) == 0 & lead(meaningful) == 0 ~ 1,
    
    # In all other cases, assign 0
    TRUE ~ 0
  ))

temp$timestamp_s <- as.POSIXct(temp$timestamp_s)

temp$no_meaningful_noninteraction_f <- factor(temp$no_meaningful_noninteraction,
                                            levels = c(1,0))

ggplot(temp) +
  aes(
    x = timestamp_s,
    y = factor(survey_id),
    colour = no_meaningful_noninteraction_f
  ) +
  geom_point(size = 0.5, alpha = 0.6) +
  theme_minimal() +
  labs(x = "Time during the day", y = "",
       color = "No meaningful interaction for at least 15 minutes")


x <- temp |> 
  group_by(survey_id) |> 
  summarise(p_no_meaningful_noninteraction = sum(no_meaningful_noninteraction)/n())

hist(x$p_no_meaningful_noninteraction,
     main = "Proportion of the segments having\nat least 15 minutes of no meaningful interaction\n(Mean = 0.18, SD = 0.16)",
     xlab = "")
mean(x$p_no_meaningful_noninteraction)

prop.table(table(temp$no_meaningful_noninteraction))

temp$no_meaningful_noninteraction_sleep <- ifelse(
  temp$no_meaningful_noninteraction == 1 & 
    temp$timestamp_s < as.POSIXct("2023-05-02 06:00:00", tz = "GMT") & 
    temp$timestamp_s > as.POSIXct("2023-05-02 00:00:00", tz = "GMT"),
  1,
  0
)

table(temp$no_meaningful_noninteraction_sleep)
table(temp$no_meaningful_noninteraction)

2791/7900

prop.table(table(temp |> 
                   filter(timestamp_s < as.POSIXct("2023-05-02 06:00:00", tz = "GMT") & 
                            timestamp_s > as.POSIXct("2023-05-02 00:00:00", tz = "GMT")) |>  
                   pull(no_meaningful_noninteraction)))

# check correlations across indices under different time cutoffs
temp_11_to_6 <- LENA_indices_cleaned_11_to_6 |> 
  mutate(timestamp_11_to_6 = ifelse(timestamp_11_to_6 == 1, "night", "day")) |> 
  pivot_wider(names_from = timestamp_11_to_6,
              names_glue = "{.value}_{timestamp_11_to_6}",
              values_from = meaningful:ava_std_score) |> 
  ungroup() |> 
  select(-c(id, birthdate, interview_type))

names(temp_11_to_6)[3:20] <- paste0(names(temp_11_to_6)[3:20], "_11_to_6")

temp_0_to_6 <- LENA_indices_cleaned_0_to_6 |> 
  mutate(timestamp_0_to_6 = ifelse(timestamp_0_to_6 == 1, "night", "day")) |> 
  pivot_wider(names_from = timestamp_0_to_6,
              names_glue = "{.value}_{timestamp_0_to_6}",
              values_from = meaningful:ava_std_score) |> 
  ungroup() |> 
  select(-c(id, birthdate, interview_type))

names(temp_0_to_6)[3:20] <- paste0(names(temp_0_to_6)[3:20], "_0_to_6")

temp_1_to_6 <- LENA_indices_cleaned_1_to_6 |> 
  mutate(timestamp_1_to_6 = ifelse(timestamp_1_to_6 == 1, "night", "day")) |> 
  pivot_wider(names_from = timestamp_1_to_6,
              names_glue = "{.value}_{timestamp_1_to_6}",
              values_from = meaningful:ava_std_score) |> 
  ungroup() |> 
  select(-c(id, birthdate, interview_type))

names(temp_1_to_6)[3:20] <- paste0(names(temp_1_to_6)[3:20], "_1_to_6")

temp <- temp_11_to_6 |> 
  left_join(temp_0_to_6, by = c("survey_id", "date_of_interview")) |> 
  left_join(temp_1_to_6, by = c("survey_id", "date_of_interview"))


# Libraries
library(ellipse)
library(RColorBrewer)

# Use of the mtcars data proposed by R
x <- temp |> select(contains("_day")) |> 
  mutate_all(as.numeric)

x <- x[, sort(colnames(x))]

data <- cor(x,
            use = "complete.obs")

# Build a Pannel of 100 colors with Rcolor Brewer
my_colors <- brewer.pal(5, "Spectral")
my_colors <- colorRampPalette(my_colors)(100)

# Order the correlation matrix
# ord <- order(data[1, ])
# data_ord <- data[ord, ord]
plotcorr(data , col=my_colors[data_ord*50+50] , mar=c(1,1,1,1)  )


test <- ADEX_indices_cleaned_0_to_6 |> 
  filter(timestamp_0_to_6 == 0)

par(mfrow = c(2, 1))
hist(test$fan_word_count, breaks = seq(0,400,10), main = "", xlab = "Female Word Count",
     xlim = c(0,400))  
hist(test$man_word_count, breaks = seq(0,400,10), main = "", xlab = "Male Word Count",
     xlim = c(0,400))  


hist(test$fan, breaks = seq(0,300,5), main = "", xlab = "Female Duration",
     xlim = c(0,300))  
hist(test$man, breaks = seq(0,300,5), main = "", xlab = "Male Duration",
     xlim = c(0,300))  


par(mfrow = c(3, 1))
hist(test$awc, main = "", xlab = "Adult Word Counts")
hist(test$turn_count, main = "", xlab = "Conversational Turns")
hist(test$child_voc_count, main = "", xlab = "Count of Child Vocalizations")


x <- ADEX_cleaned |>
  select(survey_id, interview_type) |>
  distinct() |> 
  mutate(interview_type = as.numeric(interview_type)) |> 
  group_by(survey_id) |> 
  summarise(sum_interview_type = sum(interview_type, na.rm = T))

