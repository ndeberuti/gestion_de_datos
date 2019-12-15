INSERT INTO [NO_SRTA_E_GATOREI].[DIRECCIONES]
           ([DIRECCION]
           ,[CIUDAD]
           ,[CODIGO_POSTAL])
    SELECT CLI_DIRECCION, CLI_CIUDAD , NULL 
    FROM [GD_ESQUEMA].[MAESTRA]
    WHERE CLI_DIRECCION IS NOT NULL
	GROUP BY CLI_DIRECCION, CLI_CIUDAD 
GO
INSERT INTO [NO_SRTA_E_GATOREI].[DIRECCIONES]
           ([DIRECCION]
           ,[CIUDAD]
           ,[CODIGO_POSTAL])
    SELECT PROVEE_DOM, PROVEE_CIUDAD , NULL 
    FROM [GD_ESQUEMA].[MAESTRA]
	WHERE PROVEE_DOM IS NOT NULL
	GROUP BY PROVEE_DOM, PROVEE_CIUDAD 
GO
INSERT INTO [NO_SRTA_E_GATOREI].[CLIENTES]
           ([DNI]
           ,[NOMBRE]
           ,[APELLIDO]
           ,[MAIL]
           ,[TELEFONO]
           ,[FECHA_NACIMIENTO]
           ,[USUARIO_ID]
           ,[DIRECCION_ID])
     SELECT M.CLI_DNI, M.CLI_NOMBRE, M.CLI_APELLIDO, M.CLI_MAIL, M.CLI_TELEFONO, M.CLI_FECHA_NAC, NULL , D.DIRECCION_ID
	 FROM [GD_ESQUEMA].[MAESTRA] M INNER JOIN [NO_SRTA_E_GATOREI].[DIRECCIONES] D ON M.CLI_DIRECCION = D.DIRECCION
     WHERE M.CLI_DNI IS NOT NULL
	 GROUP BY M.CLI_DNI, M.CLI_NOMBRE, M.CLI_APELLIDO, M.CLI_MAIL, M.CLI_TELEFONO, M.CLI_FECHA_NAC, D.DIRECCION_ID
GO
INSERT INTO [NO_SRTA_E_GATOREI].[RUBROS] (DESCRIPCION)
SELECT DISTINCT PROVEE_RUBRO FROM GD_ESQUEMA.MAESTRA WHERE PROVEE_RUBRO IS NOT NULL
GO
INSERT INTO [NO_SRTA_E_GATOREI].[PROVEEDORES] 
           ([CUIT]
           ,[RAZON_SOCIAL]
           ,[NOMBRE_CONTACTO]
           ,[RUBRO_ID]
           ,[MAIL]
           ,[TELEFONO]
           ,[USUARIO_ID]
           ,[DIRECCION_ID])
    SELECT M.PROVEE_CUIT, M.PROVEE_RS, NULL, R.RUBRO_ID,NULL, M.PROVEE_TELEFONO, NULL , D.DIRECCION_ID
	FROM [GD_ESQUEMA].[MAESTRA] M LEFT JOIN [NO_SRTA_E_GATOREI].[DIRECCIONES] D ON M.PROVEE_DOM = D.DIRECCION
	JOIN [NO_SRTA_E_GATOREI].[RUBROS] R ON M.Provee_Rubro = R.DESCRIPCION
    WHERE PROVEE_CUIT IS NOT NULL
	GROUP BY PROVEE_CUIT, PROVEE_RS,R.RUBRO_ID, PROVEE_TELEFONO, D.DIRECCION_ID
GO
INSERT INTO [NO_SRTA_E_GATOREI].[OFERTAS]
           ([PRECIO_LISTA]
           ,[PRECIO_OFERTA]
           ,[FECHA_PUBLICACION]
           ,[FECHA_VENCIMIENtO]
           ,[CANTIDAD]
           ,[MAXIMO_USUARIO]
           ,[DESCRIPCION]
           ,[CODIGO]
           ,[PROVEEDOR_ID])
    SELECT M.OFERTA_PRECIO_FICTICIO,
           M.OFERTA_PRECIO,
	   M.OFERTA_FECHA, 
	   M.OFERTA_FECHA_VENC,
	   M.OFERTA_CANTIDAD,
	   COUNT(DISTINCT CLI_DNI),
	   M.OFERTA_DESCRIPCION,
	   M.OFERTA_CODIGO,
	   P.PROVEEDOR_ID
