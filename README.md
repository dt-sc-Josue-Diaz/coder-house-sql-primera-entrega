# coder-house-sql-primera-entrega
Repositorio para primera entrega de la comisión 75965

# Productos financieros derivados.

Los productos derivados son instrumentos financieros cuyo valor depende de un activo subyacente. Su principal finalidad es transferir o reducir el riesgo asociado a dicho valor. Históricamente, los derivados pueden rastrearse hasta eventos como la especulación con los precios de los tulipanes en los Países Bajos durante los 1630, o más recientemente, la crisis financiera de 2008.

Durante esta última crisis, surgieron instrumentos como los Credit Default Swaps (CDS), que funcionaban como seguros para cubrir hipotecas. En ese entonces, los mercados confiaban plenamente en los activos inmobiliarios, al considerarse inversiones seguras, dado que las personas solían cumplir con el pago de sus hipotecas.

Sin embargo, el valor subyacente no reflejaba adecuadamente el riesgo real del mercado. Motivados por el afán de colocar más hipotecas, muchos bancos comenzaron a otorgar créditos de alto riesgo. Estos se empaquetaban y diversificaban en instrumentos conocidos como Collateralized Debt Obligations (CDO), que eran percibidos erróneamente como de bajo riesgo. Cuando las agencias calificadoras comenzaron a reducir la calificación crediticia de estos instrumentos, los seguros (CDS) se activaron. Esto generó una falta de liquidez que instituciones como Lehman Brothers no pudieron afrontar, precipitando su colapso.

La correcta valoración de instrumentos derivados, como los swaps, es fundamental, así como también lo es una adecuada estimación del valor del subyacente. En respuesta a estos riesgos, surgieron regulaciones y métricas como CVA (Credit Valuation Adjustment) y XVA, que buscan cuantificar la exposición al riesgo de contraparte en una negociación financiera.

En este proyecto, desarrollamos una base de datos con la información necesaria para la valoración de derivados, así como para realizar simulaciones de riesgo utilizando métricas como VaR (Value at Risk) y CVA, bases esenciales para el cálculo de XVA. De forma resumida:

CVA (Credit Valuation Adjustment): mide el riesgo de crédito de la contraparte (probabilidad de que no me pague).

DVA (Debit Valuation Adjustment): mide el riesgo de crédito propio (probabilidad de que yo no pague).

Llegando a XVA  = CVA − DVA.


# Base de Datos: DERIVADOS

## Descripción
La base de datos DERIVADOS modela posiciones financieras de productos derivados, sus flujos de efectivo, los factores de riesgo asociados y los modelos utilizados para su valuación. Todas las tablas se relacionan con la tabla principal `POSICION`.

---

## Entidad-Relación
- `POSICION` ← principal (PK: id_posicion)
- `FLUJOS` → relacionada con POSICION (FK: id_posicion)
- `FACTORES_DE_RIESGO` → relacionada con POSICION (FK: id_posicion)
- `MODELOS` → relacionada con POSICION (FK: id_posicion)

---

## Tablas y campos

### POSICION
| Campo               | Abreviatura   | Tipo de Dato      | Clave      |
|--------------------|---------------|-------------------|------------|
| id_posicion        | id_posicion   | INT AUTO_INCREMENT| PK         |
| operacion          | operacion     | VARCHAR(50)       |            |
| fecha              | fecha         | DATE              |            |
| inicio             | inicio        | DATE              |            |
| fecha_fin          | fecha_fin     | DATE              |            |
| tasa_activa        | tasa_activa   | DECIMAL(5,2)      |            |
| tasa_pasiva        | tasa_pasiva   | DECIMAL(5,2)      |            |
| modelo_valuacion   | modelo_valuacion | VARCHAR(50)   |            |
| curva_pago_1       | curva_pago_1  | VARCHAR(50)       |            |
| curva_pago_2       | curva_pago_2  | VARCHAR(50)       |            |
| curva_descuento_1  | curva_descuento_1 | VARCHAR(50)   |            |
| curva_descuento_2  | curva_descuento_2 | VARCHAR(50)   |            |

---

### FLUJOS
| Campo        | Tipo de Dato      | Clave |
|--------------|-------------------|-------|
| id_flujo     | INT AUTO_INCREMENT| PK    |
| id_posicion  | INT               | FK    |
| fecha_flujo  | DATE              |       |
| monto        | DECIMAL(15,2)     |       |
| tipo_flujo   | VARCHAR(20)       |       |

---

### FACTORES_DE_RIESGO
| Campo         | Tipo de Dato     | Clave |
|---------------|------------------|-------|
| id_factor     | INT AUTO_INCREMENT| PK   |
| id_posicion   | INT              | FK    |
| tipo_factor   | VARCHAR(50)      |       |
| valor         | DECIMAL(10,4)    |       |
| fecha         | DATE             |       |

---

### MODELOS
| Campo          | Tipo de Dato     | Clave |
|----------------|------------------|-------|
| id_modelo      | INT AUTO_INCREMENT| PK   |
| id_posicion    | INT              | FK    |
| nombre_modelo  | VARCHAR(100)     |       |
| version        | VARCHAR(20)      |       |
| descripcion    | TEXT             |       |


