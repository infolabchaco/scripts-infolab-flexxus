-- Drop the function if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'FechaVigenciaPromoDesde'
    AND ROUTINE_TYPE = N'FUNCTION'
)
DROP FUNCTION dbo.FechaVigenciaPromoDesde
GO

-- Create the function in the specified schema
CREATE FUNCTION FechaVigenciaPromoDesde (@ArticuloID VARCHAR(15), @IDUnicoEscala INT)
RETURNS DATETIME
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @Fecha DATETIME;
    
    SET @Fecha = (
        SELECT
        CASE WHEN a.UTILIZAESCALA <> 'S'
            -- No usa Escala
            THEN
                CASE WHEN a.PROMOCIONSTK = 1 AND a.FECHAVIGENCIA <= GETDATE()
                    THEN a.FECHAVIGENCIA
                    ELSE '01/01/1900'
                END
            -- Usa Escala
            ELSE (
                SELECT
                    CASE WHEN pe.PROMOCIONPES = 1 AND pe.FECHAVIGENCIA <= GETDATE()
                        THEN pe.FECHAVIGENCIA
                        ELSE '01/01/1900'
                    END
                FROM FACT0063 pe
                INNER JOIN FACT0007 a ON a.ARTICULO = pe.ARTICULO
                INNER JOIN FACT0064 ep ON pe.IDPRECIO = ep.IDPRECIO
                WHERE a.ARTICULO = @ArticuloID AND ep.IDUNICOESCALA = @IDUnicoEscala
            )
        END
    FROM FACT0007 a
    WHERE a.ARTICULO = @ArticuloID
    );

    RETURN(@Fecha);
END;
GO

/*
--Ejemplo
DECLARE @articulo VARCHAR(15) = '04447';
DECLARE @escala INT = 30955;
-- Con escala
SELECT FACT0007.ARTICULO, dbo.FechaVigenciaPromoDesde(@articulo, @escala) as FechaDesde
FROM FACT0007
WHERE FACT0007.ARTICULO = @articulo
GO
-- Sin Escala
-- ...
-- Con Escala y Sin Promo 
-- >>> 1900-01-01 00:00:00.000*/