# 📱 POS Yandu — Flutter Frontend

Aplikasi mobile Posyandu berbasis **Flutter** yang terintegrasi penuh dengan backend Node.js.

---

## 🎨 Desain & Tema

| Elemen | Warna |
|---|---|
| Primary (biru) | `#1565C0` — `#1E88E5` |
| Accent (hijau) | `#2E7D32` — `#43A047` |
| Highlight (oranye) | `#E65100` — `#FF7043` |
| Background | `#F0F4FF` |

---

## 🛠️ Tech Stack

| Layer | Library |
|---|---|
| State Management | Provider 6.x |
| HTTP Client | Dio 5.x + Interceptor JWT |
| Storage | SharedPreferences + flutter_secure_storage |
| UI | Google Fonts (Poppins) + Material 3 |
| Chart | fl_chart |
| Image | cached_network_image + image_picker |
| Loading | shimmer |

---

## 📁 Struktur Folder

```
lib/
├── main.dart                          # Entry point + Provider setup
├── splash_screen.dart                 # Splash + auto-login check
├── core/
│   ├── api/
│   │   └── api_client.dart            # Dio + JWT interceptor + refresh token
│   ├── constants/
│   │   └── app_constants.dart         # Base URL, keys, labels
│   ├── theme/
│   │   └── app_theme.dart             # Colors, ThemeData
│   ├── utils/
│   │   ├── app_router.dart            # Named routes
│   │   └── providers.dart             # Semua ChangeNotifier providers
│   └── widgets/
│       └── app_widgets.dart           # Reusable widgets
└── features/
    ├── auth/
    │   ├── data/models/models.dart     # Semua model data
    │   └── presentation/
    │       ├── auth_provider.dart      # Login/register/logout state
    │       └── screens/
    │           ├── login_screen.dart
    │           └── register_screen.dart
    └── dashboard/
        └── presentation/screens/
            └── home_screen.dart        # HomeScreen + semua tab screens
```

---

## 🚀 Cara Setup & Jalankan

### 1. Pastikan Flutter terinstall
```bash
flutter --version  # minimal 3.10.0
```

### 2. Install dependencies
```bash
cd posyandu_app
flutter pub get
```

### 3. Konfigurasi URL API

Edit `lib/core/constants/app_constants.dart`:

```dart
// Android Emulator (default):
static const String baseUrl = 'http://10.0.2.2:3000/api';

// iOS Simulator:
static const String baseUrl = 'http://localhost:3000/api';

// Physical Device (ganti dengan IP komputer Anda):
static const String baseUrl = 'http://192.168.x.x:3000/api';
```

Cek IP komputer:
- Windows: `ipconfig`
- Mac/Linux: `ifconfig` atau `ip addr`

### 4. Pastikan backend sudah berjalan
```bash
cd posyandu-backend
npm run dev   # server harus aktif di port 3000
```

### 5. Jalankan Flutter app
```bash
# Android emulator
flutter run

# iOS simulator
flutter run -d iPhone

# Physical device (USB)
flutter run --release
```

---

## 👤 Akun Test

| Role | Email | Password |
|---|---|---|
| Admin | admin@posyandu.com | Admin@123 |
| Warga | siti@gmail.com | Warga@123 |

---

## 📱 Fitur per Role

### 👑 Admin
| Fitur | Keterangan |
|---|---|
| Dashboard | Statistik, grafik, aktivitas terbaru |
| Data Balita | Lihat semua balita, CRUD, detail |
| Penimbangan | Rekam hasil timbang + kalkulasi Z-Score otomatis |
| Jadwal | Buat/edit/hapus jadwal kegiatan |
| Notifikasi | Kirim broadcast / personal |
| Artikel | Buat artikel edukasi kesehatan |
| Laporan | Rekap bulanan, distribusi gizi |
| Manajemen User | Aktif/nonaktifkan akun warga |

### 👤 Warga
| Fitur | Keterangan |
|---|---|
| Beranda | Ringkasan balita & jadwal mendatang |
| Balita Saya | Daftar & detail balita miliknya |
| Grafik Tumbuh Kembang | Histori berat/tinggi badan |
| Jadwal Posyandu | Lihat jadwal mendatang |
| Artikel Edukasi | Baca artikel kesehatan |
| Notifikasi | Terima pengumuman & peringatan gizi |
| Profil | Edit profil, ganti password |

---

## 🔗 Integrasi Backend

Semua request melalui `ApiClient` (`Dio`) dengan:
- **JWT Bearer Token** otomatis disertakan di setiap request
- **Auto Refresh Token** — jika access token expired (401), refresh token digunakan otomatis tanpa logout paksa
- **Error Handling** — format error seragam dari backend (`{status, message, errors}`)

---

## 🎓 Catatan untuk Skripsi

Beberapa fitur menarik yang bisa dibahas di skripsi:

1. **Kalkulasi Z-Score WHO 2006** — Status gizi dihitung otomatis di backend menggunakan tabel referensi standar WHO
2. **Dual Role System** — Role Admin (petugas) dan Warga dengan hak akses berbeda di setiap endpoint
3. **JWT Refresh Token** — Mekanisme token yang aman dengan auto-refresh tanpa re-login
4. **Auto Notifikasi Gizi** — Backend secara otomatis mengirim notifikasi ke orang tua jika status gizi kurang/buruk
5. **Provider Pattern** — State management yang clean dengan ChangeNotifier
6. **RESTful API Design** — Standar response format, pagination, dan filter parameter

---

## 🐛 Troubleshooting

| Masalah | Solusi |
|---|---|
| `Connection refused` | Pastikan backend jalan & URL API benar |
| `SocketException` | Cek IP device dan firewall |
| `401 Unauthorized` | Token expired, coba logout & login ulang |
| `Image not loading` | Cek `uploadBaseUrl` di `app_constants.dart` |
| Build error | Jalankan `flutter clean && flutter pub get` |
