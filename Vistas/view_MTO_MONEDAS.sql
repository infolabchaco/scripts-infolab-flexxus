SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MTO_MONEDAS] (
    CODIGOMONEDA,
    DESCRIPCION,
    CAMBIO
)
AS
  SELECT 1, 'PESOS ARGENTINOS', 1.00
  --UNION
  --SELECT 2, 'DOLAR', (SELECT ULTIMOVALORDOLAR FROM FACT0006)
GO
