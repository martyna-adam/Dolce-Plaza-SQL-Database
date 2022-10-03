-- Creating a database -- 
CREATE DATABASE DOLCE_PLAZA; 

USE DOLCE_PLAZA;

-- Creating tables -- 
CREATE TABLE HOTEL
(	Hotel_ID VARCHAR(5) PRIMARY KEY, 
	Hotel_Name VARCHAR(50) NOT NULL, 
	Hotel_Email_Address VARCHAR(50),
	Address_ID VARCHAR(5) NOT NULL,
	Hotel_Website VARCHAR(50),
	Floor_Count INTEGER, 
	Room_Capacity INTEGER,
	Checkin_Time TIME NOT NULL, 
	Checkout_Time TIME NOT NULL	
);

CREATE TABLE ROOMS
(	Room_ID VARCHAR(5) PRIMARY KEY, 
	Room_Number INTEGER,
	Hotel_ID VARCHAR(5),
	Room_TypeID VARCHAR(5)
);


CREATE TABLE ROOM_TYPE
(	Room_TypeID VARCHAR(5) PRIMARY KEY,
	Room_Name VARCHAR(50) NOT NULL,
	Room_Cost DECIMAL(6,2) NOT NULL,
	Room_Description TEXT,
	Family_Friendly BOOLEAN,
	Balcony BOOLEAN,
	Pet_Friendly BOOLEAN,
	Smoke_Friendly BOOLEAN
);

CREATE TABLE ROOMS_BOOKED
(	Rooms_BookedID VARCHAR(5) PRIMARY KEY,
	Booking_ID VARCHAR(5),
    RoomType_ID VARCHAR(5)
);



CREATE TABLE STAY_BOOKINGS
(	Booking_ID VARCHAR(5) PRIMARY KEY,
	Booking_Date DATE,
	Stay_Duration_Nights INTEGER NOT NULL, 
	Checkin_Date DATE NOT NULL,
	Checkout_Date DATE NOT NULL, 
	Card_Payment BOOLEAN NOT NULL,
	Total_Rooms INTEGER NOT NULL,
	Hotel_ID VARCHAR(5), 
	Guest_ID VARCHAR(5),
	Employee_ID VARCHAR(5),
	Booking_Amount DECIMAL(10,2)
);

CREATE TABLE EMPLOYEES
(	Employee_ID VARCHAR(5) PRIMARY KEY,
	First_Name VARCHAR(50) NOT NULL,
	Last_Name VARCHAR(50) NOT NULL,
	Role_Title VARCHAR(20),
	Manager_ID VARCHAR(5),
	Phone_Number VARCHAR(11),
	Email_Address VARCHAR(50),
	Address_ID VARCHAR(5),
	Hotel_ID VARCHAR(5)
);

CREATE TABLE ADDRESS_INFORMATION
(	Address_ID VARCHAR(5) PRIMARY KEY,
	Address_Line1 VARCHAR(50) NOT NULL,
	Address_Line2 VARCHAR(50),
	City VARCHAR(20) NOT NULL,
	Post_Code VARCHAR(10) NOT NULL,
	Country VARCHAR(20)
);

CREATE TABLE GUEST
(	Guest_ID VARCHAR(5) PRIMARY KEY,
	First_Name VARCHAR(50) NOT NULL, 
	Last_Name VARCHAR(50) NOT NULL,
	Phone_Number CHAR(11),
	Email_Address VARCHAR(50) NOT NULL,
	Address_ID VARCHAR(5)
);

-- Example of using SQL syntax to add data to the tables -- 
INSERT INTO HOTEL
(Hotel_ID, Hotel_Name, Hotel_Email_Address, Address_ID, Hotel_Website, Floor_Count, Room_Capacity, Checkin_Time, Checkout_Time)
VALUES
('H1', 'Dolce Plaza London', 'london@dolce-plaza.co.uk','A1','www.dolce-plaza-ldn.co.uk', 4, 35, '16:00', '10:30');

