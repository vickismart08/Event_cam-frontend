import 'dart:html' as html;
import 'dart:typed_data';

/// Browser: trigger a file download so the QR can be saved or airdropped.
Future<void> downloadPngBytesWeb(List<int> bytes, String filename) async {
  final u8 = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final blob = html.Blob([u8], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
