CREATE OR REPLACE FUNCTION FUNC_CHARTHEAD(
	f_petid IN ANIMAL_FACTS.PETID%TYPE)
RETURN clob
AS
 

	lv_animalname varchar(3000) := NULL;
	lv_gender ANIMAL_GENDER.GENDER_NAME%TYPE := NULL;
	lv_species_name ANIMAL_SPECIES.SPECIES_NAME%TYPE := NULL;
	lv_breed_name ANIMAL_BREED.BREED_NAME%TYPE := NULL;
	lv_temperament clob := NULL;
	lv_species_breed clob := NULL;
	lv_age  varchar(2000) := NULL;
	lv_charthead clob := NULL;
	lv_chartsibs clob :=NULL;
	lv_chartline varchar2(100) := CHR(13)||'-----------------------------------------------'||CHR(13);

BEGIN
	SELECT FUNC_CHART_NAME(PETID), FUNC_SPECIES(SPECIESID), FUNC_BREED(BREEDID), FUNC_GENDER(GENDERID), TO_CHAR(TRUNC(MONTHS_BETWEEN(SYSDATE,BIRTH_DATE)/12, 1)), TO_CLOB( TEMPERAMENT_NOTES), FUNC_ALL_SIBLING_BREEDS(PETID)
	INTO lv_animalname, lv_species_name, lv_breed_name, lv_gender, lv_age, lv_temperament, lv_chartsibs
	FROM ANIMAL_FACTS 
	WHERE PETID = f_petid;

	lv_animalname := 'Animal Name: ' || lv_animalname ||' ' ||CHR(13);
	lv_species_breed:= lv_gender||' : '||lv_species_name||' : '||  lv_breed_name||' ' ||CHR(13);
	lv_age := 'Age: '||lv_age||' years old.'||' ' ||CHR(13);
	lv_temperament := 'Animal''s general demeanor as observed is: '||' ' ||CHR(13)||lv_temperament||' ' ||CHR(13);

	lv_charthead := lv_animalname||lv_species_breed||lv_age||lv_temperament||lv_chartline||lv_chartsibs||lv_chartline; 



RETURN lv_charthead;
EXCEPTION 
	WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('This chart id/pet id does not exist' ||chr(10)||
	'Are you certain it has been typed in correctly?' );
END; 
