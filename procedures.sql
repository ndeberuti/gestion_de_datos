GO
CREATE PROCEDURE LOGIN_USUARIO @USERNAME NVARCHAR(255), @PASS NVARCHAR(255), @RESULT int OUTPUT
AS
BEGIN
DECLARE @ID INT, @USER NVARCHAR(255),@PASSWORD NVARCHAR(255), @REINTENTOS INT

SELECT 
@ID = USUARIO_ID,
@USER = USERNAME,
@PASSWORD = PASS,
@REINTENTOS = LOGIN_FALLIDO
FROM [NO_SRTA_E_GATOREI].USUARIOS
WHERE USERNAME = @USERNAME
AND BAJA_LOGICA = 0

IF @ID IS NULL
    BEGIN
    RETURN -1;
    END

ELSE IF @REINTENTOS >= 3
	BEGIN
	RETURN -2;
	END

ELSE IF @PASSWORD <> @PASS
	BEGIN
	UPDATE [NO_SRTA_E_GATOREI].[USUARIOS]
	SET LOGIN_FALLIDO = LOGIN_FALLIDO + 1
	WHERE USUARIO_ID = @ID
	RETURN -3;
	END
ELSE 
	BEGIN
	UPDATE [NO_SRTA_E_GATOREI].[USUARIOS]
	SET LOGIN_FALLIDO = 0
	WHERE USUARIO_ID = @ID
    
    SELECT @RESULT = @ID
	RETURN 0;
	END
END
GO
CREATE PROCEDURE CREAR_USUARIO_CLIENTE @USERNAME NVARCHAR(255), 
									   @PASS NVARCHAR(244), 
									   @ROL NVARCHAR(100), 
									   @NOMBRE NVARCHAR(255), 
									   @APELLIDO NVARCHAR(255), 
									   @DNI NUMERIC(18, 0),
									   @MAIL NVARCHAR(255),
									   @TELEFONO NUMERIC(18,0),
									   @DIRECCION NVARCHAR(255),
									   @CP NUMERIC(4,0),
									   @CIUDAD NVARCHAR(255),
									   @FECHA_NACIMIENTO DATETIME,
									   @FECHA_ACTUAL DATETIME
	AS
	BEGIN
		BEGIN TRANSACTION
		DECLARE @USER_ID INT, @ID_NUEVO INT
		INSERT INTO [NO_SRTA_E_GATOREI].[USUARIOS] (USERNAME,PASS,TIPO_USUARIO)
		VALUES (@USERNAME,@PASS,'CLIENTE')

		SELECT @USER_ID= USUARIO_ID 
		FROM [NO_SRTA_E_GATOREI].[USUARIOS] 
		WHERE USERNAME = @USERNAME

		INSERT INTO [NO_SRTA_E_GATOREI].[DIRECCIONES] (DIRECCION,CIUDAD,CODIGO_POSTAL)
		VALUES (@DIRECCION,@CIUDAD,@CP)

		SELECT @ID_NUEVO = DIRECCION_ID
		FROM [NO_SRTA_E_GATOREI].[DIRECCION]
		WHERE DIRECCION = @DIRECCION
		AND CIUDAD = @CIUDAD
		AND CODIGO_POSTAL = @CP

		INSERT INTO [NO_SRTA_E_GATOREI].[CLIENTES] (DNI,NOMBRE,APELLIDO,MAIL,TELEFONO,FECHA_NACIMIENTO,USUARIO_ID,DIRECCION_ID)
		VALUES (@DNI,@NOMBRE,@APELLIDO,@MAIL,@TELEFONO,@FECHA_NACIMIENTO,@USER_ID,@ID_NUEVO)

		SELECT @ID_NUEVO = CLIENTE_ID
		FROM [NO_SRTA_E_GATOREI].[CLIENTES]
		WHERE DNI = @DNI

		INSERT INTO CREDITO (FECHA,TIPO_PAGO_ID,MONTO,CLIENTE_ID)
		VALUES(@FECHA_ACTUAL,(SELECT TIPO_PAGO_ID FROM [NO_SRTA_E_GATOREI].[TIPOS_PAGOS] WHERE DESCRIPCION = 'REGALO'),200,@ID_NUEVO)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN @@ERROR
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			RETURN 0
		END
	END	
