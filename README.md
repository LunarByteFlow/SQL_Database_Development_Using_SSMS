Airport Ticketing System – SQL Implementation
Overview
This project implements a relational database schema and management procedures for an Airport Ticketing System using Microsoft SQL Server. The system is designed to handle employee management, flight bookings, ticket issuance, passenger details, baggage tracking, and additional services, along with authentication, logging, and reporting functionalities.

Features
🧑‍💼 Employee Management – Add, authenticate, and assign roles (e.g., Ticketing Staff, Supervisor).

🧍‍♂️ Passenger Management – Track personal and contact information, meal preferences, and emergency contacts.

✈️ Flight Scheduling – Maintain schedules and metadata for multiple flights.

🎫 Ticketing – Book, issue, and track tickets with seat assignment, class, and fare.

📦 Baggage Tracking – Store and retrieve baggage status and associated fees.

➕ Additional Services – Manage optional services (e.g., Wi-Fi, extra legroom).

📋 Reservation System – Create, confirm, and update reservations.

🔐 Authentication – Verify employee credentials using a stored procedure.

🔄 Triggers and Constraints – Ensure data consistency and automation.

📊 Reporting Views – Real-time revenue reporting and flight booking summaries.

📁 Logging – Track transactions and errors in dedicated tables.

💾 Database Backup – Backup capability for safety and migration.

Database Schema
Employee

Passenger

Flight

Ticket

Reservation

Baggage

AdditionalServices

ServicePrices

TransactionLog

ErrorLog

Setup Instructions
Create the Database

sql
Copy
Edit
CREATE DATABASE AirportTicketingSystem;
USE AirportTicketingSystem;
Create Tables and Relationships
Tables are created using CREATE TABLE statements with PRIMARY KEY, FOREIGN KEY, and CHECK constraints for integrity.

Insert Sample Data
Includes employees, passengers, flights, tickets, reservations, baggage, and service prices.

Stored Procedures

AddNewEmployee: Adds an employee and assigns a login and role.

SearchPassengerByLastName: Search passengers by last name.

GetBusinessClassReservationsForToday: Retrieve today’s business-class reservations.

UpdatePassengerDetails: Modify existing passenger records.

AuthenticateEmployee: Verify employee credentials.

Triggers

SetTotalFare: Automatically calculates total fare after ticket is issued.

UpdateReservationStatus: Updates reservation status to Confirmed after ticket is issued.

Views & Functions

EmployeeTicketRevenue: Calculates revenue per employee per flight.

ActiveFlightReservations: Lists confirmed reservations.

dbo.GetCheckedInBaggageCount: Returns checked-in baggage count for a flight on a given date.

Flight Status Summary
Stored procedure FlightStatusSummary summarizes bookings and occupancy rates.

Backup Command

sql
Copy
Edit
BACKUP DATABASE AirportTicketingSystem TO DISK = 'C:\DatabaseBackup_Assignment\AirportTicketingSystem.bak';
Important Notes
The system uses basic SHA2-256 hashing (via HASHBYTES) for password storage.

Logging is handled via TransactionLog and ErrorLog tables.

Sample calls for all procedures are included at the end of the script.

How to Run
Open Microsoft SQL Server Management Studio (SSMS).

Copy the script content and execute it step-by-step or all at once.

Use provided stored procedures to simulate operations.

Sample Queries
View all employees:

sql
Copy
Edit
SELECT * FROM Employee;
Authenticate an employee:

sql
Copy
Edit
EXEC AuthenticateEmployee 
    @Email = 'johndoe@example.com',
    @Password = 'yourPassword',
    @Role = @Role OUTPUT,
    @EmployeeID = @EmployeeID OUTPUT,
    @StatusMessage = @StatusMessage OUTPUT;
Author
This SQL schema and logic were implemented for academic or demonstrative purposes in the context of a task-based project.
