--CHART
	--ANIMAL_FACTS
	CREATE TABLE ANIMAL_FACTS(
	PetID	int,
	ChartID	int, --if we don't purge we will create a trigger that makes it same as PetID
	Pet_First_Name	varchar2(40),
	Pet_Middle_Name	varchar2(40),
	Owner_Last_Name	varchar2(40),
	SpeciesID int,
	BreedID	int,
	GenderID int,
	Coloring varchar2(30),
	Birth_Date	date,
	Temperament_Notes varchar2(80),
	Chart_Create_Date date,
	CONSTRAINT pk_petID_facts PRIMARY KEY (PetID),
	CONSTRAINT fk_petID_facts FOREIGN KEY (PetID)
			REFERENCES PET(PetID),
	CONSTRAINT fk_speciesID_facts FOREIGN KEY (SpeciesID)
			REFERENCES ANIMAL_SPECIES(SpeciesID), 
	CONSTRAINT fk_breedid_facts FOREIGN KEY (BreedID)
			REFERENCES ANIMAL_BREED(BreedID), 
	CONSTRAINT fk_genderid_facts FOREIGN KEY (GenderID)
			REFERENCES ANIMAL_GENDER(GenderID))
	TABLESPACE CHART;

	COMMENT ON TABLE ANIMAL_FACTS IS '1 of 2 ANIMAL_FACTS is a CHILD of PET from the CRM tablespace. 2 of 2 ANIMAL_FACTS is the foundation for the patient chart';
	COMMENT ON COLUMN ANIMAL_FACTS.PetID IS 'ALL chart objects reference the PetID in the CHART tablespace (so this one) for simplicity, and to link them together logically';
	
	--ENCOUNTER_HISTORY
	CREATE TABLE ENCOUNTER_HISTORY(
		EncounterID	int GENERATED AS IDENTITY PRIMARY KEY NOT NULL,
		PetID	int,
		Encounter_Weight number(8,2),
		VetID	int,
		Encounter_Notes	clob, 
		Encounter_Date_Time timestamp(5),				
		CONSTRAINT fk_petid_encounter FOREIGN KEY (PetID)
				REFERENCES ANIMAL_FACTS(PetID), 
		CONSTRAINT fk_vetid_encounter FOREIGN KEY (VetID)
				REFERENCES VETERINARIAN(VetID))
	TABLESPACE CHART;


	--IMPORTED_CHART_DATA
	CREATE TABLE IMPORTED_CHART_DATA(
		PetID int, 
		ImportID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
		Import_Files bfile, 
		CONSTRAINT fk_petid_import FOREIGN KEY (PetID)
				REFERENCES ANIMAL_FACTS(PetID))
	TABLESPACE CHART;

	--RADIOLOGY_HISTORY
	CREATE TABLE RADIOLOGY_HISTORY(
		PetID	int,
		RadImgID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL,
		RadImg_Date_Taken	date,
		RadImg_Notes	clob,
		RadImg_Files	bfile,
		CONSTRAINT fk_petid_rad FOREIGN KEY (PetID)
				REFERENCES ANIMAL_FACTS(PetID))
	TABLESPACE CHART;

	--PATHOLOGY_HISTORY
	CREATE TABLE PATHOLOGY_HISTORY(
		LabHistoryID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
		LabOrderID int, 
		PetID int,
		LabID int, 
		VetID int,
		Critical_Disease char(1), 
		Date_Completed date,
		Results	varchar2(1000),
		CONSTRAINT fk_petid_labhist FOREIGN KEY (PetID)
			REFERENCES ANIMAL_FACTS(PetID),
		CONSTRAINT fk_vetid_labhist FOREIGN KEY (VetID)
				REFERENCES VETERINARIAN(VetID), 
		CONSTRAINT ck_crit_disease CHECK (Critical_Disease IN ('Y', 'y', 'N', 'n', 0, 1)))
	TABLESPACE CHART;

	--VET_PROCEDURE_HISTORY
	CREATE TABLE VET_PROCEDURE_HISTORY(
		Patient_Vet_ProcedureID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
		Vet_ProcedureID int, 
		PetID int, 
		Vet_Procedure_Date date, 
		Vet_Procedure_Notes clob, 
		Vet_Procedure_FollowUp_Date date, 
		Vet_Procedure_FollowUp_Outcome clob, 
		Administered_Rx_During char(1), 
		VetID int,
		CONSTRAINT fk_vprocid_hist FOREIGN KEY (Vet_ProcedureID)
				REFERENCES VET_PROCEDURE(Vet_ProcedureID), 
		CONSTRAINT fk_petid_prochist FOREIGN KEY (PetID)
				REFERENCES ANIMAL_FACTS(PetID), 
		CONSTRAINT fk_vetid_prochist FOREIGN KEY (VetID)
				REFERENCES VETERINARIAN(VetID), 
		CONSTRAINT ck_adminrx_proc CHECK (Administered_Rx_During IN ('Y', 'y', 'N', 'n', 0, 1)))
	TABLESPACE CHART;

	
	--RX_HISTORY
	--can't add Patient_Vet_ProcedureID FOREIGN KEY until after Vet_Procedure_History Has been loaded
	CREATE TABLE RX_HISTORY(
		RxID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
		PetID int, 
		DrugID int, 
		Drug_Dosage number(9,2), 
		Drug_Units_Dispensed number(9,2),
		Date_Filled date, 
		Patient_Vet_ProcedureID int, 
		Is_Maintenance_Med char(1), 
		Notes varchar2(1000),
		CONSTRAINT fk_petid_rxhist FOREIGN KEY (PetID)
				REFERENCES ANIMAL_FACTS(PetID), 
		CONSTRAINT fk_drugid_rxhist FOREIGN KEY (DrugID)
				REFERENCES PHARMACOLOGY_STOCK(DrugID),
		CONSTRAINT fk_pvproc_rxhist FOREIGN KEY (Patient_Vet_ProcedureID)
				REFERENCES VET_PROCEDURE_HISTORY(Patient_Vet_ProcedureID), 
		CONSTRAINT ck_ismaintmed CHECK IN (Is_Maintenance_Med IN ('Y', 'y', 'N', 'n', 0, 1)))
	TABLESPACE CHART;

