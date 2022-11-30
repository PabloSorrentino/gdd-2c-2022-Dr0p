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

	EXECUTE(@SQL_FK)
--------------------------------------  E L I M I N A R   P K  --------------------------------------
	DECLARE @SQL_PK NVARCHAR(MAX) = N'';

	SELECT @SQL_PK += N'
	ALTER TABLE Dr0p.' + OBJECT_NAME(PARENT_OBJECT_ID) + ' DROP CONSTRAINT ' + OBJECT_NAME(OBJECT_ID) + ';' 
	FROM SYS.OBJECTS
	WHERE TYPE_DESC LIKE '%CONSTRAINT'
	AND type = 'PK'
	AND schema_id = SCHEMA_ID('Dr0p')

	EXECUTE(@SQL_PK)
----------------------------------------- D R O P   T A B L E S -------------------------------------
	DECLARE @SQL2 NVARCHAR(MAX) = N'';

	SELECT @SQL2 += N'
	DROP TABLE Dr0p.' + TABLE_NAME + ';' 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_SCHEMA = 'Dr0p'
	AND TABLE_TYPE = 'BASE TABLE'

	EXECUTE(@SQL2)

----------------------------------------- D R O P   S C H E M A -------------------------------------
	DROP SCHEMA Dr0p
END
GO


--CREACION ESQUEMA --
IF NOT EXISTS ( SELECT * FROM sys.schemas WHERE name = 'Dr0p')
BEGIN
EXECUTE('CREATE SCHEMA Dr0p')
END
GO


--CREACION FUNCION AUXILIAR PARA CALCULAR PORCENTAJE
CREATE FUNCTION [Dr0p].calcular_porcentaje (@total DECIMAL(18, 2),	@numero DECIMAL(18,2))
RETURNS DECIMAL(5, 2)
AS
BEGIN
RETURN (@numero / @total * 100);
END
GO


--CREACION DE TABLAS --

--	Localidad
CREATE TABLE [Dr0p].[Localidades](
	id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY ,
    nombre NVARCHAR(255),
    codigo_postal DECIMAL(18,0),
	provincia_nombre NVARCHAR(255)
)


--	Proovedores
CREATE TABLE [Dr0p].[Proveedores](
    cuit NVARCHAR(255) PRIMARY KEY,
    razon_social NVARCHAR(50),
    mail NVARCHAR(50),
    domicilio NVARCHAR(50),
    localidad_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.Localidades(id)
    )


-- Localidades-Proveedores
CREATE TABLE [Dr0p].[Localidades_Proveedores](
	proveedor_cuit NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.[Proveedores](cuit),
    localidad_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.Localidades(id),
	PRIMARY KEY(proveedor_cuit, localidad_id)
)

--Categorias
CREATE TABLE [Dr0p].[Categorias] (
                                     id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    detalle NVARCHAR(255)
    )


--Productos
CREATE TABLE [Dr0p].[Productos](
    codigo NVARCHAR(50) PRIMARY KEY,
    nombre NVARCHAR(50),
    descripcion NVARCHAR(50),
    material NVARCHAR(50),
    marca  NVARCHAR(255),
    categoria DECIMAL(18,0) FOREIGN KEY REFERENCES [Dr0p].Categorias(id)
    )

--Tipos Variante
CREATE TABLE [Dr0p].[Tipos_Variantes](
                                         id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    detalle NVARCHAR(50)
    )


--Variantes
CREATE TABLE [Dr0p].[Variantes](
    codigo NVARCHAR(50) PRIMARY KEY,
    variante NVARCHAR(50),
    tipo_variante DECIMAL(18,0) FOREIGN KEY REFERENCES [Dr0p].Tipos_Variantes(id),
    producto_codigo NVARCHAR(50) FOREIGN KEY REFERENCES [Dr0p].Productos(codigo)
    )

-- Medios de envio
CREATE TABLE [Dr0p].[Medios_de_envio](
	id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(255),
	medio_envio_precio decimal(18,2)
    )

