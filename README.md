# ASQ cleaning notes

## 01.30

*1. Remove strike-throughs:*

- ID 2: family dropped.
- ID 8: Interview taken twice in the same month (month 2). "two 4 mos. interviews were conducted with this family. First 4mos int. considered baseline." No additional notes.
- ID 21: Interview taken twice in the same month (month 4). "Repeat. Two interviews conducted with this family."
- ID 23: dropped from study.
- ID 92: Dropped from the study.
- ID 329: dropped from study.

*2. Small fixes:*

- Replacing all occurrences of 20 in column c1 with 2
- Replacing certain string values in column gm6 with numerical values and convert the entire column to numeric
- Replacing certain string values in column fm6 with 2 and convert the entire column to numeric
- ~~Replacing all occurrences of 4 in column pers6 with 3~~
- Replacing all occurrences of 3 in columns o2, o3, o4, o5, o6 with 2
- pers3 in month 60 should have multiple choices. pers5 in month 54 should have multiple choices. But it is okay not to have the text response variables since the oldest child was only 48 months.

*3. Clean Communication questions according to multiple choices questions*

- All Communication questions which have multiple choices require at least 3 responses. So I count the number of letters in the open responses, and if it is smaller than 3 (and when the answer to the main question is 1/yes), I reassign 2/sometimes to replace the 1/yes in the main question. 
- For pers2, at least 4 responses are needed. So I count the number of letters in the open responses of pers2, and if it is smaller than 4 (and when the answer to the main question is 1/yes), I reassign 2/sometimes to replace the 1/yes in the main question.

*4. Fix 999s in interview_type based on interview_date*

- ID 30, interview_type changed to 2 because only 3 is available for that survey_id 
- ID 41, 47, 38, 48, 49, 51, 33, 59, 28, interview_type changed to 1 based on earliest date in each survey_id
- ID 51 and 220 (survey_id 34206001) have the exact same date, but not identical date in the other variables. One should be age 22m and the other 24m. The baseline date should be incorrect but not sure what the replacement date value should be. The 999 in interview_type is currently set to be 1 because 22m < 24m.

*5. Check conditional sentences in the form and if that matches up with the data*

- There are conditional statements after certain sections in the ASQ form such as if item B is yes then mark item A as yes, because the behavior shown in A may be considered the same or nested in that shown in B. I apply those checks to the data cleaning. Specifically:

  - fm month 2: if fm5 is yes then mark fm1 as yes
  - gm month 8: if gm5 is yes/sometimes then mark gm1 as yes
  - fm month 8: if fm6 is yes/sometimes then mark fm2 as yes
  - fm month 9: if fm5 is yes/sometimes then mark fm2 as yes
  - fm month 10: if fm5 is yes/sometimes then mark fm2 as yes
  - fm month 12: if fm4 is yes/sometimes then mark fm2 as yes
  - ps month 12: if ps5 is yes/sometimes then mark ps4 as yes
  - ps month 14: if ps2 is yes/sometimes then mark ps1 as yes
  - ps month 16: if ps5 is yes then mark ps1 as yes
  - ps month 18: if ps6 is yes/sometimes then mark ps3 as yes
  - gm month 22: if gm6 is yes/sometimes then mark gm1 as yes
  - gm month 24: if gm6 is yes/sometimes then mark gm2 as yes
  - gm month 27: if gm6 is yes/sometimes then mark gm1 as yes
  - gm month 30: if gm5 is yes/sometimes then mark gm2 as yes

*6. change 1/2/3 from numeric responses to text labels*

- In the domain specific variables, 1/2/3 are actually labelled as yes/sometimes/no yet since the variables are technically not on a ratio scale, but an ordinal one
- For analysis purposes (e.g., if it makes sense to add up these numbers), we can recode them so that yes reflects a larger number.
- In the general observations, 1/2 are coded as yes/no.

*remaining checks:*

- Check survey_id (ask Aaron)


## 02.05

