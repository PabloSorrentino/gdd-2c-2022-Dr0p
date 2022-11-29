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
                                  direccion NVARCHAR(255),
                                 -- localidad DECIMAL(18,0) FOREIGN KEY REFERENCES [Dr0p].Localidades(id),
                                 -- provincia NVARCHAR(255) FOREIGN KEY REFERENCES [Dr0p].Provincias(nombre)
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
                                        tipo_medio NVARCHAR(255),
                                        costo_venta DECIMAL(18,2),
                                        porcentaje_descuento_venta DECIMAL(18,2)
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
    detalle NVARCHAR(50),
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
    fecha DATE,
    proveedor_cuit NVARCHAR(255) FOREIGN KEY REFERENCES Dr0p.BI_Proveedores(cuit),
    medio_de_pago_id DECIMAL(19,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Pago(id),
    total DECIMAL(18,2),
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
                                medio_pago_id DECIMAL(18,0) FOREIGN KEY REFERENCES Dr0p.BI_Medios_De_Pago(id),
                                costo_medio_de_pago_aplicado DECIMAL(18,2),
                                porcentaje_descuento_medio_pago_aplicado DECIMAL(5,2),
                                total_venta DECIMAL(18,2) NOT NULL,
                                cantidad_productos DECIMAL(18,0)
)