GO
CREATE PROCEDURE CREAR_USUARIO_PROVEEDOR @USERNAME NVARCHAR(255), 
										 @PASS NVARCHAR(255),
										 @RS NVARCHAR(255), 
										 @CUIT NVARCHAR(20), 
										 @MAIL NVARCHAR(255),
										 @TELEFONO NUMERIC(18,0),
										 @DIRECCION NVARCHAR(255),
										 @CP NUMERIC(4,0),
										 @CIUDAD NVARCHAR(255),
										 @RUBRO_ID INT,
										 @NOMBRE_CONTACTO NVARCHAR(255)
	AS
	BEGIN
		BEGIN TRANSACTION
		DECLARE @USER_ID INT, @ID_NUEVO INT
		INSERT INTO [NO_SRTA_E_GATOREI].[USUARIOS] (USERNAME,PASS,TIPO_USUARIO)
		VALUES (@USERNAME,@PASS,'PROVEEDOR')

		SELECT @USER_ID= USUARIO_ID 
		FROM [NO_SRTA_E_GATOREI].[USUARIOS] 
		WHERE USERNAME = @USERNAME

		INSERT INTO [NO_SRTA_E_GATOREI].[DIRECCIONES] (DIRECCION,CIUDAD,CODIGO_POSTAL)
		VALUES (@DIRECCION,@CIUDAD,@CP)

		SELECT @ID_NUEVO = DIRECCION_ID
		FROM [NO_SRTA_E_GATOREI].[DIRECCION]
		WHERE DIRECCION = @DIRECCION
		AND CIUDAD = @CIUDAD
		AND CODIGO_POSTAL = @CP

		INSERT INTO [NO_SRTA_E_GATOREI].[PROVEEDOR] (CUIT,RAZON_SOCIAL,NOMBRE_CONTACTO,RUBRO,MAIL,TELEFONO,USUARIO_ID,DIRECCION_ID)
		VALUES (@CUIT,@RS,@NOMBRE_CONTACTO,@RUBRO_ID,@MAIL,@TELEFONO,@USER_ID,@ID_NUEVO)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN @@ERROR
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			RETURN 0
		END
	END	
GO
CREATE PROCEDURE CARGAR_CREDITO @FECHA DATETIME,
								@CLIENTE_ID INT,
								@TIPO_PAGO NVARCHAR(255),
								@MONTO NUMERIC(18,2), 
								@NOMBRE NVARCHAR(255), 
								@FECHA_VENCIMIENTO NVARCHAR(5),
								@NUMERO NVARCHAR(100)
AS
BEGIN 
	BEGIN TRANSACTION
	DECLARE @TARJETA_ID INT
	
	INSERT INTO [NO_SRTA_E_GATOREI].[TARJETAS] (TITULAR,FECHA_VENCIMIENTO, NUMERO)
	VALUES (@NOMBRE,@FECHA_VENCIMIENTO, @NUMERO)

	SELECT @TARJETA_ID = TARJETA_ID 
	FROM [NO_SRTA_E_GATOREI].[TARJETAS]
	WHERE NUMERO = @NUMERO

	INSERT INTO [NO_SRTA_E_GATOREI].[CREDITO] (FECHA,TIPO_PAGO,MONTO,CLIENTE_ID,TARJETA_ID)
	VALUES (@FECHA,@TIPO_PAGO,@MONTO,@CLIENTE_ID,@TARJETA_ID)
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN @@ERROR
		END
		ELSE
		BEGIN	
			COMMIT TRANSACTION
			RETURN 0
		END
	END
GO
CREATE PROCEDURE FACTURAR_PROVEEDOR @PROVEEDOR_ID INT,
									@NUMERO_FACTURA INT,
									@FECHA_DESDE DATETIME, 
									@FECHA_HASTA DATETIME,
									@FECHA_FACTURACION DATETIME	
	AS								  
	BEGIN
	DECLARE @FACTURA_ID INT
	BEGIN TRANSACTION
	INSERT INTO [NO_SRTA_E_GATOREI].[FACTURAS](NUMERO,FECHA)
	VALUES (@NUMERO_FACTURA,@FECHA_FACTURACION)

	INSERT INTO FACTURAS_COMPRAS (FACTURA_ID,COMPRA_ID )
	SELECT SCOPE_IDENTITY(), C.COMPRA_ID
	FROM COMPRAS C, OFERTAS O 
	WHERE C.OFERTA_ID = O.OFERTA_ID
	AND NOT EXISTS ( SELECT 1 
					 FROM FACTURAS_COMPRAS FC 
					 WHERE FC.COMPRA_ID = C.COMPRA_ID )
	AND C.FECHA_COMPRA BETWEEN @FECHA_DESDE AND @FECHA_HASTA
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN @@ERROR
		END
		ELSE
		BEGIN	
			COMMIT TRANSACTION
			RETURN 0
		END
	END