FROM GD_ESQUEMA.MAESTRA M 
LEFT JOIN [NO_SRTA_E_GATOREI].[PROVEEDORES] P ON P.CUIT = PROVEE_CUIT
WHERE M.OFERTA_CODIGO IS NOT NULL
GROUP BY M.OFERTA_PRECIO,M.OFERTA_PRECIO_FICTICIO,M.OFERTA_FECHA, M.OFERTA_FECHA_VENC,M.OFERTA_CANTIDAD,M.OFERTA_DESCRIPCION,M.OFERTA_CODIGO, P.PROVEEDOR_ID
GO
INSERT INTO [NO_SRTA_E_GATOREI].[COMPRAS]
           ([OFERTA_ID]
           ,[CLIENTE_ID]
           ,[FECHA_COMPRA]
           ,[IMPORTE])
    SELECT O.OFERTA_ID, C.CLIENTE_ID,  M.Oferta_Fecha_Compra, M.OFERTA_PRECIO_FICTICIO 
    FROM [GD_ESQUEMA].[MAESTRA] M JOIN [NO_SRTA_E_GATOREI].[OFERTAS] O ON M.OFERTA_CODIGO = O.CODIGO 
    JOIN [NO_SRTA_E_GATOREI].[CLIENTES] C ON M.CLI_DNI = C.DNI
    WHERE m.OFERTA_FECHA_COMPRA IS NOT NULL 
    AND FACTURA_NRO IS NULL
    AND OFERTA_ENTREGADO_FECHA IS NULL
    GROUP BY O.OFERTA_ID,C.CLIENTE_ID,M.Oferta_Fecha_Compra, M.OFERTA_PRECIO_FICTICIO
GO
INSERT INTO [NO_SRTA_E_GATOREI].[CUPONES] (OFERTA_ID,CLIENTE_ID,FECHA_CONSUMO)
SELECT O.OFERTA_ID,C.CLIENTE_ID, M.OFERTA_ENTREGADO_FECHA 
FROM GD_ESQUEMA.MAESTRA M
INNER JOIN [NO_SRTA_E_GATOREI].CLIENTES C ON M.CLI_DNI = C.DNI
INNER JOIN [NO_SRTA_E_GATOREI].OFERTAS O ON M.OFERTA_CODIGO = O.CODIGO 
WHERE OFERTA_ENTREGADO_FECHA IS NOT NULL
GO
INSERT INTO [NO_SRTA_E_GATOREI].[FACTURAS]
            ([NUMERO],[FECHA])
    SELECT [FACTURA_NRO], [FACTURA_FECHA]
    FROM [GD_ESQUEMA].[MAESTRA]
    WHERE [FACTURA_NRO] IS NOT NULL
    GROUP BY [FACTURA_NRO],[FACTURA_FECHA]
GO
INSERT INTO [NO_SRTA_E_GATOREI].[FACTURAS_COMPRAS]
            ([FACTURA_ID],[COMPRA_ID])
            SELECT [FACTURA_ID] ,[COMPRA_ID]
            FROM [NO_SRTA_E_GATOREI].[COMPRAS] C
            LEFT JOIN [NO_SRTA_E_GATOREI].[OFERTAS] O ON O.[OFERTA_ID] = C.[OFERTA_ID]
            LEFT JOIN [GD_ESQUEMA].[MAESTRA] M ON O.[CODIGO] = M.[OFERTA_CODIGO]
            LEFT JOIN [NO_SRTA_E_GATOREI].[FACTURAS] F ON M.[FACTURA_NRO] = F.[NUMERO]
            WHERE M.[FACTURA_NRO] IS NOT NULL
            GROUP BY [COMPRA_ID], [FACTURA_ID]
