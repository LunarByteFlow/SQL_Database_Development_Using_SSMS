
-- Question 1
Create Database AirportTicketingSystem;
USE AirportTicketingSystem;
 

--- Task 1.1
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,       -- Unique identifier for each employee, auto-incremented
    Name NVARCHAR(100) NOT NULL,                    -- Full name of the employee; cannot be null
    Email NVARCHAR(100) NOT NULL UNIQUE,            -- Employee's email address; must be unique and not null
    Role NVARCHAR(20)                               -- Role assigned to the employee (restricted to specific values)
        CHECK (Role IN ('Ticketing Staff', 'Ticketing Supervisor')),  -- Only allows these two roles
    Password NVARCHAR(255) NOT NULL                 -- password for authentication; cannot be null
);


CREATE TABLE Passenger (
    PassengerID INT IDENTITY(1,1) PRIMARY KEY,          -- Unique identifier for each passenger
    PNR VARCHAR(20) NOT NULL UNIQUE,      -- Unique Passenger Name Record for booking reference
    Email VARCHAR(255) NOT NULL UNIQUE,   -- Passenger's email for communication
    MealType VARCHAR(15) CHECK (MealType IN ('Vegetarian', 'Non-Vegetarian')), -- Meal preference
    DateOfBirth DATE NOT NULL,            -- Passenger's Date of Birth
    FirstName VARCHAR(50) NOT NULL,       -- Passenger's first name
    LastName VARCHAR(50) NOT NULL,        -- Passenger's last name
    EmergencyContact VARCHAR(15) NULL     -- Optional emergency contact number
);

-- Create Flight table to store details about each flight
CREATE TABLE Flight (
    FlightID INT IDENTITY(1,1) PRIMARY KEY,         -- Unique ID for each flight (auto-incremented)
    flightNumber NVARCHAR(30) NOT NULL,             -- Flight number (e.g., PK301)
    departureTime DATETIME NOT NULL,                -- Scheduled departure time
    arrivalTime DATETIME NOT NULL,                  -- Scheduled arrival time
    origin NVARCHAR(30) NOT NULL,                   -- Departure location
    destination NVARCHAR(50) NOT NULL               -- Arrival location
);


-- Create Ticket table to store ticket details
CREATE TABLE Ticket (
    TicketID INT IDENTITY(1,1) PRIMARY KEY,         -- Unique ID for each ticket (auto-incremented)
    PassengerID INT NOT NULL,                       -- References Passenger who owns the ticket
    FlightID INT NOT NULL,                          -- References associated Flight
    IssueDate DATETIME DEFAULT SYSDATETIME(),       -- Auto-generated timestamp when ticket is issue
    BaseFare DECIMAL(8,2) NOT NULL,                 -- Base fare for the ticket (without additional services)
    TotalFare DECIMAL(8,2) DEFAULT 0,               -- Final fare after adding services, calculated via trigger
    SeatNumber VARCHAR(5) NOT NULL,                 -- Seat number (must be specified)
    Class VARCHAR(15) CHECK (Class IN ('Economy', 'Business', 'FirstClass')), -- Seat class with constraint 	
    EBoardingNumber NVARCHAR(20) NOT NULL UNIQUE,   -- Unique e-boarding number per ticket   
    IssuedBy INT NOT NULL,                          -- References Employee who issued the ticket   
    -- Foreign key constraints to maintain referential integrity
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID) ON DELETE CASCADE, -- Delete ticket if passenger is deleted
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID) ON DELETE CASCADE,          -- Delete ticket if flight is deleted
    FOREIGN KEY (IssuedBy) REFERENCES Employee(EmployeeID) ON DELETE NO ACTION,    -- Prevent deletion if employee has issued tickets
    -- Composite unique constraint to ensure no two tickets share the same seat on a flight
    CONSTRAINT UC_SeatNumber UNIQUE (SeatNumber, FlightID)
);


