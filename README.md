# Cleaning notes

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
- Replacing all occurrences of 4 in column pers6 with 3
- Replacing all occurrences of 3 in columns o2, o3, o4, o5, o6 with 2
- pers3 in month 60 should have multiple choices. pers5 in month 54 should have multiple choices. But it is okay not to have the text response variables since the oldest child was only 48 months.

*3. Clean Communication questions according to multiple choices questions*
- All Communication questions which have multiple choices require at least 3 responses. So I count the number of letters in the open responses, and if it is smaller than 3 (and when the answer to the main question is 1/yes), I reassign 2/sometimes to replace the 1/yes in the main question. 
- For pers2, at least 4 responses are needed. So I count the number of letters in the open responses of pers2, and if it is smaller than 4 (and when the answer to the main question is 1/yes), I reassign 2/sometimes to replace the 1/yes in the main question.

*4. Fix 999s in interview_type based on interview_date*
- ID 30, interview_date changed to 2 because only 3 is available for that survey_id 
- ID 41, 47, 38, 48, 49, 51, 33, 59, 28, interview_date changed to 1 based on earliest date in each survey_id
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
