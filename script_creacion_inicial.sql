-- noinspection SqlNoDataSourceInspectionForFile

USE [GD2C2022]
GO

--CREACION ESQUEMA --
IF NOT EXISTS ( SELECT * FROM sys.schemas WHERE name = 'Dr0p')
BEGIN
 EXECUTE('CREATE SCHEMA Dr0p')
END


--STORED PROCEDURE PARA BORRADO DE TABLAS --
EXEC sp_MSforeachtable
  @command1 = 'DROP TABLE ?', 
  @whereand = 'AND SCHEMA_NAME(schema_id) = ''Dr0p'' '


--CREACION DE TABLAS --

--	Proovedores
CREATE TABLE [Dr0p].[Proveedores](
	cuit NVARCHAR(255) PRIMARY KEY,
	razon_social NVARCHAR(50),
	mail NVARCHAR(50),
	domicilio NVARCHAR(50),
	localidad DECIMAL(18,0),
	provincia NVARCHAR(255)	
)


--	Localidad
CREATE TABLE [Dr0p].[Localidades](
	id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY ,
	nombre NVARCHAR(255),
	codigo_postal DECIMAL(18,0)
)


--	Provincia
CREATE TABLE [Dr0p].[Provincias](
	nombre NVARCHAR(255) PRIMARY KEY
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
    categoria DECIMAL(18,0)
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
	tipo_variante DECIMAL(18,0),
	producto_codigo NVARCHAR(50)
)

-- Envios Ventas
CREATE TABLE [Dr0p].[Envios_Ventas](
   id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
    medio_envio NVARCHAR(255),
    medio_envio_precio DECIMAL(18,2)
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
    localidad DECIMAL(18,0),
    provincia NVARCHAR(255)
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
    fecha_desde date,
    fecha_hasta date,
    valor DECIMAL(18,2),
    tipo NVARCHAR(50)
)

--MAPEO DE FKS --

--proveedores-localidades
ALTER TABLE [Dr0p].[Proveedores]
ADD FOREIGN KEY (localidad) REFERENCES [Dr0p].[Localidades](id)


--proveedores-provincias
ALTER TABLE [Dr0p].[Proveedores]
ADD FOREIGN KEY (provincia) REFERENCES [Dr0p].[Provincias](nombre)


--productos-categorias
ALTER TABLE [Dr0p].[Productos]
ADD FOREIGN KEY (categoria) REFERENCES [Dr0p].Categorias(id)

-- variantes-tipos_variantes-productos
ALTER TABLE [Dr0p].[Variantes]
ADD FOREIGN KEY (tipo_variante) REFERENCES [Dr0p].Tipos_Variantes(id),
    FOREIGN KEY (producto_codigo) REFERENCES [Dr0p].Productos(codigo)

-- Clientes-localidad-provincia

ALTER TABLE [Dr0p].[Clientes]
ADD FOREIGN KEY (localidad) REFERENCES [Dr0p].Localidades(id),
    FOREIGN KEY (provincia) REFERENCES [Dr0p].Provincias(nombre)


--INSERCION DE DATOS A TABLAS --

--Localidad
INSERT INTO [Dr0p].[Localidades](
	nombre,
	codigo_postal
)
SELECT DISTINCT PROVEEDOR_LOCALIDAD, PROVEEDOR_CODIGO_POSTAL
FROM [gd_esquema].[Maestra]
WHERE PROVEEDOR_LOCALIDAD IS NOT NULL 
AND PROVEEDOR_CODIGO_POSTAL IS NOT NULL


--Provincia
INSERT INTO [Dr0p].[Provincias](
	nombre
)
SELECT DISTINCT PROVEEDOR_PROVINCIA
FROM [gd_esquema].[Maestra]
WHERE PROVEEDOR_PROVINCIA IS NOT NULL 


--Proovedores
INSERT INTO [Dr0p].[Proveedores](
	cuit,
	razon_social,
	mail,
	domicilio,
	localidad,
	provincia
)
SELECT DISTINCT PROVEEDOR_CUIT, PROVEEDOR_RAZON_SOCIAL, 
PROVEEDOR_MAIL, PROVEEDOR_DOMICILIO, 
(SELECT L.id FROM [Dr0p].[Localidades] L WHERE l.codigo_postal = m.PROVEEDOR_CODIGO_POSTAL  AND l.nombre = m.PROVEEDOR_LOCALIDAD )
, PROVEEDOR_PROVINCIA
FROM [gd_esquema].[Maestra] M
WHERE PROVEEDOR_CUIT IS NOT NULL;


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

-- Envios Ventas

INSERT INTO [Dr0p].[Envios_Ventas](
    medio_envio,
    medio_envio_precio
)
SELECT VENTA_MEDIO_ENVIO, VENTA_ENVIO_PRECIO
FROM [gd_esquema].[Maestra]
WHERE VENTA_MEDIO_ENVIO IS NOT NULL

-- Canales de venta
INSERT INTO [Dr0p].[Canales_de_venta](
    descripcion,
    costo
)
SELECT DISTINCT VENTA_CANAL, VENTA_CANAL_COSTO
FROM [gd_esquema].[Maestra]
WHERE VENTA_CANAL IS NOT NULL

-- Descuentos Tipo

/*
-- OJO!! VENTA_DESCUENTO_IMPORTE NO es el valor de un descuento en particular, es el valor de la venta con los descuentos aplicados
-- HABRIA QUE VER DE DONDE SACAR EL VALOR "IMPORTE" O NO TENERLO

INSERT INTO [Dr0p].[Descuentos_Tipo](
    tipo,
    importe
)
SELECT VENTA_DESCUENTO_CONCEPTO, VENTA_DESCUENTO_IMPORTE
FROM [gd_esquema].[Maestra]
WHERE VENTA_DESCUENTO_CONCEPTO IS NOT NULL
*/


-- Clientes
INSERT INTO [Dr0p].[Clientes](
    dni,
    apellido,
    nombre,
    telefono,
    mail,
    fecha_nacimiento,
    direccion,
    localidad,
    provincia
)
SELECT DISTINCT
    M.CLIENTE_DNI,
    M.CLIENTE_APELLIDO,
    M.CLIENTE_NOMBRE,
    M.CLIENTE_TELEFONO,
    M.CLIENTE_MAIL,
    M.CLIENTE_FECHA_NAC,
    M.CLIENTE_DIRECCION,
    (SELECT L.id FROM [Dr0p].[Localidades] L WHERE l.codigo_postal = m.CLIENTE_CODIGO_POSTAL AND l.nombre = m.CLIENTE_LOCALIDAD ),
    M.CLIENTE_PROVINCIA
FROM
    gd_esquema.Maestra M
WHERE
    M.CLIENTE_DNI IS NOT NULL

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

GO