-- Create the Reservation table to store passenger flight bookings
CREATE TABLE Reservation (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY, -- Unique ID for each reservation, auto-incremented
    PNR VARCHAR(20) NOT NULL UNIQUE, -- PNR (Passenger Name Record), uniquely identifies the booking
    PassengerID INT NOT NULL, -- Reference to the Passenger who made the reservation
    FlightID INT NOT NULL, -- Reference to the Flight that is being booked
    Status VARCHAR(10) CHECK (Status IN ('Confirmed', 'Pending', 'Cancelled')), -- Status of the reservation (only allows predefined values)
    BookingDate DATETIME DEFAULT SYSDATETIME(), -- Timestamp for when the reservation was made; defaults to current system date and time
	-- Foreign key constraint to ensure the passenger exists; deletes the reservation if the passenger is deleted
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID) ON DELETE CASCADE,
	-- Foreign key constraint to ensure the flight exists; deletes the reservation if the flight is deleted
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID) ON DELETE CASCADE
);


 -- Baggage table to store baggage details associated with each ticket
CREATE TABLE Baggage (
    BaggageID INT PRIMARY KEY IDENTITY(1,1), -- Unique identifier for each baggage entry, auto-incremented
    TicketID INT NOT NULL, -- Foreign key linking this baggage to a specific ticket
    Weight DECIMAL(5,2) NOT NULL, -- Weight of the baggage in kilograms (supports up to 999.99 kg)
    Status VARCHAR(10) CHECK (Status IN ('CheckedIn', 'Loaded')), -- Current status of the baggage; only allows 'CheckedIn' or 'Loaded'
    BaggageFee DECIMAL(8,2) DEFAULT 0,   -- Additional fee for this baggage if any; defaults to 0
	-- Enforce referential integrity by linking to the Ticket table; delete baggage if the related ticket is deleted
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID) ON DELETE CASCADE
);


-- Create the AdditionalServices table to track extra services purchased for a ticket
CREATE TABLE AdditionalServices (
    ServiceID INT PRIMARY KEY IDENTITY(1,1), -- Unique identifier for each additional service entry, auto-incremented
    TicketID INT NOT NULL,-- Foreign key referencing the Ticket to which the service is linked
    Quantity INT CHECK (Quantity > 0), -- Number of units of the service purchased (e.g., meals, extra legroom); must be greater than 0
	ServicePriceID INT, -- Foreign key referencing the specific service price (e.g., price for a meal, Wi-Fi, etc.)
	-- Ensure referential integrity by linking the service to a specific ticket; cascade delete on ticket deletion
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID) ON DELETE CASCADE,
	-- Link to the ServicePrices table to fetch unit price of the service
	FOREIGN KEY (ServicePriceID) REFERENCES ServicePrices(ServicePriceID)
);

-- Create the ServicePrices table to store pricing details of each type of additional service
CREATE TABLE ServicePrices (
    ServicePriceID INT PRIMARY KEY IDENTITY(1,1), -- Unique identifier for each service pricing entry, auto-incremented
    ServiceType VARCHAR(20),  -- e.g., 'Extra Baggage', 'Upgraded Meal'
    UnitPrice DECIMAL(8,2) NOT NULL  -- Unit price for the service
);


-- creating roles for granting access
CREATE ROLE [Ticketing Staff];
CREATE ROLE [Ticketing Supervisor];

-- Granting permissions for Ticketing Staff
GRANT SELECT, INSERT, UPDATE ON Ticket TO [Ticketing Staff];

-- Granting additional permissions for Ticketing Supervisor
GRANT SELECT, INSERT, UPDATE, DELETE ON Employee TO [Ticketing Supervisor];

-- Task 1.2
-- Entering the data into the database. 
-- Adding data to the employee table.
EXEC AddNewEmployee 'Liam Thompson', 'liam.thompson@ticketingcompany.com', 'Ticketing Staff', 'SecurePass123';
EXEC AddNewEmployee 'Olivia Harris', 'olivia.harris@ticketingcompany.com', 'Ticketing Supervisor', 'SecurePass456';
EXEC AddNewEmployee 'Alice Johnson', 'alice.johnson@ticketingcompany.com', 'Ticketing Staff', 'StrongPass789';
EXEC AddNewEmployee 'Michael Williams', 'michael.williams@ticketingcompany.com', 'Ticketing Supervisor', 'Pass@456';
EXEC AddNewEmployee 'David Miller', 'david.miller@ticketingcompany.com', 'Ticketing Staff', 'P@ssword123';
EXEC AddNewEmployee 'Sophia Davis', 'sophia.davis@ticketingcompany.com', 'Ticketing Staff', 'MightySecure789';
EXEC AddNewEmployee 'Chris Brown', 'chris.brown@ticketingcompany.com', 'Ticketing Supervisor', 'PassW0rds@2025';


