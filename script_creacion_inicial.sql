USE [GD2C2022]
GO

--CREACION ESQUEMA --
IF NOT EXISTS ( SELECT * FROM sys.schemas WHERE name = 'Dr0p')
BEGIN
 EXECUTE('CREATE SCHEMA Dr0p')
END
GO

--STORED PROCEDURE PARA BORRADO DE TABLAS --
EXEC sp_MSforeachtable
  @command1 = 'DROP TABLE ?', 
  @whereand = 'AND SCHEMA_NAME(schema_id) = ''Dr0p'' '
GO

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
GO

--Provincia
INSERT INTO [Dr0p].[Provincias](
	nombre
)
SELECT DISTINCT PROVEEDOR_PROVINCIA
FROM [gd_esquema].[Maestra]
WHERE PROVEEDOR_PROVINCIA IS NOT NULL 
GO

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
GO

--Categorias
INSERT INTO [Dr0p].[Categorias] (
	detalle
)
SELECT DISTINCT PRODUCTO_CATEGORIA FROM gd_esquema.Maestra WHERE PRODUCTO_CATEGORIA IS NOT NULL ORDER BY 1 ASC
GO 

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
m.PRODUCTO_NOMBRE, 
M.PRODUCTO_CODIGO,
m.PRODUCTO_DESCRIPCION,
m.PRODUCTO_MATERIAL,
M.PRODUCTO_MARCA,
(select C.id FROM [Dr0p].[Categorias] C WHERE C.detalle = M.PRODUCTO_CATEGORIA)
FROM gd_esquema.Maestra M 
where M.PRODUCTO_NOMBRE is not null
order by PRODUCTO_NOMBRE ASC
