CREATE OR REPLACE FUNCTION FUNC_BREED(
	f_breedid IN ANIMAL_BREED.BREEDID%TYPE)
RETURN varchar2
AS
lv_breed_name ANIMAL_BREED.BREED_NAME%TYPE;
lv_except varchar2(100) 'No Breed Found';


BEGIN
	SELECT BREED_NAME
	INTO lv_breed_name
	FROM ANIMAL_BREED
	WHERE BREEDID = f_breedid;

RETURN  lv_breed_name;

EXCEPTION 
	WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('This breed id does not exist' ||chr(10)||
	'Are you certain it has been typed in correctly?' );
	RETURN NULL;
END; 


