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


## 📄 Listado de Tablas

### 1. Tabla: `POSICION`

**Descripción:** Contiene información principal de cada operación de derivados.

| Abrev. Campo      | Nombre Completo         | Tipo de Dato     | Tipo de Clave  |
|-------------------|--------------------------|------------------|----------------|
| operacion         | ID de Operación          | VARCHAR(50)      | PRIMARY KEY    |
| fecha             | Fecha de Registro        | DATE             |                |
| inicio            | Fecha de Inicio          | DATE             |                |
| fecha_fin         | Fecha de Vencimiento     | DATE             |                |
| tasa_activa       | Tasa Activa              | DECIMAL(10,6)    |                |
| tasa_pasiva       | Tasa Pasiva              | DECIMAL(10,6)    |                |
| modelo_valuacion  | Modelo de Valuación      | VARCHAR(100)     |                |
| curva_pago_1      | Curva de Pago 1          | VARCHAR(100)     |                |
| curva_pago_2      | Curva de Pago 2          | VARCHAR(100)     |                |
| curva_descuento_1 | Curva de Descuento 1     | VARCHAR(100)     |                |
| curva_descuento_2 | Curva de Descuento 2     | VARCHAR(100)     |                |

### 2. Tabla: `FLUJOS`

**Descripción:** Contiene los flujos de efectivo asociados a cada operación.

| Abrev. Campo     | Nombre Completo       | Tipo de Dato    | Tipo de Clave  |
|------------------|------------------------|-----------------|----------------|
| id_flujo         | ID del Flujo           | INT             | PRIMARY KEY    |
| operacion        | ID de Operación        | VARCHAR(50)     | FOREIGN KEY → POSICION.operacion |
| fecha_flujo      | Fecha del Flujo        | DATE            |                |
| monto            | Monto del Flujo        | DECIMAL(18,2)   |                |
| tipo_flujo       | Tipo de Flujo          | VARCHAR(50)     |                |

### 3. Tabla: `FACTORES_DE_RIESGO`

**Descripción:** Contiene los factores de riesgo que afectan la valuación de los derivados.

| Abrev. Campo     | Nombre Completo          | Tipo de Dato     | Tipo de Clave  |
|------------------|---------------------------|------------------|----------------|
| id_factor        | ID del Factor de Riesgo   | INT              | PRIMARY KEY    |
| nombre_factor    | Nombre del Factor         | VARCHAR(100)     |                |
| tipo_factor      | Tipo de Factor            | VARCHAR(50)      |                |
| valor_actual     | Valor Actual              | DECIMAL(18,6)    |                |
| fecha            | Fecha del Valor           | DATE             |                |

### 4. Tabla: `MODELOS`

**Descripción:** Contiene los distintos modelos de valuación utilizados en las operaciones.

| Abrev. Campo     | Nombre Completo          | Tipo de Dato     | Tipo de Clave  |
|------------------|---------------------------|------------------|----------------|
| id_modelo        | ID del Modelo             | INT              | PRIMARY KEY    |
| nombre_modelo    | Nombre del Modelo         | VARCHAR(100)     |                |
| descripcion      | Descripción del Modelo    | TEXT             |                |

