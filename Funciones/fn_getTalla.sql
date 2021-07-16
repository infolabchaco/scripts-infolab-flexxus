-- Drop the function if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'getTalla'
    AND ROUTINE_TYPE = N'FUNCTION'
)
DROP FUNCTION dbo.getTalla
GO

-- Create the function in the specified schema
CREATE FUNCTION getTalla (@IdTalla INT)
RETURNS VARCHAR(30)
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @Texto VARCHAR(30);
    
    SET @Texto = (
        SELECT DESCRIPCION
        FROM FACT0020 te
        WHERE te.IDTALLA = @IdTalla
    );

    RETURN(@Texto);
END;
GO
