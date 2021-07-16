-- Create a new stored procedure called 'MTO_CATEGORIAS' in schema 'dbo'
-- Drop the stored procedure if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'MTO_CATEGORIAS'
    AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE dbo.MTO_CATEGORIAS
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE dbo.MTO_CATEGORIAS
    @LISTAGSR VARCHAR(50)
    ,@NIVELES int
    --,@FECHADEMODIFICACION DATETIME
AS
BEGIN
    -- body of the stored procedure
    SELECT r.CODIGO AS ID_CATEGORIA
        ,'' AS ID_PADRE
        ,0 AS POSICION
        ,SUBSTRING(r.DESCRIPCION,1,150) AS NOMBRE
        ,1 AS ACTIVO
        --,@FECHADEMODIFICACION AS FECHAMODIFICACION
    FROM FACT0010 r
    UNION ALL 
    SELECT sr.CODIGO AS ID_CATEGORIA
        ,STR(sr.COD_RUBRO) AS ID_PADRE
        ,1 AS POSICION
        ,SUBSTRING(sr.DESCRIPCION,1,150) AS NOMBRE
        ,1 AS ACTIVO
        --,@FECHADEMODIFICACION AS FECHAMODIFICACION
    FROM FACT0048 sr
    INNER JOIN FACT0010 r ON (r.CODIGO = sr.COD_RUBRO)
    ORDER BY POSICION, NOMBRE
END
GO
-- example to execute the stored procedure we just created
--EXECUTE dbo.MTO_CATEGORIAS '', 2
--GO