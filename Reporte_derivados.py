import pandas as pd
import matplotlib.pyplot as plt
import mysql.connector
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet

# 1. Conexión a la base de datos
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='12345678',
    database='DERIVADOS'
)

# 2. Consulta SQL
query = """
SELECT p.id_posicion, p.operacion, v.fecha_valuacion, 
       v.valor_presente, r.var_historico, r.var_Markowitz,
       x.cva, x.dva, x.fva
FROM POSICION p
LEFT JOIN VALUACION v ON p.id_posicion = v.id_posicion
LEFT JOIN VAR r ON p.id_posicion = r.id_posicion
LEFT JOIN XVA x ON p.id_posicion = x.id_posicion
"""
df = pd.read_sql(query, conn)
conn.close()

# 3. Crear gráficas y guardarlas como imágenes
plt.figure(figsize=(8, 4))
df[['cva', 'dva', 'fva']].plot()
plt.title('XVA por posición')
plt.xlabel('Índice')
plt.ylabel('Valor')
plt.tight_layout()
plt.savefig('grafico_xva.png')
plt.close()

# Otra gráfica: VAR
plt.figure(figsize=(8, 4))
df[['var_historico', 'var_Markowitz']].plot()
plt.title('VaR Histórico vs Markowitz')
plt.xlabel('Índice')
plt.ylabel('Valor')
plt.tight_layout()
plt.savefig('grafico_var.png')
plt.close()

# 4. Crear PDF con reportlab
pdf_file = "reporte_financiero_completo.pdf"
doc = SimpleDocTemplate(pdf_file, pagesize=letter)
styles = getSampleStyleSheet()
elements = []

# Título
elements.append(Paragraph("Reporte Financiero Completo", styles['Title']))
elements.append(Spacer(1, 12))

# Tabla de datos (primeras 15 filas como ejemplo)
table_data = [df.columns.tolist()] + df.head(15).values.tolist()
table = Table(table_data, repeatRows=1)
table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.darkblue),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.black),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
]))
elements.append(table)
elements.append(Spacer(1, 20))

# Incluir las gráficas
elements.append(Paragraph("Gráfica de XVA", styles['Heading2']))
elements.append(Image('grafico_xva.png', width=500, height=200))
elements.append(Spacer(1, 12))

elements.append(Paragraph("Gráfica de VaR", styles['Heading2']))
elements.append(Image('grafico_var.png', width=500, height=200))

# 5. Generar PDF
doc.build(elements)
