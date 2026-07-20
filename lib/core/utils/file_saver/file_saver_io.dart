import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// true kalau target-nya browser (selalu false di file ini karena ini
/// implementasi untuk io/mobile/desktop).
const bool isWebPlatform = false;

/// Simpan bytes ke folder dokumen aplikasi dan kembalikan path lengkapnya.
/// Path ini bisa dipakai untuk membuka file dengan `open_filex`.
Future<String> saveBytesAndGetPath(List<int> bytes, String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}