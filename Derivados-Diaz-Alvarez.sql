CREATE DATABASE IF NOT EXISTS  DERIVADOS;

USE DERIVADOS;
----------------------------------------------------------------------------------------------------- Sección de Tablas.
-- POSICION
CREATE TABLE IF NOT EXISTS POSICION (
    id_posicion INT PRIMARY KEY AUTO_INCREMENT,
    operacion VARCHAR(50),
    fecha DATE,
    inicio DATE,
    fecha_fin DATE,
    tasa_activa DECIMAL(5,2),
    tasa_pasiva DECIMAL(5,2),
    modelo_valuacion VARCHAR(50),
    curva_pago_1 VARCHAR(50),
    curva_pago_2 VARCHAR(50),
    curva_descuento_1 VARCHAR(50),
    curva_descuento_2 VARCHAR(50)
);

--- Flujos
CREATE TABLE IF NOT EXISTS FLUJOS (
    id_flujo INT PRIMARY KEY AUTO_INCREMENT,
    id_posicion INT,
    fecha_flujo DATE,
    monto DECIMAL(15,2),
    tipo_flujo VARCHAR(20),
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);

--- Factores de riesgo
CREATE TABLE IF NOT EXISTS FACTORES_DE_RIESGO (
    id_factor INT PRIMARY KEY AUTO_INCREMENT,
    id_posicion INT,
    tipo_factor VARCHAR(50),
    valor DECIMAL(10,4),
    fecha DATE,
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);

--- Modelos
CREATE TABLE IF NOT EXISTS MODELOS (
    id_modelo INT PRIMARY KEY AUTO_INCREMENT,
    id_posicion INT,
    nombre_modelo VARCHAR(100),
    version VARCHAR(20),
    descripcion TEXT,
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);

-- Tabla de VALUACIÓN
CREATE TABLE VALUACION (
    id_posicion INT PRIMARY KEY,
    fecha_valuacion DATE NOT NULL,
    valor_presente DECIMAL(18,2) NOT NULL,
    metodo_valuacion VARCHAR(100),
    moneda VARCHAR(10),
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);

-- Tabla de VAR (Valor en Riesgo)
CREATE TABLE VAR (
    id_posicion INT PRIMARY KEY,
    fecha_calculo DATE NOT NULL,
    var_historico DECIMAL(18,2),
    var_Markowitz DECIMAL(18,2),
    escenarios_var INT,
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);

-- Tabla de XVA (ajustes por valoración de crédito)
CREATE TABLE XVA (
    id_posicion INT PRIMARY KEY,
    fecha_xva DATE NOT NULL,
    cva DECIMAL(18,2),  -- Credit Valuation Adjustment
    dva DECIMAL(18,2),  -- Debit Valuation Adjustment
    fva DECIMAL(18,2),  -- Funding Valuation Adjustment
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);

------------------------------------------------------------------------------------------------- Sección de vistas.
CREATE VIEW  vista_posiciones_con_modelo AS
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


CREATE OR REPLACE VIEW vw_reporte_completo AS
SELECT p.id_posicion, p.operacion, p.fecha, p.fecha_fin,
       v.fecha_valuacion, v.valor_presente, v.moneda,
       r.var_historico, r.var_Markowitz,
       x.cva, x.dva, x.fva
FROM POSICION p
LEFT JOIN VALUACION v ON p.id_posicion = v.id_posicion
LEFT JOIN VAR r ON p.id_posicion = r.id_posicion
LEFT JOIN XVA x ON p.id_posicion = x.id_posicion;


--------------------------------------------------------------------------------------------------------------- FUNCIONES
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

-- Función de valuación neta
DELIMITER //
CREATE FUNCTION fn_valuacion_neta(id INT) RETURNS DECIMAL(18,2)
READS SQL DATA
BEGIN
  DECLARE resultado DECIMAL(18,2);
  SELECT valor_presente_neto - (COALESCE(cva,0) + COALESCE(dva,0) + COALESCE(fva,0))
  INTO resultado
  FROM VALUACION v LEFT JOIN XVA x ON v.id_posicion = x.id_posicion
  WHERE v.id_posicion = id;
  RETURN resultado;
END //
DELIMITER ;

----------------------------------------------------------------------------------------------------------STORED PROCEDURES

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
DELIMITER;

-- Stored Procedure para actualizar VAR
DELIMITER //
CREATE PROCEDURE sp_actualizar_var(IN id INT, IN nuevo_valor DECIMAL(18,2))
BEGIN
  UPDATE VAR SET var_1d_99 = nuevo_valor WHERE id_posicion = id;
END //
DELIMITER ;



------------------------------------------------------------------------------------------------------------------ TRIGGERS

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


-- Trigger para auditoría de cambios en XVA
CREATE TABLE auditoria_xva (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_posicion INT,
    campo_modificado VARCHAR(10),
    valor_anterior DECIMAL(18,2),
    fecha_modificacion DATETIME
);