-- Inserting into flight table
INSERT INTO Flight (flightNumber, departureTime, arrivalTime, origin, destination)
VALUES 
('AI101', '2025-04-01 08:00:00', '2025-04-01 10:00:00', 'New York', 'Los Angeles'),
('AI102', '2025-04-01 09:00:00', '2025-04-01 11:00:00', 'Los Angeles', 'Chicago'),
('AI103', '2025-04-01 12:00:00', '2025-04-01 14:00:00', 'Chicago', 'Dallas'),
('AI104', '2025-04-02 07:00:00', '2025-04-02 09:00:00', 'Dallas', 'San Francisco'),
('AI105', '2025-04-02 13:00:00', '2025-04-02 15:00:00', 'San Francisco', 'New York'),
('AI106', '2025-04-03 15:00:00', '2025-04-03 17:00:00', 'Los Angeles', 'Miami'),
('AI107', '2025-04-03 16:00:00', '2025-04-03 18:00:00', 'Miami', 'Chicago');


-- Inserting innto Passenger table
INSERT INTO Passenger (PNR, Email, MealType, DateOfBirth, FirstName, LastName, EmergencyContact)
VALUES 
('PNR001', 'johnpassenger@example.com', 'Vegetarian', '1985-05-15', 'John', 'Doe', '1234567890'),
('PNR002', 'janepassenger@example.com', 'Non-Vegetarian', '1990-08-25', 'Jane', 'Smith', '2345678901'),
('PNR003', 'alicepassenger@example.com', 'Non-Vegetarian', '1982-03-30', 'Alice', 'Brown', '3456789012'),
('PNR004', 'bobpassenger@example.com', 'Vegetarian', '1987-11-10', 'Bob', 'White', '4567890123'),
('PNR005', 'charliepassenger@example.com', 'Non-Vegetarian', '1992-06-20', 'Charlie', 'Black', '5678901234'),
('PNR006', 'davidpassenger@example.com', 'Vegetarian', '1980-02-17', 'David', 'Green', '6789012345'),
('PNR007', 'evapassenger@example.com', 'Non-Vegetarian', '1986-12-05', 'Eva', 'Blue', '7890123456');


-- Inserting innto Ticket table
INSERT INTO Ticket (PassengerID, FlightID, BaseFare,  SeatNumber, Class, EBoardingNumber, IssuedBy)
VALUES 
(1, 1, 500.00,  '12A', 'Economy', 'EBN001', 1),
(2, 2, 450.00,  '15B', 'Business', 'EBN002', 2),
(3, 3, 600.00,  '10C', 'FirstClass', 'EBN003', 1),
(4, 4, 400.00,  '18D', 'Economy', 'EBN004', 1),
(5, 5, 700.00,  '5E', 'FirstClass', 'EBN005', 2),
(6, 6, 350.00,  '20F', 'Economy', 'EBN006', 1),
(7, 7, 450.00,  '8G', 'Business', 'EBN007', 2);

-- Inserting innto Reservation table
INSERT INTO Reservation (PNR, PassengerID, FlightID, Status, BookingDate)
VALUES 
('PNR001', 1, 1, 'Confirmed', GETDATE()),
('PNR002', 2, 2, 'Pending', GETDATE()),
('PNR003', 3, 3, 'Confirmed', GETDATE()),
('PNR004', 4, 4, 'Cancelled', GETDATE()),
('PNR005', 5, 5, 'Confirmed', GETDATE()),
('PNR006', 6, 6, 'Pending', GETDATE()),
('PNR007', 7, 7, 'Confirmed', GETDATE());


