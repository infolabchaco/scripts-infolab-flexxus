-- Drop the function if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'PrecioPromocion'
    AND ROUTINE_TYPE = N'FUNCTION'
)
DROP FUNCTION dbo.PrecioPromocion
GO

-- Create the function in the specified schema
CREATE FUNCTION PrecioPromocion (@ArticuloID VARCHAR(15), @IDUnicoEscala INT)
RETURNS FLOAT
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @Precio FLOAT;
    DECLARE @UtilizaEscala VARCHAR(1) = (SELECT a.UTILIZAESCALA FROM FACT0007 a WHERE a.ARTICULO = @ArticuloID)
    
    SET @Precio = (
        CASE @UtilizaEscala
            WHEN 'S' THEN (
                -- Usa Escala
                SELECT 
                    CASE WHEN (pe.FECHAVIGENCIA <= GETDATE() AND pe.HASTAFECHAVIGENCIA >= GETDATE() AND pe.PROMOCIONPES = 1)  
                        THEN (
                            CASE pe.UTILIZAPRECIOOFERTA
                                WHEN 'Porcentaje' THEN (
                                    CASE pe.LISTAOFERTA
                                        WHEN 'Lista 1'
                                            THEN ROUND(pe.PRECIO_LISTA1 - (pe.PRECIO_LISTA1 * pe.PRECIOOFERTA), 2)
                                        WHEN 'Lista 2'
                                            THEN ROUND(pe.PRECIO_LISTA2 - (pe.PRECIO_LISTA2 * pe.PRECIOOFERTA), 2)
                                        WHEN 'Lista 3'
                                            THEN ROUND(pe.PRECIO_LISTA3 - (pe.PRECIO_LISTA3 * pe.PRECIOOFERTA), 2)
                                        ELSE 0
                                    END                                    
                                )
                                WHEN 'Precio' THEN ROUND(pe.PRECIOOFERTA, 2)
                                WHEN 'Lista' THEN (
                                    CASE pe.LISTAOFERTA
                                        WHEN 'Lista 1'
                                            THEN ROUND(pe.PRECIO_LISTA1, 2)
                                        WHEN 'Lista 2'
                                            THEN ROUND(pe.PRECIO_LISTA2, 2)
                                        WHEN 'Lista 3'
                                            THEN ROUND(pe.PRECIO_LISTA3, 2)
                                        -- Devuelve Lista1 por default                                        
                                        ELSE ROUND(pe.PRECIO_LISTA1, 2) 
                                    END                                
                                )
                            END
                        )
                    ELSE 0
                    END 
                FROM FACT0063 pe
                INNER JOIN FACT0064 ep ON pe.IDPRECIO = ep.IDPRECIO
                WHERE ep.IDUNICOESCALA = @IDUnicoEscala
            )
            -- No usa Escala            
            ELSE (
                SELECT
                    CASE WHEN (a.FECHAVIGENCIA <= GETDATE() AND a.HASTAFECHAVIGENCIA >= GETDATE() AND a.PROMOCIONSTK = 1)
                        THEN (
                            CASE a.UTILIZAPRECIOOFERTA
                                WHEN 'Porcentaje' THEN (
                                    CASE a.LISTAOFERTA
                                        WHEN 'Lista 1'
                                            THEN ROUND(a.PRECIO_LISTA1 - (a.PRECIO_LISTA1 * a.PRECIOOFERTA), 2)
                                        WHEN 'Lista 2'
                                            THEN ROUND(a.PRECIO_LISTA2 - (a.PRECIO_LISTA2 * a.PRECIOOFERTA), 2)
                                        WHEN 'Lista 3'
                                            THEN ROUND(a.PRECIO_LISTA3 - (a.PRECIO_LISTA3 * a.PRECIOOFERTA), 2)
                                        ELSE 0
                                    END                                    
                                )
                                WHEN 'Precio' THEN ROUND(a.PRECIOOFERTA, 2)
                                WHEN 'Lista' THEN (
                                    CASE a.LISTAOFERTA
                                        WHEN 'Lista 1'
                                            THEN ROUND(a.PRECIO_LISTA1, 2)
                                        WHEN 'Lista 2'
                                            THEN ROUND(a.PRECIO_LISTA2, 2)
                                        WHEN 'Lista 3'
                                            THEN ROUND(a.PRECIO_LISTA3, 2)
                                        -- Devuelve Lista1 por default                                        
                                        ELSE ROUND(a.PRECIO_LISTA1, 2) 
                                    END                                
                                )
                            END                                
                        )
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
DECLARE @articulo VARCHAR(15) = '04447';
DECLARE @IDUnicoEscala INT = 30955 
SELECT FACT0007.ARTICULO
    ,dbo.PrecioPromocion(@articulo, @IDUnicoEscala) as PrecioOferta
FROM FACT0007
WHERE FACT0007.ARTICULO = @articulo
GO
-- Sin Escala
DECLARE @articulo VARCHAR(15) = '19468';
DECLARE @IDUnicoEscala INT = 0
SELECT FACT0007.ARTICULO
    ,dbo.PrecioPromocion(@articulo, @IDUnicoEscala) as PrecioOferta
FROM FACT0007
WHERE FACT0007.ARTICULO = @articulo
GO
*/