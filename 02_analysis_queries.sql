--                                                        HospitalTrainingDB 
---------------------------------------------------------------------------------------------------------------------------------------------

USE HospitalTrainingDB;



----------------------------------------------------------------------------------------
--  Find patients who visited more than one doctor.
------------------------------------------------------------------------------

SELECT
    p.PatientID,
    p.FirstName,
    p.LastName,
    COUNT(DISTINCT a.DoctorID) AS DoctorsVisited
FROM Patients p
JOIN Appointments a ON p.PatientID = a.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName
HAVING COUNT(DISTINCT a.DoctorID) > 1;



----------------------------------------------------------------------------------------
--  Find the doctor with the highest average treatment cost.
----------------------------------------------------------------------------------

SELECT TOP 1
    d.DoctorID,
    d.FirstName,
    d.LastName,
    AVG(t.Cost) AS AvgTreatmentCost
FROM Doctors d
JOIN Appointments a ON d.DoctorID = a.DoctorID
JOIN Treatments t ON a.AppointmentID = t.AppointmentID
GROUP BY d.DoctorID, d.FirstName, d.LastName
ORDER BY AvgTreatmentCost DESC;



----------------------------------------------------------------------------------------
--  Find all patients whose total treatment cost exceeds
--    the average spending of all patients.
----------------------------------------------------------------------------------
WITH PatientSpending AS
(
    SELECT
        p.PatientID,
        p.FirstName,
        p.LastName,
        SUM(t.Cost) AS TotalSpending
    FROM Patients p
    JOIN Appointments a ON p.PatientID = a.PatientID
    JOIN Treatments t ON a.AppointmentID = t.AppointmentID
    GROUP BY p.PatientID, p.FirstName, p.LastName
)
SELECT *
FROM PatientSpending
WHERE TotalSpending > (SELECT AVG(TotalSpending) FROM PatientSpending);



----------------------------------------------------------------------------------------
--  Find doctors who have more appointments than the average doctor.
---------------------------------------------------------------------------------

WITH DoctorAppointments AS
(
    SELECT
        d.DoctorID,
        d.FirstName,
        d.LastName,
        COUNT(a.AppointmentID) AS AppointmentCount
    FROM Doctors d
    LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
    GROUP BY d.DoctorID, d.FirstName, d.LastName
)
SELECT *
FROM DoctorAppointments
WHERE AppointmentCount > (SELECT AVG(AppointmentCount * 1.0) FROM DoctorAppointments);



----------------------------------------------------------------------------------------
--  CTE: monthly appointment counts + busiest month
-----------------------------------------------------------------------------------

WITH MonthlyAppointments AS
(
    SELECT
        FORMAT(AppointmentDate, 'yyyy-MM') AS AppointmentMonth,
        COUNT(*) AS AppointmentCount
    FROM Appointments
    GROUP BY FORMAT(AppointmentDate, 'yyyy-MM')
)
SELECT TOP 1 *
FROM MonthlyAppointments
ORDER BY AppointmentCount DESC;



----------------------------------------------------------------------------------------
--  For every treatment, show Treatment Cost and the patient's
--    Average Treatment Cost, WITHOUT GROUP BY, using AVG() OVER()
-----------------------------------------------------------------------------------

SELECT
    p.PatientID,
    p.FirstName,
    p.LastName,
    t.TreatmentID,
    t.TreatmentName,
    t.Cost AS TreatmentCost,
    AVG(t.Cost) OVER (PARTITION BY p.PatientID) AS AvgTreatmentCostForPatient
FROM Treatments t
JOIN Appointments a ON t.AppointmentID = a.AppointmentID
JOIN Patients p ON a.PatientID = p.PatientID;



----------------------------------------------------------------------------------------
--  Previous appointment date for each patient (LAG)
-----------------------------------------------------------------------------------

SELECT
    p.PatientID,
    p.FirstName,
    p.LastName,
    a.AppointmentID,
    a.AppointmentDate,
    LAG(a.AppointmentDate) OVER (PARTITION BY p.PatientID ORDER BY a.AppointmentDate) AS PreviousAppointmentDate
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID;