-- Envios Ventas
CREATE TABLE [Dr0p].[Envios_Ventas](
                                       id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    medio_envio_id DECIMAL(18,0) FOREIGN KEY REFERENCES [Dr0p].[Medios_de_envio](id),
    medio_envio_precio DECIMAL(18,2)
    )

--Medios de envio - localidad
CREATE TABLE [Dr0p].[Medios_de_envio_Localidad](
    medio_envio_id DECIMAL(18,0) FOREIGN KEY REFERENCES [Dr0p].[Medios_de_envio](id),
    localidad_id DECIMAL(18,0) FOREIGN KEY REFERENCES [Dr0p].[Medios_de_envio](id),
    importe DECIMAL(18,2),
    tiempo_estimado DECIMAL(18,0),
	PRIMARY KEY( medio_envio_id, localidad_id)
)


-- Canales de venta
CREATE TABLE [Dr0p].[Canales_de_venta](
                                          id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    descripcion NVARCHAR(255),
    costo DECIMAL(18,2)
    )

-- Clientes
CREATE TABLE [Dr0p].[Clientes](
                                  id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    dni DECIMAL(18,0),
    apellido NVARCHAR(255),
    nombre NVARCHAR(255),
    telefono DECIMAL(18,0),
    mail NVARCHAR(255),
    fecha_nacimiento DATE,
    direccion NVARCHAR(255),
    localidad DECIMAL(18,0) FOREIGN KEY REFERENCES [Dr0p].Localidades(id),
    provincia_nombre NVARCHAR(255)
    )

--Descuentos tipo
CREATE TABLE[Dr0p].[Descuentos_Tipo](
                                        id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    tipo NVARCHAR(255),
    importe DECIMAL(18,2)
    )

-- Cupones
CREATE TABLE [Dr0p].[Cupones](
                                 id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    codigo NVARCHAR(255),
    fecha_desde DATE,
    fecha_hasta DATE,
    valor DECIMAL(18,2),
    tipo NVARCHAR(50)
    )

--Medios de Pago
CREATE TABLE [Dr0p].[Medios_De_Pago](
                                        id DECIMAL(19,0) IDENTITY(1,1) PRIMARY KEY,
    tipo_medio NVARCHAR(255),
    costo_venta DECIMAL(18,2),
    porcentaje_descuento_venta DECIMAL(18,2)
    )

--Compras
CREATE TABLE [Dr0p].[Compras](
                                 numero DECIMAL(19,0) PRIMARY KEY,
    fecha DATE,
    proveedor  NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.Proveedores(cuit),
    medio_pago DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.Medios_De_Pago(id),
    total DECIMAL(18,2)
    )

--Descuento-Compras
CREATE TABLE [Dr0p].[Descuentos_Compra](
                                           codigo DECIMAL(18,0) PRIMARY KEY,
    numero_compra DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.Compras(numero),
    valor_descuento DECIMAL(18,2)
    )

--Compras-Productos
CREATE TABLE [Dr0p].[Compras_Productos](
    id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    precio DECIMAL(18,2),
    cantidad DECIMAL(18,2),
    compra_numero DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.Compras(numero),
    producto_codigo  NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.Productos(codigo),
	variante_codigo NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.Variantes(codigo)
    )

--Ventas
CREATE TABLE [Dr0p].[Ventas](
                                codigo DECIMAL(19,0) PRIMARY KEY,
    fecha DATE,
    cliente_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.Clientes(id),
    envio_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.Envios_Ventas(id),
    canal_venta_id  DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.Canales_de_venta(id),
    total DECIMAL(18,2) NOT NULL,
    costo_canal_venta DECIMAL(18,2)
    )

--Ventas-Productos
CREATE TABLE [Dr0p].[Ventas_Productos](
    id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    venta_codigo DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.Ventas(codigo),
    producto_codigo NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.Productos(codigo), 
	variante_codigo NVARCHAR(50) FOREIGN KEY REFERENCES Dr0p.Variantes(codigo),
    precio DECIMAL(18,2) NOT NULL,
    cantidad DECIMAL(18,0) NOT NULL
    )