-- The rest of the data was prepared by me in Excel. I have imported the data into SQL by selecting the database in the scheme, selecting the relevant table, right clicking and selecting Table Data Import Wizard. Files were converted to .csv prior to import --  

-- Adding constraints - setting up foreign keys linking different tables together -- 
ALTER TABLE HOTEL
ADD CONSTRAINT
fk_Address_ID
FOREIGN KEY
(Address_ID)
REFERENCES
ADDRESS_INFORMATION
(Address_ID);

ALTER TABLE ROOMS
ADD CONSTRAINT
fk_Room_TypeID
FOREIGN KEY
(Room_TypeID)
REFERENCES
ROOM_TYPE
(Room_TypeID);

ALTER TABLE ROOMS
ADD CONSTRAINT
fk_Hotel_ID
FOREIGN KEY
(Hotel_ID)
REFERENCES
HOTEL
(Hotel_ID);


ALTER TABLE ROOMS_BOOKED
ADD CONSTRAINT
fk_Booking_ID
FOREIGN KEY
(Booking_ID)
REFERENCES
STAY_BOOKINGS
(Booking_ID);

ALTER TABLE ROOMS_BOOKED
ADD CONSTRAINT
fk_Room_ID
FOREIGN KEY
(RoomType_ID)
REFERENCES
ROOMS
(Room_TypeID);

ALTER TABLE STAY_BOOKINGS
ADD CONSTRAINT
f_k_Hotel_ID
FOREIGN KEY
(Hotel_ID)
REFERENCES
HOTEL
(Hotel_ID);

ALTER TABLE STAY_BOOKINGS
ADD CONSTRAINT
fk_Guest_ID
FOREIGN KEY
(Guest_ID)
REFERENCES
GUEST
(Guest_ID);

ALTER TABLE STAY_BOOKINGS
ADD CONSTRAINT
fk_Employee_ID
FOREIGN KEY
(Employee_ID)
REFERENCES
EMPLOYEES
(Employee_ID);

ALTER TABLE EMPLOYEES
ADD CONSTRAINT
f_k_Address_ID
FOREIGN KEY
(Address_ID)
REFERENCES
ADDRESS_INFORMATION
(Address_ID);

ALTER TABLE EMPLOYEES
ADD CONSTRAINT
foreign_k_Hotel_ID
FOREIGN KEY
(Hotel_ID)
REFERENCES
HOTEL
(Hotel_ID);

ALTER TABLE GUEST
ADD CONSTRAINT
foreign_k_Address_ID
FOREIGN KEY
(Address_ID)
REFERENCES
ADDRESS_INFORMATION
(Address_ID);

-- --------------------------------TASKS ------------------

-- Prepare an example query with group by and having to demonstrate how to extract data from your DB for analysis
-- Q. What are the unique cities in our address list, where those cities begin with either 'M' or 'L' 
SELECT 
	DISTINCT(A.City) AS 'City'
FROM
	ADDRESS_INFORMATION AS A
GROUP BY A.City
HAVING (A.City LIKE 'm%' OR A.City LIKE 'l%' OR A.City LIKE 'w%')
ORDER BY A.City DESC;

-- Prepare an example query with a subquery to demonstrate how to extract data from your DB for analysis
-- What is the first name, last name, email address  of guests who booked 2 or more rooms.  

SELECT 
	G.First_Name AS 'First Name',
    G.Last_Name AS 'Last Name',
    G.Email_Address AS 'Email Address'
FROM GUEST AS G
WHERE G.Guest_ID IN
	(SELECT DISTINCT S.Guest_ID
	FROM
	STAY_BOOKINGS AS S
    WHERE S.Total_Rooms >= 2)
; 

-- Customer Kyan Bennett has phoned up to ask what the check in time is for his booking. 

SELECT
	H.Checkin_Time AS 'Check In Time',
    H.Checkout_Time AS 'Check Out Time'