-- Inserting innto Baggage table
INSERT INTO Baggage (TicketID, Weight, Status, BaggageFee)
VALUES
(1, 30.0, 'CheckedIn', 75.00),  
(2, 12.5, 'Loaded', 0),         
(3, 25.0, 'CheckedIn', 60.00),  
(4, 18.0, 'Loaded', 0),         
(5, 22.0, 'CheckedIn', 45.00),  
(6, 22.0, 'Loaded', 35.00),     
(7, 22.0, 'CheckedIn', 15.00);  

-- Insert additional services for each ticket
INSERT INTO AdditionalServices (TicketID, Quantity, ServicePriceID)
VALUES
(1, 7, 1),    
(2, 4, 2),    
(3, 6, 3),    
(4, 2, 1),    
(5, 1, 2),    
(6, 5, 3),    
(7, 3, 2);    

-- Inserting into the ServicePrices table
INSERT INTO ServicePrices (ServiceType, UnitPrice)
VALUES
('Extra Baggage', 50.00),            
('Upgraded Meal', 20.00),             
('Preferred Seat', 30.00),           
('Lounge Access', 40.00),             
('Priority Boarding', 25.00),         
('Wi-Fi Access', 10.00),             
('Additional Legroom', 35.00);        

-- For displaying all the tables:


-- Question 2. 
-- Add the constraint to check that the reservation date is not in the past.
ALTER TABLE Reservation
ADD CONSTRAINT CHK_Reservation_BookingDate
CHECK (CAST(BookingDate AS DATE) >= CAST(GETDATE() AS DATE));

-- (Testing the constraint) This should fail if the constraint is working correctly
INSERT INTO Reservation (PNR, PassengerID, FlightID, Status, BookingDate)
VALUES ('TEST123', 1, 1, 'Confirmed', '2020-01-01');


-- 3 Identify Passengers with Pending Reservations and Passengers with age more than 40
-- years.
SELECT pass.PassengerID, pass.FirstName,pass.LastName, pass.DateOfBirth, res.Status
FROM Passenger pass
JOIN Reservation res ON pass.PassengerID = res.PassengerID
WHERE res.Status = 'Pending'
   AND DATEDIFF(YEAR, pass.DateOfBirth, GETDATE()) > 40;

DROP VIEW EmployeeTicketRevenue;


-- Question 4 (a) Search the database of the ticketing system for matching character strings by last
-- name of passenger. Results should be sorted with most recent issued ticket first.

-- Stored procedure to search passengers by their last name
CREATE PROCEDURE SearchPassengerByLastName
    @LastName NVARCHAR(50)  -- Input parameter: Last name of the passenger to search for
AS
BEGIN
    -- Select relevant details about passengers and their tickets
    SELECT
        p.PNR,                    -- Passenger Reservation Number (PNR)
        p.FirstName,              -- Passenger's first name
        p.LastName,               -- Passenger's last name
        p.Email,                  -- Passenger's email address
        p.MealType,               -- Type of meal chosen by the passenger
        t.IssueDate               -- The date when the ticket was issued
    FROM 
        Passenger p              -- From the Passenger table
    JOIN 
        Ticket t                 -- Join with the Ticket table on PassengerID to get ticket info
        ON p.PassengerID = t.PassengerID
    WHERE 
        p.LastName LIKE '%' + @LastName + '%'  -- Filter records where last name contains the search term
    ORDER BY 
        t.IssueDate DESC;        -- Sort by ticket issue date in descending order (most recent first)
END;




-- Question 4 (b) Return a full list of passengers and his/her specific meal requirement in business class
-- who has a reservation today (i.e., the system date when the query is run)
CREATE PROCEDURE GetBusinessClassReservationsForToday
AS
BEGIN
    SELECT
        p.PNR,
        p.FirstName,
        p.LastName,
        p.MealType,
        r.FlightID,
        t.IssueDate
    FROM 
        Passenger p
    JOIN 
        Reservation r ON p.PassengerID = r.PassengerID -- Assuming the link is by PassengerID
    JOIN 
        Ticket t ON r.FlightID = t.FlightID -- Assuming the link is by FlightID
    WHERE 
        t.Class = 'Business' AND
        t.IssueDate = CAST(GETDATE() AS DATE); -- Today's date
END;
select * from TransactionLog