GO
CREATE PROCEDURE INVERTIR_BAJA_LOGICA_CLIENTE @CLIENTE_ID INT
AS
BEGIN
BEGIN TRANSACTION
	DECLARE @STATE BIT, @USER_ID BIT
	SELECT @STATE = ~BAJA_LOGICA, @USER_ID = USUARIO_ID
	FROM [NO_SRTA_E_GATOREI].CLIENTES
	WHERE CLIENTE_ID = @CLIENTE_ID

	UPDATE [NO_SRTA_E_GATOREI].CLIENTES 
	SET BAJA_LOGICA = @STATE 
	WHERE CLIENTE_ID = @CLIENTE_ID

	IF @USER_ID IS NOT NULL
	BEGIN
		UPDATE [NO_SRTA_E_GATOREI].USUARIOS
		SET BAJA_LOGICA = @STATE
		WHERE USUARIO_ID = @USER_ID
	END

	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN @@ERROR
		END
		ELSE
		BEGIN	
			COMMIT TRANSACTION
			RETURN 0
		END
	END
GO
CREATE PROCEDURE INVERTIR_BAJA_LOGICA_PROVEEDOR @PROVEEDOR_ID INT
AS
BEGIN
BEGIN TRANSACTION
	DECLARE @STATE BIT, @USER_ID BIT
	SELECT @STATE = ~BAJA_LOGICA, @USER_ID = USUARIO_ID
	FROM [NO_SRTA_E_GATOREI].PROVEEDORES
	WHERE PROVEEDOR_ID = @PROVEEDOR_ID

	UPDATE [NO_SRTA_E_GATOREI].PROVEEDORES 
	SET BAJA_LOGICA = @STATE 
	WHERE PROVEEDOR_ID = @PROVEEDOR_ID

	IF @USER_ID IS NOT NULL
	BEGIN
		UPDATE [NO_SRTA_E_GATOREI].USUARIOS
		SET BAJA_LOGICA = @STATE
		WHERE USUARIO_ID = @USER_ID
	END

	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN @@ERROR
		END
		ELSE
		BEGIN	
			COMMIT TRANSACTION
			RETURN 0
		END
	END
GO
CREATE FUNCTION STRING_SPLIT
(
    @string    nvarchar(max),
    @delimiter nvarchar(max)
)
RETURNS TABLE AS RETURN
(
    SELECT 
           ROW_NUMBER ( ) over(order by (select 0))  id     --  Not sure if it works correct
         , Split.a.value('.', 'NVARCHAR(MAX)')       value
    FROM
    (
        SELECT CAST('<X>'+REPLACE(@string, @delimiter, '</X><X>')+'</X>' AS XML) AS String
    ) AS a
    CROSS APPLY String.nodes('/X') AS Split(a)
)
GO
CREATE PROCEDURE ACTUALIZAR_ROL @ROL_ID INT, @ROL_DESC NVARCHAR(100), @PERMISOS NVARCHAR(255)
AS
BEGIN
BEGIN TRANSACTION
UPDATE [NO_SRTA_E_GATOREI].[ROLES] 
SET NOMBRE = @ROL_DESC
WHERE ROL_ID = @ROL_ID

DELETE [NO_SRTA_E_GATOREI].[PERMISOS_ROLES]
WHERE ROL_ID = @ROL_ID

INSERT INTO [NO_SRTA_E_GATOREI].[PERMISOS_ROLES] (PERMISO_ID,ROL_ID)
SELECT VALUE,@ROL_ID 
FROM STRING_SPLIT(@PERMISOS,'|')

IF @@ERROR <> 0 
BEGIN 
ROLLBACK
RETURN @@ERROR
END
ELSE 
BEGIN
COMMIT TRANSACTION
RETURN 0 
END
END
GO
CREATE PROCEDURE CREAR_ROL @ROL_DESC NVARCHAR(100), @PERMISOS NVARCHAR(255)
AS
BEGIN
BEGIN TRANSACTION
DECLARE @ROL_ID INT;

INSERT INTO [NO_SRTA_E_GATOREI].ROLES(NOMBRE) VALUES (@ROL_DESC);
SELECT @ROL_ID FROM [NO_SRTA_E_GATOREI].ROLES WHERE NOMBRE = @ROL_DESC;

INSERT INTO [NO_SRTA_E_GATOREI].[PERMISOS_ROLES] (PERMISO_ID,ROL_ID)
SELECT VALUE,@ROL_ID 
FROM STRING_SPLIT(@PERMISOS,'|')

IF @@ERROR <> 0 
BEGIN 
ROLLBACK
RETURN @@ERROR
END
ELSE 
BEGIN
COMMIT TRANSACTION
RETURN 0 
END
END
GO