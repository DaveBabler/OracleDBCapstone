CREATE OR REPLACE VIEW GRIEF_COUNSELOR_ADOPTION_V
AS
SELECT ALERTID, ALERT_DATE, gca.PETID, FUNC_CHECK_IN_NAME(gca.PETID) as "Deceased Name", DEATH_DATE AS "Date of Passing",  ENCOUNTER_NOTES as "Method of Passing", OWNERID, FUNC_OWNER_NAME(gca.PETID) as "Parent Name", PHONE_PRIMARY as "Parent Phone", FUNC_ALL_OTHER_PETS(gca.PETID) AS "Previously owned pets", COMPLETE_DATE, RESOLUTION_NOTES
FROM GRIEF_COUNSELOR_ALERT gca JOIN ENCOUNTER_HISTORY eh
	ON gca.PETID = eh.PETID
WHERE COMPLETE_DATE IS NULL
AND TRUNC( TO_DATE( REGEXP_SUBSTR(ENCOUNTER_NOTES, '([0-9][0-9]\-[A-Z][A-Z][A-Z]\-[0-9][0-9])'), 'DD-MON-YY')) >= TRUNC(DEATH_DATE);







----TESTING BELOW
SELECT TRUNC( TO_DATE( REGEXP_SUBSTR(ENCOUNTER_HISTORY, '([0-9][0-9]\-[A-Z][A-Z][A-Z]\-[0-9][0-9])'), 'DD-MON-YY'))
FROM ENCOUNTER_HISTORY;



/*CODE TESTING
SELECT TRUNC( TO_DATE( REGEXP_SUBSTR('Owner alerted us of animal death on 03-MAR-08  Addtional notes including cause of death if known follows: Old Age, in sleep', '([0-9][0-9]\-[A-Z][A-Z][A-Z]\-[0-9][0-9])'), 'DD-MON-YY'))
FROM DUAL;*/