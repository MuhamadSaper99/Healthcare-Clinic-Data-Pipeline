-- Patient Stored Procedure
CREATE OR ALTER PROCEDURE gold.usp_Load_DimPatient
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @LoadDate DATETIME2(0) = GETDATE();

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- Close Current Record
        ------------------------------------------------------------
        UPDATE D
        SET
            EndDate = @LoadDate,
            IsCurrent = 0
        FROM gold.DimPatient D
        INNER JOIN gold.DimPatient_Changes C
            ON D.PatientID = C.PatientID
        WHERE
            D.IsCurrent = 1
            AND C.RowStatus = 'Changed';

        ------------------------------------------------------------
        -- Insert New Version
        ------------------------------------------------------------
        INSERT INTO gold.DimPatient
        (
            PatientID,
            FullName,
            Gender,
            DateOfBirth,
            RegistrationDate,
            BloodGroup,
            InsuranceStatus,
            InsuranceProvider,
            CoverageLevel,
            StartDate,
            EndDate,
            IsCurrent
        )
        SELECT
            PatientID,
            FullName,
            Gender,
            DateOfBirth,
            RegistrationDate,
            BloodGroup,
            InsuranceStatus,
            InsuranceProvider,
            CoverageLevel,
            @LoadDate,
            NULL,
            1
        FROM gold.DimPatient_Changes
        WHERE RowStatus IN ('New','Changed');

        ------------------------------------------------------------
        -- Clear Changes Table
        ------------------------------------------------------------
        TRUNCATE TABLE gold.DimPatient_Changes;

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH

END;
GO

--------------------------------------------------------------
-- Doctors Stored Procedure
CREATE OR ALTER PROCEDURE gold.usp_Load_DimDoctor
AS
BEGIN

    ------------------------------------------------------------
    -- Close Current Records
    ------------------------------------------------------------
    UPDATE D
    SET
        D.EndDate = CURRENT_TIMESTAMP,
        D.IsCurrent = 0
    FROM gold.DimDoctor D
    INNER JOIN gold.DimDoctor_Changes C
        ON D.DoctorID = C.DoctorID
    WHERE
        C.RowStatus = 'Changed'
        AND D.IsCurrent = 1;


    ------------------------------------------------------------
    -- Insert New & Changed Records
    ------------------------------------------------------------
    INSERT INTO gold.DimDoctor
    (
        DoctorID,
        FullName,
        Specialty,
        ClinicID,
        StartDate,
        EndDate,
        IsCurrent
    )
    SELECT
        DoctorID,
        FullName,
        Specialty,
        ClinicID,
        CURRENT_TIMESTAMP,
        NULL,
        1
    FROM gold.DimDoctor_Changes
    WHERE RowStatus IN ('New', 'Changed');


    ------------------------------------------------------------
    -- Clear Staging Table
    ------------------------------------------------------------
    TRUNCATE TABLE gold.DimDoctor_Changes;

END;
GO