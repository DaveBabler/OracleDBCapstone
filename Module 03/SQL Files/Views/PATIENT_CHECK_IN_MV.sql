CREATE MATERIALIZED VIEW PATIENT_CHECK_IN_MV
NOCOMPRESS LOGGING
TABLESPACE "CRM"
PCTFREE 10 PCTUSED 40
REFRESH COMPLETE
START WITH SYSDATE NEXT SYSDATE + 1/24
AS
	SELECT o.OWNERID, p.PET_FIRST_NAME, p.PET_MIDDLE_NAME, o.LAST_NAME, s.SPECIES_NAME, ab.BREED_NAME, RTRIM(FUNC_PET_SIBLINGS(PETID), ', ') AS "Patient's Animal Siblings"
	FROM PET p JOIN OWNER o ON 
		p.ownerid = o.ownerid JOIN  
			ANIMAL_SPECIES s ON
		 		p.SPECIESID = s.SPECIESID JOIN
		 			ANIMAL_BREED ab ON
		 				p.BREEDID = ab.BREEDID
	WHERE IS_LIVING IN ('y', 'Y', '1'); --restricting to show only living pets so a deceased pet is not checked in.