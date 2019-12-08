--CRM TABLES (NO VIEWS!!!)

DROP TABLE  OWNER CASCADE CONSTRAINTS;
DROP TABLE  PET CASCADE CONSTRAINTS;
DROP TABLE  PET_HISTORICAL CASCADE CONSTRAINTS;
DROP TABLE  ANIMAL_GENDER CASCADE CONSTRAINTS;
DROP TABLE  ANIMAL_SPECIES CASCADE CONSTRAINTS;
DROP TABLE  ANIMAL_BREED CASCADE CONSTRAINTS;
DROP TABLE  GRIEF_COUNSELOR_ALERT CASCADE CONSTRAINTS;
	--OWNER
		CREATE TABLE OWNER(
		OwnerID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
		First_Name varchar2(40), 
		Last_Name varchar2(40), 
		Phone_Primary varchar2(9), 
		Phone_Secondary varchar2(9), 
		Address_Street varchar2(60), 
		Address_Apt varchar2(10), 
		City varchar2(40), 
		State char(2), 
		Zip char(2), 
		Email varchar2(50), 
		Alt_Family_Mem_First_Name  varchar2(40), 
		Alt_Family_Mem_Last_Name varchar2(40), 
		Alt_Family_Mem_Phone varchar2(9), 
		Emerg_Cont_First_Name varchar2(40), 
		Emerg_Cont_Last_Name varchar2(40), 
		Emerg_Cont_Phone varchar2(9))
		TABLESPACE CRM;

	--PET
		CREATE TABLE PET(
		PetID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
		OwnerID int NOT NULL, 
		Pet_First_Name varchar2(40), 
		Pet_Middle_Name varchar2(40), 
		/*The next 3 lines of "IDs" are Foreign Keys that cannot yet be created, 
		will need to create after the appropriate tables are created*/
		SpeciesID int, 
		BreedID int,
		GenderID int,
		Coloring varchar2(30), 
		Birth_Date date, 
		Is_Living char(1), 
		Photo blob, 
		Temperament_Notes varchar2(80), 
		CONSTRAINT ck_is_living CHECK (is_living IN ('Y', 'y', 'N', 'n', 0, 1))
		)
		TABLESPACE CRM; 
		COMMENT ON COLUMN PET.Is_Living IS 'Oracle does not support BOOLEAN attributes, this is a pseudoBoolean to create a flag, currently unknown if the programmers will use upper or lower case, or a 1|0 to set the flag have taken all into account';
	--PET_HISTORICAL
		CREATE TABLE PET_HISTORICAL(
		PetID int NOT NULL, 
		OwnerID int, 
		Pet_First_Name varchar2(40), 
		Pet_Middle_Name varchar2(40), 
		/*The next 3 lines of "IDs" are Foreign Keys that cannot yet be created, 
		will need to create after the appropriate tables are created*/
		SpeciesID int, 
		BreedID int,
		GenderID int,
		Coloring varchar2(30), 
		Birth_Date date, 
		Is_Living char(1), 
		Photo blob, 
		Temperament_Notes varchar2(80), 
		CONSTRAINT pet_historical_pk PRIMARY KEY (PetID), 
		CONSTRAINT check_is_living_historical CHECK (is_living IN ('N', 'n', 0))
		)
		TABLESPACE CRM; 
		COMMENT ON TABLE PET_HISTORICAL IS 'This is where archived data about dead pets is stored';
	--ANIMAL_GENDER
		CREATE TABLE ANIMAL_GENDER(
		GenderID int NOT NULL, 
		Gender_Name varchar2(25), 
		CONSTRAINT pk_genderID PRIMARY KEY (GenderID))
		TABLESPACE CRM;
	--ANIMAL_SPECIES
		CREATE TABLE ANIMAL_SPECIES(
		SpeciesID int NOT NULL, 
		Species_Name varchar2(25),
		CONSTRAINT pk_speciesID PRIMARY KEY (SpeciesID))
		TABLESPACE CRM;
	--ANIMAL_BREED
		CREATE TABLE ANIMAL_BREED(
			BreedID int NOT NULL,
			SpeciesID int NOT NULL, 
			Breed_Name varchar2(25), 
			CONSTRAINT pk_breedID PRIMARY KEY (BreedID), 
			CONSTRAINT fk_species_breed FOREIGN KEY (SpeciesID) 
				REFERENCES ANIMAL_SPECIES(SpeciesID))
		TABLESPACE CRM; 
	--GRIEF_COUNSELOR_ALERT
		CREATE TABLE GRIEF_COUNSELOR_ALERT(
		AlertID int GENERATED AS IDENTITY PRIMARY KEY, 
		Alert_Date date,
		PetID int, 
		OwnerID int, 
		Parent_Last varchar2(40),
		Pet_First varchar2(40), 
		Complete_Date date, 
		Resolution_Notes clob, 
		Phone_Primary varchar2(9), 
		Death_Date date, 
		CONSTRAINT fk_pet_grief FOREIGN KEY (PetID)
			REFERENCES PET_HISTORICAL(PetID), 
		CONSTRAINT fk_owner_grief FOREIGN KEY (OwnerID)
			REFERENCES OWNER(OwnerID))
		TABLESPACE CRM;

	COMMENT ON COLUMN GRIEF_COUNSELOR_ALERT.PetID IS 'the pet has died don''t use the living pet table for a reference';

