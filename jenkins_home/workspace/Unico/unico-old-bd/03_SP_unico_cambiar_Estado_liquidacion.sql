USE [DBUnico]
GO
/****** Object:  StoredProcedure [dbo].[unico_cambiar_Estado_liquidacion]    Script Date: 12/04/2021 8:28:11 a. m. ******/
SET ANSI_NULLS ON
GO

IF (OBJECT_ID('unico_cambiar_Estado_liquidacion') IS NOT NULL)
  DROP PROCEDURE [unico_cambiar_Estado_liquidacion]
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[unico_cambiar_Estado_liquidacion] (@txRedencion varchar(30),
@comision decimal(10, 3),
@Servicio varchar(30),
@valorComisionAplicar decimal(10, 3),
@observaciones varchar(60),
@estado int,
@tipo int)

AS
BEGIN

  BEGIN TRY
    DECLARE @fechaTransaccion datetime;
    SET @fechaTransaccion = CONVERT(datetime, (SUBSTRING(@txRedencion, LEN(@txRedencion) - 9, LEN(@txRedencion) - 1)), 101);
    SET @txRedencion = SUBSTRING(@txRedencion, 1, LEN(@txRedencion) - 10);

    IF @tipo = 1
    BEGIN
      INSERT INTO UNICO_MONITOR_PROCESOS
        VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 1. Inserta en UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));

      SET @estado = (SELECT
        idEstado
      FROM [DBUNICO].[dbo].[UNICO_ESTADOS_COMPENSACION_AMAZON]
      WHERE Estado = 'Aplicado')

      IF NOT EXISTS (SELECT
          txRedencion
        FROM [UNICO_COMISIONES_LIQUIDACION_ESTADOS]
        WHERE txRedencion = LTRIM(RTRIM(@txRedencion)))
      BEGIN
        INSERT INTO UNICO_MONITOR_PROCESOS
          VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 1. Inserta en UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));

        INSERT INTO [DBUNICO].[dbo].[UNICO_COMISIONES_LIQUIDACION_ESTADOS]
          VALUES (@txRedencion, @fechaTransaccion, @comision, @Servicio, GETDATE(), @valorComisionAplicar, @observaciones, @estado)


        INSERT INTO UNICO_MONITOR_PROCESOS
          VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 2. Fin insertando en UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));

      END
      IF EXISTS (SELECT
          txRedencion
        FROM [UNICO_COMISIONES_LIQUIDACION_ESTADOS]
        WHERE txRedencion = LTRIM(RTRIM(@txRedencion)))
      BEGIN

        INSERT INTO UNICO_MONITOR_PROCESOS
          VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 1. Inicio Actualizar estado UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));

        UPDATE [DBUNICO].[dbo].[UNICO_COMISIONES_LIQUIDACION_ESTADOS]
        SET comision = @comision,
            Servicio = @Servicio,
            fechaAplicacion = GETDATE(),
            valorComisionAplicar = @valorComisionAplicar,
            observaciones = @observaciones,
            estado = @estado
        WHERE txRedencion = @txRedencion
        AND fechaTransaccion = SUBSTRING(CONVERT(varchar, @fechaTransaccion, 112), 1, 10)

        INSERT INTO UNICO_MONITOR_PROCESOS
          VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 2. Fin Actualizar en UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));
      END
    END

	 IF @tipo = 2
    BEGIN
      INSERT INTO UNICO_MONITOR_PROCESOS
        VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 1. Inserta en UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));


      IF NOT EXISTS (SELECT
          txRedencion
        FROM [UNICO_COMISIONES_LIQUIDACION_ESTADOS]
        WHERE txRedencion = LTRIM(RTRIM(@txRedencion)))
      BEGIN
        INSERT INTO UNICO_MONITOR_PROCESOS
          VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 1. Inserta en UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));

        INSERT INTO [DBUNICO].[dbo].[UNICO_COMISIONES_LIQUIDACION_ESTADOS]
          VALUES (@txRedencion, @fechaTransaccion, @comision, @Servicio, GETDATE(), @valorComisionAplicar, @observaciones, @estado)


        INSERT INTO UNICO_MONITOR_PROCESOS
          VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 2. Fin insertando en UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));

      END
      IF EXISTS (SELECT
          txRedencion
        FROM [UNICO_COMISIONES_LIQUIDACION_ESTADOS]
        WHERE txRedencion = LTRIM(RTRIM(@txRedencion)))
      BEGIN

        INSERT INTO UNICO_MONITOR_PROCESOS
          VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 1. Inicio Actualizar estado UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));

        UPDATE [DBUNICO].[dbo].[UNICO_COMISIONES_LIQUIDACION_ESTADOS]
        SET comision = @comision,
            Servicio = @Servicio,
            fechaAplicacion = GETDATE(),
            valorComisionAplicar = @valorComisionAplicar,
            observaciones = @observaciones,
            estado = @estado
        WHERE txRedencion = @txRedencion
        AND fechaTransaccion = SUBSTRING(CONVERT(varchar, @fechaTransaccion, 112), 1, 10)

        INSERT INTO UNICO_MONITOR_PROCESOS
          VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - 2. Fin Actualizar en UNICO_COMISIONES_LIQUIDACION_ESTADOS para el id ' + CAST(@txRedencion AS varchar(10)));
      END
    END

  END TRY
  BEGIN CATCH
    DECLARE @ErrorMessage varchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

    SELECT
      @ErrorMessage = ERROR_MESSAGE(),
      @ErrorSeverity = ERROR_SEVERITY(),
      @ErrorState = ERROR_STATE();

    INSERT INTO UNICO_MONITOR_PROCESOS
      VALUES (GETDATE(), 'unico_cambiar_Estado_liquidacion - Proceso abortado por error: ' + SUBSTRING(@ErrorMessage, 1, 460));

    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH

END