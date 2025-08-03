# ✈️ Airport Ticketing System – SQL Implementation

## 🗒️ Overview

This project implements a **relational database** for an **Airport Ticketing System** using **Microsoft SQL Server**. It provides full support for:

- Employee management
- Flight bookings
- Ticket issuance
- Passenger records
- Baggage tracking
- Additional services
- Authentication & security
- Error logging
- Revenue reporting

---

## 💡 Features

- 👩‍💼 **Employee Management**  
  Add, authenticate, and assign roles (e.g., `Ticketing Staff`, `Supervisor`).

- 🧍‍♂️ **Passenger Management**  
  Track personal info, contact details, meal preferences, and emergency contacts.

- 🛫 **Flight Scheduling**  
  Maintain departure, arrival, and route information for each flight.

- 🎟️ **Ticketing**  
  Book and manage tickets with seat number, class, fare, and boarding details.

- 🧳 **Baggage Tracking**  
  Store baggage weights, fees, and check-in/load statuses.

- ➕ **Additional Services**  
  Offer premium services (Wi-Fi, legroom, lounge access, etc.).

- 📋 **Reservation System**  
  Manage booking statuses (`Confirmed`, `Pending`, `Cancelled`, `Reserved`).

- 🔐 **Authentication**  
  Authenticate employees via stored procedures with hashed passwords.

- ⚙️ **Triggers & Constraints**  
  Enforce data integrity and automate updates.

- 📈 **Reporting Views**  
  Track revenues per employee, reservation summaries, and occupancy rates.

- 📝 **Logging**  
  Log all transactions and errors for audit and debugging.

- 💾 **Database Backup**  
  Create `.bak` backup files for data safety and migration.

---

## 🧱 Database Schema

- `Employee`  
- `Passenger`  
- `Flight`  
- `Ticket`  
- `Reservation`  
- `Baggage`  
- `AdditionalServices`  
- `ServicePrices`  
- `TransactionLog`  
- `ErrorLog`

---

## ⚙️ Setup Instructions

### 1. Create the Database
```sql
CREATE DATABASE AirportTicketingSystem;
USE AirportTicketingSystem;
