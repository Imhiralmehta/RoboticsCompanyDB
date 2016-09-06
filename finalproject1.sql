--Name: Hiral Mehta, Final Project

--All tables are being dropped to avoid integrity error.
DROP TABLE partInventory;
DROP TABLE PartType;
DROP TABLE RobotPrt;
DROP TABLE RobotInventory;

-- Four tables are created in WTG Robotics schema as per definition given.
CREATE TABLE RobotInventory
(RobotID Number(4),
RobotName VARCHAR2(24),
Status VARCHAR2(64));

CREATE TABLE RobotPrt
(RbPrtSerial Number(4),
RobotID Number(4),
PartTypeID Number(4));

CREATE TABLE PartType
(ParttypeID  Number(4),
PartName VARCHAR2(64),
NumMissingPrts Number(4));

CREATE TABLE partInventory
(PrtSerial Number(4),
ParttypeID  Number(4));

-- Parttype and Partinventory tables are populated with some values.

INSERT INTO PartType VALUES (1,'Microcontroller',0);
INSERT INTO PartType VALUES (2,'Radio communication unit',0);
INSERT INTO PartType VALUES (3,'Radio communication unit',0);
INSERT INTO PartType VALUES (4,'Power supply unit',0);
INSERT INTO PartType VALUES (5,'Serial Interface',0);
INSERT INTO PartType VALUES (6,'Wheels set',0);
INSERT INTO PartType VALUES (7,'Joints set',0);
INSERT INTO PartType VALUES (8,'Body',0);
COMMIT;

INSERT INTO partInventory VALUES (11, 1);
INSERT INTO partInventory VALUES (321, 2);
INSERT INTO partInventory VALUES (144, 3);
INSERT INTO partInventory VALUES (12, 4);
INSERT INTO partInventory VALUES (151, 5);
INSERT INTO partInventory VALUES (443, 6);
INSERT INTO partInventory VALUES (565, 7);
INSERT INTO partInventory VALUES (421, 8);
INSERT INTO partInventory VALUES (233, 8);
INSERT INTO partInventory VALUES (445, 1);
INSERT INTO partInventory VALUES (167, 2);
INSERT INTO partInventory VALUES (877, 3);
INSERT INTO partInventory VALUES (654, 4);
INSERT INTO partInventory VALUES (555, 5);
INSERT INTO partInventory VALUES (343, 6);
INSERT INTO partInventory VALUES (233, 7);
COMMIT;

Select * from partInventory;
Select * from PartType;
Select * from RobotPrt;
Select * from RobotInventory;

-- A sequence named Seq_id has been created which starts at 1 and increment by 1
DROP SEQUENCE Seq_id;
CREATE SEQUENCE Seq_id START WITH 1 INCREMENT BY 1;
SET SERVEROUTPUT ON

-- A new trigger has been created before inserting any row on RobotInventory table
CREATE OR REPLACE TRIGGER newRobot_trg BEFORE INSERT ON RobotInventory
FOR EACH ROW
  DECLARE
  invCount Integer; -- a variable to store distinct count from partinventory table
  msgNancy CONSTANT VARCHAR2(50) := 'Email to Nancy: Please check missing parts'; -- a constant to show message to nancy 
  TYPE tempPartsType IS TABLE OF PARTINVENTORY%ROWTYPE; -- temporary table of partinventory type to collect temp data
  tempParts tempPartsType;
  BEGIN
    SELECT COUNT(DISTINCT PARTTYPEID) INTO invCount FROM partInventory;
    /*Task 1 & 2 of populating automatic robotid with status of ready*/
      IF invCount = 8 THEN    -- When distinct parttypeid count is 8 then robotid will be incremented by 1 and status of ready being updated.     
          SELECT Seq_id.nextval INTO :NEW.ROBOTID FROM dual;         
          :NEW.STATUS := 'Ready for assembly';
      ELSE -- When distinct count is less than 8, robotid will be incremented by 1 but with status of waiting, and parttype table will be updated for missing parts
          SELECT Seq_id.nextval INTO :NEW.ROBOTID FROM dual;         
          :NEW.STATUS := 'Waiting for parts';
          /*Task 4 of updating nummissingpart column in parttype table*/
          UPDATE PartType SET NumMissingPrts = NumMissingPrts + 1 WHERE PartTypeID NOT IN (SELECT DISTINCT PARTTYPEID FROM partInventory);
          /*Task 5 of sending Nancy a message*/
          DBMS_OUTPUT.PUT_LINE(msgNancy); -- When parttype table is updated, an email will be sent to nancy for missing parts
      END IF;
      /*Task 3 of inserting parts in RobotPrt and deleting from Partinventory*/
      SELECT * BULK COLLECT INTO tempParts FROM PartInventory WHERE ROWNUM < 9;
      FOR i in 1..tempParts.LAST LOOP
      INSERT INTO RobotPrt VALUES (tempParts(i).prtserial,:NEW.ROBOTID,tempParts(i).parttypeid);
      END LOOP;     
     DELETE FROM PartInventory WHERE ROWNUM < 9;     
  END;
  /
INSERT INTO RobotInventory(ROBOTNAME) VALUES ('yyy');  
Select * from RobotInventory;
Select * from partInventory;
Select * from RobotPrt;
Select * from Parttype;



