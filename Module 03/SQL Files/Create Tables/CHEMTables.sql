--CHEMICAL/PHARMA
	--DISPOSABLE_PRODUCTS
		CREATE TABLE DISPOSABLE_PRODUCTS(
			ProductID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL,
			Product_Description varchar2(40), 
			Product_Size varchar2(10), 
			Product_On_Hand int)
		TABLESPACE CHEM;
		
	--LOCAL_BLOOD_BANK
		CREATE TABLE LOCAL_BLOOD_BANK(
			BloodBagID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
			SpeciesID int, 
			Type_Blood varchar2(40), 
			CONSTRAINT fk_SpeciesID FOREIGN KEY (SpeciesID)
				REFERENCES ANIMAL_SPECIES(SpeciesID), 
			CONSTRAINT ck_Type_Blood CHECK (Type_Blood IN ('A', 'B', 'AB', '-', '+', 'universal')))
		TABLESPACE CHEM;
 --LAB SECTION
 	--PATHOLOGY_LAB_TESTS
 		CREATE TABLE PATHOLOGY_LAB_TESTS(
		LabID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
		Lab_Name varchar2(40), 
		Lab_Cost number(7,2), 
		Kits_on_Hand int) 
	TABLESPACE CHEM;

	--PATHOLOGY_LAB_ORDERS
		CREATE TABLE PATHOLOGY_LAB_ORDERS(
			LabOrderID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
			LabID int, 
			PetID int, 
			VetID int, 
			Date_Completed date, 
			CONSTRAINT fk_labid FOREIGN KEY (LabID)
					REFERENCES PATHOLOGY_LAB_TESTS(LabID), 
			CONSTRAINT fk_petid_lab FOREIGN KEY (PetID)
					REFERENCES ANIMAL_FACTS(PetID), 
			CONSTRAINT fk_vetID_laborders FOREIGN KEY (VetID)
					REFERENCES VETERINARIAN(VetID))
		TABLESPACE CHEM;
		/*WARNING, YOU CANNOT LOAD THIS TABLE UNTIL SOME OF THE CHART HAS BEN MADE*/

	--PHARMACOLOGY_STOCK
		CREATE TABLE PHARMACOLOGY_STOCK(
			DrugID	int GENERATED AS IDENTITY PRIMARY KEY NOT NULL,
			Drug_Name varchar2(60),
			Drug_Dosage	number(9,2),
			Drug_Units_Inv number(9,2),
			Drug_Units_Meas varchar2(20),
			Drug_Cost_Per_Unit	number(7,2),
			Is_Controlled	char(1),
			Avian_Safe	char(1),
			Canine_Safe	char(1),
			Feline_Safe	char(1),
			Reptile_Safe char(1),
			Date_Stocked date,
			Date_Expiration	date,
			Order_Level	number(7,2),
			Reorder_Flag char(1),
			CONSTRAINT ck_is_controlled CHECK (Is_Controlled IN ('Y', 'y', 'N', 'n', 0, 1)),
			CONSTRAINT ck_aviansafe CHECK (Avian_Safe IN ('Y', 'y', 'N', 'n', 0, 1)), 
			CONSTRAINT ck_caninesafe CHECK (Canine_Safe IN ('Y', 'y', 'N', 'n', 0, 1)),
			CONSTRAINT ck_felinesafe CHECK (Feline_Safe IN ('Y', 'y', 'N', 'n', 0, 1)),
			CONSTRAINT ck_reptilesafe CHECK (Reptile_Safe IN ('Y', 'y', 'N', 'n', 0, 1)),
			CONSTRAINT ck_reorder CHECK (Reorder_Flag IN ('Y', 'y', 'N', 'n', 0, 1)))
		TABLESPACE CHEM;

	--RX_ORDER
	/*note: do not create FORIEGN KEYS for 
	RxID
	until Tablespace Chart's Rx_History is created*/
		CREATE TABLE RX_ORDER(
			RxID int,
			VetID int,
			PetID int,
			Date_Submitted date,
			DrugID int,
			Drug_Units_Prescribed number(9,2),
			Drug_Units_Dispensed number(9,2),
			Vet_Procedure_ID int,
			Date_Filled date,
			CONSTRAINT pk_rxorder_rxid PRIMARY KEY (RxID), 
			CONSTRAINT fk_drug_rxorder FOREIGN KEY (DrugID)
					REFERENCES PHARMACOLOGY_STOCK(DrugID))
		TABLESPACE CHEM;
	COMMENT ON TABLE RX_ORDER IS 'RX_ORDER is a child table of RX_HISTORY';

	--RX_REFILLS
		---The constraints for this table can load immediately after RX_ORDER even if it's constraints are not ready
		CREATE TABLE RX_REFILLS (
			RefillID int GENERATED AS IDENTITY PRIMARY KEY NOT NULL, 
			RxOrderID int, 
			RxID int, 
			Num_Refills_Left int, 
			Date_Filled date, 
			CONSTRAINT pk_rx_refillid PRIMARY KEY (RefillID))
		TABLESPACE CHEM;
--add after installing RX_history table 
ALTER TABLE RX_REFILLS --make sure that RX_History is in first.
	ADD CONSTRAINT fk_rxid_refills FOREIGN KEY (RxID)
	REFERENCES RX_ORDER(RxID);
ALTER TABLE RX_ORDER
	ADD CONSTRAINT fk_rxidhist FOREIGN KEY (RxID)
	REFERENCES RX_HISTORY(RxID);