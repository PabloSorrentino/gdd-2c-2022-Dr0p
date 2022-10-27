USE [GD2C2022]
GO

--CREACION ESQUEMA
IF NOT EXISTS ( SELECT * FROM sys.schemas WHERE name = 'Dr0p')
BEGIN
 EXECUTE('CREATE SCHEMA Dr0p')
END
GO

--STORED PROCEDURE PARA BORRADO DE TABLAS.
EXEC sp_MSforeachtable
  @command1 = 'DROP TABLE ?', 
  @whereand = 'AND SCHEMA_NAME(schema_id) = ''Dr0p'' '
GO

--CREACION DE TABLAS

--	Proovedores
CREATE TABLE [Dr0p].[Proveedores](
	cuit NVARCHAR(255) PRIMARY KEY,
	razon_social nvarchar(50),
	mail NVARCHAR(50),
	domicilio NVARCHAR(50),
	localidad DECIMAL(18,0),
	provincia NVARCHAR(255)	
)

--	Localidad
CREATE TABLE [Dr0p].[Localidad](
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY ,
	nombre nvarchar(255),
	codigo_postal DECIMAL(18,0)
)


--	Provincia
CREATE TABLE [Dr0p].[Provincia](
	nombre nvarchar(255) PRIMARY KEY
)

--MAPEO DE FKS

--proveedores-localidades
ALTER TABLE [Dr0p].[Proveedores]
ADD FOREIGN KEY (localidad) REFERENCES [Dr0p].[Localidad](id)

--proveedores-provincias
ALTER TABLE [Dr0p].[Proveedores]
ADD FOREIGN KEY (provincia) REFERENCES [Dr0p].[Provincia](nombre)

--INSERCION DE DATOS A TABLAS

--Localidad
INSERT INTO [Dr0p].[Localidad](
	nombre,
	codigo_postal
)
SELECT DISTINCT PROVEEDOR_LOCALIDAD, PROVEEDOR_CODIGO_POSTAL
FROM [gd_esquema].[Maestra]
WHERE PROVEEDOR_LOCALIDAD IS NOT NULL 
AND PROVEEDOR_CODIGO_POSTAL IS NOT NULL
GO

--Provincia
INSERT INTO [Dr0p].[Provincia](
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
(SELECT L.id FROM [Dr0p].[Localidad] L WHERE l.codigo_postal = m.PROVEEDOR_CODIGO_POSTAL  AND l.nombre = m.PROVEEDOR_LOCALIDAD )
, PROVEEDOR_PROVINCIA
FROM [gd_esquema].[Maestra] M
WHERE PROVEEDOR_CUIT IS NOT NULL;
GO
