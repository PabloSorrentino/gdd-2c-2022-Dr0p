USE [GD2C2022]
GO

IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE schema_id = SCHEMA_ID('Dr0p'))
BEGIN
	
	--------------------------------------  E L I M I N A R   FUNCTIONS  --------------------------------------
	DECLARE @SQL_FN NVARCHAR(MAX) = N'';

	SELECT @SQL_FN += N'
	DROP FUNCTION Dr0p.' + name  + ';' 
	FROM sys.objects WHERE type = 'FN' 
	AND schema_id = SCHEMA_ID('Dr0p')

	EXECUTE(@SQL_FN)
--------------------------------------  E L I M I N A R   S P  --------------------------------------
	DECLARE @SQL_SP NVARCHAR(MAX) = N'';

	SELECT @SQL_SP += N'
	DROP PROCEDURE Dr0p.' + name  + ';' 
	FROM sys.objects WHERE type = 'P' 
	AND schema_id = SCHEMA_ID('Dr0p')

	EXECUTE(@SQL_SP)

	--------------------------------------  E L I M I N A R   F K  --------------------------------------
	DECLARE @SQL_FK NVARCHAR(MAX) = N'';
	
	SELECT @SQL_FK += N'
	ALTER TABLE Dr0p.' + OBJECT_NAME(PARENT_OBJECT_ID) + ' DROP CONSTRAINT ' + OBJECT_NAME(OBJECT_ID) + ';' 
	FROM SYS.OBJECTS
	WHERE TYPE_DESC LIKE '%CONSTRAINT'
	AND type = 'F'
	AND schema_id = SCHEMA_ID('Dr0p')
	
	--PRINT @SQL_FK
	EXECUTE(@SQL_FK)

	--------------------------------------  E L I M I N A R   P K  --------------------------------------
	DECLARE @SQL_PK NVARCHAR(MAX) = N'';
	
	SELECT @SQL_PK += N'
	ALTER TABLE Dr0p.' + OBJECT_NAME(PARENT_OBJECT_ID) + ' DROP CONSTRAINT ' + OBJECT_NAME(OBJECT_ID) + ';' 
	FROM SYS.OBJECTS
	WHERE TYPE_DESC LIKE '%CONSTRAINT'
	AND type = 'PK'
	AND schema_id = SCHEMA_ID('Dr0p')
	
	--PRINT @SQL_PK
	EXECUTE(@SQL_PK)

	------------------------------------  D R O P    T A B L E S   -----------------------------------
	DECLARE @SQL_DROP NVARCHAR(MAX) = N'';

	SELECT @SQL_DROP += N'
	DROP TABLE Dr0p.' + TABLE_NAME + ';' 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_SCHEMA = 'Dr0p'
	AND TABLE_TYPE = 'BASE TABLE'
	AND TABLE_NAME LIKE 'BI[_]%'

	--PRINT @SQL_DROP
	EXECUTE(@SQL_DROP)



	----------------------------------------- D R O P   V I E W  -------------------------------------
	DECLARE @SQL_VIEW NVARCHAR(MAX) = N'';

	SELECT @SQL_VIEW += N'
	DROP VIEW Dr0p.' + TABLE_NAME + ';' 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_SCHEMA = 'Dr0p'
	AND TABLE_TYPE = 'VIEW'
	AND TABLE_NAME LIKE 'BI[_]%'

	--PRINT @SQL_VIEW
	EXECUTE(@SQL_VIEW)

END
GO


CREATE FUNCTION Dr0p.bi_obtener_rango_etario (@fecha_de_nacimiento date)
    RETURNS varchar(10)
AS
BEGIN
    DECLARE @returnvalue varchar(10);
    DECLARE @edad int;
    SELECT @edad = (CONVERT(int,CONVERT(char(8),GetDate(),112))-CONVERT(char(8),@fecha_de_nacimiento,112))/10000;

    IF (@edad < 25)
        BEGIN
            SET @returnvalue = '< 25';
        END
    ELSE IF (@edad > 24 AND @edad <36)
        BEGIN
            SET @returnvalue = '25 - 35';
        END
    ELSE IF (@edad > 35 AND @edad <56)
        BEGIN
            SET @returnvalue = '35 - 55';
        END
    ELSE IF(@edad > 55)
        BEGIN
            SET @returnvalue = '> 50';
        END

    RETURN @returnvalue;
END

GO

CREATE FUNCTION Dr0p.bi_calcular_rentabilidad (@ingresos DECIMAL(18,2), @egresos DECIMAL(18,2))
    RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @returnvalue DECIMAL(5,2);
    SET @returnvalue = ((@ingresos - @egresos) / @ingresos) * 100


    RETURN @returnvalue;
END

GO

--CREACION DE TABLAS --

-- BI Provincias
CREATE TABLE [Dr0p].[BI_Provincias](
    nombre NVARCHAR(255) PRIMARY KEY
)


-- BI Rangos Etarios
CREATE TABLE [Dr0p].[BI_Rangos_etarios](
                                           id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
                                           descripcion NVARCHAR(255),
                                           cantidad_total_vendido DECIMAL(18,0),
                                           producto_codigo NVARCHAR(50),
                                           anio DECIMAL(4,0),
                                           mes DECIMAL(2,0)
)

-- BI Tiempos
CREATE TABLE [Dr0p].[BI_Tiempos](
                                    id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
                                    anio DECIMAL(4,0),
                                    mes DECIMAL(2,0),
)


--BI Medios de Pago
CREATE TABLE [Dr0p].[BI_Medios_De_Pago](
                                           id DECIMAL(19,0) IDENTITY(1,1) PRIMARY KEY,
                                           tipo_medio NVARCHAR(255),
                                           descuento_medio_pago_aplicado DECIMAL(18,2),
                                           costo_medio_pago_aplicado DECIMAL(18,2)
)

-- BI Canales de venta

CREATE TABLE [Dr0p].[BI_Canales_De_Venta](
                                             id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
                                             descripcion NVARCHAR(255),
                                             costo DECIMAL(18,0)
)

-- BI categorias de productos

CREATE TABLE [Dr0p].[BI_Categorias_De_Productos](
                                                    id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
                                                    detalle NVARCHAR(255)
)

-- BI productos
CREATE TABLE [Dr0p].[BI_Productos](
                                      codigo NVARCHAR(50) PRIMARY KEY,
                                      nombre NVARCHAR(50),
                                      descripcion NVARCHAR(50),
                                      material NVARCHAR(50),
                                      marca NVARCHAR(255)
)

-- BI Medios de envio

CREATE TABLE [Dr0p].[BI_Medios_De_Envio](
                                            id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
                                            nombre NVARCHAR(255)
)

-- BI Descuentos tipo ( tipo de descuento como los
-- correspondientes a envío, medio de pago, cupones)

CREATE TABLE [Dr0p].[BI_Descuentos_Tipo](
                                            id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
                                            tipo NVARCHAR(255)
)

--    BI Proovedores
CREATE TABLE [Dr0p].[BI_Proveedores](
                                        cuit NVARCHAR(255) PRIMARY KEY,
                                        razon_social NVARCHAR(50),
                                        mail NVARCHAR(50),
                                        domicilio NVARCHAR(50)
)

-- BI Hechos descuentos

CREATE TABLE [Dr0p].[BI_Hechos_Descuentos](
                                              descuento_tipo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Descuentos_Tipo(id),
                                              tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                              canales_de_venta_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Canales_De_Venta(id),
                                              total_descuento DECIMAL(18,2)
)

-- Hechos Compras
CREATE TABLE [Dr0p].[BI_Hechos_Compras](
                                           tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                           proveedor_cuit NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.BI_Proveedores(cuit),
                                           medio_de_pago_id DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Pago(id),
                                           producto_codigo NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.BI_Productos(codigo),
                                           precio DECIMAL(18,2),
                                           cantidad DECIMAL(19,0)
)


--Hechos Ventas
CREATE TABLE [Dr0p].[BI_Hechos_Ventas](
                                          tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                          rango_etario_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Rangos_etarios(id),
                                          canal_venta_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Canales_De_Venta(id),
                                          producto_codigo  NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.BI_Productos(codigo),
                                          categoria_producto_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Categorias_De_Productos(id),
                                          medio_envio_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Envio(id),
                                          provincia_id NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.BI_Provincias(nombre),
                                          medio_pago_id DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Pago(id),
                                          total_venta DECIMAL(18,2) NOT NULL,
                                          cantidad_productos DECIMAL(18,0)
)
--INSERCION DE DATOS A TABLAS --



