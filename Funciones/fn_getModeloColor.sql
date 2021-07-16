-- Drop the function if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'getModeloColor'
    AND ROUTINE_TYPE = N'FUNCTION'
)
DROP FUNCTION dbo.getModeloColor
GO

-- Create the function in the specified schema
CREATE FUNCTION getModeloColor (@IdModeloColor INT)
RETURNS VARCHAR(30)
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @Texto VARCHAR(30);
    
    SET @Texto = (
        SELECT DESCRIPCION
        FROM FACT0021 mc
        WHERE mc.IDMODELO = @IdModeloColor
    );

    RETURN(@Texto);
END;
GO