----------------------------------------------------------------------------------------
--  Next appointment date for each patient (LEAD).
------------------------------------------------------------------------------------

SELECT
    p.PatientID,
    p.FirstName,
    p.LastName,
    a.AppointmentID,
    a.AppointmentDate,
    LEAD(a.AppointmentDate) OVER (PARTITION BY p.PatientID ORDER BY a.AppointmentDate) AS NextAppointmentDate
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID;



--------------------------------------------------------------------------------------------------------------
-- First appointment for every patient (ROW_NUMBER).
--------------------------------------------------------------------------------------

WITH RankedAppointments AS
(
    SELECT
        p.PatientID,
        p.FirstName,
        p.LastName,
        a.AppointmentID,
        a.AppointmentDate,
        ROW_NUMBER() OVER (PARTITION BY p.PatientID ORDER BY a.AppointmentDate) AS rn
    FROM Appointments a
    JOIN Patients p ON a.PatientID = p.PatientID
)
SELECT PatientID, FirstName, LastName, AppointmentID, AppointmentDate
FROM RankedAppointments
WHERE rn = 1;



--------------------------------------------------------------------------------------------------------
--  Percentage contribution of each patient's spending
--     to total hospital treatment revenue (SUM() OVER()).
---------------------------------------------------------------------------------------

WITH PatientSpending AS
(
    SELECT
        p.PatientID,
        p.FirstName,
        p.LastName,
        SUM(t.Cost) AS TotalSpending
    FROM Patients p
    JOIN Appointments a ON p.PatientID = a.PatientID
    JOIN Treatments t ON a.AppointmentID = t.AppointmentID
    GROUP BY p.PatientID, p.FirstName, p.LastName
)
SELECT
    PatientID,
    FirstName,
    LastName,
    TotalSpending,
    TotalSpending * 100.0 / SUM(TotalSpending) OVER () AS PercentageOfTotalRevenue
FROM PatientSpending;






-------------------------------------------------------------------------------------------------
--  Patient spending leaderboard:Rank, Patient Name, Total Spending, % of Total Revenue.
---------------------------------------------------------------------------------------

WITH PatientSpending AS
(
    SELECT
        p.PatientID,
        p.FirstName + ' ' + p.LastName AS PatientName,
        SUM(t.Cost) AS TotalSpending
    FROM Patients p
    JOIN Appointments a ON p.PatientID = a.PatientID
    JOIN Treatments t ON a.AppointmentID = t.AppointmentID
    GROUP BY p.PatientID, p.FirstName, p.LastName
)
SELECT
    RANK() OVER (ORDER BY TotalSpending DESC) AS SpendingRank,
    PatientName,
    TotalSpending,
    TotalSpending * 100.0 / SUM(TotalSpending) OVER () AS PercentageOfTotalRevenue
FROM PatientSpending
ORDER BY SpendingRank;



-- -------------------------------------------------------------------------------------------------
--  loyal patients: visited at least 3 times
--     AND spent more than the average patient.
---------------------------------------------------------------------------------------

WITH PatientStats AS
(
    SELECT
        p.PatientID,
        p.FirstName,
        p.LastName,
        COUNT(DISTINCT a.AppointmentID) AS VisitCount,
        SUM(t.Cost) AS TotalSpending
    FROM Patients p
    JOIN Appointments a ON p.PatientID = a.PatientID
    JOIN Treatments t ON a.AppointmentID = t.AppointmentID
    GROUP BY p.PatientID, p.FirstName, p.LastName
)
SELECT *
FROM patientStats
WHERE VisitCount >= 3
  AND TotalSpending > (SELECT AVG(TotalSpending) FROM PatientStats);



-- -----------------------------------------------------------------------------
--  Report: Doctor, Number of Patients, Number of Appointments,
--     Revenue Generated, Revenue Rank.
-- -------------------------------------------------------------------------------------

