-- Create a new stored procedure called 'MTO_PRODUCTOS' in schema 'dbo'
-- Drop the stored procedure if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'MTO_PRODUCTOS'
    AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE dbo.MTO_PRODUCTOS
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE dbo.MTO_PRODUCTOS
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
        '' AS DESCRIPCIONLARGA,
        a.DESCRIPCION AS NOMBRE,
        dbo.PrecioLista(a.ARTICULO, @LISTAPRECIO, 0) AS PRECIO,
        dbo.PrecioPromocion(a.ARTICULO, 0) AS PRECIOPROMOCION,
        dbo.FechaVigenciaPromoDesde(a.ARTICULO, 0) AS FECHADESDE,
        dbo.FechaVigenciaPromoHasta(a.ARTICULO, 0) AS FECHAHASTA, 
        CONVERT(VARCHAR(15), a.MARCA) AS ID_MARCA,
        a.ARTICULO AS CODIGO_PRODUCTO, -- idem ID_ARTICULO en caso de Producto Sin Escala
        a.ARTICULO AS ID_ARTICULO,
        CASE WHEN b.CodeBar IS NOT NULL
            THEN b.CodeBar
            ELSE a.ARTICULO
        END AS CODIGO_BARRA
    FROM FACT0007 a
    LEFT JOIN FACT0007_CB b ON a.ARTICULO = b.ARTICULO
    WHERE a.ESTADO = 'En Vigencia' AND a.UTILIZAESCALA = 'N' --AND a.LISTADISTRIBUCION = 1 
    -- Artículos con Actualización de Precios de 3 Semanas atrás hasta HOY
    AND a.FECHAACTPRECIOS BETWEEN DATEADD(wk, -3, @FECHADEMODIFICACION) AND @FECHADEMODIFICACION
END
GO

-- example to execute the stored procedure we just created
/*
DECLARE @LISTACODIGOSDEPOSITOS VARCHAR(250) = '1',
    @FECHADEMODIFICACION DATETIME = GETDATE(),
    @LISTAPRECIO INT = 1;
EXECUTE dbo.MTO_PRODUCTOS @LISTACODIGOSDEPOSITOS, @FECHADEMODIFICACION, @LISTAPRECIO
GO
*/