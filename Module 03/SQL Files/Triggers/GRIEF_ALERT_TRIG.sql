CREATE OR REPLACE TRIGGER GRIEF_ALERT_TRG
AFTER INSERT ON PET_HISTORICAL
FOR EACH ROW 
WHEN (NEW.IS_LIVING IN ('N','0', 'n'))
--other inserts are irrelevant to this those are for pets that have moved away
DECLARE 
/*will grab from a JOIN of data that comes from 
CRM and CHART areas of the database to avoid having to 
either use a Global Temp table and/to avoid having to deal with 
Mutating tables*/
lv_petid GRIEF_COUNSELOR_ALERT.PETID%TYPE := :NEW.PETID;
lv_ownerid GRIEF_COUNSELOR_ALERT.OWNERID%TYPE;
lv_deathdate date;
lv_phone OWNER.PHONE_PRIMARY%TYPE;

BEGIN 

SELECT o.OWNERID, o.PHONE_PRIMARY, DEATH_DATE
INTO lv_ownerid, lv_phone, lv_deathdate
FROM ANIMAL_FACTS af JOIN PET p
    ON af.PETID = p.PETID JOIN OWNER o 
        ON p.OWNERID = o.OWNERID
WHERE af.PETID = lv_petid;

INSERT INTO GRIEF_COUNSELOR_ALERT (ALERT_DATE, PETID, OWNERID, PHONE_PRIMARY, DEATH_DATE)
			VALUES(SYSDATE, lv_petid, lv_ownerid, lv_phone, lv_deathdate);

END;