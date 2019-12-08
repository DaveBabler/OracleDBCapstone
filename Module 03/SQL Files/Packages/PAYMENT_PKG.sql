CREATE OR REPLACE PACKAGE PAYMENT_PKG
AS
	FUNCTION ENCRYPT_CC (pv_card_no IN VARCHAR2) RETURN RAW;
	FUNCTION DECRYPT_CC (pv_encryptcard_no IN RAW, pv_last4 IN VARCHAR2) RETURN VARCHAR2;
	PROCEDURE INVOICE_MOVE(pv_invoiceid IN int);
	PROCEDURE PAYMENT_SUBMIT(pv_type_pay IN int, pv_amt_paid IN number, pv_invoiceid IN int, pv_card_no IN varchar2 DEFAULT NULL, pv_check_no IN int DEFAULT NULL);

END;


CREATE OR REPLACE PACKAGE BODY PAYMENT_PKG
AS
	FUNCTION ENCRYPT_CC (pv_card_no IN VARCHAR2) 
		RETURN RAW
	IS
		lv_key RAW(128) := UTL_RAW.CAST_TO_RAW('a proper key goes here');
		lv_ccnum RAW(128) := UTL_RAW.CAST_TO_RAW(pv_card_no);
		lv_encrypted_out RAW(2048) := NULL; 

		BEGIN
			lv_encrypted_out := DBMS_CRYPTO.ENCRYPT(lv_ccnum, DBMS_CRYPTO.DES_CBC_PKCS5, lv_key);
		RETURN lv_encrypted_out;
	END ENCRYPT_CC;


	FUNCTION DECRYPT_CC (pv_encryptcard_no IN RAW,  pv_last4 IN VARCHAR2) RETURN VARCHAR2
	IS
		lv_key RAW(128) := UTL_RAW.CAST_TO_RAW('a proper key goes here');
		lv_decrypted_out VARCHAR2(24) := NULL;
		lv_decrypted_raw RAW(2048);
        lv_combination_out VARCHAR2(24);
		BEGIN
			lv_decrypted_raw := DBMS_CRYPTO.DECRYPT(src => pv_encryptcard_no, 
													typ => DBMS_CRYPTO.DES_CBC_PKCS5,
													key => lv_key);
		lv_decrypted_out := UTL_RAW.CAST_TO_VARCHAR2(lv_decrypted_raw);
        lv_combination_out := CONCAT(lv_decrypted_out, pv_last4);
		RETURN lv_combination_out;
	END DECRYPT_CC;

	PROCEDURE INVOICE_MOVE(pv_invoiceid IN int)
	IS
	BEGIN
		INSERT INTO INVOICE_CLOSED
		SELECT * 
		FROM INVOICE_OPEN
		WHERE INVOICEID = pv_invoiceid; 
		DELETE FROM INVOICE_OPEN
		WHERE INVOICEID = pv_invoiceid; 
		COMMIT;
	END INVOICE_MOVE;


	PROCEDURE PAYMENT_SUBMIT(pv_type_pay IN int, pv_amt_paid IN number, pv_invoiceid IN int, pv_card_no IN varchar2 DEFAULT NULL, pv_check_no IN int DEFAULT NULL)
	IS
		lv_last4 VARCHAR2(4) := NULL;
		lv_first12 varchar2(12) := NULL;
		lv_encryptcc RAW(2048) := NULL;
	BEGIN 
		CASE 
			WHEN pv_type_pay = 1 OR pv_type_pay = 4	THEN
				 INSERT INTO PAYMENT_VERIFICATION(INVOICEID, PAYMENT_TYPEID, AMOUNT_PAID, DATE_PAID)
					VALUES(pv_invoiceid, pv_type_pay, pv_amt_paid, SYSDATE);
				INVOICE_MOVE(pv_invoiceid);
			WHEN pv_type_pay = 2 THEN 
				INSERT INTO PAYMENT_VERIFICATION(INVOICEID, PAYMENT_TYPEID, AMOUNT_PAID, CHECK_NUMBER, DATE_PAID)
					VALUES(pv_invoiceid, pv_type_pay, pv_amt_paid, pv_check_no, SYSDATE);
				INVOICE_MOVE(pv_invoiceid);
			WHEN pv_type_pay = 3 THEN 
				lv_last4 := SUBSTR(pv_card_no, -4);
				lv_first12 := SUBSTR(pv_card_no, 0, 12);
				lv_encryptcc := ENCRYPT_CC(lv_first12);
			INSERT INTO PAYMENT_VERIFICATION(INVOICEID, PAYMENT_TYPEID, AMOUNT_PAID, DATE_PAID, CC_ENCRYPTED12, CC_LAST4)
					VALUES(pv_invoiceid, pv_type_pay, pv_amt_paid, SYSDATE, lv_encryptcc, lv_last4);
				INVOICE_MOVE(pv_invoiceid);
			ELSE NULL;
			END CASE;
		COMMIT;
	END PAYMENT_SUBMIT;
			

END;
