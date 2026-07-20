// Helper untuk menyimpan file hasil download (mis. export Excel) dengan
// cara yang berbeda tergantung platform:
//  - Mobile/Desktop (io): simpan ke folder aplikasi lewat path_provider,
//    lalu bisa dibuka dengan open_filex.
//  - Web: browser TIDAK punya filesystem & TIDAK mendukung path_provider
//    (`getApplicationDocumentsDirectory` akan melempar MissingPluginException
//    kalau dipanggil di Chrome/web). Jadi di web kita langsung trigger
//    download lewat browser (dart:html) tanpa path_provider sama sekali.
//
// Dart akan otomatis memilih implementasi yang benar sesuai target build
// (`dart.library.html` hanya true saat compile ke web).
export 'file_saver_io.dart' if (dart.library.html) 'file_saver_web.dart';