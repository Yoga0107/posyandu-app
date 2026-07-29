import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/models/models.dart';
import '../api/api_client.dart';
import '../constants/app_constants.dart';
import 'file_saver/file_saver.dart' as file_saver;

// ═══════════════════════════════════════════════════════
//  WARGA PROVIDER
// ═══════════════════════════════════════════════════════
class WargaProvider extends ChangeNotifier {
  final _api = ApiClient.instance;
  List<WargaModel> _list = [];
  WargaModel? _selected;
  List<dynamic> _riwayat = [];
  List<dynamic> _grafik = [];
  PaginationModel? _pagination;
  bool _isLoading = false;
  String? _error;

  List<WargaModel> get list        => _list;
  WargaModel? get selected         => _selected;
  List<dynamic> get riwayat        => _riwayat;
  List<dynamic> get grafik         => _grafik;
  PaginationModel? get pagination  => _pagination;
  bool get isLoading               => _isLoading;
  String? get error                => _error;

  Future<void> fetchAll({int page = 1, String? search, String? kategori}) async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/warga', params: {
        'page': page, 'limit': AppConstants.defaultPageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (kategori != null) 'kategori': kategori,
      });
      _list = (r.data['data'] as List).map((e) => WargaModel.fromJson(e)).toList();
      if (r.data['pagination'] != null) _pagination = PaginationModel.fromJson(r.data['pagination']);
    } catch (e) { _error = parseApiError(e); }
    _isLoading = false; notifyListeners();
  }

  Future<bool> fetchById(String id) async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/warga/$id');
      _selected = WargaModel.fromJson(r.data['data']['warga']);
      _riwayat  = r.data['data']['riwayat'] ?? [];
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _error = parseApiError(e); _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<bool> fetchGrafik(String id) async {
    try {
      final r = await _api.get('/warga/$id/grafik');
      _grafik = r.data['data']['grafik'] ?? [];
      notifyListeners(); return true;
    } catch (_) { return false; }
  }

  Map<String, dynamic>? _lastPendaftaran;
  Map<String, dynamic>? get lastPendaftaran => _lastPendaftaran;

  /// [data] boleh menyertakan key 'jadwal_id' supaya warga yang baru dibuat
  /// langsung didaftarkan (status 'terdaftar') ke jadwal tsb dalam satu
  /// request — lihat warga.controller.js `create()`.
  Future<bool> create(Map<String, dynamic> data) async {
    try {
      final r = await _api.post('/warga', data: data);
      _lastPendaftaran = r.data['data']?['pendaftaran'];
      await fetchAll(); return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  Future<bool> verify(String id) async {
    try {
      await _api.patch('/warga/$id/verify');
      await fetchById(id); return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  void clearError() { _error = null; notifyListeners(); }
}

// ═══════════════════════════════════════════════════════
//  JADWAL PROVIDER
// ═══════════════════════════════════════════════════════
class JadwalProvider extends ChangeNotifier {
  final _api = ApiClient.instance;
  List<JadwalModel> _list = [];
  JadwalModel? _selected;
  List<MenuPMTModel> _menu = [];
  Map<String, dynamic>? _statistik;
  bool _isLoading = false;
  String? _error;

  List<JadwalModel> get list        => _list;
  JadwalModel? get selected         => _selected;
  List<MenuPMTModel> get menu       => _menu;
  Map<String, dynamic>? get statistik => _statistik;
  bool get isLoading                => _isLoading;
  String? get error                 => _error;

  Future<void> fetchAll({String? jenis, bool upcoming = false}) async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/jadwal', params: {
        if (jenis != null) 'jenis': jenis,
        if (upcoming) 'upcoming': 'true',
      });
      _list = (r.data['data'] as List).map((e) => JadwalModel.fromJson(e)).toList();
    } catch (e) { _error = parseApiError(e); }
    _isLoading = false; notifyListeners();
  }

  Future<bool> fetchById(String id) async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/jadwal/$id');
      _selected   = JadwalModel.fromJson(r.data['data']['jadwal']);
      _menu       = (r.data['data']['menu'] as List? ?? []).map((e) => MenuPMTModel.fromJson(e)).toList();
      _statistik  = r.data['data']['statistik'];
      _isLoading = false; notifyListeners(); return true;
    } catch (e) { _error = parseApiError(e); _isLoading = false; notifyListeners(); return false; }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _api.post('/jadwal', data: data);
      await fetchAll(); return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  Future<bool> addMenu(String jadwalId, String namaMenu, {String? deskripsi}) async {
    try {
      await _api.post('/jadwal/$jadwalId/menu', data: {'nama_menu': namaMenu, 'deskripsi': deskripsi});
      await fetchById(jadwalId); return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  Future<bool> delete(String id) async {
    try { await _api.delete('/jadwal/$id'); await fetchAll(); return true; }
    catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  void clearError() { _error = null; notifyListeners(); }
}

// ═══════════════════════════════════════════════════════
//  KUNJUNGAN PROVIDER
// ═══════════════════════════════════════════════════════
class KunjunganProvider extends ChangeNotifier {
  final _api = ApiClient.instance;
  List<KunjunganModel> _list = [];
  List<KunjunganModel> _hariIni = [];
  Map<String, dynamic>? _ringkasanHariIni;
  PaginationModel? _pagination;
  bool _isLoading = false;
  String? _error;

  List<KunjunganModel> get list               => _list;
  List<KunjunganModel> get hariIni            => _hariIni;
  Map<String, dynamic>? get ringkasanHariIni  => _ringkasanHariIni;
  PaginationModel? get pagination             => _pagination;
  bool get isLoading                          => _isLoading;
  String? get error                           => _error;

  Future<void> fetchAll({String? jadwalId, String? wargaId, int page = 1}) async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/kunjungan', params: {
        'page': page, 'limit': 20,
        if (jadwalId != null) 'jadwal_id': jadwalId,
        if (wargaId != null)  'warga_id': wargaId,
      });
      _list = (r.data['data'] as List).map((e) => KunjunganModel.fromJson(e)).toList();
      if (r.data['pagination'] != null) _pagination = PaginationModel.fromJson(r.data['pagination']);
    } catch (e) { _error = parseApiError(e); }
    _isLoading = false; notifyListeners();
  }

  Future<void> fetchStatusHariIni(String jadwalId) async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/kunjungan/hari-ini', params: {'jadwal_id': jadwalId});
      _hariIni = (r.data['data']['daftar'] as List).map((e) => KunjunganModel.fromJson(e)).toList();
      _ringkasanHariIni = r.data['data']['ringkasan'];
    } catch (e) { _error = parseApiError(e); }
    _isLoading = false; notifyListeners();
  }

  /// Langkah 1: WARGA mendaftar ke jadwal (belum tentu hadir). Dipakai oleh
  /// warga sendiri (memilih salah satu data balita/lansia miliknya) atau
  /// kader yang membantu mendaftarkan warga yang tidak pakai aplikasi.
  Future<bool> daftar(String wargaId, String jadwalId) async {
    try {
      await _api.post('/kunjungan/daftar', data: {'warga_id': wargaId, 'jadwal_id': jadwalId});
      return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  /// Langkah 2: KADER meng-check-in warga yang datang langsung ("walk-in",
  /// belum pernah daftar) — kalau ternyata sudah pernah daftar, baris yang
  /// sama otomatis dikonfirmasi 'hadir' oleh backend.
  Future<bool> checkin(String wargaId, String jadwalId) async {
    try {
      await _api.post('/kunjungan/checkin', data: {'warga_id': wargaId, 'jadwal_id': jadwalId});
      return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  /// KADER meng-check-in satu baris pendaftaran tertentu langsung dari
  /// daftar antrian (mis. tap tombol "Check-in" di daftar "Menunggu").
  Future<bool> checkinById(String kunjunganId) async {
    try {
      await _api.patch('/kunjungan/$kunjunganId/checkin');
      return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  /// WARGA membatalkan pendaftarannya sendiri (selama belum check-in).
  Future<bool> batalkan(String kunjunganId) async {
    try {
      await _api.patch('/kunjungan/$kunjunganId/batal');
      return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  Future<bool> konfirmasiPMT(String kunjunganId) async {
    try {
      await _api.patch('/kunjungan/$kunjunganId/pmt');
      return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  void clearError() { _error = null; notifyListeners(); }
}

// ═══════════════════════════════════════════════════════
//  PEMERIKSAAN PROVIDER
// ═══════════════════════════════════════════════════════
class PemeriksaanProvider extends ChangeNotifier {
  final _api = ApiClient.instance;
  PemeriksaanBalitaModel? _lastBalita;
  PemeriksaanPosbinduModel? _lastPosbindu;
  bool _isLoading = false;
  String? _error;

  PemeriksaanBalitaModel? get lastBalita   => _lastBalita;
  PemeriksaanPosbinduModel? get lastPosbindu => _lastPosbindu;
  bool get isLoading                       => _isLoading;
  String? get error                        => _error;

  Future<bool> createBalita(Map<String, dynamic> data) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final r = await _api.post('/pemeriksaan/balita', data: data);
      _lastBalita = PemeriksaanBalitaModel.fromJson(r.data['data']);
      _isLoading = false; notifyListeners(); return true;
    } catch (e) { _error = parseApiError(e); _isLoading = false; notifyListeners(); return false; }
  }

  Future<bool> createPosbindu(Map<String, dynamic> data) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final r = await _api.post('/pemeriksaan/posbindu', data: data);
      _lastPosbindu = PemeriksaanPosbinduModel.fromJson(r.data['data']);
      _isLoading = false; notifyListeners(); return true;
    } catch (e) { _error = parseApiError(e); _isLoading = false; notifyListeners(); return false; }
  }

  void clearError() { _error = null; notifyListeners(); }
}

// ═══════════════════════════════════════════════════════
//  DASHBOARD PROVIDER
// ═══════════════════════════════════════════════════════
class DashboardProvider extends ChangeNotifier {
  final _api = ApiClient.instance;
  DashboardModel? _data;
  bool _isLoading = false;
  String? _error;

  DashboardModel? get data  => _data;
  bool get isLoading        => _isLoading;
  String? get error         => _error;

  Future<void> fetch() async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/dashboard');
      _data = DashboardModel.fromJson(r.data['data']);
    } catch (e) { _error = parseApiError(e); }
    _isLoading = false; notifyListeners();
  }
}

// ═══════════════════════════════════════════════════════
//  USER MANAGEMENT PROVIDER (khusus RW)
//  Kelola akun kader & warga: GET/POST /users, PATCH /users/:id/toggle
// ═══════════════════════════════════════════════════════
class UserManagementProvider extends ChangeNotifier {
  final _api = ApiClient.instance;
  List<UserModel> _list = [];
  PaginationModel? _pagination;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<UserModel> get list        => _list;
  PaginationModel? get pagination => _pagination;
  bool get isLoading              => _isLoading;
  bool get isSubmitting           => _isSubmitting;
  String? get error               => _error;

  Future<void> fetchAll({int page = 1, String? search, String? role}) async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/users', params: {
        'page': page, 'limit': AppConstants.defaultPageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null) 'role': role,
      });
      _list = (r.data['data'] as List).map((e) => UserModel.fromJson(e)).toList();
      if (r.data['pagination'] != null) _pagination = PaginationModel.fromJson(r.data['pagination']);
    } catch (e) { _error = parseApiError(e); }
    _isLoading = false; notifyListeners();
  }

  // role wajib 'kader' atau 'warga' (RW tidak membuat akun RW baru dari sini)
  Future<bool> createUser({
    required String nama,
    required String noHp,
    String? email,
    String? password,
    required String role,
  }) async {
    _isSubmitting = true; _error = null; notifyListeners();
    try {
      await _api.post('/users', data: {
        'nama': nama,
        'no_hp': noHp,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (password != null && password.trim().isNotEmpty) 'password': password.trim(),
        'role': role,
      });
      await fetchAll();
      _isSubmitting = false; notifyListeners();
      return true;
    } catch (e) {
      _error = parseApiError(e);
      _isSubmitting = false; notifyListeners();
      return false;
    }
  }

  Future<bool> toggleActive(String id) async {
    try {
      await _api.patch('/users/$id/toggle');
      await fetchAll();
      return true;
    } catch (e) { _error = parseApiError(e); notifyListeners(); return false; }
  }

  void clearError() { _error = null; notifyListeners(); }
}


