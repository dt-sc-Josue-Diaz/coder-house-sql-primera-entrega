CREATE VIEW vista_posiciones_con_modelo AS
SELECT 
    p.id_posicion,
    p.operacion,
    p.fecha,
    m.nombre_modelo,
    m.version
FROM POSICION p
JOIN MODELOS m ON p.id_posicion = m.id_posicion;

CREATE VIEW vista_flujos_futuros AS
SELECT 
    f.id_flujo,
    f.fecha_flujo,
    f.monto,
    f.tipo_flujo,
    p.operacion
FROM FLUJOS f
JOIN POSICION p ON f.id_posicion = p.id_posicion
WHERE f.fecha_flujo > CURDATE();

CREATE VIEW vista_factores_actuales AS
SELECT 
    f.id_factor,
    f.tipo_factor,
    f.valor,
    f.fecha,
    p.operacion
FROM FACTORES_DE_RIESGO f
JOIN POSICION p ON f.id_posicion = p.id_posicion
WHERE f.fecha = (SELECT MAX(fecha) FROM FACTORES_DE_RIESGO WHERE tipo_factor = f.tipo_factor);

-- FUNCIONES

DELIMITER //
CREATE FUNCTION obtener_duracion_dias(fecha_inicio DATE, fecha_fin DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(fecha_fin, fecha_inicio);
END;
//

CREATE FUNCTION calcular_spread(tasa_activa DECIMAL(5,2), tasa_pasiva DECIMAL(5,2))
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    RETURN tasa_activa - tasa_pasiva;
END;
//

CREATE FUNCTION es_flujo_positivo(monto DECIMAL(15,2))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN monto > 0;
END;
//
DELIMITER ;

-- STORED PROCEDURES

DELIMITER //
CREATE PROCEDURE insertar_nueva_posicion (
    IN operacion_ VARCHAR(50),
    IN fecha_ DATE,
    IN inicio_ DATE,
    IN fecha_fin_ DATE,
    IN tasa_activa_ DECIMAL(5,2),
    IN tasa_pasiva_ DECIMAL(5,2),
    IN modelo_valuacion_ VARCHAR(50),
    IN curva_pago_1_ VARCHAR(50),
    IN curva_pago_2_ VARCHAR(50),
    IN curva_descuento_1_ VARCHAR(50),
    IN curva_descuento_2_ VARCHAR(50)
)
BEGIN
    INSERT INTO POSICION (
        operacion, fecha, inicio, fecha_fin,
        tasa_activa, tasa_pasiva, modelo_valuacion,
        curva_pago_1, curva_pago_2,
        curva_descuento_1, curva_descuento_2)
    VALUES (
        operacion_, fecha_, inicio_, fecha_fin_,
        tasa_activa_, tasa_pasiva_, modelo_valuacion_,
        curva_pago_1_, curva_pago_2_,
        curva_descuento_1_, curva_descuento_2_);
END;
//

CREATE PROCEDURE insertar_flujo_para_posicion (
    IN id_posicion_ INT,
    IN fecha_flujo_ DATE,
    IN monto_ DECIMAL(15,2),
    IN tipo_flujo_ VARCHAR(20)
)
BEGIN
    INSERT INTO FLUJOS (id_posicion, fecha_flujo, monto, tipo_flujo)
    VALUES (id_posicion_, fecha_flujo_, monto_, tipo_flujo_);
END;
//

CREATE PROCEDURE actualizar_valor_factor (
    IN id_factor_ INT,
    IN nuevo_valor_ DECIMAL(10,4)
)
BEGIN
    UPDATE FACTORES_DE_RIESGO
    SET valor = nuevo_valor_
    WHERE id_factor = id_factor_;
END;
//
DELIMITER ;

-- TRIGGERS

DELIMITER //
CREATE TRIGGER trg_before_insert_flujos
BEFORE INSERT ON FLUJOS
FOR EACH ROW
BEGIN
    IF NEW.monto < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto del flujo no puede ser negativo';
    END IF;
END;
//

CREATE TRIGGER trg_after_insert_posicion
AFTER INSERT ON POSICION
FOR EACH ROW
BEGIN
    INSERT INTO MODELOS (id_posicion, nombre_modelo, version, descripcion)
    VALUES (NEW.id_posicion, 'Pendiente', 'v0', 'Modelo pendiente de definir');
END;
//

CREATE TRIGGER trg_before_update_factor
BEFORE UPDATE ON FACTORES_DE_RIESGO
FOR EACH ROW
BEGIN
    IF OLD.valor <> NEW.valor THEN
        INSERT INTO FACTORES_DE_RIESGO (
            id_posicion, tipo_factor, valor, fecha
        ) VALUES (
            OLD.id_posicion, CONCAT('AUDIT-', OLD.tipo_factor), OLD.valor, NOW()
        );
    END IF;
END;
//
DELIMITER ;
