-- Drop the function if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'getDescripcionEscala'
    AND ROUTINE_TYPE = N'FUNCTION'
)
DROP FUNCTION dbo.getDescripcionEscala
GO

-- Create the function in the specified schema
CREATE FUNCTION getDescripcionEscala (@ArticuloID VARCHAR(15), @IDUnicoEscala INT)
RETURNS VARCHAR(2000)
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @Texto VARCHAR(2000);
    
    SET @Texto = (
        SELECT a.DESCRIPCION + ' Talle: ' + dbo.getTalla(ea.IDTALLA) + ' Color: ' +  dbo.getModeloColor(ea.IDMODELO)
        FROM FACT0007 a
        INNER JOIN FACT0022 ea ON a.ARTICULO = ea.ARTICULO
    WHERE a.ARTICULO = @ArticuloID AND ea.IDUNICOESCALA = @IDUnicoEscala
    );

    RETURN(@Texto);
END;
GO
