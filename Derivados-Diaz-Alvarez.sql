CREATE DATABASE IF NOT EXISTS DERIVADOS;

USE DERIVADOS;

-- POSICION
CREATE TABLE IF NOT EXISTS POSICION (
    id_posicion INT PRIMARY KEY AUTO_INCREMENT,
    operacion VARCHAR(50) NOT NULL,
    fecha DATE NOT NULL,
    inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    tasa_activa DECIMAL(5,2) NOT NULL,
    tasa_pasiva DECIMAL(5,2) NOT NULL,
    modelo_valuacion VARCHAR(50) NOT NULL,
    curva_pago_1 VARCHAR(50) NOT NULL,
    curva_pago_2 VARCHAR(50) NOT NULL,
    curva_descuento_1 VARCHAR(50) NOT NULL,
    curva_descuento_2 VARCHAR(50) NOT NULL
);

-- FLUJOS
CREATE TABLE IF NOT EXISTS FLUJOS (
    id_flujo INT PRIMARY KEY AUTO_INCREMENT,
    id_posicion INT NOT NULL,
    fecha_flujo DATE NOT NULL,
    monto DECIMAL(15,2) NOT NULL,
    tipo_flujo VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);

-- FACTORES DE RIESGO
CREATE TABLE IF NOT EXISTS FACTORES_DE_RIESGO (
    id_factor INT PRIMARY KEY AUTO_INCREMENT,
    id_posicion INT NOT NULL,
    tipo_factor VARCHAR(50) NOT NULL,
    valor DECIMAL(10,4) NOT NULL,
    fecha DATE NOT NULL,
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);

-- MODELOS
CREATE TABLE IF NOT EXISTS MODELOS (
    id_modelo INT PRIMARY KEY AUTO_INCREMENT,
    id_posicion INT NOT NULL,
    nombre_modelo VARCHAR(100) NOT NULL,
    version VARCHAR(20) NOT NULL,
    descripcion TEXT NOT NULL,
    FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion)
);


/*
Datos ficticios demostrativos. 
*/

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

SELECT * FROM POSICION;
SELECT * FROM FLUJOS;
SELECT * FROM FACTORES_DE_RIESGO;
SELECT * FROM MODELOS;
