CREATE OR REPLACE FUNCTION FUNC_SPECIES(
f_speciesid IN ANIMAL_SPECIES.SPECIESID%TYPE)
RETURN varchar2
AS
	lv_species_name ANIMAL_SPECIES.SPECIES_NAME%TYPE;
BEGIN
	SELECT SPECIES_NAME
	INTO lv_species_name
	FROM ANIMAL_SPECIES
	WHERE SPECIESID = f_speciesid;
RETURN lv_species_name;
EXCEPTION 
	WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('This species id does not exist' ||chr(10)||
	'Are you certain it has been typed in correctly?' );
	RETURN NULL;
END; 

