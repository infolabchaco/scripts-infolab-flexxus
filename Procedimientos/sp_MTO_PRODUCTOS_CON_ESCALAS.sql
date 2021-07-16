-- Create a new stored procedure called 'MTO_PRODUCTOS_CON_ESCALAS' in schema 'dbo'
-- Drop the stored procedure if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'MTO_PRODUCTOS_CON_ESCALAS'
    AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE dbo.MTO_PRODUCTOS_CON_ESCALAS
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE dbo.MTO_PRODUCTOS_CON_ESCALAS
    @LISTACODIGOSDEPOSITOS VARCHAR(250),
    @FECHADEMODIFICACION DATETIME,
    @LISTAPRECIO INT    
AS
BEGIN
    /*
    CANTIDAD double precision,
    PESO double precision,
    META_DESCRIPTION varchar(250),
    META_KEYWORDS varchar(250),
    META_TITLE varchar(250),
    FECHAMODIFICACION timestamp,
    DESCRIPCIONCORTA varchar(2000),
    DESCRIPCIONLARGA varchar(2000),
    COEFICIENTE double precision,
    NOMBRE CADENA250 collate NONE,
    PRECIO double precision,
    MONTOII double precision,
    PORCENTAJEII double precision,
    PRECIOPROMOCION double precision,
    FECHADESDE timestamp,
    FECHAHASTA timestamp,
    ACTIVO integer,
    ID_MARCA varchar(15),
    CODIGO_PRODUCTO varchar(20),
    ID_CATEGORIA varchar(16),
    DESTACADOWEB smallint,
    ID_ARTICULO varchar(15),
    ESPACK smallint,
    CANTIDADXBULTO double precision,
    CODIGO_BARRA varchar(30),
    FAMILIA integer
    */    
    SELECT a.DESCRIPCION AS DESCRIPCIONCORTA,
        dbo.getDescripcionEscala(a.ARTICULO, ea.IDUNICOESCALA) AS DESCRIPCIONLARGA,
        a.DESCRIPCION AS NOMBRE,
        dbo.PrecioLista(a.ARTICULO, @LISTAPRECIO, ep.IDUNICOESCALA) AS PRECIO,
        dbo.PrecioPromocion(a.ARTICULO, ep.IDUNICOESCALA) AS PRECIOPROMOCION,
        dbo.FechaVigenciaPromoDesde(a.ARTICULO, ep.IDUNICOESCALA) AS FECHADESDE,
        dbo.FechaVigenciaPromoHasta(a.ARTICULO, ep.IDUNICOESCALA) AS FECHAHASTA, 
        CONVERT(VARCHAR(15), a.MARCA) AS ID_MARCA,
        ea.CODESCALA AS CODIGO_PRODUCTO, -- idem ID_ARTICULO en caso de Producto Sin Escala
        a.ARTICULO AS ID_ARTICULO,
        '' AS CODIGO_BARRA
    FROM FACT0007 a
        INNER JOIN FACT0022 ea ON a.ARTICULO = ea.ARTICULO
        INNER JOIN FACT0064 ep ON ea.IDUNICOESCALA = ep.IDUNICOESCALA
    WHERE a.ESTADO = 'En Vigencia' AND a.UTILIZAESCALA = 'S' --AND a.LISTADISTRIBUCION = 1 
    -- Artículos con Actualización de Precios de 4 meses atrás hasta HOY.
    -- Se podría actualizar la FECHAACTPRECIOS cuando se crea una OfertaPromo para así poder filtrar esos art. solamente
    AND a.FECHAACTPRECIOS BETWEEN DATEADD(MONTH, -4, @FECHADEMODIFICACION) AND @FECHADEMODIFICACION
END
GO

-- ejemplo
/*
DECLARE @LISTACODIGOSDEPOSITOS VARCHAR(250) = '1',
    @FECHADEMODIFICACION DATETIME = GETDATE(),
    @LISTAPRECIO INT = 1;
EXECUTE dbo.MTO_PRODUCTOS_CON_ESCALAS @LISTACODIGOSDEPOSITOS, @FECHADEMODIFICACION, @LISTAPRECIO
GO
*/