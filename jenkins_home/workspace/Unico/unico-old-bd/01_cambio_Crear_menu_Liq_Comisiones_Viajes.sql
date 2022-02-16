USE DBSeguridad
GO
/*
-- Author:Roberto Carlos Baron RQxxx Liq Comisiones Viajes
-- Create date: 2021-01-14
-- Description:  Script que realiza la creación del menú Liq Comisiones Viajes
*/
DECLARE @mensaje_error varchar(max);
BEGIN TRY
  BEGIN TRAN

   --Declarar  variables --

	DECLARE @MODULO INT,
			@ORDEN INT

	SELECT @MODULO = IDMODULO FROM C3_MODULO WHERE NOMBREMODULO = 'TUPLUS';

	SELECT @ORDEN = ISNULL(MAX(ORDEN), 0) FROM C3_MENU WHERE IDMODULO = @MODULO;

	--- crear menu Liq Comisiones Viajes ---

	IF NOT EXISTS (SELECT * FROM C3_menu WHERE LINKMENU = 'liqComisionesViaj') 
	BEGIN
		SET @ORDEN = @ORDEN + 1;
		INSERT INTO C3_MENU (NOMBREMENU, LINKMENU, IDPADRE, IDMODULO, ORDEN, ESELIMINADO) 
		VALUES ('Liq Comisiones Viajes', 'liqComisionesViaj', null, @MODULO, @ORDEN , 0);
	END
	ELSE
	BEGIN
	    PRINT 'El menu Liq Comisiones Viajes ya existe'
	END


  COMMIT TRAN
END TRY
BEGIN CATCH
  ROLLBACK TRAN
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_STATE() AS ErrorState,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
  SET @mensaje_error = 'Error al ejecutar Script - RQ32455 Conciliación de Redenciones Creacion menu. Error: ' + ERROR_MESSAGE();
  RAISERROR (@mensaje_error, 16, 1);
END CATCH