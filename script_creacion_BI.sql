USE [GD2C2022]
GO

IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE schema_id = SCHEMA_ID('Dr0p'))
BEGIN

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


--CREACION DE TABLAS --

-- BI Provincias
CREATE TABLE [Dr0p].[BI_Provincias](
    nombre NVARCHAR(255) PRIMARY KEY
)

-- BI Clientes
CREATE TABLE [Dr0p].[BI_Clientes](
                                  id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
                                  dni DECIMAL(18,0),
                                  apellido NVARCHAR(255),
                                  nombre NVARCHAR(255),
                                  telefono DECIMAL(18,0),
                                  mail NVARCHAR(255),
                                  fecha_nacimiento DATE,
                                  direccion NVARCHAR(255)
)

-- BI Rangos Etarios
CREATE TABLE [Dr0p].[BI_Rangos_etarios](
                                id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
                                descripcion NVARCHAR(255),
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
                                           producto_codigo NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.BI_Productos(codigo),
                                           precio DECIMAL(18,2),
                                           cantidad DECIMAL(19,0)
)


--Hechos Ventas
CREATE TABLE [Dr0p].[BI_Hechos_Ventas](
                                tiempo_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Tiempos(id),
                                cliente_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Clientes(id),
                                rango_etario_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Rangos_etarios(id),
                                canal_venta_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Canales_De_Venta(id),
                                producto_codigo  NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.BI_Productos(codigo),
                                categoria_producto_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Categorias_De_Productos(id),
                                medio_envio_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Envio(id),
                                provincia_id NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.BI_Provincias(nombre),
                                medio_pago_id DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Pago(id),
                                costo_medio_de_pago_aplicado DECIMAL(18,2),
                                porcentaje_descuento_medio_pago_aplicado DECIMAL(5,2),
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

-- BI Clientes
INSERT INTO [Dr0p].BI_Clientes(dni, apellido, nombre, telefono, mail, fecha_nacimiento, direccion)
SELECT DISTINCT dni, apellido, nombre, telefono, mail, fecha_nacimiento, direccion FROM [Dr0p].Clientes


-- BI Rango Etario

INSERT INTO [Dr0p].BI_Rangos_etarios(descripcion)
VALUES ('< 25')
INSERT INTO [Dr0p].BI_Rangos_etarios(descripcion)
VALUES ('25 - 35')
INSERT INTO [Dr0p].BI_Rangos_etarios(descripcion)
VALUES ('35 - 55')
INSERT INTO [Dr0p].BI_Rangos_etarios(descripcion)
VALUES ('> 50')

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
SELECT tipo_medio
FROM
[Dr0p].Medios_De_Pago

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
         INNER JOIN [Dr0p].Envios_Ventas EV on EV.id = V.envio_id
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
       VMP.PORCENTAJE_DESCUENTO_MEDIO_PAGO_APLICADO as descuento
from [Dr0p].Ventas V
         INNER JOIN [Dr0p].Ventas_Medios_De_Pago VMP on VMP.venta_codigo = V.codigo
         JOIN [Dr0p].Canales_de_venta CV on CV.id = V.canal_venta_id
WHERE VMP.PORCENTAJE_DESCUENTO_MEDIO_PAGO_APLICADO <> 0


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
WHERE DV.importe_descuento_venta IS NOT NULL



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
    cliente_id,
    rango_etario_id,
    canal_venta_id,
    producto_codigo,
    medio_envio_id,
    provincia_id,
    medio_pago_id,
    costo_medio_de_pago_aplicado,
    porcentaje_descuento_medio_pago_aplicado,
    total_venta,
    cantidad_productos
)
SELECT

    (SELECT id FROM Dr0p.BI_Tiempos BITI WHERE BITI.anio = YEAR(V.fecha) AND BITI.mes = MONTH(V.fecha)) as tiempo_id,
    (SELECT id FROM Dr0p.BI_Clientes BICL WHERE BICL.dni = CL.dni AND BICL.apellido = CL.apellido AND BICL.nombre = CL.nombre) as cliente_id,
    (SELECT id FROM Dr0p.BI_Rangos_etarios BIRE WHERE  BIRE.descripcion = Dr0p.bi_obtener_rango_etario(CL.fecha_nacimiento)) as rango_etario,
    (SELECT id FROM Dr0p.BI_Canales_De_Venta BICV WHERE BICV.descripcion = CV.descripcion) as canal_de_venta_id,
    VP.producto_codigo,
    (SELECT id FROM Dr0p.BI_Medios_De_Envio BIME WHERE BIME.nombre = (SELECT nombre FROM Dr0p.Medios_de_envio ME WHERE ME.id= EV.medio_envio_id)) as medio_envio_id,
    (SELECT provincia_nombre FROM Dr0p.Localidades L WHERE L.id = CL.localidad) as provincia_id,
    (SELECT id FROM Dr0p.BI_Medios_De_Pago BIMP WHERE BIMP.tipo_medio = (SELECT tipo_medio FROM Dr0p.Medios_de_Pago MP WHERE MP.id= VMP.medio_de_pago_id)) as medio_pago_id,
    VMP.costo_medio_pago_aplicado as costo_medio_de_pago_aplicado,
    VMP.porcentaje_descuento_medio_pago_aplicado as porcentaje_descuento_medio_pago_aplicado,
    VP.precio as total_venta,
    VP.cantidad as cantidad_productos


FROM
    Dr0p.Ventas V
        INNER JOIN Dr0p.Clientes CL ON CL.id = V.cliente_id
        LEFT JOIN Dr0p.Canales_de_venta CV on CV.id = V.canal_venta_id
        INNER JOIN Dr0p.Ventas_Productos VP ON VP.venta_codigo = V.codigo
        LEFT JOIN Dr0p.Ventas_Medios_De_Pago VMP ON VMP.venta_codigo = V.codigo
        INNER JOIN Dr0p.Envios_Ventas EV ON EV.id = V.envio_id



GO
