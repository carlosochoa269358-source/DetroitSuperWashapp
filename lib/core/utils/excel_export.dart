import 'dart:html' as html;
import 'package:excel/excel.dart';

/// Arma un archivo .xlsx a partir de una o más hojas y dispara la descarga
/// en el navegador. [sheets] es un mapa nombre de hoja -> filas (cada fila
/// es una lista de valores: String, num o null).
void downloadExcel({
  required String fileName,
  required Map<String, List<List<Object?>>> sheets,
}) {
  final excel = Excel.createExcel();

  sheets.forEach((sheetName, rows) {
    final sheet = excel[sheetName];
    for (final row in rows) {
      sheet.appendRow(row.map(_toCellValue).toList());
    }
  });

  // Excel crea una hoja "Sheet1" por defecto; se borra si no se usó.
  if (!sheets.containsKey('Sheet1') && excel.sheets.containsKey('Sheet1')) {
    excel.delete('Sheet1');
  }

  final bytes = excel.save();
  if (bytes == null) return;

  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

CellValue? _toCellValue(Object? value) {
  if (value == null) return null;
  if (value is int) return IntCellValue(value);
  if (value is double) return DoubleCellValue(value);
  return TextCellValue(value.toString());
}
