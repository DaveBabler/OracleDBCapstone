create or replace TRIGGER pet_facts_trg
AFTER INSERT ON PET
DECLARE
lv_petid int;

--using max PETID as there will never be an insert of a smaller ID and this is a way of getting around a VERY long series of steps

BEGIN
SELECT MAX(PETID)
INTO lv_petid
FROM PET;


INSERT INTO ANIMAL_FACTS
(PETID,	PET_FIRST_NAME,	PET_MIDDLE_NAME, OWNER_LAST_NAME, SPECIESID, BREEDID, GENDERID, COLORING, BIRTH_DATE, TEMPERAMENT_NOTES)

(SELECT PetID, PET_FIRST_NAME, PET_MIDDLE_NAME, o.Last_Name, SPECIESID, BREEDID, GENDERID, COLORING, BIRTH_DATE, TEMPERAMENT_NOTES
FROM PET p JOIN OWNER o USING(OwnerID)
WHERE p.petid = lv_petid
);

END;