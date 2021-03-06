SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MTO_TIPOSIVA] (
    CODIGOTIPO,
    DESCRIPCION,
    IVA1
)
AS
  SELECT IDTASA,
    'IVA ' + FORMAT(TASA, '0.#', 'es-AR') + ' %' AS DESCRIPCION,
    TASA
  FROM FACT2001
  WHERE ESTADO = 'En Vigencia'
GO