*1. Create developmental area scores*
- Recode Yes/Sometimes/No to 10/5/0 according to the ASQ scoring rules
- Create sum scores for each developmental area (Cases with at least one NA are omitted in creating the composite score because in the ASQ technical report, they also excluded cases with at least one NA in their analysis.)
- Extract the normative means and SDs from Table 18 in the ASQ technical report
- Create z-scores for each developmental area score based on the normative curve for that developmental stage

## 02.14

*1. Check ASQ survey_id*

- The following IDs in ASQ cannot be found in the Mother ID list. I searched for the first 4 digits and the ones with a question mark do not even have a likely match in the Mother ID list.

  - 11508401 may be 11508901 because there is only one value starting with 11508
  - 11714801 (11717201, 11717401, 11717501?)
  - 11717001 ?
  - 15413801 ?
  - 18914801 ?
  - 23103401 ?
  - 33106101 ?
  - 33309901 (33300901?)
  - 35609701 (35609401?)
  - 35618901 (35613501?)
  - 36616601 (36619301?)
  - 37111901 (37119901?)
  - 50810801 (50810701, 50800901?)
  - 53619801 ?
  - 53620101 ?
  - 54913501 (54913001, 54913601?)
  - 55212601 ?

- The following ASQ ids have mismatches with the Mother ID list in terms of the interview_type.

- For 34206001, there are two 2015-06-14s in the ASQ dataset, so I guess if interview_type 999 is set to 1, then the 2015-06-14 for interview_type == 2 should be 2015-10-11. 

- None of the other interview_type that have been changed to 1 has this issue. 32103301 32104501 32402901 33705501 34205601 34206001 34401401 42006301 42101001


| survey_id | interview_date | interview_type | interview_type_master |
|----------:|:--------------:|---------------:|----------------------:|
|  10800201 |   2014-12-05   |              2 |                     1 |
|  20900401 |   2015-05-06   |              1 |                     2 |
|  21300601 |   2015-01-27   |              2 |                     1 |
|  32403901 |   2016-04-29   |              1 |                     3 |
|  34206001 |   2015-06-14   |              2 |                     1 |
|  35105801 |   2015-10-11   |              2 |                     1 |

## 02.21

- For 34206001, there are two 2015-06-14s in the ASQ dataset, the date 2015-06-14 for interview_type == 2 is changed tod 2015-10-11. 

- Replace interview_type with mismatches from the master ID list using values from the ID list

- Manually fix several ID mismatches according to Aaron's suggestions

## 02.25

- Fix all ID mismatches (see word document commented by Aaron)

- Remove 6 rows that are very likely unconsented cases (which do not match with the master dataset)

# LENA cleaning Notes

## 02.28

- The following ids are in LENA but not in the master ID list:
  - 112415 (?)
  - 11513901 (51513901?) 
  - 16201 (?)
  - 18914801 (also an unclear case in ASQ)
  - 33202201 (33202101 / 33202301?)
  - 33302002 (33302001?)
  - 36107101 (31607101?)
  - 36612701 (36612201? 36612901? 31002701?)
  - 55212601 (also an unclear case in ASQ)
  - 7000101 (?)
  - test
  - Sandra

- The following cases in LENA have different birth dates from the master ID list:
 	`id`	`birthdate_lena`	`birthdate_master` 
1	53404401	4/12/2013	3/12/2013
2	33317701	10/25/2014	5/16/2014
3	41116501	10/14/2014	10/13/2014
4	35609401	3/11/2015	11/24/2014
5	33420701	11/1/2015	1/1/2015
6	33601301	3/26/2015	3/16/2015
7	34205601	5/18/2015	4/7/2015
8	56017101	5/17/2015	5/7/2015
9	52905301	6/14/2015	6/4/2015
10	41005401	8/22/2015	7/21/2015
11	53103201	7/19/2015	7/29/2015
12	36612201	7/2/2015	9/2/2015
13	33509901	11/2/2015	11/30/2015
14	33309501	3/31/2016	4/2/2016
15	51018701	11/15/2016	9/2/2016
16	112415	11/24/2015	NA
17	11513901	8/19/2015	NA
18	16201	12/30/2014	NA
19	18914801	11/12/2015	NA
20	33202201	12/27/2014	NA
21	33302002	4/2/2013	NA
22	36107101	7/15/2015	NA
23	36612701	11/10/2015	NA
24	55212601	4/4/2015	NA
25	NA	10/15/2015	NA
26	NA	4/13/2016	NA
27	7000101	9/1/2015	NA