-- Ventas-Medios de Pago
CREATE TABLE [Dr0p].[Ventas_Medios_De_Pago](
                                               id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    costo_medio_pago_aplicado DECIMAL(18,2),
    porcentaje_descuento_medio_pago_aplicado DECIMAL(5,2),
    venta_codigo DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.Ventas(codigo),
    medio_de_pago_id DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.Medios_de_Pago(id)
    )

--Ventas-Cupones
CREATE TABLE [Dr0p].[Ventas_Cupones](
                                        id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    importe DECIMAL(18,2),
    venta_codigo DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.Ventas(codigo),
    cupon_id DECIMAL(18,0)  FOREIGN KEY REFERENCES Dr0p.Cupones(id)
    )

--Descuentos-Venta
CREATE TABLE [Dr0p].[Descuentos_Ventas](
                                           id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    descuento_tipo_id DECIMAL (18,0) FOREIGN KEY REFERENCES Dr0p.Descuentos_Tipo(id),
    concepto NVARCHAR(255),
    venta_codigo DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.Ventas(codigo),
    importe_descuento_venta DECIMAL(18,2)
    )
GO

    --INSERCION DE DATOS A TABLAS --

--Localidad
CREATE PROCEDURE Dr0p.MIGRACION_LOCALIDADES 
AS
BEGIN
INSERT INTO Dr0p.Localidades(
	nombre,
    codigo_postal,
	provincia_nombre
)
SELECT DISTINCT 
	M.CLIENTE_LOCALIDAD,
	M.CLIENTE_CODIGO_POSTAL,
	M.CLIENTE_PROVINCIA
FROM 
	gd_esquema.Maestra M	


INSERT INTO Dr0p.Localidades(
	nombre,
    codigo_postal,
	provincia_nombre
)
SELECT DISTINCT 
	M.PROVEEDOR_LOCALIDAD,
	M.PROVEEDOR_CODIGO_POSTAL,
	M.PROVEEDOR_PROVINCIA
FROM 
	gd_esquema.Maestra M

END
GO

EXEC Dr0p.MIGRACION_LOCALIDADES
GO

--Proovedores
INSERT INTO [Dr0p].[Proveedores](
    cuit,
    razon_social,
    mail,
    domicilio
)
SELECT DISTINCT PROVEEDOR_CUIT, 
				PROVEEDOR_RAZON_SOCIAL,
                PROVEEDOR_MAIL, 
				PROVEEDOR_DOMICILIO
FROM [gd_esquema].[Maestra] M
WHERE PROVEEDOR_CUIT IS NOT NULL 

-- Localidades - Proovedores
INSERT INTO [Dr0p].[Localidades_Proveedores](
   proveedor_cuit,
   localidad_id
)
SELECT DISTINCT PROVEEDOR_CUIT, 
                L.id
FROM 
	[gd_esquema].[Maestra] M
	JOIN [Dr0p].[Localidades] L
ON 
	L.codigo_postal = M.PROVEEDOR_CODIGO_POSTAL AND L.nombre = M.PROVEEDOR_LOCALIDAD
WHERE 
	PROVEEDOR_CUIT IS NOT NULL 


--Categorias
INSERT INTO [Dr0p].[Categorias] (
    detalle
)
SELECT DISTINCT
    PRODUCTO_CATEGORIA
FROM
    gd_esquema.Maestra
WHERE
    PRODUCTO_CATEGORIA IS NOT NULL
ORDER BY 1 ASC


--Productos
    INSERT INTO [Dr0p].[Productos](
    codigo,
    nombre,
    descripcion,
    material,
    marca,
    categoria
)
SELECT DISTINCT
    M.PRODUCTO_CODIGO,
    M.PRODUCTO_NOMBRE,
    M.PRODUCTO_DESCRIPCION,
    M.PRODUCTO_MATERIAL,
    M.PRODUCTO_MARCA,
    (select C.id FROM [Dr0p].[Categorias] C WHERE C.detalle = M.PRODUCTO_CATEGORIA)
