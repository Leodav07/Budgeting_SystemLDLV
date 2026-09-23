import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'

/**
 * Genera un PDF simple para un reporte: título, fecha de generación,
 * imagen del gráfico (si se pasa un <canvas>) y una tabla de datos.
 */
export function exportReportePdf({ titulo, subtitulo, chartCanvas, columnas, filas, nombreArchivo }) {
  const doc = new jsPDF({ orientation: 'portrait', unit: 'pt' })
  const margen = 40

  doc.setFontSize(16)
  doc.setTextColor(30, 41, 59)
  doc.text(titulo, margen, 46)

  doc.setFontSize(10)
  doc.setTextColor(100, 116, 139)
  if (subtitulo) doc.text(subtitulo, margen, 64)
  doc.text(`Generado el ${new Date().toLocaleString('es')}`, margen, subtitulo ? 78 : 64)

  let cursorY = subtitulo ? 96 : 82

  if (chartCanvas) {
    try {
      const imgData = chartCanvas.toDataURL('image/png', 1.0)
      const pageWidth = doc.internal.pageSize.getWidth()
      const imgWidth = pageWidth - margen * 2
      const imgHeight = (chartCanvas.height / chartCanvas.width) * imgWidth
      doc.addImage(imgData, 'PNG', margen, cursorY, imgWidth, imgHeight)
      cursorY += imgHeight + 20
    } catch {
      // si el canvas no se puede exportar (p. ej. todavía no renderizó), seguimos sin imagen
    }
  }

  if (columnas && filas) {
    autoTable(doc, {
      startY: cursorY,
      head: [columnas],
      body: filas,
      margin: { left: margen, right: margen },
      styles: { fontSize: 9, cellPadding: 6 },
      headStyles: { fillColor: [79, 70, 229], textColor: 255 },
      alternateRowStyles: { fillColor: [248, 250, 252] },
    })
  }

  doc.save(nombreArchivo || 'reporte.pdf')
}