## 03.05

*1. Clean LENA log:*

- The following IDs are in LENA log but not the ID list: 
  - 53906401 (54616401?)
  - 11513901 (51513901?)
  - 32011901 (22111901?)
  - 50810801 (changed to 50810701 based on ASQ notes)
  - 18914801 (non-consented case)
  - 56416401 (54616401?)
  - 22110101 (10201101?)
  
- Removed rows that should be dropped
- Transform numeric values to their corresponding character values
- Recode values like "1, 2", "1,2", "1,2,3", "1,3" into the actual literal meanings
- Pivot this dataset to long format and match its datetime with the datetime in LENA and ADEX datasets

*2. Matching LENA log with LENA dataset:*

- There is a huge issue of non-matching between survey & dates in LENA data and those in the master ID list: only 98 rows match, 531 rows do not match. Many dates in the LENA data are completely off (maybe a systematic error in the recording device).

- I have written codes to filter the LENA dataset after joining it with the LENA log data (which is joined with the ID master to get the recording dates). But this would only take effect if we get the dates correct.

## 03.25

- *Question*: How should we deal with those with multiple days of recordings in LENA pro but only one log survey indicating when to delete? Should I delete the same time period in all consecutive dates?

- Assuming the dates in the LENA dataset are completely unreliable and should not be used, we need to figure out what the most possible interview type is for each particular date. Therefore, a given id assigned a particular interview type can be associated with multiple consecutive dates (recorded by LENA pro). Essentially, I am assigning a new interview_type to the LENA dates from the ID list where the date gap is below 30 days.

- The following are the IDs that do not have a match between LENA data and the LENA log data (after merging it with the ID list), for various reasons:

| ID        | Status                                                              | Gap                 |
|-----------|----------------------------------------------------------------------|---------------------|
| 22110201  | In ID list but not in LENA log (no need to match?)                   |                     |
| 36614401  | In ID list but not in LENA log (no need to match?)                   |                     |
| 55314701  | In ID list but not in LENA log (no need to match?)                   |                     |
| 11717501  | In ID list but not in LENA log (no need to match?)                   |                     |
| 36713401  | In ID list but not in LENA log (no need to match?)                   |                     |
| 32012001  | In ID list but not in LENA log (no need to match?)                   |                     |
| 36811401  | In ID list but not in LENA log (no need to match?)                   |                     |
| 20914601  | No match within reasonable date_gap                                   | Gap: 241/244 days   |
| 42007001  | No match within reasonable date_gap                                   | Gap: 48-49 days     |
| 55312301  | No match within reasonable date_gap                                   | Gap: 366/388 days   |
| 50004101  | No match within reasonable date_gap                                   | Gap: 230 days       |
| 31002701  | No match within reasonable date_gap                                   | Gap: 145/148/149 days|
| 50810901  | No match within reasonable date_gap                                   | Gap: 35/62/63 days  |
| 36612201  | No match within reasonable date_gap                                   | Gap: 123/124/129 days|
| 54913601  | No match within reasonable date_gap                                   | Gap: 141/142 days   |
| 112415    | Not in ID list                                                      |                     |
| 33202201  | Not in ID list                                                      |                     |
| 36612701  | Not in ID list                                                      |                     |
| 11513901  | Not in ID list                                                      |                     |
| 33302002  | Not in ID list                                                      |                     |
| 36107101  | Not in ID list                                                      |                     |
| 16201     | Not in ID list                                                      |                     |
| 7000101   | Not in ID list                                                      |                     |

## 04.09

- Clean IDs in LENA data: 11513901 ~ 51513901, 33202201 ~ 33202101, 33302002 ~ 33302001, 36107101 ~ 31607101; remove 112415, 16201, 18914801, 36612701, 55212601, 7000101

- Clean birth dates using the correct ones from the master ID list

- Replace LENA interview dates (which is completely unreliable) with interview_type and date_of_interview in ID_list