GO
UPDATE [NO_SRTA_E_GATOREI].[FACTURAS]
SET IMPORTE= (SELECT SUM(C.IMPORTE)
				FROM [NO_SRTA_E_GATOREI].[COMPRAS] C,[NO_SRTA_E_GATOREI].[FACTURAS_COMPRAS] FC
				WHERE C.[COMPRA_ID] = FC.[COMPRA_ID]
				AND FC.[FACTURA_ID] = [NO_SRTA_E_GATOREI].[FACTURAS].[FACTURA_ID]
				GROUP BY FC.[FACTURA_ID]);
GO
INSERT INTO [NO_SRTA_E_GATOREI].[TIPOS_PAGOS] (DESCRIPCION)
SELECT DISTINCT(TIPO_PAGO_DESC) 
FROM GD_ESQUEMA.MAESTRA 
WHERE TIPO_PAGO_DESC IS NOT NULL
GO
INSERT INTO [NO_SRTA_E_GATOREI].[TIPOS_PAGOS] (DESCRIPCION)
VALUES('REGALO')
GO
INSERT INTO [NO_SRTA_E_GATOREI].CREDITOS (FECHA,TIPO_PAGO_ID,MONTO,CLIENTE_ID)
SELECT M.CARGA_FECHA,(SELECT TIPO_PAGO_ID FROM [NO_SRTA_E_GATOREI].TIPOS_PAGOS WHERE DESCRIPCION = M.TIPO_PAGO_DESC),M.CARGA_CREDITO,C.CLIENTE_ID
FROM GD_ESQUEMA.MAESTRA M
INNER JOIN [NO_SRTA_E_GATOREI].CLIENTES C ON M.CLI_DNI = C.DNI
WHERE M.CARGA_CREDITO IS NOT NULL
GO
INSERT INTO [NO_SRTA_E_GATOREI].[ROLES](NOMBRE) VALUES ('ADMINISTRATIVO') 
GO
INSERT INTO [NO_SRTA_E_GATOREI].[ROLES](NOMBRE) VALUES ('CLIENTE') 
GO
INSERT INTO [NO_SRTA_E_GATOREI].[ROLES](NOMBRE) VALUES ('PROVEEDOR') 
GO
INSERT INTO [NO_SRTA_E_GATOREI].[USUARIOS](USERNAME,PASS) VALUES ('admin','e6b87050bfcb8143fcb8db0170a4dc9ed00d904ddd3e2a4ad1b1e8dc0fdc9be7')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Abm Roles','ABM_ROLES')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Abm Clientes','ABM_CLIENTES')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Abm Proveedores','ABM_PROVEEDORES')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Abm Usuarios','ABM_USUARIOS')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Generar Reportes', 'REPORTES')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Facturar','FACTURAS')
GO 
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Cargar Credito','CARGAR_CREDITO')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Comprar Oferta','COMPRAR_OFERTA')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Armar Ofertas', 'CREAR_OFERTA')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS(PERMISO_DESC,PERMISO_CLAVE) VALUES ('Canjear Oferta', 'CANJEAR_OFERTA')
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'ADMINISTRATIVO'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'ABM_ROLES'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'ADMINISTRATIVO'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'ABM_CLIENTES'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'ADMINISTRATIVO'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'ABM_PROVEEDORES'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'ADMINISTRATIVO'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'ABM_USUARIOS'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'ADMINISTRATIVO'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'REPORTES'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'ADMINISTRATIVO'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'FACTURAS'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'CLIENTE'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'CARGAR_CREDITO'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'CLIENTE'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'COMPRAR_OFERTA'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'PROVEEDOR'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'CREAR_OFERTA'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].PERMISOS_ROLES(ROL_ID,PERMISO_ID) VALUES ((SELECT ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = 'PROVEEDOR'), (SELECT PERMISO_ID FROM [NO_SRTA_E_GATOREI].PERMISOS WHERE PERMISO_CLAVE = 'CANJEAR_OFERTA'))
GO
INSERT INTO [NO_SRTA_E_GATOREI].USUARIOS_ROLES(USUARIO_ID,ROL_ID)
SELECT 1,ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES