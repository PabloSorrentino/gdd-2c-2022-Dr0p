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
    RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @returnvalue DECIMAL(10,2);
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
                                           descripcion NVARCHAR(255)
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
                                           tipo_medio NVARCHAR(255)
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
                                           precio DECIMAL(18,2)
)

--Hechos Ventas Total
CREATE TABLE [Dr0p].[BI_Hechos_Ganancia_Mensual_Canal](
                                          tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                          canal_venta_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Canales_De_Venta(id),
                                          total_ganancias DECIMAL(18,2) NOT NULL
)

--Hechos Ventas Total
CREATE TABLE [Dr0p].[BI_Hechos_Ventas_Total](
                                                tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                                canal_venta_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Canales_De_Venta(id),
                                                medio_envio_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Envio(id),
                                                provincia_id NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.BI_Provincias(nombre),
                                                medio_pago_id DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Pago(id),
                                                costo_medio_de_pago_aplicado DECIMAL(18,2),
                                                descuento_medio_pago_aplicado DECIMAL(18,2),
                                                total_venta DECIMAL(18,2) NOT NULL
)

--Hechos Venta x Producto

 CREATE TABLE [Dr0p].BI_Hechos_Productos_Rentabilidad(
    tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
	producto_codigo  NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.BI_Productos(codigo),
	rentabilidad DECIMAL(10,2)
)

--Hechos Venta x Producto

CREATE TABLE [Dr0p].BI_Hechos_Ventas_Producto(
                                                 tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                                 rango_etario_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Rangos_etarios(id),
                                                 canal_venta_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Canales_De_Venta(id),
                                                 categoria_producto_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Categorias_De_Productos(id),
                                                 producto_codigo  NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.BI_Productos(codigo),
                                                 total_productos_vendidos DECIMAL(18,2) NOT NULL,
                                                 cantidad_producto DECIMAL(18,0)
)

CREATE TABLE [Dr0p].BI_Hechos_Envios_Provincias(
                                                 tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                                 provincia_id NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.BI_Provincias(nombre),
                                                 porcentaje_envios DECIMAL(10,2) NOT NULL,
                                                 total_envios DECIMAL(18,2) NOT NULL
)


CREATE TABLE [Dr0p].BI_Hechos_Medios_Envios_Provincias(
                                                          tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                                          provincia_id NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.BI_Provincias(nombre),
                                                          medio_de_envio_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Envio(id),
                                                          total_envios DECIMAL(18,0) NOT NULL,
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

INSERT INTO [Dr0p].BI_Rangos_etarios(descripcion)
SELECT DISTINCT [Dr0p].bi_obtener_rango_etario(C.fecha_nacimiento)
FROM [Dr0p].Ventas V
         INNER JOIN [Dr0p].Clientes C ON V.cliente_id = C.id

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
    tipo_medio
)
SELECT MP.tipo_medio
FROM Dr0p.Medios_De_Pago MP


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
-- 'Por envio' --
INSERT INTO [Dr0p].BI_Hechos_Descuentos(
    descuento_tipo_id,
    tiempo_id,
    canales_de_venta_id,
    total_descuento)

SELECT (SELECT id from [Dr0p].BI_Descuentos_Tipo BIDT WHERE BIDT.tipo = 'Por envio') as descuento_tipo_id,
       (SELECT id FROM [Dr0p].BI_Tiempos WHERE anio = YEAR(V.fecha) AND mes = MONTH(V.fecha)) as tiempo_id,
       (SELECT id FROM [Dr0p].BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
       SUM ( ME.medio_envio_precio - EV.medio_envio_precio) as total_descuento
from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Envios_Ventas EV on EV.venta_codigo = V.codigo
         JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
         INNER JOIN [Dr0p].Medios_de_envio ME ON ME.id = EV.medio_envio_id
WHERE EV.medio_envio_precio = 0
GROUP BY YEAR(V.fecha), MONTH(V.fecha), CV.descripcion


INSERT INTO [Dr0p].BI_Hechos_Descuentos(
    descuento_tipo_id,
    tiempo_id,
    canales_de_venta_id,
    total_descuento)

-- 'Por medio de pago' --
SELECT (SELECT id from [Dr0p].BI_Descuentos_Tipo BIDT WHERE BIDT.tipo = 'Por medio de pago') as descuento_tipo_id,
       (SELECT id FROM [Dr0p].BI_Tiempos WHERE anio = YEAR(V.fecha) AND mes = MONTH(V.fecha)) as tiempo_id,
       (SELECT id FROM [Dr0p].BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
       SUM ( DV.importe_descuento_venta ) as descuento
from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Descuentos_Ventas DV on DV.venta_codigo = V.codigo
         JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
WHERE DV.importe_descuento_venta IS NOT NULL AND DV.concepto <> 'Otros'
GROUP BY YEAR(V.fecha), MONTH(V.fecha), CV.descripcion

-- 'Por cupon' --
INSERT INTO [Dr0p].BI_Hechos_Descuentos(
    descuento_tipo_id,
    tiempo_id,
    canales_de_venta_id,
    total_descuento)

SELECT (SELECT id from [Dr0p].BI_Descuentos_Tipo BIDT WHERE BIDT.tipo = 'Por cupon') as descuento_tipo_id,
       (SELECT id FROM [Dr0p].BI_Tiempos WHERE anio = YEAR(V.fecha) AND mes = MONTH(V.fecha)) as tiempo_id,
       (SELECT id FROM [Dr0p].BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
       SUM ( VC.importe ) as descuento
from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Ventas_Cupones VC on VC.venta_codigo = V.codigo
         JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
WHERE VC.importe IS NOT NULL
GROUP BY YEAR(V.fecha), MONTH(V.fecha), CV.descripcion

-- 'Por descuento especial' --
INSERT INTO [Dr0p].BI_Hechos_Descuentos(
    descuento_tipo_id,
    tiempo_id,
    canales_de_venta_id,
    total_descuento)

SELECT (SELECT id from [Dr0p].BI_Descuentos_Tipo BIDT WHERE BIDT.tipo = 'Por descuento especial') as descuento_tipo_id,
       (SELECT id FROM [Dr0p].BI_Tiempos WHERE anio = YEAR(V.fecha) AND mes = MONTH(V.fecha)) as tiempo_id,
       (SELECT id FROM [Dr0p].BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
       SUM ( DV.importe_descuento_venta ) as descuento
from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Descuentos_Ventas DV on DV.venta_codigo = V.codigo
         JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
WHERE DV.importe_descuento_venta IS NOT NULL AND DV.concepto = 'Otros'
GROUP BY YEAR(V.fecha), MONTH(V.fecha), CV.descripcion



-- BI_Hechos_Ganancia_Mensual_Canal --
INSERT INTO [Dr0p].BI_Hechos_Ganancia_Mensual_Canal(tiempo_id, canal_venta_id, total_ganancias)
SELECT T.id, BICV.id, SUM (V.total - C.total - VMP.costo_medio_pago_aplicado)
FROM
    Dr0p.Ventas V
        INNER JOIN Dr0p.BI_Tiempos T ON YEAR(V.fecha) = T.anio AND MONTH(V.fecha) = T.mes
        INNER JOIN Dr0p.Ventas_Medios_De_Pago VMP ON VMP.venta_codigo = V.codigo
        INNER JOIN Dr0p.Compras C ON YEAR(C.fecha) = T.anio AND MONTH(C.fecha) = T.mes
        INNER JOIN Dr0p.BI_Canales_De_Venta BICV ON BICV.descripcion = (SELECT CV.descripcion FROM Dr0p.Canales_de_venta CV WHERE CV.id = V.canal_venta_id)
group BY T.id, BICV.id

-- BI Hechos ventas total

INSERT INTO [Dr0p].BI_Hechos_Ventas_Total(
    tiempo_id,
    canal_venta_id,
    medio_envio_id,
    provincia_id,
    medio_pago_id,
    costo_medio_de_pago_aplicado,
    descuento_medio_pago_aplicado,
    total_venta
)
SELECT

    (SELECT id FROM Dr0p.BI_Tiempos BITI WHERE BITI.anio = YEAR(V.fecha) AND BITI.mes = MONTH(V.fecha)) as tiempo_id,
    (SELECT id FROM Dr0p.BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
    (SELECT id FROM Dr0p.BI_Medios_De_Envio BIME WHERE BIME.nombre = (SELECT nombre FROM Dr0p.Medios_de_envio ME WHERE ME.id= EV.medio_envio_id)) as medio_envio_id,
    (SELECT provincia_nombre FROM Dr0p.Localidades L WHERE L.id = CL.localidad) as provincia_id,
    (SELECT id FROM Dr0p.BI_Medios_De_Pago BIMP WHERE BIMP.tipo_medio = (SELECT tipo_medio FROM Dr0p.Medios_de_Pago MP WHERE MP.id= VMP.medio_de_pago_id)) as medio_pago_id,
    SUM (VMP.costo_medio_pago_aplicado) as costo_medio_de_pago_aplicado,
    SUM (
            CASE
                WHEN (DV.concepto <> 'Otros') THEN ISNULL(DV.importe_descuento_venta, 0)
                ELSE 0
                END
        )
        as descuento_medio_pago_aplicado,
    SUM ( V.total) as total


FROM
    Dr0p.Ventas V
        LEFT JOIN Dr0p.Canales_de_venta CV on CV.id = V.canal_venta_id
        INNER JOIN Dr0p.Clientes CL ON CL.id = V.cliente_id
        LEFT JOIN Dr0p.Ventas_Medios_De_Pago VMP ON VMP.venta_codigo = V.codigo
        INNER JOIN Dr0p.Envios_Ventas EV ON EV.venta_codigo = V.codigo
        LEFT JOIN Dr0p.Descuentos_Ventas DV ON DV.venta_codigo = V.codigo
GROUP BY MONTH(V.fecha), YEAR(V.fecha), CV.descripcion,
         CL.localidad, EV.medio_envio_id, VMP.medio_de_pago_id
GO


-- BI Hechos ventas x producto
INSERT INTO [Dr0p].BI_Hechos_Ventas_Producto(
    tiempo_id,
	rango_etario_id,
    canal_venta_id,
	categoria_producto_id,
	producto_codigo,
	total_productos_vendidos,
	cantidad_producto
)
SELECT T.id, RE.id, V.canal_venta_id, P.categoria, P.codigo, SUM(VP.precio * VP.cantidad) , SUM(VP.cantidad)
FROM
	Dr0p.Ventas V
	INNER JOIN Dr0p.BI_Tiempos T ON YEAR(V.fecha) = T.anio AND MONTH(V.fecha) = T.mes
	INNER JOIN Dr0p.Clientes C ON C.id = V.cliente_id
	INNER JOIN Dr0p.BI_Rangos_etarios RE ON RE.descripcion = Dr0p.bi_obtener_rango_etario(C.fecha_nacimiento)
	INNER JOIN Dr0p.Ventas_Productos VP ON VP.venta_codigo = V.codigo
	INNER JOIN Dr0p.Productos P ON P.codigo = VP.producto_codigo
	GROUP BY T.id, RE.id, V.canal_venta_id, P.categoria, P.codigo
GO

--
INSERT INTO [Dr0p].BI_Hechos_Productos_Rentabilidad(tiempo_id, producto_codigo, rentabilidad)
SELECT
    T.id,
       P.codigo,
    Dr0p.bi_calcular_rentabilidad( SUM( CONVERT(DECIMAL(18, 2), VP.cantidad*VP.precio )) , SUM( CONVERT(DECIMAL(18, 2),  CP.cantidad*CP.precio)) )
FROM Dr0p.BI_Tiempos T
         LEFT JOIN Dr0p.Ventas V ON YEAR(V.fecha) = T.anio AND MONTH(V.fecha) = T.mes
         INNER JOIN Dr0p.Ventas_Productos VP ON VP.venta_codigo = V.codigo
         INNER JOIN Dr0p.Productos P ON P.codigo = VP.producto_codigo
         LEFT JOIN Dr0p.Compras_Productos CP ON CP.producto_codigo = P.codigo
         LEFT JOIN Dr0p.Compras C ON YEAR(C.fecha) = T.anio AND MONTH(C.fecha) = T.mes AND C.numero = CP.compra_numero
GROUP BY T.id, P.codigo
GO

INSERT INTO Dr0p.BI_Hechos_Envios_Provincias (
    tiempo_id,
    provincia_id,
    porcentaje_envios,
    total_envios)
SELECT
    T.id as tiempo,
    L.provincia_nombre as provincia,
    [Dr0p].calcular_porcentaje(
            (SELECT count(EV2.id)
             FROM Dr0p.Ventas V2
                      INNER JOIN Dr0p.Envios_Ventas EV2 ON EV2.venta_codigo = V2.codigo
             WHERE YEAR(V2.fecha) = T.anio AND MONTH(V2.fecha) = T.mes
            ) , count(EV.id) ) as porcentaje,

    (SELECT count(EV2.id)
     FROM Dr0p.Ventas V2
              INNER JOIN Dr0p.Envios_Ventas EV2 ON EV2.venta_codigo = V2.codigo
     WHERE YEAR(V2.fecha) = T.anio AND MONTH(V2.fecha) = T.mes
    ) as total_envios

FROM Dr0p.Ventas V
         INNER JOIN Dr0p.BI_Tiempos T ON  YEAR(V.fecha) = T.anio AND MONTH(V.fecha) = T.mes
         INNER JOIN Dr0p.Envios_Ventas EV ON EV.venta_codigo = V.codigo
         INNER JOIN Dr0p.Envios_Ventas_Localidad EVL ON EVL.envio_venta_id = EV.id
         INNER JOIN Dr0p.Localidades L ON L.id = EVL.localidad_id

GROUP BY T.id, T.mes, T.anio, L.provincia_nombre
GO

INSERT INTO Dr0p.BI_Hechos_Medios_Envios_Provincias(
    tiempo_id,
    provincia_id,
    medio_de_envio_id,
    total_envios)
SELECT
    T.id as tiempo,
    L.provincia_nombre as provincia,
    (SELECT id FROM Dr0p.BI_Medios_De_Envio BIME WHERE BIME.nombre = ME.nombre) as medio_de_envio_id,
    count(EV.id)

FROM Dr0p.Ventas V
         INNER JOIN Dr0p.BI_Tiempos T ON  YEAR(V.fecha) = T.anio AND MONTH(V.fecha) = T.mes
         INNER JOIN Dr0p.Envios_Ventas EV ON EV.venta_codigo = V.codigo
         INNER JOIN Dr0p.Medios_de_Envio ME ON ME.id = EV.medio_envio_id
         INNER JOIN Dr0p.Envios_Ventas_Localidad EVL ON EVL.envio_venta_id = EV.id
         INNER JOIN Dr0p.Localidades L ON L.id = EVL.localidad_id

GROUP BY T.id, T.mes, T.anio, L.provincia_nombre, ME.nombre

/*
INSERT INTO [Dr0p].BI_Hechos_Compras(
    tiempo_id,
    proveedor_cuit,
    medio_de_pago_id,
    precio
)
SELECT (SELECT id FROM Dr0p.BI_Tiempos BITI WHERE BITI.anio = YEAR(C.fecha) AND BITI.mes = MONTH(C.fecha)) as tiempo_id,
       C.proveedor,
       (SELECT id FROM Dr0p.BI_Medios_De_Pago BIMP WHERE BIMP.tipo_medio = MP.tipo_medio) as medio_pago_id,
       CP.precio
FROM
    Dr0p.Compras C
        JOIN Dr0p.Medios_De_Pago MP ON C.medio_pago = MP.id
        INNER JOIN Dr0p.Compras_Productos CP ON CP.compra_numero = C.numero
GO
*/
--------------------- CREACION DE VISTAS ---------------------

-- Las ganancias mensuales de cada canal de venta.

CREATE VIEW [Dr0p].[BI_VIEW_GANANCIA_MENSUAL_CANAL_VENTA]
AS
	SELECT  T.anio, T.mes, CV.descripcion, HG.total_ganancias
	FROM
		Dr0p.BI_Hechos_Ganancia_Mensual_Canal HG
		INNER JOIN Dr0p.BI_Tiempos T ON T.id = HG.tiempo_id
		INNER JOIN Dr0p.BI_Canales_De_Venta CV ON CV.id = HG.canal_venta_id
	GROUP BY T.anio, T.mes, CV.descripcion, HG.total_ganancias
GO


-- Los 5 productos con mayor rentabilidad anual
CREATE VIEW [Dr0p].[BI_VIEW_TOP_5_RENTABILIDAD_PRODUCTOS]
AS
SELECT TOP 5
    P.codigo,
    P.nombre,
    T.anio,
    AVG(BIHPR.rentabilidad) as rentabilidad
FROM [Dr0p].BI_Hechos_Productos_Rentabilidad BIHPR

         INNER JOIN Dr0p.BI_Tiempos T ON T.id = BIHPR.tiempo_id
         INNER JOIN Dr0p.BI_Productos P ON P.codigo = BIHPR.producto_codigo
GROUP BY P.codigo, P.nombre, T.anio
ORDER BY rentabilidad DESC

GO


-- Las 5 categorías de productos más vendidos por rango etario de clientes por mes.
CREATE VIEW [Dr0p].[BI_PRODUCTOS_MAS_VENDIDOS_POR_RANGO_ETARIO]
AS
    SELECT 
		T.mes, T.anio, RE.descripcion AS rango_etario, CP.detalle, SUM(HVP.cantidad_producto) as total_vendido
    FROM
        Dr0p.BI_Hechos_Ventas_Producto HVP
		INNER JOIN Dr0p.BI_Rangos_etarios RE ON HVP.rango_etario_id = RE.id
		INNER JOIN Dr0p.BI_Categorias_De_Productos CP ON CP.id = HVP.categoria_producto_id
		INNER JOIN Dr0p.BI_Tiempos T ON HVP.tiempo_id = T.id
	GROUP BY 
		T.anio, T.mes, RE.descripcion, CP.detalle
	ORDER BY 
		T.mes, rango_etario, CP.detalle ASC
	OFFSET 0 ROWS
GO


/*Total de Ingresos por cada medio de pago por mes, descontando los costos
por medio de pago (en caso que aplique) y descuentos por medio de pago
(en caso que aplique)*/
CREATE VIEW [Dr0p].[BI_VIEW_INGRESOS_MENSUALES_POR_MEDIO_DE_PAGO]
AS
	SELECT T.anio, T.mes, MP.tipo_medio, SUM(HVT.total_venta - HVT.costo_medio_de_pago_aplicado - HVT.descuento_medio_pago_aplicado) as total_ingresos
	FROM 
		Dr0p.BI_Hechos_Ventas_Total HVT
	INNER JOIN Dr0p.BI_Tiempos T ON T.id = HVT.tiempo_id
	INNER JOIN Dr0p.BI_Medios_De_Pago MP ON MP.id = HVT.medio_pago_id
	GROUP BY   T.anio, T.mes, MP.tipo_medio  
GO

/* Importe total en descuentos aplicados según su tipo de descuento, por
canal de venta, por mes. Se entiende por tipo de descuento como los
correspondientes a envío, medio de pago, cupones, etc)*/
CREATE VIEW [Dr0p].[BI_DESCUENTOS_APLICADOS_MENSUALMENTE_POR_TIPO_Y_CANAL_DE_VENTA]
AS
SELECT
    DT.tipo,
    CV.descripcion as canal_de_venta,
    T.mes ,
    T.anio,
    total_descuento as total_descuento_mensual
FROM [Dr0p].BI_Hechos_Descuentos HD
         INNER JOIN
     Dr0p.BI_Tiempos T ON HD.tiempo_id = T.id
         INNER JOIN
     Dr0p.BI_Descuentos_Tipo DT ON DT.id = HD.descuento_tipo_id
         INNER JOIN
     Dr0p.BI_Canales_De_Venta CV ON CV.id = HD.canales_de_venta_id
GO


/*Porcentaje de envíos realizados a cada Provincia por mes. El porcentaje
debe representar la cantidad de envíos realizados a cada provincia sobre
total de envío mensuales*/
CREATE VIEW [Dr0p].[BI_VIEW_ENVIOS_PROVINCIA_POR_MES]
AS
	SELECT T.anio, T.mes, P.nombre, porcentaje_envios 
	FROM  [Dr0p].BI_HECHOS_ENVIOS_PROVINCIAS HEP
	INNER JOIN Dr0p.BI_Tiempos T on T.id = HEP.tiempo_id
	INNER JOIN Dr0p.BI_Provincias P on p.nombre = HEP.provincia_id
	GROUP BY T.anio, T.mes, P.nombre, porcentaje_envios
GO


-- TODO: ver esto
-- Valor promedio de envío por Provincia por Medio De Envío anual.
/*
CREATE VIEW [Dr0p].[BI_VIEW_VALOR_PROMEDIO_ENVIO_ANUAL_PROVINCIA]
AS
	SELECT T.anio, P.nombre, ME.nombre, HEP.promedio_envios 
	FROM  [Dr0p].BI_HECHOS_ENVIOS_PROVINCIAS HEP
	INNER JOIN Dr0p.BI_Tiempos T on T.id = HEP.tiempo_id
	INNER JOIN Dr0p.BI_Provincias P on p.nombre = HEP.provincia_id
	INNER JOIN Dr0p.BI_Medios_De_Envio ME ON ME.id = HEP.medio_envio_id
	GROUP BY T.anio, P.nombre, ME.nombre, HEP.promedio_envios
GO

*/




/*INSERT INTO Dr0p.BI_Hechos_Envios_Provincias (
    tiempo_id,
    provincia_id,
    medio_envio_id,
    porcentaje_envios,
    promedio_envios,
    total_envios)
SELECT
    T.id as tiempo,
    L.provincia_nombre as provincia,
    (SELECT id FROM Dr0p.BI_Medios_De_Envio BIME WHERE BIME.nombre = ME.nombre) as medio_de_envio,
    (count(DISTINCT EV.id)) as envios_provincia_por_medio_de_envio,
    /*(	SELECT count (DISTINCT EV2.id)

        FROM Dr0p.Ventas V2
        INNER JOIN Dr0p.Envios_Ventas EV2 ON EV2.venta_codigo = V2.codigo
        INNER JOIN Dr0p.Medios_de_envio_Localidad MEL2 ON MEL2.medio_envio_id = EV2.medio_envio_id
        INNER JOIN Dr0p.Localidades L2 ON L2.id = MEL2.localidad_id
        WHERE YEAR(V2.fecha) = T.anio AND MONTH(V2.fecha) = T.mes
        AND L2.provincia_nombre = L.provincia_nombre
        GROUP BY L2.provincia_nombre
    ) as envios_provincia,*/
    (SELECT count(EV.id)
     FROM Dr0p.Ventas V2
              INNER JOIN Dr0p.Envios_Ventas EV ON EV.venta_codigo = V2.codigo
     WHERE YEAR(V2.fecha) = T.anio AND MONTH(V2.fecha) = T.mes
    ) as total_envios*/