FROM
    gd_esquema.Maestra M
where
    M.PRODUCTO_NOMBRE is not null
order by
    PRODUCTO_NOMBRE ASC


--Tipos Variante
INSERT INTO [Dr0p].[Tipos_Variantes](
    detalle
)
SELECT DISTINCT
    m.PRODUCTO_TIPO_VARIANTE
FROM
    gd_esquema.Maestra m
WHERE
    m.PRODUCTO_TIPO_VARIANTE IS NOT NULL


--Variantes
    INSERT INTO [Dr0p].[Variantes](
    codigo,
    variante,
    tipo_variante,
    producto_codigo
)
SELECT
    M.PRODUCTO_VARIANTE_CODIGO,
    M.PRODUCTO_VARIANTE,
    (SELECT id FROM [Dr0p].[Tipos_Variantes] TV WHERE  TV.detalle = M.PRODUCTO_TIPO_VARIANTE),
    M.PRODUCTO_CODIGO
FROM
    gd_esquema.Maestra M
WHERE
    m.PRODUCTO_TIPO_VARIANTE IS NOT NULL
  AND  M.PRODUCTO_VARIANTE IS NOT NULL
  AND M.PRODUCTO_VARIANTE_CODIGO IS NOT NULL
GROUP BY
    M.PRODUCTO_VARIANTE_CODIGO,
    M.PRODUCTO_VARIANTE,
    M.PRODUCTO_TIPO_VARIANTE,
    M.PRODUCTO_CODIGO

-- Medios de envio
INSERT INTO [Dr0p].[Medios_de_envio](
    nombre,
	medio_envio_precio
)
SELECT DISTINCT 
	VENTA_MEDIO_ENVIO
	,VENTA_MEDIO_PAGO_COSTO
FROM 
	[gd_esquema].[Maestra]
WHERE 
	VENTA_MEDIO_ENVIO IS NOT NULL


-- Envios Ventas
INSERT INTO [Dr0p].[Envios_Ventas](
    medio_envio_id,
    medio_envio_precio
)
SELECT
    (SELECT TOP 1 id FROM [Dr0p].[Medios_de_envio] me WHERE me.nombre = VENTA_MEDIO_ENVIO),
    VENTA_ENVIO_PRECIO
FROM [gd_esquema].[Maestra]
WHERE VENTA_MEDIO_ENVIO IS NOT NULL

-- Canales de venta
INSERT INTO [Dr0p].[Canales_de_venta](
    descripcion,
    costo
)
SELECT DISTINCT VENTA_CANAL, 0
FROM [gd_esquema].[Maestra]
WHERE VENTA_CANAL IS NOT NULL

-- Descuentos Tipo
INSERT INTO [Dr0p].[Descuentos_Tipo](
    tipo,
    importe
)
SELECT VENTA_DESCUENTO_CONCEPTO as TIPO, 0 as IMPORTE
FROM [gd_esquema].[Maestra]
WHERE VENTA_DESCUENTO_CONCEPTO IS NOT NULL



-- Clientes
INSERT INTO [Dr0p].[Clientes](
    dni,
    apellido,
    nombre,
    telefono,
    mail,
    fecha_nacimiento,
    direccion,
    localidad
)
SELECT DISTINCT
    M.CLIENTE_DNI,
    M.CLIENTE_APELLIDO,
    M.CLIENTE_NOMBRE,
    M.CLIENTE_TELEFONO,
    M.CLIENTE_MAIL,
    M.CLIENTE_FECHA_NAC,
    M.CLIENTE_DIRECCION,
    L.id
FROM
    gd_esquema.Maestra M
JOIN
	Dr0p.Localidades L
ON
	M.CLIENTE_LOCALIDAD = L.nombre
