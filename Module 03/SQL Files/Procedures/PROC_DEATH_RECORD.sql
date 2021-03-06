CREATE OR REPLACE PROCEDURE PROC_DEATH_RECORD(
	p_inoffice IN char,
	p_petid IN PET.PETID%TYPE,
	p_date IN ANIMAL_FACTS.DEATH_DATE%TYPE,
	p_vetid IN VETERINARIAN.VETID%TYPE DEFAULT NULL,
	p_notes IN ENCOUNTER_HISTORY.ENCOUNTER_NOTES%TYPE DEFAULT NULL
	)

AS

lv_isliving PET.IS_LIVING%TYPE;
lv_clobbuilder clob;
BEGIN

	UPDATE ANIMAL_FACTS
	SET DEATH_DATE = p_date
	WHERE PETID =  p_petid;
/*Case below is regarding if the animal died in the office or not */
	CASE 
		WHEN p_inoffice IN ('Y', 'y', '1') THEN
		lv_clobbuilder := CONCAT(CONCAT(CONCAT('In office death recorded notes including cause of death follow: ', p_notes), 'RECORDED: '), p_date);
		INSERT INTO ENCOUNTER_HISTORY(PETID, VETID, ENCOUNTER_DATE_TIME, ENCOUNTER_NOTES)
			VALUES(p_petid, p_vetid, SYSTIMESTAMP, lv_clobbuilder);
		ELSE
			lv_clobbuilder := CONCAT(CONCAT(CONCAT('Owner alerted us of animal death on ', p_date), 'Addtional notes including cause of death if known follows: '), p_notes);
			INSERT INTO ENCOUNTER_HISTORY(PETID, VETID, ENCOUNTER_DATE_TIME, ENCOUNTER_NOTES)
			VALUES(p_petid, NULL, SYSTIMESTAMP, lv_clobbuilder);
	END CASE;

	UPDATE PET 
	SET IS_LIVING = 'N'
	WHERE PETID = p_petid;


  --TWO NULL VALUES RELATE TO DEATH DATE AND MOVED_AWAY. MOVED_AWAY IS NOT RELEVANT IN THIS CASE DEATH DATE WILL BE UPDATED AFTER THIS. 
	INSERT INTO PET_HISTORICAL 
    SELECT PETID, OWNERID, PET_FIRST_NAME, PET_MIDDLE_NAME, SPECIESID, BREEDID, GENDERID, COLORING, BIRTH_DATE, IS_LIVING, PHOTO, TEMPERAMENT_NOTES, NULL,  NULL
	FROM PET
	WHERE PETID = p_petid;
	COMMIT;
	UPDATE PET_HISTORICAL
	SET DEATH_DATE = p_date
	WHERE PETID = p_petid;


COMMIT;
END;



SELECT eh.ENCOUNTERID, p.petid, FUNC_CHECK_IN_NAME(af.petid), p.IS_LIVING, af.DEATH_DATE, eh.ENCOUNTER_NOTES, eh.ENCOUNTER_DATE_TIME
FROM ANIMAL_FACTS af JOIN PET p ON af.PETID = p.PETID 
JOIN ENCOUNTER_HISTORY eh ON p.PETID = eh.PETID



EXECUTE PROC_DEATH_RECORD('Y', 46,  '03-JUL-18', 18, 'Patient crashed during cancer operation, unable to recover');'