*Remaining issues:*
- There are cases in LENA where there isn't a single match with any of the interview date in the master ID list. And the number of these cases depends on the threshold. Given the number of these cases, I would choose 60 days as the threshold and manually try to figure out the 6 problematic cases. From a first glance, there are two cases caused by apprarent typo in the master ID list (2017 instead of 2007)

30 days as the threshold
[1] 21300601 22111901 22117301 31607101 32103301 32400101 32402901 33200801
[9] 33202101 33209201 33504801 35105801 35418201 37218501 41102501 41111501
[17] 41415201 42101601 51018701 53106701 53110101 53514301 55114001 55418101

60 days as the threshold
[1] 33202101 35105801 41102501 42101601 51018701 55418101


- Then, before removing rows based on what parents indicated to drop, we may need to figure out which exact day in a multi-day sequence they are referring to. However, there is no reliable way to detect which day is the actual interview day if there are consecutive days of recording. I would consider filtering out the dates indicated by the parents to drop *for all the days associated with one interview type*. By doing so, we definitely filter out the drop-out periods for the correct day, and it wouldn't hurt much for the other consecutive days since there were not supposed to be recordings on these days and any information we have is additional. 

## 04.14

*LENA:*
- remove survey_id == 35105801 & date_of_interview == "2015-06-12", because the family did 4 LENA recordings and the first one was a pre-intervention recording and needs to be removed from the dataset.

- manually clean all the ids that do not have a match based on the 60-day fuzzy matching rule

- Link LENA log with the LENA dataset to remove the time periods indicated by parents to drop. There are altogether 27 ids that have something to drop, and 934 5-min clips (out of 39675, 2.4%) should be dropped.

- Still need to manually check one more case 33420701 (only two interview dates available in the ID list): 2018-05-01 in LENA versus 2017-03-20 or 2017-08-09 in the ID list

*ADEX:*
- I applied the same data cleaning process for LENA dataset to the ADEX dataset, and all cleaning steps have been successfully replicated and implemented.

- One issue is that the raw LENA and ADEX files have different number of rows in the first place (LENA: 40435, ADEX: 40474). I suspect it's because the parsing of the ITS file is more accurate than the output directly from the LENA software, but I am not sure. 

- A maybe related issue is that some of the ADEX timestamps do not perfectly match with the LENA ones, on the "seconds" level. Maybe the ITS files contain more accurate information about the timestamps.

## 04.23

- Although there are only very few cases when other people are present when parents are present, there are many cases when only other people are present. These people could be relatives, but in the original excel file, it says "Other person. No need to specify. Enter only numeric values." So there is no way for us to know who these people are.

| Who is present in the household?            | Prop    | Freq |
| :----------------------------------------- | :-----: | ---- |
| Father                                     | 0.022   | 54   |
| Father and other person                     | 0.001   | 2    |
| Mother                                     | 0.262   | 630  |
| Mother and father                          | 0.3     | 721  |
| Mother and other person                     | 0.005   | 13   |
| Mother, father, and other person            | 0.006   | 15   |
| Other person                               | 0.403   | 970  |



## 05.01

- In both LENA and ADEX, I dropped time periods where only "other person" was present for ethical reason listed in the IRB

- Remove incomplete non-5-min clips from LENA (1092/39568 = 2.7%) and ADEX (616/39592 = 1.6%)

- 20.5% of all segments have at least 15 minutes of consecutive no-meaningful-interaction, and 35.3% of these no-meaningful-interaction periods happened in between midnight and 6am. Between midnight and 6am, 65% of the segments are a part of at least 15 minutes of consecutive no-meaningful-interaction chunks.

- We should first determine whether to remove a certain period of data for all families. If so, we need to a period (e.g., midnight to 6am; see informational graphs in the Word doc). Given the sparsity of no-meaningful-interaction chunks, we can maybe assume that all activities during the day are somewhat meaningful to the baby's development (even long periods of no interaction). Then we divide the summary indices (e.g., sum of the word count) by the length of this common period.

- If we are still interested in the limited interactions happening during night (e.g., when babies woke up and parents had to talk a little bit), we can create two sets of summary indices, one during the day, and one during the night. 
