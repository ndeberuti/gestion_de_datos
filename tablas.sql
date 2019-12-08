USE [GD2C2019]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE SCHEMA [NO_SRTA_E_GATOREI] AUTHORIZATION [GDCUPON2019]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[PERMISOS](
	[PERMISO_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[PERMISO_DESC] [NVARCHAR](255) NOT NULL,
	[PERMISO_CLAVE] [NVARCHAR](255) NOT NULL
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[ROLES](
		[ROL_ID] INT IDENTITY(1,1) PRIMARY KEY,
		[NOMBRE] [NVARCHAR](100) UNIQUE NOT NULL,
		[BAJA_LOGICA] [BIT] NOT NULL DEFAULT 0
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[PERMISOS_ROLES](
	[ROL_ID] INT FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[ROLES](ROL_ID) NOT NULL,
	[PERMISO_ID] INT FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[PERMISOS](PERMISO_ID) NOT NULL
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[USUARIOS](
	[USUARIO_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[USERNAME] [NVARCHAR](250) UNIQUE NOT NULL,
	[PASS] [NVARCHAR](250) NOT NULL,
	[TIPO_USUARIO] [NVARCHAR](250),
	[BAJA_LOGICA] [BIT] NOT NULL DEFAULT 0,
	[LOGIN_FALLIDO] INT NOT NULL DEFAULT 0
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[USUARIOS_ROLES](
	[ROL_ID] INT FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[ROLES](ROL_ID) NOT NULL,
	[USUARIO_ID] INT FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[USUARIOS](USUARIO_ID) NOT NULL
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[DIRECCIONES](
	[DIRECCION_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[DIRECCION] [NVARCHAR](255) NOT NULL,
	[CIUDAD] [NVARCHAR](255) NOT NULL,
	[CODIGO_POSTAL] [NUMERIC](4,0) DEFAULT 0	
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[CLIENTES](
	[CLIENTE_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[DNI] [NUMERIC](18, 0) UNIQUE NOT NULL,
	[NOMBRE] [NVARCHAR](255) NOT NULL,
	[APELLIDO] [NVARCHAR](255) NOT NULL,
	[MAIL] [NVARCHAR](255) NOT NULL,
	[TELEFONO] [NUMERIC](18, 0) NOT NULL,
	[FECHA_NACIMIENTO] [DATETIME] NOT NULL,
	[BAJA_LOGICA] [BIT] NOT NULL DEFAULT 0,
	[USUARIO_ID] INT FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[USUARIOS](USUARIO_ID),
	[DIRECCION_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[DIRECCIONES](DIRECCION_ID)
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[RUBROS](
	[RUBRO_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[DESCRIPCION] [NVARCHAR](100) NOT NULL
)
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[PROVEEDORES](
	[PROVEEDOR_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[CUIT] [NVARCHAR](20) UNIQUE NOT NULL,
	[RAZON_SOCIAL] [NVARCHAR](255) UNIQUE NOT NULL,
	[NOMBRE_CONTACTO] [NVARCHAR](255),
	[RUBRO_ID] INT FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[RUBROS] (RUBRO_ID) ,
	[MAIL] [NVARCHAR](255) ,
	[TELEFONO] [NUMERIC](18, 0) NOT NULL,
	[BAJA_LOGICA] [BIT] NOT NULL DEFAULT 0,
	[USUARIO_ID] INT FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[USUARIOS](USUARIO_ID),
	[DIRECCION_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[DIRECCIONES](DIRECCION_ID)
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[TARJETAS](
	[TARJETA_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[TITULAR] [NVARCHAR](255) NOT NULL,
	[FECHA_VENCIMIENTO] [NVARCHAR](5) NOT NULL,
	[NUMERO] NVARCHAR(100) NOT NULL
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[TIPOS_PAGOS](
	[TIPO_PAGO_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[DESCRIPCION] [NVARCHAR](100) NOT NULL,
)
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[CREDITOS](
	[CREDITO_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[FECHA] DATETIME NOT NULL,
	[TIPO_PAGO_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[TIPOS_PAGOS](TIPO_PAGO_ID),
	[MONTO] [NUMERIC](18, 2) NOT NULL,
	[CLIENTE_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[CLIENTES](CLIENTE_ID),
	[TARJETA_ID] INT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[TARJETAS](TARJETA_ID)
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[OFERTAS](
	[OFERTA_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[PRECIO_LISTA] [NUMERIC](18, 2) NULL,
	[PRECIO_OFERTA] [NUMERIC](18, 2) NULL,
	[FECHA_PUBLICACION] [DATETIME] NULL,
	[FECHA_VENCIMIENDO] [DATETIME] NULL,
	[CANTIDAD] [NUMERIC](18, 0) NULL,
	[MAXIMO_USUARIO] [NUMERIC](18,0) NULL,
	[DESCRIPCION] [NVARCHAR](255) NULL,
	[FECHA_COMPRA] [DATETIME],
	[CODIGO] [NVARCHAR](50),
	[PROVEDOR_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[PROVEEDORES](PROVEEDOR_ID),
	[ENTREGADO] [DATETIME]
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[CONSUMOS_CUPONES](
	[CONSUMO_CUPON_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[OFERTA_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[OFERTAS](OFERTA_ID),
	[CLIENTE_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[CLIENTES](CLIENTE_ID),
	[FECHA_CONSUMO] [DATETIME] NOT NULL
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[COMPRAS](
	[COMPRA_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[OFERTA_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[OFERTAS](OFERTA_ID),
	[CLIENTE_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[CLIENTES](CLIENTE_ID),
	[FECHA_COMPRA] [DATETIME] NOT NULL,
	[IMPORTE] [NUMERIC](18, 2) NULL
) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[FACTURAS](
	[FACTURA_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[NUMERO] [NUMERIC](18,0),
	[FECHA] datetime not null,
	[IMPORTE] [NUMERIC](18,2) not null default 0 ) ON [PRIMARY]
GO
CREATE TABLE [NO_SRTA_E_GATOREI].[FACTURAS_COMPRAS](
	[FACTURA_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[FACTURAS](FACTURA_ID),
	[COMPRA_ID] INT NOT NULL FOREIGN KEY REFERENCES [NO_SRTA_E_GATOREI].[COMPRAS](COMPRA_ID)
) ON [PRIMARY]
GO
