--STAFFING
	--STAFF
		CREATE TABLE STAFF(
		StaffID int GENERATED AS IDENTITY PRIMARY KEY, 
		Staff_First_Name varchar2(40), 
		Staff_Last_Name varchar2(40), 
		Employment_Date date, 
		Termination_Date date, 
		Is_Rehireable char(1), 
		Is_Vet char(1), 
		Database_Role varchar2(40),
		CONSTRAINT chk_rehire CHECK (Is_Rehireable IN ('Y', 'y', 'N', 'n', 0, 1)), 
		CONSTRAINT chk_vet CHECK (Is_Vet IN ('Y', 'y', 'N', 'n', 0, 1)))
		TABLESPACE PERSONNEL;
COMMENT ON COLUMN STAFF.Is_Rehireable IS 'Oracle does not support BOOLEAN attributes, this is a pseudoBoolean to create a flag, currently unknown if the programmers will use upper or lower case, or a 1|0 to set the flag have taken all into account';
COMMENT ON COLUMN STAFF.Is_Vet IS 'Oracle does not support BOOLEAN attributes, this is a pseudoBoolean to create a flag, currently unknown if the programmers will use upper or lower case, or a 1|0 to set the flag have taken all into account';

  CREATE TABLE "DAVEDBA"."VET_PROCEDURE" 
   (	"VET_PROCEDUREID" int GENERATED AS IDENTITY PRIMARY KEY,  
	"SPECIALITYID" int DEFAULT NULL, 
	"VET_PROCEDURE_NAME" VARCHAR2(30 BYTE), 
	"IS_SURGERY" CHAR(1 BYTE), 
	"VET_PROCEDURE_COST" NUMBER(7,2)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "PERSONNEL" ;

   COMMENT ON COLUMN "DAVEDBA"."VET_PROCEDURE"."SPECIALITYID" IS 'Null is ok, especially if primary care';
   COMMENT ON TABLE "DAVEDBA"."VET_PROCEDURE"  IS 'Originally named PROCEDURE during the creation of the ERD was changed to VET_PROCEDURE to avoid confusion with the function "procedure''';
