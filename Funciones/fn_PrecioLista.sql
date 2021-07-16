-- Drop the function if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'PrecioLista'
    AND ROUTINE_TYPE = N'FUNCTION'
)
DROP FUNCTION dbo.PrecioLista
GO

-- Create the function in the specified schema
CREATE FUNCTION PrecioLista (@ArticuloID VARCHAR(15), @ListaPrecio INT, @IDUnicoEscala INT)
RETURNS FLOAT
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @Precio FLOAT;
    DECLARE @UtilizaEscala VARCHAR(1) = (SELECT a.UTILIZAESCALA FROM FACT0007 a WHERE a.ARTICULO = @ArticuloID)
    
    SET @Precio = (
        CASE @UtilizaEscala 
            -- Usa Escala
            WHEN 'S' THEN (
                SELECT
                    CASE @ListaPrecio
                        WHEN 1 THEN ROUND(pe.PRECIO_LISTA1, 2)
                        WHEN 2 THEN ROUND(pe.PRECIO_LISTA2, 2)
                        WHEN 3 THEN ROUND(pe.PRECIO_LISTA3, 2)
                        ELSE ROUND(pe.PRECIO_LISTA1, 2)
                    END                
                FROM FACT0063 pe
                INNER JOIN FACT0064 ep ON pe.IDPRECIO = ep.IDPRECIO
                WHERE ep.IDUNICOESCALA = @IDUnicoEscala
            )
            -- No usa Escala
            ELSE (
                SELECT
                    CASE @ListaPrecio
                        WHEN 1 THEN ROUND(a.PRECIO_LISTA1, 2) 
                        WHEN 2 THEN ROUND(a.PRECIO_LISTA2, 2)
                        WHEN 3 THEN ROUND(a.PRECIO_LISTA3, 2)
                        ELSE ROUND(a.PRECIO_LISTA1, 2) 
                    END                
                FROM FACT0007 a
                WHERE a.ARTICULO = @ArticuloID                
            )
        END
    );

    RETURN(@Precio);
END;
GO

/*** Ejemplo
-- Con Escala
DECLARE @articulo VARCHAR(15) = '50618';
DECLARE @IDUnicoEscala INT = 211726 
SELECT FACT0007.ARTICULO
    ,dbo.PrecioLista(@articulo, 1, @IDUnicoEscala) as PrecioLista
FROM FACT0007
WHERE FACT0007.ARTICULO = @articulo
GO
-- Sin Escala
DECLARE @articulo VARCHAR(15) = '29401';
DECLARE @IDUnicoEscala INT = 0
SELECT FACT0007.ARTICULO
    ,dbo.PrecioLista(@articulo, 1, @IDUnicoEscala) as PrecioLista
FROM FACT0007
WHERE FACT0007.ARTICULO = @articulo
GO
*/
