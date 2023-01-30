# Cleaning notes

## 01.29

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

*remaining checks:*
- Check conditional sentences in the form and if that matches up with the data
- Check if age_form matches with the actual date sequence
- Check survey_id (ask Aaron)