-- BI Provincias
INSERT INTO [Dr0p].[BI_Provincias](
    nombre
)
SELECT DISTINCT provincia_nombre
FROM
    [Dr0p].Localidades
WHERE provincia_nombre IS NOT NULL



-- BI Rango Etario

INSERT INTO [Dr0p].BI_Rangos_etarios(descripcion, cantidad_total_vendido, producto_codigo, anio, mes)
SELECT [Dr0p].bi_obtener_rango_etario(C.fecha_nacimiento), SUM( VP.cantidad), VP.producto_codigo, YEAR(V.fecha), MONTH(V.fecha)
FROM [Dr0p].Ventas V
         INNER JOIN [Dr0p].Clientes C ON V.cliente_id = C.id
         INNER JOIN Dr0p.Ventas_Productos VP ON VP.venta_codigo = V.codigo

GROUP BY [Dr0p].bi_obtener_rango_etario(C.fecha_nacimiento), VP.producto_codigo, YEAR(V.fecha), MONTH(V.fecha)

-- BI Tiempos

INSERT INTO [Dr0p].BI_Tiempos(
    anio,
    mes
)
    (SELECT YEAR(fecha) as anio, MONTH(fecha) as mes
     FROM [Dr0p].Ventas
     UNION
     SELECT YEAR(fecha) as anio, MONTH(fecha) as mes
     FROM [Dr0p].Compras
    )

-- BI Productos
INSERT INTO [Dr0p].BI_Productos(
    codigo,
    nombre,
    descripcion,
    material,
    marca
)
SELECT  codigo,
        nombre,
        descripcion,
        material,
        marca
FROM [Dr0p].Productos


-- BI Productos
INSERT INTO [Dr0p].BI_Categorias_De_Productos(detalle)
SELECT detalle FROM [Dr0p].Categorias

-- BI Medios de pago
INSERT INTO [Dr0p].BI_Medios_De_Pago(
    tipo_medio, descuento_medio_pago_aplicado , costo_medio_pago_aplicado
)
SELECT MP.tipo_medio,
       ISNULL((SELECT DV.importe_descuento_venta FROM Dr0p.Descuentos_Ventas DV WHERE DV.venta_codigo = V.codigo AND DV.concepto <> 'Otros') , 0)
                                     as descuento_medio_pago_aplicado,
       VMP.costo_medio_pago_aplicado as costo_medio_de_pago_aplicado

FROM
    [Dr0p].Ventas V
        INNER JOIN Dr0p.Ventas_Medios_De_Pago VMP ON VMP.venta_codigo = V.codigo
        INNER JOIN Dr0p.Medios_De_Pago MP ON MP.id = VMP.medio_de_pago_id


-- BI Medios de envio
INSERT INTO [Dr0p].BI_Medios_De_envio(
    nombre
)
SELECT nombre
FROM
    [Dr0p].Medios_De_Envio

-- BI Canales de Venta

INSERT INTO [Dr0p].BI_Canales_De_Venta(descripcion, costo)
SELECT descripcion, costo
FROM [Dr0p].Canales_de_venta

-- BI tipos de descuentos
INSERT INTO [Dr0p].BI_Descuentos_Tipo(tipo)
VALUES ('Por envio')
INSERT INTO [Dr0p].BI_Descuentos_Tipo(tipo)
VALUES ('Por medio de pago')
INSERT INTO [Dr0p].BI_Descuentos_Tipo(tipo)
VALUES ('Por cupon')
INSERT INTO [Dr0p].BI_Descuentos_Tipo(tipo)
VALUES ('Por descuento especial')

-- BI Proveedores

INSERT INTO [Dr0p].BI_Proveedores(
    cuit,
    razon_social,
    mail,
    domicilio
)
SELECT cuit, razon_social, mail, domicilio
FROM
    [Dr0p].Proveedores


-- Hechos --

-- Descuentos --
INSERT INTO [Dr0p].BI_Hechos_Descuentos(
    descuento_tipo_id,
    tiempo_id,
    canales_de_venta_id,
    total_descuento)

