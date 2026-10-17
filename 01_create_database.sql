-- ==========================================
-- Create Database
-- ==========================================

CREATE DATABASE HospitalTrainingDB;
GO

USE HospitalTrainingDB;
GO

-- ==========================================
-- Patients
-- ==========================================

CREATE TABLE Patients
(
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Gender CHAR(1),
    DateOfBirth DATE,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    City VARCHAR(50),
    RegistrationDate DATE DEFAULT GETDATE()
);

-- ==========================================
-- Doctors
-- ==========================================

CREATE TABLE Doctors
(
    DoctorID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Specialty VARCHAR(100),
    HireDate DATE,
    Phone VARCHAR(20)
);

-- ==========================================
-- Departments
-- ==========================================

CREATE TABLE Departments
(
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100)
);

-- ==========================================
-- Doctor Departments
-- ==========================================

CREATE TABLE DoctorDepartments
(
    DoctorID INT,
    DepartmentID INT,

    PRIMARY KEY (DoctorID, DepartmentID),

    FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID),

    FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);

-- ==========================================
-- Appointments
-- ==========================================

CREATE TABLE Appointments
(
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    AppointmentStatus VARCHAR(20),
    Notes VARCHAR(500),

    FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID),

    FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID)
);

-- ==========================================
-- Treatments
-- ==========================================

CREATE TABLE Treatments
(
    TreatmentID INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentID INT NOT NULL,
    TreatmentName VARCHAR(100),
    Cost DECIMAL(10,2),
    TreatmentDate DATE,

    FOREIGN KEY (AppointmentID)
        REFERENCES Appointments(AppointmentID)
);

-- ==========================================
-- Prescriptions
-- ==========================================

CREATE TABLE Prescriptions
(
    PrescriptionID INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentID INT NOT NULL,
    MedicationName VARCHAR(100),
    Dosage VARCHAR(50),
    DurationDays INT,

    FOREIGN KEY (AppointmentID)
        REFERENCES Appointments(AppointmentID)
);
------------------------------------

INSERT INTO Departments (DepartmentName)
VALUES
('Cardiology'),
('Neurology'),
('Orthopedics'),
('Pediatrics'),
('Dermatology');


INSERT INTO Doctors
(
    FirstName,
    LastName,
    Specialty,
    HireDate,
    Phone
)
VALUES
('Ahmad','Khalil','Cardiologist','2018-05-01','0799000001'),
('Sara','Hassan','Neurologist','2019-03-15','0799000002'),
('Omar','Saleh','Orthopedic Surgeon','2017-09-10','0799000003'),
('Lina','Naser','Pediatrician','2020-01-05','0799000004'),
('Yousef','Mahmoud','Dermatologist','2021-07-18','0799000005');

INSERT INTO DoctorDepartments
VALUES
(1,1),
(2,2),
(3,3),
(4,4),
(5,5);


INSERT INTO Patients
(
    FirstName,
    LastName,
    Gender,
    DateOfBirth,
    Phone,
    Email,
    City,
    RegistrationDate
)
VALUES
('Mohammad','Hamad','M','1990-05-12','0791111111','m.hamad@email.com','Amman','2024-01-01'),
('Alaa','Ali','F','1988-02-20','0791111112','alaa@email.com','Zarqa','2024-01-10'),
('Khaled','Ahmad','M','1995-08-10','0791111113','khaled@email.com','Irbid','2024-01-15'),
('Rania','Samir','F','1992-11-01','0791111114','rania@email.com','Amman','2024-02-01'),
('Yazan','Nabil','M','1985-06-14','0791111115','yazan@email.com','Aqaba','2024-02-05'),
('Hiba','Khalaf','F','1998-09-22','0791111116','hiba@email.com','Salt','2024-02-10'),
('Tariq','Odeh','M','1979-03-15','0791111117','tariq@email.com','Madaba','2024-03-01'),
('Dana','Yousef','F','1997-12-05','0791111118','dana@email.com','Amman','2024-03-10');



INSERT INTO Appointments
(
    PatientID,
    DoctorID,
    AppointmentDate,
    AppointmentStatus,
    Notes
)
VALUES
(1,1,'2025-01-05 10:00','Completed','Heart Checkup'),
(1,1,'2025-02-10 11:00','Completed','Follow Up'),
(2,2,'2025-01-08 09:00','Completed','Migraine'),
(3,3,'2025-01-15 13:00','Completed','Knee Pain'),
(4,4,'2025-01-20 15:00','Completed','Child Vaccination'),
(5,5,'2025-02-01 14:00','Completed','Skin Rash'),
(6,2,'2025-02-12 09:30','Completed','Headache'),
(7,1,'2025-02-15 08:30','Completed','Blood Pressure'),
(8,3,'2025-03-01 16:00','Completed','Back Pain'),
(1,1,'2025-03-10 12:00','Scheduled','Routine Visit');



INSERT INTO Treatments
(
    AppointmentID,
    TreatmentName,
    Cost,
    TreatmentDate
)
VALUES
(1,'ECG',75,'2025-01-05'),
(1,'Blood Test',25,'2025-01-05'),
(2,'ECG Follow-up',50,'2025-02-10'),
(3,'Brain Scan',300,'2025-01-08'),
(4,'X-Ray',120,'2025-01-15'),
(5,'Vaccination',60,'2025-01-20'),
(6,'Skin Treatment',90,'2025-02-01'),
(7,'Neurological Exam',150,'2025-02-12'),
(8,'Blood Pressure Assessment',40,'2025-02-15'),
(9,'Physical Therapy',200,'2025-03-01');


INSERT INTO Prescriptions
(
    AppointmentID,
    MedicationName,
    Dosage,
    DurationDays
)
VALUES
(1,'Aspirin','100mg',30),
(2,'Aspirin','100mg',60),
(3,'Sumatriptan','50mg',14),
(4,'Pain Reliever','500mg',10),
(5,'Vitamin D','1000IU',30),
(6,'Skin Cream','Apply Twice Daily',21),
(7,'Ibuprofen','400mg',7),
(8,'Amlodipine','5mg',90),
(9,'Muscle Relaxant','10mg',14)