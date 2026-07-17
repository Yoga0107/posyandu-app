class AppConstants {
  // ─── API ───
  static const String baseUrl       = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl    = 'http://localhost:3000/api'; // iOS simulator
  // static const String baseUrl    = 'http://YOUR_IP:3000/api';   // Physical device
  static const String uploadBaseUrl = 'http://10.0.2.2:3000';

  // ─── Storage Keys ───
  static const String tokenKey        = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey         = 'user_data';
  static const String roleKey         = 'user_role';

  // ─── Timeouts ───
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // ─── Pagination ───
  static const int defaultPageSize = 15;

  // ─── App Info ───
  static const String appName    = 'POS Yandu';
  static const String appVersion = '2.0.0';

  // ─── Jenis Kegiatan ───
  static const Map<String, String> jenisKegiatan = {
    'posyandu': 'Posyandu (Balita)',
    'posbindu': 'Posbindu (Lansia)',
  };

  // ─── Status Gizi ───
  static const Map<String, String> labelStatusGizi = {
    // Ryan ERD codes
    'normal':      'Normal',
    'stunting':    'Stunting (Pendek)',
    'underweight': 'Berat Badan Kurang',
    'overweight':  'Berat Badan Lebih',
    'gizi-buruk':  'Gizi Buruk',
  };

  // Alias untuk backward compat
  static const Map<String, String> statusGiziLabel = {
    'normal':      'Normal',
    'stunting':    'Stunting (Pendek)',
    'underweight': 'Berat Badan Kurang',
    'overweight':  'Berat Badan Lebih',
    'gizi-buruk':  'Gizi Buruk',
  };

  // ─── Status Tensi ───
  static const Map<String, String> labelStatusTensi = {
    'normal':          'Normal',
    'pra-hipertensi':  'Pra-Hipertensi',
    'hipertensi-1':    'Hipertensi Tingkat 1',
    'hipertensi-2':    'Hipertensi Tingkat 2',
  };

  // ─── Faktor Risiko PTM ───
  static const List<String> faktorRisikoPTM = [
    'Obesitas', 'Merokok', 'Kurang aktivitas fisik',
    'Diabetes', 'Hiperkolesterol', 'Riwayat jantung',
    'Riwayat stroke',
  ];

  // ─── Daftar Imunisasi ───
  static const List<String> daftarImunisasi = [
    'HB0', 'BCG', 'Polio 1', 'Polio 2', 'Polio 3', 'Polio 4',
    'DPT-HB-Hib 1', 'DPT-HB-Hib 2', 'DPT-HB-Hib 3',
    'DPT-HB-Hib Booster', 'MR (Campak Rubella)', 'IPV', 'PCV 1', 'PCV 2',
  ];

  // ─── Lokasi Default ───
  static const String lokasiDefault = 'Posyandu Bunga Melur RW 05';
}