FROM Hotel AS H
WHERE H.Hotel_ID IN(
	SELECT S.Hotel_ID
    FROM Stay_Bookings AS S
    WHERE S.Guest_ID IN(
		SELECT G.Guest_ID
        FROM Guest AS G
        WHERE G.First_Name = 'Kyan'
        AND 
			G.Last_Name = 'Bennett'));

-- Using any type of the joins create a view that combines multiple tables in a logical way
CREATE VIEW Employee_Information
AS
	SELECT 
		E1.First_Name AS 'Employee First Name',
		E1.Last_Name AS 'Employee Last Name', 
        E1.Email_Address AS 'Employee Email Address',
        E2.First_Name AS 'Manager First Name',
        E2.Last_Name AS 'Manager Last Name',
        E2.Email_Address AS 'Manager Email Address'
	FROM Employees as E1
    LEFT JOIN Employees as E2
    ON E1.Manager_ID = E2.Employee_ID;

-- In your database, create a stored function that can be applied to a query in your DB

-- Step 1: Find out mininimum and maximum booking amounts to determine thresholds for discount

SELECT
	MIN(Booking_Amount), MAX(Booking_Amount), AVG(Booking_Amount)
FROM
	STAY_BOOKINGS;

-- Step 2: Create a stored function to calculate discount eligibility based on Total Booking Amount 
DELIMITER //
CREATE FUNCTION discount_eligibility(
      Booking_Amount DECIMAL(10,2)
	) 
RETURNS VARCHAR(20)
DETERMINISTIC
	BEGIN
    DECLARE guest_discount_status VARCHAR(20);
    IF Booking_Amount < 500 THEN
        SET guest_discount_status = 'NO';
    ELSEIF (Booking_Amount >= 500 AND 
            Booking_Amount <= 2000) THEN
        SET guest_discount_status = 'YES - 10%';
    ELSEIF (Booking_Amount > 2000 AND Booking_Amount <= 4000) THEN
        SET guest_discount_status = 'YES - 20%';
	ELSEIF (Booking_Amount > 4000) THEN
		SET guest_discount_status = 'YES - 25%';
    END IF;
    RETURN (guest_discount_status);
	END//Booking_Amount
DELIMITER ;

-- Step 3: Get the first name, last name, email address and discount eligibility information for guests to send out a voucher
SELECT 
	G.First_Name AS 'Guest First Name',
    G.Last_Name AS 'Guest Last Name',
    G.Email_Address AS 'Guest Email Address',
    S.Booking_Amount AS 'Total Booking Amount',
    discount_eligibility(Booking_Amount) AS 'Discount eligibility'
FROM
    GUEST AS G
INNER JOIN 
	STAY_BOOKINGS AS S
ON G.Guest_ID = S.Guest_ID;

-- In your database, create a stored procedure and demonstrate how it runs
-- First 2 stored procedure is to get the whole list of staff emails and guest emails to be able to quickly send a bulk email to all
DELIMITER //
CREATE PROCEDURE All_Staff_Email_List()
BEGIN
	SELECT Email_Address FROM Employees;
END //
DELIMITER ;

CALL All_Staff_Email_List();

DELIMITER //
CREATE PROCEDURE All_Guest_Email_List()
BEGIN
	SELECT Email_Address FROM Guest;
END //
DELIMITER ;

CALL All_Guest_Email_List();

-- Next stored procedure is to get Total Rooms booked for a certain date

DELIMITER //
CREATE PROCEDURE Get_Rooms_Booked(
	Check_in_date DATE)
BEGIN 
	SELECT 
		SUM(Total_Rooms)
	FROM STAY_BOOKINGS
    WHERE Checkin_date = check_in_date;
END //
DELIMITER ;

CALL Get_Rooms_Booked('2022-05-05');

-- In your database, create a trigger and demonstrate how it runs
-- I will be using a before insert trigger to change the data inserted into tables to be consistent and in line with reporting requirements. 