WHERE
    M.CLIENTE_DNI IS NOT NULL AND M.CLIENTE_LOCALIDAD IS NOT NULL

-- Cupones
INSERT INTO [Dr0p].[Cupones](
    codigo,
    fecha_desde,
    fecha_hasta,
    valor,
    tipo
)
SELECT DISTINCT
    VENTA_CUPON_CODIGO,
    VENTA_CUPON_FECHA_DESDE,
    VENTA_CUPON_FECHA_HASTA,
    VENTA_CUPON_VALOR,
    VENTA_CUPON_TIPO
FROM
    gd_esquema.Maestra
WHERE
    VENTA_CUPON_CODIGO IS NOT NULL

--Medios de Pago
    INSERT INTO [Dr0p].[Medios_De_Pago] (
    tipo_medio,
    costo_venta,
    porcentaje_descuento_venta
)
SELECT DISTINCT
    VENTA_MEDIO_PAGO,
    VENTA_MEDIO_PAGO_COSTO,
    0 as PORCENTAJE_DESCUENTO_VENTA
FROM
    gd_esquema.Maestra
WHERE
    VENTA_MEDIO_PAGO IS NOT NULL

--Compras
    INSERT INTO [Dr0p].[Compras](
    numero,
    fecha,
    proveedor,
    medio_pago,
    total
)
SELECT DISTINCT
    M.COMPRA_NUMERO,
    M.COMPRA_FECHA,
    (SELECT P.cuit FROM [Dr0p].[Proveedores] P Where P.cuit = M.PROVEEDOR_CUIT) as PROVEEDOR_CUIT,
                                                   (SELECT MP.id FROM [Dr0p].[Medios_De_Pago] MP WHERE MP.tipo_medio = M.COMPRA_MEDIO_PAGO),
    COMPRA_TOTAL
FROM
    [GD2C2022].[gd_esquema].[Maestra] M
WHERE
    M.COMPRA_NUMERO IS NOT NULL
ORDER BY
    M.COMPRA_NUMERO ASC

--Compras Productos
INSERT INTO [Dr0p].[Compras_Productos](
    precio,
    cantidad,
    compra_numero,
    producto_codigo,
	variante_codigo
)
SELECT
    COMPRA_PRODUCTO_PRECIO,
    COMPRA_PRODUCTO_CANTIDAD,
    COMPRA_NUMERO,
    PRODUCTO_CODIGO,
	PRODUCTO_VARIANTE_CODIGO
FROM
    [GD2C2022].[gd_esquema].[Maestra]

WHERE
    COMPRA_NUMERO IS NOT NULL
ORDER BY
    COMPRA_NUMERO ASC

--Descuentos Compra
INSERT INTO [Dr0p].[Descuentos_Compra](
    codigo,
    numero_compra,
    valor_descuento
)
SELECT
    DESCUENTO_COMPRA_CODIGO,
    COMPRA_NUMERO,
    DESCUENTO_COMPRA_VALOR
FROM
    [gd_esquema].[Maestra]
WHERE
    DESCUENTO_COMPRA_CODIGO IS NOT NULL
ORDER BY
    DESCUENTO_COMPRA_CODIGO ASC


--Ventas
INSERT INTO [Dr0p].[Ventas](
    codigo,
    fecha,
    cliente_id,
    envio_id,
    canal_venta_id,
    total,
    costo_canal_venta
)
SELECT DISTINCT
    VENTA_CODIGO,
    VENTA_FECHA,
    (SELECT TOP 1 id FROM Dr0p.Clientes C WHERE
            C.dni = M.CLIENTE_DNI AND C.apellido = M.CLIENTE_APELLIDO AND C.nombre = M.CLIENTE_NOMBRE),
    (SELECT TOP 1 id FROM Dr0p.Envios_Ventas E WHERE E.medio_envio_id =
                                                     (SELECT TOP 1 id FROM Dr0p.Medios_de_envio me WHERE me.nombre = M.VENTA_MEDIO_ENVIO)
                                                 AND E.medio_envio_precio = M.VENTA_ENVIO_PRECIO),
    (SELECT TOP 1 id FROM Dr0p.Canales_de_venta C WHERE  C.descripcion = M.VENTA_CANAL AND C.descripcion IS NOT NULL),
    ISNULL(VENTA_TOTAL, 0),
    VENTA_CANAL_COSTO
