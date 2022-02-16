USE DBUnico
GO
/*
-- Author:Roberto Carlos Baron RQxxx Liq Comisiones Viajes
-- Create date: 2021-01-14
-- Description:  Script que realiza la creación constante CONST_PERFIL_ADMIN_COMPENSACION_UNICO
*/
DECLARE @mensaje_error varchar(max);
BEGIN TRY
  BEGIN TRAN

	--- Añadir constante menu CONST_PERFIL_ADMIN_COMPENSACION_UNICO ---

	IF NOT EXISTS (SELECT * FROM C3_CONSTANTESCOMPENSACION WHERE NOMBRE = 'CONST_PERFIL_ADMIN_COMPENSACION_UNICO') 
	BEGIN
	   INSERT INTO C3_CONSTANTESCOMPENSACION VALUES('CONST_PERFIL_ADMIN_COMPENSACION_UNICO', 7);
	END
	ELSE
	BEGIN
	    PRINT 'La constante CONST_PERFIL_ADMIN_COMPENSACION_UNICO ya existe'
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