SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MTO_PROVINCIAS] (
    CODIGOPROVINCIA
    ,NOMBRE
    --,FECHAMODIFICACION
)
AS
  SELECT CODIGO, NOMBRE
  FROM FACT0013
GO