FROM
    [gd_esquema].[Maestra] M
WHERE VENTA_CODIGO IS NOT NULL


-- Descuentos ventas

INSERT INTO [Dr0p].[Descuentos_Ventas](
    descuento_tipo_id,
    concepto,
    venta_codigo,
    importe_descuento_venta
)
SELECT
    (SELECT TOP 1 id FROM [Dr0p].[Descuentos_Tipo] DT WHERE DT.tipo = M.VENTA_DESCUENTO_CONCEPTO),
    VENTA_DESCUENTO_CONCEPTO,
    VENTA_CODIGO,
    VENTA_DESCUENTO_IMPORTE
FROM [gd_esquema].[Maestra] M
WHERE M.VENTA_DESCUENTO_CONCEPTO IS NOT NULL

--Venta-Cupones
INSERT INTO Dr0p.Ventas_Cupones(
    importe,
    venta_codigo,
    cupon_id
)
SELECT
    VENTA_CUPON_IMPORTE,
    (SELECT V.codigo FROM Dr0p.Ventas V WHERE V.codigo = M.VENTA_CODIGO),
    (SELECT c.id FROM Dr0p.Cupones C WHERE C.codigo = M.VENTA_CUPON_CODIGO)
FROM
    [gd_esquema].[Maestra] M

--Ventas-Productos

INSERT INTO [Dr0p].[Ventas_Productos](
    venta_codigo,
    producto_codigo,
	variante_codigo,
    precio,
    cantidad
)
SELECT DISTINCT
    VENTA_CODIGO,
    PRODUCTO_CODIGO,
	PRODUCTO_VARIANTE_CODIGO,
    VENTA_PRODUCTO_PRECIO,
    VENTA_PRODUCTO_CANTIDAD
FROM [gd_esquema].[Maestra] M
WHERE M.VENTA_CODIGO IS NOT NULL AND M.PRODUCTO_CODIGO IS NOT NULL


-- Ventas-Medios de Pago

INSERT INTO [Dr0p].[Ventas_Medios_De_Pago](
    costo_medio_pago_aplicado,
    porcentaje_descuento_medio_pago_aplicado,
    venta_codigo,
    medio_de_pago_id
)
SELECT DISTINCT
    VENTA_MEDIO_PAGO_COSTO,
    CASE
        WHEN (M.VENTA_DESCUENTO_CONCEPTO = M.VENTA_MEDIO_PAGO) THEN (SELECT Dr0p.calcular_porcentaje(M.VENTA_TOTAL, M.VENTA_DESCUENTO_IMPORTE))
        ELSE 0
        END,
    VENTA_CODIGO,
    (SELECT TOP 1 id FROM [Dr0p].[Medios_De_Pago] MP WHERE MP.tipo_medio = M.VENTA_MEDIO_PAGO)
FROM [gd_esquema].[Maestra] M
WHERE M.VENTA_CODIGO IS NOT NULL AND M.VENTA_MEDIO_PAGO IS NOT NULL


--Medios de envio - localidad
INSERT INTO [Dr0p].[Medios_de_envio_Localidad](
    medio_envio_id,
    localidad_id,
    importe,
    tiempo_estimado
)
SELECT
	ME.id,
	L.id,
	ME.medio_envio_precio,
	null	
FROM
	Dr0p.Localidades L
INNER JOIN 
	Dr0p.Medios_de_envio_Localidad ML
ON
	L.id = ML.localidad_id
INNER JOIN
	Dr0p.Medios_de_envio ME
ON
	ML.medio_envio_id = ME.id
GO