-- Question 4 (c) Insert a new employee into the database.
CREATE PROCEDURE AddNewEmployee
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Role NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HashedPassword VARBINARY(64);
    DECLARE @LoginName NVARCHAR(100) = @Name;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Action NVARCHAR(200);
    DECLARE @Timestamp DATETIME = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Check if employee with duplicate email exists
        IF EXISTS (SELECT 1 FROM Employee WHERE Email = @Email)
        BEGIN
            -- Log the duplicate email failure into TransactionLog
            INSERT INTO TransactionLog (Action, Timestamp, Details)
            VALUES ('AddNewEmployee Failed - Duplicate Email', @Timestamp, @Email);
            -- Log to the ErrorLog as well
            INSERT INTO ErrorLog (ErrorMessage, ErrorProcedure, ErrorDate)
            VALUES ('Employee with email already exists.', 'AddNewEmployee', GETDATE());
            -- Rollback transaction and exit
            ROLLBACK TRANSACTION;
            PRINT 'Employee with email already exists. Transaction rolled back.';  -- Make sure this is visible
            RETURN;
        END
        -- Hash password before inserting into the database
        SET @HashedPassword = HASHBYTES('SHA2_256', CONVERT(VARBINARY(100), @Password));
        -- Insert new employee into the Employee table
        INSERT INTO Employee (Name, Email, Role, Password)
        VALUES (@Name, @Email, @Role, CONVERT(NVARCHAR(100), @HashedPassword));
        -- Create Login if not exists
        IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = @LoginName)
        BEGIN
            SET @SQL = 'CREATE LOGIN [' + @LoginName + '] WITH PASSWORD = ''' + @Password + '''';
            EXEC(@SQL);
        END
        -- Create User if not exists
        IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = @LoginName)
        BEGIN
            SET @SQL = 'CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + ']';
            EXEC(@SQL);
        END
        -- Assign Role if it exists
        IF EXISTS (SELECT * FROM sys.database_principals WHERE name = @Role)
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM sys.database_role_members drm
                JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
                JOIN sys.database_principals u ON drm.member_principal_id = u.principal_id
                WHERE r.name = @Role AND u.name = @LoginName
            )
            BEGIN
                SET @SQL = 'EXEC sp_addrolemember ''' + @Role + ''', ''' + @LoginName + '''';
                EXEC(@SQL);
            END
        END
        ELSE
        BEGIN
            PRINT 'Role does not exist: ' + @Role;
        END
        COMMIT TRANSACTION;
        -- Log success to the TransactionLog
        SET @Action = 'AddNewEmployee Success';
        INSERT INTO TransactionLog (Action, Timestamp, Details)
        VALUES (@Action, @Timestamp, 'Employee added: ' + @Email); 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        -- Log error to ErrorLog
        INSERT INTO ErrorLog (ErrorMessage, ErrorProcedure, ErrorDate)
        VALUES (ERROR_MESSAGE(), 'AddNewEmployee', GETDATE());
        PRINT 'An error occurred: ' + ERROR_MESSAGE();  -- Print error message
    END CATCH
END;


EXEC AddNewEmployee 
    @Name = 'John Doe', 
    @Email = 'johndoe@airport.com', 
    @Role = 'Ticketing Staff', 
    @Password = 'securePassword123';



-- Question 4 (d)  Update the details for a passenger that has booked a flight before.
CREATE PROCEDURE UpdatePassengerDetails
    @PNR NVARCHAR(50),
    @NewFirstName NVARCHAR(100),
    @NewLastName NVARCHAR(100),
    @NewEmail NVARCHAR(100),
    @NewMealRequirement NVARCHAR(50)
AS
BEGIN
    UPDATE Passenger
    SET 
        FirstName = @NewFirstName,
        LastName = @NewLastName,
        Email = @NewEmail,
        MealType = @NewMealRequirement
    WHERE PNR = @PNR;
END;


-- Excecution and Usage Commands of Stored Procedures. 
-- 4a
EXEC SearchPassengerByLastName @LastName = 'Smith';

-- 4b
EXEC GetBusinessClassReservationsForToday;

-- 4c
EXEC AddNewEmployee @Name = 'John Doe22', @Email = 'johndoe22@example.com', 
@Role = 'Ticketing Supervisor', @Password = 'password1233';

-- 4d
EXEC UpdatePassengerDetails 
    @PNR = 'PNR001', 
    @NewFirstName = 'John', 
    @NewLastName = 'Smith', 
    @NewEmail = 'johnsmith@example.com', 
    @NewMealRequirement = 'Vegetarian';

select * from Employee


--Question 5
-- The ticketing system wants to be able to view all e-boarding numbers Issued by a Specific
-- Employee showing the overall revenue generated by that employee on a particular
-- flight. It should include details of the fare, additional baggage fees, upgraded meal or
-- preferred seat. You should create a view containing all the required information.
CREATE VIEW EmployeeTicketRevenue AS
SELECT
    e.Name AS EmployeeName, 
    t.EBoardingNumber, 
    t.FlightID, 
    SUM(t.BaseFare) AS Fare,  -- Aggregate the fare
    SUM(ISNULL(b.BaggageFee, 0)) AS BaggageFee,  -- Sum baggage fees
    SUM(ISNULL(s.UnitPrice * asv.Quantity, 0)) AS ServiceFee,  -- Calculate service fee from ServicePrice * Quantity
    SUM(t.BaseFare + ISNULL(b.BaggageFee, 0) + ISNULL(s.UnitPrice * asv.Quantity, 0)) AS TotalRevenue  -- Total revenue
FROM
    Ticket t
JOIN
    Employee e ON t.IssuedBy = e.EmployeeID  -- Join to Employee table using the IssuedBy field
LEFT JOIN
    Baggage b ON t.TicketID = b.TicketID  -- Left join to Baggage table
LEFT JOIN
    AdditionalServices asv ON t.TicketID = asv.TicketID  -- Join to AdditionalServices table
LEFT JOIN
    ServicePrices s ON asv.ServicePriceID = s.ServicePriceID  -- Join to Services table to get the ServicePrice
GROUP BY
    e.Name, t.EBoardingNumber, t.FlightID;  -- Group by these columns to get the aggregates



-- Question 6:  Create a trigger so that the current seat allotment of a passenger automatically updates
-- to reserved when the ticket is issued.
CREATE TRIGGER UpdateReservationStatus
ON Ticket
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Declare variables to hold PassengerID and PNR
    DECLARE @PassengerID INT;
    DECLARE @PNR NVARCHAR(20);
    DECLARE @Timestamp DATETIME = GETDATE();
    DECLARE @Action NVARCHAR(200);   
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Get the PassengerID from the inserted ticket
        SELECT @PassengerID = PassengerID FROM INSERTED;
        -- Get the PNR from the Passenger table using the PassengerID
        SELECT @PNR = PNR FROM Passenger WHERE PassengerID = @PassengerID;
        -- Update the Reservation table to set the Status to 'Confirmed' based on PNR
        UPDATE Reservation
        SET Status = 'Confirmed'
        WHERE PNR = @PNR;
        -- Log the transaction in the TransactionLog table
        SET @Action = 'Reservation Status Updated for PNR: ' + @PNR;
        INSERT INTO TransactionLog (Action, Timestamp, Details)
        VALUES (@Action, @Timestamp, 'Ticket inserted, status updated to Confirmed for PNR: ' + @PNR);
        -- Notify user if transaction log insertion failed
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Transaction log insertion failed for PNR: ' + @PNR;
        END
        COMMIT TRANSACTION;
        PRINT 'Transaction successfully completed. Reservation status updated to "Confirmed" for PNR: ' + @PNR;
    END TRY
    BEGIN CATCH
        -- Rollback transaction if any error occurs
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        -- Log error to the ErrorLog table
        INSERT INTO ErrorLog (ErrorMessage, ErrorProcedure, ErrorDate)
        VALUES (ERROR_MESSAGE(), 'UpdateReservationStatus', GETDATE());
        -- Notify user of error
        PRINT 'An error occurred in the trigger: ' + ERROR_MESSAGE();
    END CATCH
END;



-- Entry for testing the trigger.
INSERT INTO Ticket (PassengerID,FlightID,BaseFare,TotalFare,SeatNumber,Class,EBoardingNumber,IssuedBy)
VALUES (6, 6, 500.00,550.00,'12A','Economy','PNR006',2);

SELECT * FROM Reservation WHERE PNR = 'PNR006';


-- Example: Insert a new ticket for a passenger with PassengerID 1 and FlightID 101
INSERT INTO Ticket (PassengerID, FlightID, BaseFare, TotalFare, SeatNumber, Class, EBoardingNumber, IssuedBy)
VALUES
(4, 4, 500.00, 500.00, '12A', 'Economy', 'EBN0012', 1);
select * from Reservation
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Ticket';

ALTER TABLE Reservation
ADD CONSTRAINT CK__Reservati__Statu__4CA06362
CHECK (Status IN ('Confirmed', 'Pending', 'Cancelled', 'Reserved'));


-- Question 7: You should provide a function or view which allows the ticketing system to identify the
-- total number of baggage’s (which are checkedin) made on a specified date for a specific
-- flight.
CREATE FUNCTION dbo.GetCheckedInBaggageCount
(
    @FlightID INT,
    @SpecifiedDate DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @CheckedInBaggageCount INT;

    SELECT 
        @CheckedInBaggageCount = COUNT(b.BaggageID)
    FROM 
        Baggage b
    JOIN 
        Ticket t ON b.TicketID = t.TicketID
    WHERE 
        t.FlightID = @FlightID
        AND CAST(t.IssueDate AS DATE) = @SpecifiedDate
        AND b.Status = 'CheckedIn'; -- Only count checked-in baggage

    RETURN @CheckedInBaggageCount;
END;

-- Example call
DECLARE @Result INT;

SET @Result = dbo.GetCheckedInBaggageCount(7, '2025-04-18 00:41:47.947');

SELECT @Result AS CheckedInBaggageCount;

-- Question 8
--This stored procedure generates a summary of each flight's booking status by showing the number of 
-- booked seats and calculating the occupancy rate (assuming 50 seats per flight). 
-- It joins the Flight and Ticket tables and groups the data by flight details. 
--This helps in quickly assessing flight performance and seat utilization.
 -- (8) Part 1. 
CREATE PROCEDURE FlightStatusSummary
AS
BEGIN
    SELECT 
        F.flightNumber,
        F.departureTime,
        F.origin,
        F.destination,
        COUNT(T.TicketID) AS BookedSeats,
        -- If you want SeatCapacity, add that column to Flight table or remove this logic
        COUNT(T.TicketID) * 1.0 / NULLIF(50, 0) AS OccupancyRate  -- Assuming 50 seats for demo
    FROM 
        Flight F
    LEFT JOIN 
        Ticket T ON F.FlightID = T.FlightID
    GROUP BY 
        F.flightNumber, F.departureTime, F.origin, F.destination
END;


EXEC FlightStatusSummary;

-- 8 Part 2. 
CREATE VIEW ActiveFlightReservations AS
SELECT
    R.ReservationID,
    R.PNR,
    P.FirstName,
    P.LastName,
    F.flightNumber,
    F.origin,
    F.destination,
    R.Status AS ReservationStatus,
    R.BookingDate
FROM
    Reservation R
JOIN
    Passenger P ON R.PassengerID = P.PassengerID
JOIN
    Flight F ON R.FlightID = F.FlightID
WHERE
    R.Status = 'Confirmed';


SELECT * FROM ActiveFlightReservations;





-- Stored procedure to authenticate employee
CREATE PROCEDURE AuthenticateEmployee
    @Email NVARCHAR(100),
    @Password NVARCHAR(255),
    @Role NVARCHAR(20) OUTPUT,
    @EmployeeID INT OUTPUT,
    @StatusMessage NVARCHAR(100) OUTPUT
AS
BEGIN
    -- Start a transaction
    BEGIN TRANSACTION;

    -- Declare variables for password verification
    DECLARE @StoredPassword NVARCHAR(255), @StoredRole NVARCHAR(20), @StoredEmployeeID INT;
    DECLARE @LogMessage NVARCHAR(255);

    -- Check if the employee exists and get their details
    SELECT @StoredPassword = Password, 
           @StoredRole = Role,
           @StoredEmployeeID = EmployeeID
    FROM Employee
    WHERE Email = @Email;

    -- Check if the employee exists
    IF @StoredPassword IS NULL
    BEGIN
        SET @StatusMessage = 'Employee not found.';
        SET @Role = NULL;
        SET @EmployeeID = NULL;

        -- Log the transaction (Employee not found)
        SET @LogMessage = 'Failed authentication attempt: Employee not found';
        INSERT INTO TransactionLog (Action, PerformedBy, Details)
        VALUES (@LogMessage, @Email, 'Invalid login attempt.');

        -- Rollback transaction
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Verify the password (for simplicity, this assumes plain text comparison; use proper hashing in a real-world app)
    IF @StoredPassword = @Password
    BEGIN
        -- Authentication successful, return role and employee ID
        SET @StatusMessage = 'Authentication successful.';
        SET @Role = @StoredRole;
        SET @EmployeeID = @StoredEmployeeID;

        -- Log the transaction (successful login)
        SET @LogMessage = 'Employee logged in successfully.';
        INSERT INTO TransactionLog (Action, PerformedBy, Details)
        VALUES (@LogMessage, @Email, 'Successful login attempt.');
    END
    ELSE
    BEGIN
        -- Password mismatch
        SET @StatusMessage = 'Incorrect password.';
        SET @Role = NULL;
        SET @EmployeeID = NULL;

        -- Log the transaction (Incorrect password)
        SET @LogMessage = 'Failed authentication attempt: Incorrect password';
        INSERT INTO TransactionLog (Action, PerformedBy, Details)
        VALUES (@LogMessage, @Email, 'Failed login due to incorrect password.');
    END

    -- Commit transaction
    COMMIT TRANSACTION;
END;

-- Testing the authenticate Employee
DECLARE @Role NVARCHAR(20),
        @EmployeeID INT,
        @StatusMessage NVARCHAR(100);
--- Cheking AuthenticateEmployee Stored procedure. 
EXEC AuthenticateEmployee 
    @Email = 'bob@airport.com',
    @Password = 'staff123',
    @Role = @Role OUTPUT,
    @EmployeeID = @EmployeeID OUTPUT,
    @StatusMessage = @StatusMessage OUTPUT;

-- Display output
SELECT 
    @Role AS Role, 
    @EmployeeID AS EmployeeID, 
    @StatusMessage AS Message;



-- Trigger to update The value of totalfare in the Ticket table. 
CREATE TRIGGER SetTotalFare
ON Ticket
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update TotalFare to equal BaseFare for newly inserted rows
    UPDATE T
    SET T.TotalFare = I.BaseFare
    FROM Ticket T
    INNER JOIN inserted I ON T.TicketID = I.TicketID;
END;
GO
delete from AdditionalServices
-- To view the data of all the tables.
select * from AdditionalServices
select * from Baggage
select * from Employee
select * from Flight
select * from Passenger
select * from Reservation
select * from ServicePrices
select * from Ticket
select * from TransactionLog
select * from ErrorLog

DBCC CHECKIDENT('AdditionalServices',  RESEED, 0);

-- Table for Keeping Track of the errors occuring. 
CREATE TABLE ErrorLog (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorMessage NVARCHAR(MAX),
    ErrorLine INT,
    ErrorProcedure NVARCHAR(128),
    ErrorDate DATETIME
);
 
select * from ErrorLog

-- transaction log for keeping a track of transactions in the system. 
CREATE TABLE TransactionLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(255),        -- Description of the action performed
    PerformedBy NVARCHAR(100),   -- Employee email or ID of the person who performed the action
    Timestamp DATETIME DEFAULT GETDATE(), -- Timestamp of the action
    Details NVARCHAR(255)        -- Additional details or comments about the transaction
);
select * from TransactionLog
SELECT * 
FROM TransactionLog
ORDER BY Timestamp DESC;
-- seeing the recent logged Error
SELECT * 
FROM ErrorLog 
ORDER BY ErrorDate DESC;

-- Seeing the recent logged Transaction
SELECT * 
FROM TransactionLog 
ORDER BY LogID DESC;


-- Creating a backup for our current database.
BACKUP DATABASE AirportTicketingSystem TO DISK = 'C:\DatabaseBackup_Assignment\AirportTicketingSystem.bak';

DROP PROCEDURE AddNewEmployee;
DROP TRIGGER UpdateReservationStatus;
