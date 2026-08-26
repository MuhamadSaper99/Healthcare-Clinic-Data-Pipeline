-- Creating Dim Patient
CREATE TABLE gold.DimPatient
(
    PatientSK BIGINT IDENTITY NOT NULL,

    PatientID VARCHAR(20) NOT NULL,

    FullName VARCHAR(200),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    RegistrationDate DATE,
    BloodGroup VARCHAR(10),

    InsuranceStatus VARCHAR(50),
    InsuranceProvider VARCHAR(100),
    CoverageLevel VARCHAR(50),

    StartDate DATETIME2(0),
    EndDate DATETIME2(0),
    IsCurrent BIT
);

-- Create DimPatient Changes To Implement SCD T2
CREATE TABLE gold.DimPatient_Changes
(
    PatientID VARCHAR(20),
    FullName VARCHAR(200),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    RegistrationDate DATE,
    BloodGroup VARCHAR(10),

    InsuranceStatus VARCHAR(50),
    InsuranceProvider VARCHAR(100),
    CoverageLevel VARCHAR(50),

    RowStatus VARCHAR(20)
);

-- Create Dim Doctor
CREATE TABLE gold.DimDoctor
(
    DoctorSK BIGINT IDENTITY NOT NULL,

    DoctorID VARCHAR(20) NOT NULL,

    FullName VARCHAR(200),
    Specialty VARCHAR(100),
    ClinicID VARCHAR(20),

    StartDate DATETIME2(0),
    EndDate DATETIME2(0),

    IsCurrent BIT
);

-- Create DimDoctor Changes to Implement SCD T2
CREATE TABLE gold.DimDoctor_Changes
(
    DoctorID VARCHAR(20),

    FullName VARCHAR(200),
    Specialty VARCHAR(100),
    ClinicID VARCHAR(20),

    RowStatus VARCHAR(20)
);

-- Create DimClinic
CREATE TABLE gold.DimClinic
(
    ClinicSK BIGINT IDENTITY NOT NULL,

    ClinicID VARCHAR(20) NOT NULL,
    ClinicName VARCHAR(200),
    Address VARCHAR(300),
    City VARCHAR(100),
    State VARCHAR(100),
    OpeningHours VARCHAR(100),
    ClinicType VARCHAR(100)
);
----------------------------
-- Create Dim Treatment
CREATE TABLE gold.DimTreatment
(
    TreatmentSK BIGINT IDENTITY NOT NULL,

    TreatmentID VARCHAR(20) NOT NULL,
    TreatmentType VARCHAR(100),
    TreatmentStatus VARCHAR(50)
);
ALTER TABLE gold.DimTreatment
ADD AppointmentID VARCHAR(20);

------------------------------------
-- Create Dim Medicine
CREATE TABLE gold.DimMedicine
(
    MedicineSK BIGINT IDENTITY NOT NULL,

    PrescriptionID VARCHAR(20) NOT NULL,
    AppointmentID VARCHAR(20) NOT NULL,

    MedicineName VARCHAR(200),
    Instructions VARCHAR(500)
);
-------------------------------------------
-- Create Dim Appointment
CREATE TABLE gold.DimAppointment
(
    AppointmentSK BIGINT IDENTITY NOT NULL,

    AppointmentID VARCHAR(20) NOT NULL,

    AppointmentStatus VARCHAR(50),
    ReasonForVisit VARCHAR(300),

    PaymentStatus VARCHAR(50),
    PaymentMethod VARCHAR(50)
);

-----------------------------------------------
-- Create Dim Date
CREATE TABLE gold.DimDate
(
    DateSK INT NOT NULL,

    FullDate DATE NOT NULL,

    DayNumber SMALLINT,
    DayName VARCHAR(20),

    WeekNumber SMALLINT,

    MonthNumber SMALLINT,
    MonthName VARCHAR(20),

    QuarterNumber SMALLINT,

    YearNumber SMALLINT,

    IsWeekend BIT
);

----------------------------------------
-- Filling Date Dim
INSERT INTO gold.DimDate
(
    DateSK,
    FullDate,
    DayNumber,
    DayName,
    WeekNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber,
    IsWeekend
)
SELECT
    YEAR(D.DateValue) * 10000
        + MONTH(D.DateValue) * 100
        + DAY(D.DateValue)                    AS DateSK,

    D.DateValue                              AS FullDate,

    DAY(D.DateValue)                         AS DayNumber,

    DATENAME(WEEKDAY, D.DateValue)           AS DayName,

    DATEPART(WEEK, D.DateValue)              AS WeekNumber,

    MONTH(D.DateValue)                       AS MonthNumber,

    DATENAME(MONTH, D.DateValue)             AS MonthName,

    DATEPART(QUARTER, D.DateValue)           AS QuarterNumber,

    YEAR(D.DateValue)                        AS YearNumber,

    CASE
        WHEN DATENAME(WEEKDAY, D.DateValue) IN ('Saturday','Sunday')
        THEN 1
        ELSE 0
    END                                      AS IsWeekend
FROM
(
    SELECT DATEADD(DAY, value, CAST('2022-01-01' AS DATE)) AS DateValue
    FROM GENERATE_SERIES
    (
        0,
        DATEDIFF(DAY, '2022-01-01', '2040-12-31')
    )
) D;
--------------------------------------------------------------------------------------
-- Creating Fact
CREATE TABLE gold.FactAppointment
(
    AppointmentSK BIGINT NOT NULL,
    PatientSK BIGINT NOT NULL,
    DoctorSK BIGINT NOT NULL,
    ClinicSK BIGINT NOT NULL,
    TreatmentSK BIGINT NOT NULL,
    MedicineSK BIGINT NOT NULL,
    DateSK INT NOT NULL,

    PaymentAmount DECIMAL(18,2) NULL
);

-- 1. Rename DateSK to AppointmentDateSK
EXEC sp_rename
    'gold.FactAppointment.DateSK',
    'AppointmentDateSK',
    'COLUMN';

-- 2. Adding PaymentDateSK
ALTER TABLE gold.FactAppointment
ADD PaymentDateSK INT NULL;

-------------------------------------
-- Create ColorTheme table
CREATE TABLE dbo.ColorTheme
(
    ModeName   VARCHAR(10)  NOT NULL ,
    BG         CHAR(7)      NOT NULL,
    VisualBG   CHAR(7)      NOT NULL,
    TextColor  CHAR(7)      NOT NULL,
    LabelColor CHAR(7)      NOT NULL
);

-- Insert theme values
INSERT INTO dbo.ColorTheme
(
    ModeName,
    BG,
    VisualBG,
    TextColor,
    LabelColor
)
VALUES
('Light', '#F8F7F8', '#FFFFFF', '#605E5C', '#000000'),
('Dark',  '#07171A', '#102126', '#E6E6E6', '#FFFFFF');