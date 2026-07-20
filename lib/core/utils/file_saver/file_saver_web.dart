// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// true kalau target-nya browser.
const bool isWebPlatform = true;

/// Di web tidak ada filesystem aplikasi seperti di mobile, jadi kita
/// langsung memicu download lewat browser (klik elemen <a> tersembunyi).
/// Mengembalikan nama file (bukan path asli, karena browser yang
/// menentukan lokasi penyimpanan/folder Downloads).
Future<String> saveBytesAndGetPath(List<int> bytes, String filename) async {
  final blob = html.Blob([Uint8List.fromList(bytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;
  html.document.body!.children.add(anchor);
  anchor.click();
  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
  return filename;
}