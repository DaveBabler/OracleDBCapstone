CREATE OR REPLACE FUNCTION FUNC_ALL_SIBLING_BREEDS(
	f_petid IN int)  
RETURN clob
AS

	lv_ownerid OWNER.OWNERID%TYPE; 
	lv_sibling_name varchar2(500) := NULL;
	lv_sibling_species varchar2(500) :=NULL;
	lv_sibling_breed varchar2(500) :=NULL;
	--using clobs not varchar because we have no clue how many animals someone will have over a lifetime
	
	lv_other_pets clob :=NULL;  --will be the builder each data type will get concated in there.
	lv_avian clob := NULL;
	lv_canine clob := NULL;
	lv_feline clob := NULL;
	lv_reptile clob := NULL;
	lv_aviancount int :=0;
	lv_caninecount int := 0;
	lv_felinecount int := 0;
	lv_reptilecount int :=0;

  	lv_loop int :=0; 

  	CURSOR cur_otherpets IS
	SELECT s.speciesID, ab.BREED_NAME, ab.breedid, s.SPECIES_NAME 
	FROM ANIMAL_BREED ab JOIN ANIMAL_SPECIES S
	ON ab.SPECIESID = s.SPECIESID
	WHERE  ab.BREEDID 
	 = ANY (SELECT BREEDID
			FROM PET
			WHERE PETID <> f_petid
			AND OWNERID = lv_ownerid
			AND IS_LIVING IN ('1', 'y', 'Y'));
BEGIN
	
	SELECT OWNERID
	INTO lv_ownerid 
	FROM PET
	WHERE PETID = f_petid;

	FOR rec_otherpets IN cur_otherpets LOOP 

	CASE 
		WHEN  rec_otherpets.speciesID = 1 THEN 
			lv_aviancount := lv_aviancount + 1;
			lv_avian:= lv_avian || rec_otherpets.BREED_NAME||', ';
		WHEN rec_otherpets.speciesID = 2 THEN 
			lv_caninecount := lv_caninecount + 1;
			lv_canine:= lv_canine || rec_otherpets.BREED_NAME||', ';
		WHEN rec_otherpets.speciesID = 3 THEN 
			lv_felinecount := lv_felinecount + 1;
			lv_feline:= lv_feline || rec_otherpets.BREED_NAME||', ';
		WHEN rec_otherpets.speciesID = 4 THEN 
			lv_reptilecount := lv_reptilecount + 1;
			lv_reptile:= lv_reptile || rec_otherpets.BREED_NAME||', ';
		ELSE NULL;
	END CASE;
	lv_loop := lv_loop + 1;
	END LOOP;

	CASE
	WHEN lv_loop IS NULL OR lv_loop = 1 THEN
		lv_other_pets := 'No other (known) pets owned by this owner currently.';
	ELSE 
		lv_other_pets := 'This animal has pet-siblings with the following species/breeds:' ||' '|| CHR(10);
		IF lv_aviancount > 0
			THEN lv_other_pets := lv_other_pets || lv_aviancount||' birds of the following breeds: '||lv_avian||' '|| CHR(10);
		END IF;
		IF lv_caninecount > 0 
			THEN lv_other_pets := lv_other_pets || lv_caninecount||' dogs of the following breeds: '||lv_canine||' '|| CHR(10);
		END IF;
		IF lv_felinecount > 0 
			THEN lv_other_pets := lv_other_pets ||lv_felinecount||' cats of the following breeds: '||lv_feline||' '|| CHR(10);
		END IF;
		IF lv_reptilecount > 0 
			THEN lv_other_pets := lv_other_pets ||lv_reptilecount||' reptiles of the following breeds: '||lv_reptile||' '|| CHR(10);
		END IF;
		lv_other_pets := lv_other_pets||'End of other known animal siblings for this patient.';

	END CASE;
RETURN lv_other_pets;
END;