DELIMITER //
CREATE TRIGGER tr_auditoria_xva
BEFORE UPDATE ON XVA
FOR EACH ROW
BEGIN
  IF OLD.cva <> NEW.cva THEN
    INSERT INTO auditoria_xva (id_posicion, campo_modificado, valor_anterior, fecha_modificacion)
    VALUES (OLD.id_posicion, 'CVA', OLD.cva, NOW());
  END IF;
  IF OLD.dva <> NEW.dva THEN
    INSERT INTO auditoria_xva (id_posicion, campo_modificado, valor_anterior, fecha_modificacion)
    VALUES (OLD.id_posicion, 'DVA', OLD.dva, NOW());
  END IF;
  IF OLD.fva <> NEW.fva THEN
    INSERT INTO auditoria_xva (id_posicion, campo_modificado, valor_anterior, fecha_modificacion)
    VALUES (OLD.id_posicion, 'FVA', OLD.fva, NOW());
  END IF;
END //
DELIMITER ;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- Datos ficticios


INSERT INTO POSICION (operacion, fecha, inicio, fecha_fin, tasa_activa, tasa_pasiva, modelo_valuacion, curva_pago_1, curva_pago_2, curva_descuento_1, curva_descuento_2)
VALUES 
('Swap', '2025-01-01', '2025-01-01', '2028-01-01', 6.25, 5.75, 'Black-Scholes', 'CURVA_MXN', 'CURVA_USD', 'CURVA_MXN', 'CURVA_USD'),
('Forward', '2025-02-01', '2025-02-10', '2025-12-10', 6.50, 6.00, 'Monte Carlo', 'CURVA_MXN', 'CURVA_EUR', 'CURVA_MXN', 'CURVA_EUR'),
('Swap', '2025-03-01', '2025-03-01', '2027-03-01', 7.00, 6.50, 'Black', 'CURVA_MXN', 'CURVA_USD', 'CURVA_MXN', 'CURVA_USD'),
('Cap', '2025-01-15', '2025-01-20', '2026-01-20', 5.80, 5.30, 'Bachelier', 'CURVA_MXN', 'CURVA_EUR', 'CURVA_MXN', 'CURVA_EUR'),
('Floor', '2025-04-01', '2025-04-15', '2027-04-15', 6.90, 6.40, 'Hull-White', 'CURVA_USD', 'CURVA_EUR', 'CURVA_USD', 'CURVA_EUR'),
('Swap', '2025-05-01', '2025-05-10', '2026-05-10', 7.10, 6.80, 'SABR', 'CURVA_MXN', 'CURVA_USD', 'CURVA_MXN', 'CURVA_USD'),
('Swap', '2025-06-01', '2025-06-10', '2027-06-10', 7.30, 7.00, 'LIBOR', 'CURVA_MXN', 'CURVA_USD', 'CURVA_MXN', 'CURVA_USD'),
('Forward', '2025-07-01', '2025-07-15', '2026-07-15', 6.85, 6.45, 'Bachelier', 'CURVA_EUR', 'CURVA_MXN', 'CURVA_EUR', 'CURVA_MXN'),
('Swap', '2025-08-01', '2025-08-10', '2028-08-10', 6.75, 6.25, 'Monte Carlo', 'CURVA_USD', 'CURVA_EUR', 'CURVA_USD', 'CURVA_EUR'),
('Cap', '2025-09-01', '2025-09-05', '2026-09-05', 5.95, 5.55, 'Hull-White', 'CURVA_EUR', 'CURVA_USD', 'CURVA_EUR', 'CURVA_USD');



INSERT INTO FLUJOS (id_posicion, fecha_flujo, monto, tipo_flujo)
VALUES
(1, '2025-06-01', 50000.00, 'Interes'),
(1, '2025-12-01', 52000.00, 'Principal'),
(2, '2025-10-01', 45000.00, 'Interes'),
(3, '2026-03-01', 48000.00, 'Principal'),
(4, '2025-08-01', 47000.00, 'Interes'),
(5, '2026-04-01', 55000.00, 'Principal'),
(6, '2025-11-01', 60000.00, 'Interes'),
(7, '2026-06-01', 58000.00, 'Principal'),
(8, '2025-12-01', 43000.00, 'Interes'),
(9, '2026-08-01', 61000.00, 'Principal');


INSERT INTO FACTORES_DE_RIESGO (id_posicion, tipo_factor, valor, fecha)
VALUES
(1, 'Tasa Interés', 0.0625, '2025-01-01'),
(2, 'Tasa Interés', 0.0650, '2025-02-01'),
(3, 'Tasa Interés', 0.0700, '2025-03-01'),
(4, 'Tasa Interés', 0.0580, '2025-01-15'),
(5, 'Tasa Interés', 0.0690, '2025-04-01'),
(6, 'Volatilidad', 0.1500, '2025-05-01'),
(7, 'Volatilidad', 0.1450, '2025-06-01'),
(8, 'Tipo de cambio', 18.50, '2025-07-01'),
(9, 'Tipo de cambio', 1.12, '2025-08-01'),
(10, 'Tasa Interés', 0.0595, '2025-09-01');


