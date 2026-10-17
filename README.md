# 🏥 Hospital Database: SQL Analysis

A SQL Server (T-SQL) project that designs a small **hospital database** and answers real business questions about patients, doctors, departments, appointments, and revenue, from simple joins to window functions and multi-CTE reports.

## 📌 Overview
| | |
|---|---|
| **Database** | Microsoft SQL Server (T-SQL) |
| **Tables** | 7 related tables with primary and foreign keys |
| **Queries** | 16 analysis queries |
| **Skills** | JOINs, GROUP BY / HAVING, subqueries, CTEs, window functions, ranking |

## 🗂️ Database Schema
```
Departments ──< DoctorDepartments >── Doctors
                                         │
Patients ──────────< Appointments >──────┘
                         │
              ┌──────────┴──────────┐
         Treatments            Prescriptions
```
| Table | Description |
|---|---|
| `Patients` | Patient details, city, and registration date |
| `Doctors` | Doctors and their specialty |
| `Departments` | Hospital departments |
| `DoctorDepartments` | Many-to-many link between doctors and departments |
| `Appointments` | Which patient saw which doctor, when, and the status |
| `Treatments` | Treatments given in each appointment, with cost |
| `Prescriptions` | Medications, dosage, and duration per appointment |

## ❓ Business Questions Answered
**Patients**
- Which patients visited more than one doctor?
- Which patients spend more than the average patient?
- Who are the **loyal patients** (3+ visits **and** above-average spending)?
- **Patient Lifetime Value:** total visits, treatments, prescriptions, and spending per patient.
- **Spending leaderboard:** rank and % of total hospital revenue per patient.

**Doctors and departments**
- Which doctor has the highest average treatment cost?
- Which doctors have more appointments than the average doctor?
- **Doctor report:** patients, appointments, revenue, and revenue rank.
- **Top doctor by revenue in each department** (CTE + `ROW_NUMBER()`).

**Time and visits**
- Monthly appointment counts and the **busiest month** (CTE).
- Previous and next appointment for each patient (`LAG` / `LEAD`).
- Each patient's first appointment (`ROW_NUMBER()`).
- Each treatment's cost next to the patient's average cost, **without GROUP BY** (`AVG() OVER()`).

**Executive dashboard**
- Total patients, doctors, appointments, treatments, revenue, and average revenue per patient in one query.

## 💡 Example: Top Doctor by Revenue in Each Department
```sql
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
```
See [`02_analysis_queries.sql`](02_analysis_queries.sql) for the full queries.

## ▶️ How to Run
1. Open **SQL Server Management Studio (SSMS)** or Azure Data Studio.
2. Run [`01_create_database.sql`](01_create_database.sql): it creates `HospitalTrainingDB`, the tables, and sample data.
3. Run the queries in [`02_analysis_queries.sql`](02_analysis_queries.sql) one at a time.

## 📁 Project Structure
```
├── 01_create_database.sql   # Database, tables, keys, and sample data
└── 02_analysis_queries.sql  # 16 business analysis queries
```

## 👤 Author
**Waseem Mahmoud** · [LinkedIn](https://www.linkedin.com/in/waseem-mahmoud-a34154213) · [GitHub](https://github.com/waseemalali)