WITH DoctorStats AS
(
    SELECT
        d.DoctorID,
        d.FirstName + ' ' + d.LastName AS DoctorName,
        COUNT(DISTINCT a.PatientID) AS NumberOfPatients,
        COUNT(DISTINCT a.AppointmentID) AS NumberOfAppointments,
        ISNULL(SUM(t.Cost),0) AS RevenueGenerated
    FROM Doctors d
    LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
    LEFT JOIN Treatments t ON a.AppointmentID = t.AppointmentID
    GROUP BY d.DoctorID, d.FirstName, d.LastName
)
SELECT
    DoctorName,
    NumberOfPatients,
    NumberOfAppointments,
    RevenueGenerated,
    RANK() OVER (ORDER BY RevenueGenerated DESC) AS RevenueRank
FROM DoctorStats
ORDER BY RevenueRank;



-- -----------------------------------------------------------------------------------------
--  For each department: Top Doctor by Revenue + Revenue Amount.
--     (CTE + ROW_NUMBER())
-- -------------------------------------------------------------------------------------

WITH DoctorRevenue AS
(
    SELECT
        dep.DepartmentID,
        dep.DepartmentName,
        d.DoctorID,
        d.FirstName + ' ' + d.LastName AS DoctorName,
        SUM(t.Cost) AS Revenue
    FROM Departments dep
    JOIN DoctorDepartments dd ON dep.DepartmentID = dd.DepartmentID
    JOIN Doctors d ON dd.DoctorID = d.DoctorID
    JOIN Appointments a ON d.DoctorID = a.DoctorID
    JOIN Treatments t ON a.AppointmentID = t.AppointmentID
    GROUP BY dep.DepartmentID, dep.DepartmentName, d.DoctorID, d.FirstName, d.LastName
),
RankedDoctors AS
(
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY DepartmentID ORDER BY Revenue DESC) AS rn
    FROM DoctorRevenue
)
SELECT
    DepartmentName,
    DoctorName AS TopDoctor,
    Revenue AS RevenueAmount
FROM RankedDoctors
WHERE rn = 1;



-------------------------------------------------------------------------------------------
-- Patient Lifetime Value (LTV):
--     Total Visits, Total Treatments, Total Prescriptions, Total Spending.
--     
---------------------------------------------------------------------------------------

WITH Visits AS
(
    SELECT PatientID, COUNT(*) AS TotalVisits
    FROM Appointments
    GROUP BY PatientID
),
TreatmentStats AS
(
    SELECT
        a.PatientID,
        COUNT(t.TreatmentID) AS TotalTreatments,
        SUM(t.Cost) AS TotalSpending
    FROM Appointments a
    JOIN Treatments t ON a.AppointmentID = t.AppointmentID
    GROUP BY a.PatientID
),
PrescriptionStats AS
(
    SELECT
        a.PatientID,
        COUNT(pr.PrescriptionID) AS TotalPrescriptions
    FROM Appointments a
    JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
    GROUP BY a.PatientID
)
SELECT
    p.PatientID,
    p.FirstName,
    p.LastName,
    ISNULL(v.TotalVisits, 0) AS TotalVisits,
    ISNULL(ts.TotalTreatments, 0) AS TotalTreatments,
    ISNULL(ps.TotalPrescriptions, 0) AS TotalPrescriptions,
    ISNULL(ts.TotalSpending, 0) AS TotalSpending
FROM Patients p
LEFT JOIN Visits v ON p.PatientID = v.PatientID
LEFT JOIN TreatmentStats ts ON p.PatientID = ts.PatientID
LEFT JOIN PrescriptionStats ps ON p.PatientID = ps.PatientID
ORDER BY p.PatientID;



-----------------------------------------------------------------------------------------
--  Executive dashboard:
--     Total Patients, Total Doctors, Total Appointments, Total Treatments,
--------------------------------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM Patients)      AS TotalPatients,
    (SELECT COUNT(*) FROM Doctors)       AS TotalDoctors,
    (SELECT COUNT(*) FROM Appointments)  AS TotalAppointments,
    (SELECT COUNT(*) FROM Treatments)    AS TotalTreatments,
    (SELECT SUM(Cost) FROM Treatments)   AS TotalRevenue,
    (SELECT SUM(Cost) FROM Treatments) * 1.0 / (SELECT COUNT(*) FROM Patients) AS AvgRevenuePerPatient;
