INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Labrador Retriever');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (3,'Calico');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (4,'Monitor Lizard');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (1,'Cockatoo');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (1,'African Grey Parrot');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (4,'Cobra');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Daschund');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Bloodhound');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Basset Hound');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Mutt');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (3,'Domestic Short Hair');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (3,'Domestic Long Hair');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (3,'African Several');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (3,'Sphynx');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (3,'Maine Coon');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Weimaraner');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Dalmation');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Boxer');
INSERT INTO ANIMAL_BREED (SpeciesID, Breed_Name) VALUES (2,'Portuguese Water Dog');

SELECT * FROM ANIMAL_BREED;

SELECT SPECIES_NAME, BREED_NAME
FROM ANIMAL_SPECIES JOIN ANIMAL_BREED USING(SPECIESID)
ORDER BY SPECIES_NAME, BREED_NAME;
