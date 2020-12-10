USE mimic_iii_project;

CREATE VIEW mortality_analysis_vw 
AS

WITH dx_query AS 
(SELECT LEFT(YEAR(a.ADMITTIME),3) AS DECADE, b.ICD9_CODE, count(b.ICD9_CODE) as dx_count, c.gender
FROM admissions a
JOIN diagnoses_icd b ON a.HADM_ID=b.HADM_ID
JOIN PATIENTS c ON a.SUBJECT_ID=c.SUBJECT_ID
WHERE a.HOSPITAL_EXPIRE_FLAG = 1
GROUP BY LEFT(YEAR(a.ADMITTIME),3), b.ICD9_CODE, c.gender
ORDER BY LEFT(YEAR(a.ADMITTIME),3), c.gender
)

, days_query AS
(SELECT DISTINCT LEFT(YEAR(a.ADMITTIME),3) AS DECADE, ROUND(AVG(datediff(a.DISCHTIME, a.ADMITTIME)),2) avg_days_since_admission, b.gender
FROM admissions a
JOIN PATIENTS b ON a.SUBJECT_ID=b.SUBJECT_ID
WHERE HOSPITAL_EXPIRE_FLAG = 1
GROUP BY LEFT(YEAR(a.ADMITTIME),3), b.gender
ORDER by LEFT(YEAR(a.ADMITTIME),3), b.gender
)

select a.decade, a.gender, a.avg_days_since_admission, c.short_title, b.dx_count
from days_query a
JOIN dx_query b on a.decade=b.decade AND b.gender=a.gender
JOIN D_ICD_DIAGNOSES c ON b.ICD9_CODE=c.ICD9_CODE
WHERE b.dx_count = (SELECT MAX(dx_count) FROM dx_query WHERE decade=b.decade AND gender=b.gender)
ORDER BY a.decade,a.gender;