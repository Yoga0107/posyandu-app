import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────────────────────
  // API
  // ─────────────────────────────────────────────────────────────

  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web (Chrome)
      return 'http://127.0.0.1:3000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:3000/api';
  }

  static String get uploadBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:3000';
    }

    // Android Emulator
    return 'http://10.0.2.2:3000';
  }

  // ─────────────────────────────────────────────────────────────
  // Storage Keys
  // ─────────────────────────────────────────────────────────────

  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // ─────────────────────────────────────────────────────────────
  // Timeouts
  // ─────────────────────────────────────────────────────────────

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // ─────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────

  static const int defaultPageSize = 15;

  // ─────────────────────────────────────────────────────────────
  // App Info
  // ─────────────────────────────────────────────────────────────

  static const String appName = 'POS Yandu';
  static const String appVersion = '2.0.0';

  // ─────────────────────────────────────────────────────────────
  // Jenis Kegiatan
  // ─────────────────────────────────────────────────────────────

  static const Map<String, String> jenisKegiatan = {
    'posyandu': 'Posyandu (Balita)',
    'posbindu': 'Posbindu (Lansia)',
  };

  // ─────────────────────────────────────────────────────────────
  // Status Gizi
  // ─────────────────────────────────────────────────────────────

  static const Map<String, String> labelStatusGizi = {
    'normal': 'Normal',
    'stunting': 'Stunting (Pendek)',
    'underweight': 'Berat Badan Kurang',
    'overweight': 'Berat Badan Lebih',
    'gizi-buruk': 'Gizi Buruk',
  };

  // Alias untuk backward compatibility
  static const Map<String, String> statusGiziLabel = labelStatusGizi;

  // ─────────────────────────────────────────────────────────────
  // Status Tensi
  // ─────────────────────────────────────────────────────────────

  static const Map<String, String> labelStatusTensi = {
    'normal': 'Normal',
    'pra-hipertensi': 'Pra-Hipertensi',
    'hipertensi-1': 'Hipertensi Tingkat 1',
    'hipertensi-2': 'Hipertensi Tingkat 2',
  };

  // ─────────────────────────────────────────────────────────────
  // Faktor Risiko PTM
  // ─────────────────────────────────────────────────────────────

  static const List<String> faktorRisikoPTM = [
    'Obesitas',
    'Merokok',
    'Kurang aktivitas fisik',
    'Diabetes',
    'Hiperkolesterol',
    'Riwayat jantung',
    'Riwayat stroke',
  ];

  // ─────────────────────────────────────────────────────────────
  // Daftar Imunisasi
  // ─────────────────────────────────────────────────────────────

  static const List<String> daftarImunisasi = [
    'HB0',
    'BCG',
    'Polio 1',
    'Polio 2',
    'Polio 3',
    'Polio 4',
    'DPT-HB-Hib 1',
    'DPT-HB-Hib 2',
    'DPT-HB-Hib 3',
    'DPT-HB-Hib Booster',
    'MR (Campak Rubella)',
    'IPV',
    'PCV 1',
    'PCV 2',
  ];

  // ─────────────────────────────────────────────────────────────
  // Lokasi Default
  // ─────────────────────────────────────────────────────────────

  static const String lokasiDefault = 'Posyandu Bunga Melur RW 05';
}