DELIMITER //
CREATE TRIGGER Employee_Details
BEFORE INSERT 
ON Employees FOR EACH ROW
BEGIN
SET NEW.First_Name = TRIM(CONCAT(UPPER(SUBSTRING(NEW.First_Name,1,1)), LOWER(SUBSTRING(NEW.First_Name,2))));
SET NEW.Last_Name = TRIM(CONCAT(UPPER(SUBSTRING(NEW.Last_Name,1,1)), LOWER(SUBSTRING(NEW.Last_Name,2))));
SET NEW.Role_Title = TRIM(CONCAT(UPPER(SUBSTRING(NEW.Role_Title,1,1)), LOWER(SUBSTRING(NEW.Role_Title,2))));
SET NEW.Employee_ID = UPPER(NEW.Employee_ID);
SET NEW.Manager_ID = UPPER(NEW.Manager_ID);
SET NEW.Address_ID = UPPER(NEW.Address_ID);
SET NEW.Hotel_ID = UPPER(NEW.Hotel_ID);
END;
//
DELIMITER ;

INSERT INTO EMPLOYEES
VALUES
('e21', 'victoria', 'smiTh', 'mAnaGer', 'e6', '7709123456', 'Victoria.Smith@dolce-plaza.co.uk','a9', 'H1');

-- DELETE
-- FROM EMPLOYEES
-- WHERE Employee_ID = 'E21';

-- In your database, create an event and demonstrate how it runs -- 

-- I will create a new table to include audit information and schedule a recurring event to add audit messages to the table every one minute -- 
CREATE TABLE AUDIT
(	ID INTEGER PRIMARY KEY AUTO_INCREMENT,
	Audit_Message VARCHAR(300) NOT NULL, 
	Audit_Created_At DATETIME NOT NULL
);

SET GLOBAL event_scheduler = ON;
CREATE EVENT IF NOT EXISTS Hotel_Audit
ON SCHEDULE EVERY 30 second
STARTS CURRENT_TIMESTAMP 
ENDS CURRENT_TIMESTAMP + INTERVAL 1 MONTH 
DO  
	INSERT INTO AUDIT
		(Audit_Message, Audit_Created_At)
        VALUES
        ('Hotel Dolce Plaza Database Audit Completed', NOW());
        
-- DROP EVENT IF EXISTS Hotel_Audit;
-- DROP TABLE AUDIT;

-- Create a view that uses at least 3-4 base tables; prepare and demonstrate a query that uses the view to produce a logically arranged result set for analysis.-- 

-- I will create a view that joins multiple tables together to show all of the room information together, with guest information and booking information. 

CREATE VIEW Full_Booking_Information
AS
	SELECT 
		S.Checkin_Date,
        S.Checkout_Date,
        S.Total_Rooms,
        S.Booking_Amount,
        G.First_Name,
        G.Last_Name,
        G.Phone_Number,
        G.Email_Address,
		R.Room_Name,
        R.Room_Cost,
        R.Family_Friendly,
        R.Balcony,
        R.Pet_Friendly,
        R.Smoke_Friendly,
        R.Room_Description,
        H.Hotel_Name,
        H.Checkin_Time,
        H.Checkout_Time
	FROM Stay_Bookings AS S
    LEFT JOIN
		Guest AS G
		ON S.Guest_ID = G.Guest_ID
    LEFT JOIN 
		Rooms_Booked AS RB
        ON S.Booking_ID = RB.Booking_ID
	LEFT JOIN
		Room_Type AS R
        ON RB.RoomType_ID = R.Room_TypeID
	LEFT JOIN
		Hotel AS H
        ON S.Hotel_ID = H.Hotel_ID;
        
SELECT * FROM Full_Booking_Information;

-- Due to urgent maintenance, all rooms with a balcony are unavialble, and bookings need to be moved to a different type of room. We will need to find the name and contant details of guests who have made a booking which includes a room with a balcony to let them know of the change.

SELECT DISTINCT 
	FB.First_Name,
    FB.Last_Name,
    FB.Phone_Number, 
    FB.Email_Address
FROM Full_Booking_Information AS FB
WHERE Balcony = TRUE;