SELECT (SELECT id from [Dr0p].BI_Descuentos_Tipo BIDT WHERE BIDT.tipo = 'Por envio') as descuento_tipo_id,
       (SELECT id FROM [Dr0p].BI_Tiempos WHERE anio = YEAR(V.fecha) AND mes = MONTH(V.fecha)) as tiempo_id,
       (SELECT id FROM [Dr0p].BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) canal_de_venta_id,
       (select medio_envio_precio FROM [Dr0p].Medios_de_envio ME WHERE ME.id = EV.medio_envio_id) - EV.medio_envio_precio as total_descuento
from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Envios_Ventas EV on EV.venta_codigo = V.codigo
         JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
WHERE EV.medio_envio_precio = 0


INSERT INTO [Dr0p].BI_Hechos_Descuentos(
    descuento_tipo_id,
    tiempo_id,
    canales_de_venta_id,
    total_descuento)

SELECT (SELECT id from [Dr0p].BI_Descuentos_Tipo BIDT WHERE BIDT.tipo = 'Por medio de pago') as descuento_tipo_id,
       (SELECT id FROM [Dr0p].BI_Tiempos WHERE anio = YEAR(V.fecha) AND mes = MONTH(V.fecha)) as tiempo_id,
       (SELECT id FROM [Dr0p].BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
       DV.importe_descuento_venta as descuento
    from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Descuentos_Ventas DV on DV.venta_codigo = V.codigo
    JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
WHERE DV.importe_descuento_venta IS NOT NULL AND DV.concepto <> 'Otros'




INSERT INTO [Dr0p].BI_Hechos_Descuentos(
    descuento_tipo_id,
    tiempo_id,
    canales_de_venta_id,
    total_descuento)

SELECT (SELECT id from [Dr0p].BI_Descuentos_Tipo BIDT WHERE BIDT.tipo = 'Por cupon') as descuento_tipo_id,
       (SELECT id FROM [Dr0p].BI_Tiempos WHERE anio = YEAR(V.fecha) AND mes = MONTH(V.fecha)) as tiempo_id,
       (SELECT id FROM [Dr0p].BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
       VC.importe as descuento
from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Ventas_Cupones VC on VC.venta_codigo = V.codigo
         JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
WHERE VC.importe IS NOT NULL

INSERT INTO [Dr0p].BI_Hechos_Descuentos(
    descuento_tipo_id,
    tiempo_id,
    canales_de_venta_id,
    total_descuento)

SELECT (SELECT id from [Dr0p].BI_Descuentos_Tipo BIDT WHERE BIDT.tipo = 'Por descuento especial') as descuento_tipo_id,
       (SELECT id FROM [Dr0p].BI_Tiempos WHERE anio = YEAR(V.fecha) AND mes = MONTH(V.fecha)) as tiempo_id,
       (SELECT id FROM [Dr0p].BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
       DV.importe_descuento_venta as descuento
from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Descuentos_Ventas DV on DV.venta_codigo = V.codigo
         JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
WHERE DV.importe_descuento_venta IS NOT NULL AND DV.concepto <> 'Otros'



-- BI Hechos compras

INSERT INTO [Dr0p].BI_Hechos_Compras(
    tiempo_id,
    proveedor_cuit,
    medio_de_pago_id,
    producto_codigo,
    precio,
    cantidad
)
SELECT (SELECT id FROM Dr0p.BI_Tiempos BITI WHERE BITI.anio = YEAR(C.fecha) AND BITI.mes = MONTH(C.fecha)) as tiempo_id,
       C.proveedor,
       (SELECT id FROM Dr0p.BI_Medios_De_Pago BIMP WHERE BIMP.tipo_medio = MP.tipo_medio) as medio_pago_id,
       producto_codigo,
       CP.precio,
       CP.cantidad
FROM
    Dr0p.Compras C
        JOIN Dr0p.Medios_De_Pago MP ON C.medio_pago = MP.id
        INNER JOIN Dr0p.Compras_Productos CP ON CP.compra_numero = C.numero


-- BI Hechos ventas

INSERT INTO [Dr0p].BI_Hechos_Ventas(
    tiempo_id,
    rango_etario_id,
    canal_venta_id,
    producto_codigo,
    categoria_producto_id,
    medio_envio_id,
    provincia_id,
    medio_pago_id,
    total_venta,
    cantidad_productos
)
SELECT

    (SELECT id FROM Dr0p.BI_Tiempos BITI WHERE BITI.anio = YEAR(V.fecha) AND BITI.mes = MONTH(V.fecha)) as tiempo_id,
    (SELECT id FROM Dr0p.BI_Rangos_etarios BIRE WHERE BIRE.descripcion = Dr0p.bi_obtener_rango_etario(CL.fecha_nacimiento)
                                                  AND BIRE.anio = YEAR(V.fecha) AND BIRE.mes = MONTH(V.fecha) AND BIRE.producto_codigo = VP.producto_codigo) as rango_etario,
    (SELECT id FROM Dr0p.BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
    VP.producto_codigo,
    (SELECT id FROM Dr0p.BI_Categorias_De_Productos BIME WHERE BIME.detalle = (SELECT detalle FROM Dr0p.Categorias CAT WHERE CAT.id= P.categoria)) as categoria_id,
    (SELECT id FROM Dr0p.BI_Medios_De_Envio BIME WHERE BIME.nombre = (SELECT nombre FROM Dr0p.Medios_de_envio ME WHERE ME.id= EV.medio_envio_id)) as medio_envio_id,
    (SELECT provincia_nombre FROM Dr0p.Localidades L WHERE L.id = CL.localidad) as provincia_id,
    (SELECT id FROM Dr0p.BI_Medios_De_Pago BIMP WHERE BIMP.tipo_medio = (SELECT tipo_medio FROM Dr0p.Medios_de_Pago MP WHERE MP.id= VMP.medio_de_pago_id)) as medio_pago_id,
    VP.precio as total_venta,
    VP.cantidad as cantidad_productos


FROM
    Dr0p.Ventas V
        LEFT JOIN Dr0p.Canales_de_venta CV on CV.id = V.canal_venta_id
        INNER JOIN Dr0p.Clientes CL ON CL.id = V.cliente_id
        INNER JOIN Dr0p.Ventas_Productos VP ON VP.venta_codigo = V.codigo
        INNER JOIN Dr0p.Productos P ON P.codigo = VP.producto_codigo
        LEFT JOIN Dr0p.Ventas_Medios_De_Pago VMP ON VMP.venta_codigo = V.codigo
        INNER JOIN Dr0p.Envios_Ventas EV ON EV.venta_codigo = V.codigo

GO

--------------------- CREACION DE VISTAS ---------------------

-- Las ganancias mensuales de cada canal de venta.
CREATE VIEW [Dr0p].[BI_VIEW_GANANCIA_MENSUAL_CANAL_VENTA]
AS
SELECT
    CV.descripcion AS CANAL_VENTA, T.mes as MES, (SUM(HV.total_venta) - SUM(HV.costo_medio_de_pago_aplicado) - SUM(HC.precio)) AS TOTAL_VENDIDO
FROM
    Dr0p.BI_Canales_De_Venta CV
        INNER JOIN
    Dr0p.BI_Hechos_Ventas HV
    ON
            CV.id = HV.canal_venta_id
        INNER JOIN
    Dr0p.BI_Tiempos T
    ON
            HV.tiempo_id = T.id
        INNER JOIN
    Dr0p.BI_Hechos_Compras HC
    ON
            HC.producto_codigo = HV.producto_codigo
GROUP BY
    T.mes, CV.descripcion
GO


-- Los 5 productos con mayor rentabilidad anual
CREATE VIEW [Dr0p].[BI_VIEW_TOP_5_RENTABILIDAD_PRODUCTOS]
AS

SELECT TOP 5
    HV.producto_codigo,
    P.nombre,
    T.anio,
    Dr0p.bi_calcular_rentabilidad(SUM(HV.total_venta * HV.cantidad_productos), SUM(HC.precio * HC.cantidad)) as rentabilidad
FROM [Dr0p].[BI_Hechos_Ventas] HV
         INNER JOIN
     Dr0p.BI_Tiempos T
     ON
             HV.tiempo_id = T.id
         INNER JOIN
     Dr0p.BI_Productos P
     ON
             P.codigo = HV.producto_codigo
         INNER JOIN
     Dr0p.BI_Hechos_Compras HC on HC.producto_codigo = HV.producto_codigo AND HC.tiempo_id = HV.tiempo_id
GROUP BY HV.producto_codigo, P.nombre, T.anio
ORDER BY rentabilidad DESC

GO


/*Importe total en descuentos aplicados según su tipo de descuento, por
canal de venta, por mes. Se entiende por tipo de descuento como los
correspondientes a envío, medio de pago, cupones, etc)*/
CREATE VIEW [Dr0p].[BI_DESCUENTOS_APLICADOS_MENSUALMENTE_POR_TIPO_Y_CANAL_DE_VENTA]
AS

SELECT
    DT.tipo,
    CV.descripcion,
    T.mes ,
    T.anio,
    SUM(total_descuento) as total_descuento_mensual
FROM [Dr0p].BI_Hechos_Descuentos HD
         INNER JOIN
     Dr0p.BI_Tiempos T ON HD.tiempo_id = T.id
         INNER JOIN
     Dr0p.BI_Descuentos_Tipo DT ON DT.id = HD.descuento_tipo_id
         INNER JOIN
     Dr0p.BI_Canales_De_Venta CV ON CV.id = HD.canales_de_venta_id

GROUP BY DT.tipo, T.mes , T.anio, CV.descripcion
GO

/*Total de Ingresos por cada medio de pago por mes, descontando los costos
por medio de pago (en caso que aplique) y descuentos por medio de pago
(en caso que aplique)*/
CREATE VIEW [Dr0p].[BI_VIEW_INGRESOS_MENSUALES_POR_MEDIO_DE_PAGO]
AS
SELECT
    MP.tipo_medio ,
    T.mes,
    T.anio,
    SUM((HV.total_venta * HV.cantidad_productos) - HV.costo_medio_de_pago_aplicado - HV.porcentaje_descuento_medio_pago_aplicado) as total_ingresos
FROM [Dr0p].[BI_Hechos_Ventas] HV
         INNER JOIN
     Dr0p.BI_Tiempos T
     ON HV.tiempo_id = T.id
         INNER JOIN
     Dr0p.BI_Medios_De_Pago MP ON MP.id = HV.medio_pago_id
GROUP BY MP.tipo_medio, T.anio, T.mes
GO

/*Porcentaje de envíos realizados a cada Provincia por mes. El porcentaje
debe representar la cantidad de envíos realizados a cada provincia sobre
total de envío mensuales*/
CREATE VIEW [Dr0p].[BI_VIEW_ENVIOS_PROVINCIA_POR_MES]
AS

SELECT HV.provincia_id,
       T.anio,
       T.mes,
       (COUNT(*) / (SELECT count(*) FROM [Dr0p].[BI_Hechos_Ventas] HV2 WHERE HV2.tiempo_id = HV.tiempo_id AND HV2.medio_envio_id IS NOT NULL))*100 as porcentaje_provincia

FROM [Dr0p].[BI_Hechos_Ventas] HV
         INNER JOIN
     Dr0p.BI_Tiempos T
     ON HV.tiempo_id = T.id
WHERE HV.medio_envio_id IS NOT NULL
GROUP BY HV.provincia_id, HV.tiempo_id, T.anio, T.mes
GO


-- Las 5 categorías de productos más vendidos por rango etario de clientes por mes.
/*
CREATE VIEW [Dr0p].[BI_PRODUCTOS_MAS_VENDIDOS_POR_RANGO_ETARIO]
AS
    SELECT
		T.mes, RE.descripcion AS rango_etario, CP.detalle, SUM(HV.cantidad_productos) as total_vendido
    FROM
        Dr0p.BI_Hechos_Ventas HV
    INNER JOIN
        Dr0p.BI_Rangos_etarios RE
    ON
        HV.rango_etario_id = RE.id
    INNER JOIN
        Dr0p.BI_Categorias_De_Productos CP
    ON
        CP.id = HV.categoria_producto_id
    INNER JOIN
        Dr0p.BI_Tiempos T
    ON
        HV.tiempo_id = T.id
    GROUP BY T.mes, RE.descripcion, CP.detalle
	ORDER BY T.mes, rango_etario, CP.detalle ASC
	OFFSET 0 ROWS
GO
*/
