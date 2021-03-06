USE [DBUnico]
GO
/****** Object:  StoredProcedure [dbo].[unico_conciliacion_liquidaciones_comisiones]    Script Date: 20/04/2021 9:43:18 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author:    	Roberto Carlos Baron Lopez
-- date:		Mayo 2019
-- Description:	Sp realiza los colculos de comision respecto a los porcentajes 
--				acordes a cada servicio.
-- Request:		RQ34563

ALTER PROCEDURE [dbo].[unico_conciliacion_liquidaciones_comisiones] (@fechaInicio datetime,
@fechaFin datetime,
@estado varchar(200)
--@idPaginador int
)

AS
BEGIN
    BEGIN TRY
        -----------------------------------------------------------------------------------------------------
        --DATOS A TRABAJAR:
        -----------------------------------------------------------------------------------------------------
        DECLARE @sesion varchar(15);
        SET @sesion = REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar, GETDATE(), 121), '-', ''), ':', ''), '.', ''), ' ', '');

        INSERT INTO unico_monitor_procesos
            VALUES (GETDATE(), 'unico_conciliacion_redenciones. Sesión: ' + ISNULL(CONVERT(varchar(15), @sesion), 'NULL') + ' - paso 01. INICIO PROCESO --------------------------------;' + ' Parametros:' + ' | FechaInicio-> ' + ISNULL(CONVERT(varchar(10), @fechaInicio, 111), 'NULL') + ' | FechaFin-> ' + ISNULL(CONVERT(varchar(10), @fechaFin, 111), 'NULL') + ' | Estado-> ' + ISNULL(CONVERT(varchar(200), @estado), 'NULL'));
        --	+ ' | IdPaginador-> '+ isnull(convert(varchar(10),@idPaginador),'NULL'));

        BEGIN
            INSERT INTO unico_monitor_procesos
                VALUES (GETDATE(), 'unico_conciliacion_liquidaciones_comisiones. Sesión: ' + ISNULL(CONVERT(varchar(15), @sesion), 'NULL') + ' - paso 02. Inicia consulta consolidada');

            SELECT
                ISNULL(ISNULL(a.idtxRedencionFecha, b.idtxRedencionFecha), '') idtxRedencionFecha,
                SUBSTRING(CONVERT(varchar, ISNULL(a.fechaRedencion, b.fechaTransaccion), 121), 1, 10) fechaTransaccion, 
                ISNULL(a.entidadDebitoBAVV, 'N/A') entidadDebitoBAVV,
                ISNULL(a.entidadDebitoBBOG, 'N/A') entidadDebitoBBOG,
                ISNULL(a.entidadDebitoBOCC, 'N/A') entidadDebitoBOCC,
                ISNULL(a.entidadDebitoBPOP, 'N/A') entidadDebitoBPOP,
                ISNULL(a.valorPuntosSiebel, 0) valorPuntosSiebel,
                b.tarifaNeta,
                b.valorPuntosAviatur,
                b.valorTarjetaCredito,
                b.valorTotalCompra,
                b.tipoServicioproducto,
                b.porcentajeComision,
                b.comisionCalculadaAviatur,
                0 comisionCalculadaSiebel,
                ISNULL(a.valorPuntosSiebel, 0) - ISNULL(b.valorPuntosAviatur, 0) diferenciaValorPuntos,
                ISNULL(b.comisionCalculadaAviatur, 0) - ISNULL(b.valorComisionAplicar, 0) diferenciaComisionCalculada,
                ISNULL(b.valorComision,b.valorComisionAplicar) valorComisionAplicar,
                b.porcentajePuntos,
                b.porcentajeTarjetaCredito,
                b.valorComisionPuntos,
                b.entidadTC,
                b.valorComisionTarjetaCredito,
                ISNULL(a.porcentajeBAVV * b.comisionCalculadaAviatur, 0) valorComisionBAVV,
                ISNULL(a.porcentajeBBOG * b.comisionCalculadaAviatur, 0) valorComisionBBOG,
                ISNULL(a.porcentajeBOCC * b.comisionCalculadaAviatur, 0) valorComisionBOCC,
                ISNULL(a.porcentajeBPOP * b.comisionCalculadaAviatur, 0) valorComisionBPOP,
                b.valorComision,
                b.observaciones,
                b.estado
            FROM (SELECT
                a.idTxRedencion,
                a.idtxRedencionFecha,
                a.fechaRedencion,
                MIN(a.entidadDebitoBAVV) entidadDebitoBAVV,
                MIN(a.entidadDebitoBBOG) entidadDebitoBBOG,
                MIN(a.entidadDebitoBOCC) entidadDebitoBOCC,
                MIN(a.entidadDebitoBPOP) entidadDebitoBPOP,
                SUM(a.valorBAVV) / SUM(a.valorPuntosSiebel) porcentajeBAVV,
                SUM(a.valorBBOG) / SUM(a.valorPuntosSiebel) porcentajeBBOG,
                SUM(a.valorBOCC) / SUM(a.valorPuntosSiebel) porcentajeBOCC,
                SUM(a.valorBPOP) / SUM(a.valorPuntosSiebel) porcentajeBPOP,
                SUM(a.valorPuntosSiebel) valorPuntosSiebel
            FROM (SELECT
                a.idTxRedencion,
                a.fechaRedencion,
                (a.idTxRedencion + SUBSTRING(CONVERT(varchar, a.fechaRedencion, 121), 1, 10)) idtxRedencionFecha,
                CASE
                    WHEN a.entidadDebito = 52 THEN c.razonSocial
                    ELSE 'N/A'
                END entidadDebitoBAVV,
                CASE
                    WHEN a.entidadDebito = 1 THEN c.razonSocial
                    ELSE 'N/A'
                END entidadDebitoBBOG,
                CASE
                    WHEN a.entidadDebito = 23 THEN c.razonSocial
                    ELSE 'N/A'
                END entidadDebitoBOCC,
                CASE
                    WHEN a.entidadDebito = 2 THEN c.razonSocial
                    ELSE 'N/A'
                END entidadDebitoBPOP,
                CASE
                    WHEN a.entidadDebito = 52 THEN SUM(a.valorPuntos)
                    ELSE 0
                END valorBAVV,
                CASE
                    WHEN a.entidadDebito = 1 THEN SUM(a.valorPuntos)
                    ELSE 0
                END valorBBOG,
                CASE
                    WHEN a.entidadDebito = 23 THEN SUM(a.valorPuntos)
                    ELSE 0
                END valorBOCC,
                CASE
                    WHEN a.entidadDebito = 2 THEN SUM(a.valorPuntos)
                    ELSE 0
                END valorBPOP,
                SUM(a.valorPuntos) valorPuntosSiebel
            FROM unico_puntos_aval a
            INNER JOIN unico_Entidad c
                ON a.entidadDebito = c.idEntidad
            WHERE SUBSTRING(CONVERT(varchar, a.fechaNegocio, 112), 1, 10) BETWEEN CONVERT(varchar, @fechaInicio, 112) AND CONVERT(varchar, @fechaFin, 112)
            GROUP BY a.idTxRedencion,
                     a.fechaRedencion,
                     a.entidadDebito,
                     c.razonSocial) a
            GROUP BY a.idTxRedencion,
					 a.fechaRedencion,
                     a.idtxRedencionFecha) a
            RIGHT JOIN (SELECT
                CASE WHEN B.numeroAutorizacion IS NULL THEN SUBSTRING(CONVERT(varchar, b.fechaTransaccion, 121), 1, 10) 
                ELSE B.numeroAutorizacion + SUBSTRING(CONVERT(varchar, b.fechaTransaccion, 121), 1, 10) END idtxRedencionFecha,
                b.fechaTransaccion,
                SUM(b.tarifaNeta) tarifaNeta,
                SUM(b.valorPuntosRedimidos) valorPuntosAviatur,
                SUM(b.valorCOPTC) valorTarjetaCredito,
                SUM(b.valorPuntosRedimidos) + SUM(b.valorCOPTC) valorTotalCompra,
                b.tipoServicioproducto tipoServicioProducto,
                MAX(d.comision) porcentajeComision,
                MAX(d.comision) * SUM(b.tarifaNeta) / 100 comisionCalculadaAviatur,
                ROUND(SUM(b.valorPuntosRedimidos) /
                (SUM(b.valorPuntosRedimidos) + SUM(b.valorCOPTC)) * 100, 2)
                porcentajePuntos,
                ROUND(SUM(b.valorCOPTC) /
                (SUM(b.valorPuntosRedimidos) + SUM(b.valorCOPTC)) * 100, 2)
                porcentajeTarjetaCredito,
                ROUND((SUM(b.tarifaNeta) * MAX(d.comision)/ 100) * ROUND(SUM(b.valorPuntosRedimidos) /
                (SUM(b.valorPuntosRedimidos) + SUM(b.valorCOPTC)), 4), 2)
                valorComisionPuntos,
                CASE
                    WHEN MIN(b.entidadTC) IS NULL OR
                        MIN(b.entidadTC) LIKE 'Banco Debito' THEN 'N/A'
                    ELSE MIN(b.entidadTC)
                END AS entidadTC,
                ROUND((SUM(b.tarifaNeta) * MAX(d.comision)/ 100) * ROUND(SUM(b.valorCOPTC) /
                (SUM(b.valorPuntosRedimidos) + SUM(b.valorCOPTC)), 4), 2)
                valorComisionTarjetaCredito,
                SUM(b.valorComision) valorComisionAplicar,
				e.valorComisionAplicar valorComision,
                e.observaciones observaciones,
                CASE
                    WHEN  e.estado IS NULL THEN 1
                    ELSE e.estado
                END AS estado
            FROM UNICO_CONCILIACION_AVIATUR b
			INNER JOIN unico_archivo_cargado a 
				ON(b.idArchivoCargado = a.idArchivoCargado)
            INNER JOIN UNICO_COMISIONES_AVIATUR d
                ON UPPER(b.tipoServicioProducto) = UPPER(d.servicio)
            LEFT JOIN UNICO_COMISIONES_LIQUIDACION_ESTADOS e
                ON (B.numeroAutorizacion = e.txRedencion)
		    LEFT JOIN UNICO_ESTADOS_COMPENSACION_AMAZON f
			    ON (e.estado= f.idEstado)
            WHERE SUBSTRING(CONVERT(varchar, a.fechaNegocio, 112), 1, 10) BETWEEN CONVERT(varchar, @fechaInicio, 112) AND CONVERT(varchar, @fechaFin, 112)
			AND 1 =
			CASE
				WHEN @estado IS NOT NULL AND
					(@estado = 0) THEN 1
				WHEN @estado IS NOT NULL AND
					@estado = 1 AND (e.estado is null or (e.estado != 2 and e.estado != 3)) THEN 1
				WHEN @estado IS NOT NULL AND
					(@estado = 2 OR
					@estado = 3) and e.estado = @estado THEN 1
				WHEN @estado IS NOT NULL AND
					@estado = 4 and (e.estado is null or e.estado != 3) THEN 1
				ELSE 0
			END
            GROUP BY --CASE WHEN b.numeroAutorizacion IS NULL THEN '' ELSE b.numeroAutorizacion END,
					 b.numeroAutorizacion,
					 b.fechaTransaccion,
                     b.tipoServicioproducto,
                     d.comision,
                     e.valorComisionAplicar,
                     e.observaciones,
                     e.estado) b
                ON (a.idtxRedencionFecha = b.idtxRedencionFecha)
            ORDER BY fechaTransaccion 
                     
            INSERT INTO unico_monitor_procesos
                VALUES (GETDATE(), 'unico_conciliacion_liquidaciones_comisiones. Sesión: ' + ISNULL(CONVERT(varchar(15), @sesion), 'NULL') + ' - paso 02. FINALIZA PROCESO SIN ERRORES --------------------------------;');
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
        INSERT INTO unico_monitor_procesos
            VALUES (GETDATE(), 'unico_conciliacion_redenciones. Sesión: ' + ISNULL(CONVERT(varchar(15), @sesion), 'NULL') + ' - paso 03. Proceso abortado por ERROR: ' + @ErrorMessage);
        INSERT INTO unico_monitor_procesos
            VALUES (GETDATE(), 'unico_conciliacion_redenciones. Sesión: ' + ISNULL(CONVERT(varchar(15), @sesion), 'NULL') + ' - paso 04. FINALIZA PROCESO CON ERRORES --------------------------------;');
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