INSERT INTO MODELOS (id_posicion, nombre_modelo, version, descripcion)
VALUES
(1, 'Black-Scholes', '1.0', 'Modelo estándar para opciones europeas'),
(2, 'Monte Carlo', '2.1', 'Simulación de precios bajo riesgo neutral'),
(3, 'Black', '1.1', 'Modelo Black para futuros'),
(4, 'Bachelier', '1.2', 'Modelo aditivo para tasas negativas'),
(5, 'Hull-White', '3.0', 'Modelo de tasas de interés con reversión a la media'),
(6, 'SABR', '2.0', 'Modelo estocástico para volatilidad implícita'),
(7, 'LIBOR Market Model', '1.0', 'Modelo para proyección de tasas forward'),
(8, 'Bachelier', '1.3', 'Revisión del modelo para swaps'),
(9, 'Monte Carlo', '2.2', 'Monte Carlo con cambio de medida'),
(10, 'Hull-White', '3.1', 'Versión calibrada para mercado MXN');


INSERT INTO VALUACION (id_posicion, fecha_valuacion, valor_presente, metodo_valuacion, moneda)
VALUES
(1, '2025-01-02', 125000.00,'Black-Scholes', 'MXN'),
(2, '2025-02-11', 95000.00, 'Monte Carlo', 'MXN'),
(3, '2025-03-02', 110000.00, 'Black', 'MXN'),
(4, '2025-01-21', 88000.00, 'Bachelier', 'MXN'),
(5, '2025-04-16', 103000.00,'Hull-White', 'USD'),
(6, '2025-05-11', 98000.00, 'SABR', 'MXN'),
(7, '2025-06-11', 120000.00, 'LIBOR Market Model', 'MXN'),
(8, '2025-07-16', 89000.00, 'Bachelier', 'EUR'),
(9, '2025-08-11', 133000.00, 'Monte Carlo',  'USD'),
(10, '2025-09-06', 87000.00, 'Hull-White', 'EUR');

select * from  VALUACION;


INSERT INTO VAR (id_posicion, fecha_calculo, var_historico, var_Markowitz, escenarios_var)
VALUES
(1, '2025-01-02', 4000.00, 4200.00, 1000),
(2, '2025-02-11', 3800.00, 3950.00, 1000),
(3, '2025-03-02', 4600.00, 4500.00, 1000),
(4, '2025-01-21', 3100.00, 3000.00, 1000),
(5, '2025-04-16', 4700.00, 4800.00, 1000),
(6, '2025-05-11', 4550.00, 4400.00, 1000),
(7, '2025-06-11', 5000.00, 4900.00, 1000),
(8, '2025-07-16', 3600.00, 3500.00, 1000),
(9, '2025-08-11', 5200.00, 5300.00, 1000),
(10, '2025-09-06', 3450.00, 3400.00, 1000);

select * from  VAR;



INSERT INTO XVA (id_posicion, fecha_xva, cva, dva, fva)
VALUES
(1, '2025-01-02', 1200.00, 800.00, 300.00),
(2, '2025-02-11', 1100.00, 850.00, 250.00),
(3, '2025-03-02', 1500.00, 950.00, 350.00),
(4, '2025-01-21', 900.00, 700.00, 200.00),
(5, '2025-04-16', 1600.00, 1000.00, 400.00),
(6, '2025-05-11', 1300.00, 900.00, 300.00),
(7, '2025-06-11', 1700.00, 1100.00, 450.00),
(8, '2025-07-16', 1000.00, 750.00, 220.00),
(9, '2025-08-11', 1800.00, 1200.00, 480.00),
(10, '2025-09-06', 950.00, 700.00, 240.00);

select * from  XVA;
-----------


-- -------------------------------------------------------------------------------------------------------- Creacion de usuarios  y roles

CREATE USER 'Auditor'@'%' IDENTIFIED BY 'Auditir1';
GRANT SELECT ON DERIVADOS.* TO 'Auditor'@'%';

CREATE USER 'analista'@'%' IDENTIFIED BY 'analista_1';
GRANT SELECT, INSERT, UPDATE ON DERIVADOS.VALUACION TO 'analista'@'%';
GRANT SELECT, INSERT, UPDATE ON DERIVADOS.VAR TO 'analista'@'%';
GRANT SELECT, INSERT, UPDATE ON DERIVADOS.XVA TO 'analista'@'%';

SELECT 
    CONNECTION_ID() AS id_conexion,
    CURRENT_USER() AS usuario_actual,
    USER() AS usuario_conectado,
    DATABASE() AS base_datos_actual,
    @@hostname AS host_servidor,
    @@port AS puerto,
    @@version AS version_mysql;