class LaporanProvider extends ChangeNotifier {
  final _api = ApiClient.instance;
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _error;

  Map<String, dynamic>? get data  => _data;
  bool get isLoading              => _isLoading;
  bool get isExporting            => _isExporting;
  String? get error               => _error;

  Future<void> fetchBulanan(int bulan, int tahun) async {
    _isLoading = true; notifyListeners();
    try {
      final r = await _api.get('/laporan/bulanan', params: {'bulan': bulan, 'tahun': tahun});
      _data = r.data['data'];
    } catch (e) { _error = parseApiError(e); }
    _isLoading = false; notifyListeners();
  }

  // Export rekap bulanan (dari VIEW v_rekap_bulanan) ke file .xlsx.
  // `tahun = null` akan mengexport seluruh data yang ada di view (semua bulan).
  // Di mobile: file disimpan ke folder aplikasi (path dikembalikan, bisa
  // dibuka dengan open_filex). Di web: browser langsung memicu download,
  // path_provider TIDAK dipakai sama sekali karena tidak didukung di web.
  // Mengembalikan path/nama file jika berhasil, null jika gagal (lihat `error`).
  Future<String?> exportExcel({int? tahun}) async {
    _isExporting = true; _error = null; notifyListeners();
    String? savedPath;
    try {
      final response = await _api.downloadBytes(
        '/laporan/export/excel',
        params: tahun != null ? {'tahun': tahun} : null,
      );
      final bytes = response.data!;
      final suffix = tahun != null ? '_$tahun' : '_semua';
      final filename = 'rekap_bulanan$suffix.xlsx';
      savedPath = await file_saver.saveBytesAndGetPath(bytes, filename);
    } catch (e) {
      _error = parseApiError(e);
    }
    _isExporting = false; notifyListeners();
    return savedPath;
  }

  void clearError() { _error = null; notifyListeners(); }
}