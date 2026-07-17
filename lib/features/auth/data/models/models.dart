// ═══════════════════════════════════════
//  USER MODEL — 3 roles: rw, kader, warga
// ═══════════════════════════════════════
class UserModel {
  final String id;
  final String nama;
  final String? email;
  final String noHp;
  final String role; // 'rw' | 'kader' | 'warga'
  final bool isActive;
  final String? lastLogin;
  final String? createdAt;

  UserModel({required this.id, required this.nama, this.email, required this.noHp, required this.role, this.isActive = true, this.lastLogin, this.createdAt});

  bool get isRW    => role == 'rw';
  bool get isKader => role == 'kader';
  bool get isWarga => role == 'warga';
  bool get isAdmin => role == 'rw' || role == 'kader';
  String get roleLabel => {'rw':'RW (Admin)', 'kader':'Kader', 'warga':'Warga'}[role] ?? role;

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'], nama: j['nama'], email: j['email'], noHp: j['no_hp'],
    role: j['role'], isActive: j['is_active'] ?? true,
    lastLogin: j['last_login'], createdAt: j['created_at'],
  );
  Map<String, dynamic> toJson() => {'id':id,'nama':nama,'email':email,'no_hp':noHp,'role':role,'is_active':isActive};
}

// ═══════════════════════════════════════
//  WARGA MODEL
// ═══════════════════════════════════════
class WargaModel {
  final String id;
  final String userId;
  final String nik;
  final String? alamat;
  final String tanggalLahir;
  final String jenisKelamin; // 'L' | 'P'
  final String kategori;     // 'balita' | 'lansia'
  final String? namaOrangTua;
  final String? namaUser;
  final String? noHp;
  final String? namaVerifikator;
  final String? verifiedAt;
  final double? umurBulan;
  final double? umurTahun;
  final String? createdAt;

  WargaModel({required this.id, required this.userId, required this.nik, this.alamat, required this.tanggalLahir, required this.jenisKelamin, required this.kategori, this.namaOrangTua, this.namaUser, this.noHp, this.namaVerifikator, this.verifiedAt, this.umurBulan, this.umurTahun, this.createdAt});

  bool get sudahVerifikasi => verifiedAt != null;
  bool get isBalita  => kategori == 'balita';
  bool get isLansia  => kategori == 'lansia';
  String get jenisKelaminLabel => jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan';
  String get kategoriLabel => isBalita ? 'Balita' : 'Lansia';

  factory WargaModel.fromJson(Map<String, dynamic> j) => WargaModel(
    id: j['id'], userId: j['user_id'], nik: j['nik'],
    alamat: j['alamat'], tanggalLahir: j['tanggal_lahir'],
    jenisKelamin: j['jenis_kelamin'], kategori: j['kategori'],
    namaOrangTua: j['nama_orang_tua'], namaUser: j['nama_user'],
    noHp: j['no_hp'], namaVerifikator: j['nama_verifikator'],
    verifiedAt: j['verified_at'],
    umurBulan: j['umur_bulan'] != null ? (j['umur_bulan'] as num).toDouble() : null,
    umurTahun: j['umur_tahun'] != null ? (j['umur_tahun'] as num).toDouble() : null,
    createdAt: j['created_at'],
  );
}

// ═══════════════════════════════════════
//  JADWAL KEGIATAN MODEL
// ═══════════════════════════════════════
class JadwalModel {
  final String id;
  final String tanggal;
  final String jam;
  final String lokasi;
  final String jenisKegiatan; // 'posyandu' | 'posbindu'
  final String? keterangan;
  final String dibuatOleh;
  final String? namaPembuat;
  final int jumlahMenu;
  final String? createdAt;

  JadwalModel({required this.id, required this.tanggal, required this.jam, required this.lokasi, required this.jenisKegiatan, this.keterangan, required this.dibuatOleh, this.namaPembuat, this.jumlahMenu = 0, this.createdAt});

  bool get isPosyandu => jenisKegiatan == 'posyandu';
  bool get isPosbindu => jenisKegiatan == 'posbindu';
  String get jenisLabel => isPosyandu ? 'Posyandu' : 'Posbindu';

  factory JadwalModel.fromJson(Map<String, dynamic> j) => JadwalModel(
    id: j['id'], tanggal: j['tanggal'], jam: j['jam'],
    lokasi: j['lokasi'], jenisKegiatan: j['jenis_kegiatan'],
    keterangan: j['keterangan'], dibuatOleh: j['dibuat_oleh'],
    namaPembuat: j['nama_pembuat'],
    jumlahMenu: j['jumlah_menu'] != null ? (j['jumlah_menu'] as num).toInt() : 0,
    createdAt: j['created_at'],
  );
}

// ═══════════════════════════════════════
//  MENU PMT MODEL
// ═══════════════════════════════════════
class MenuPMTModel {
  final String id;
  final String jadwalId;
  final String namaMenu;
  final String? deskripsi;

  MenuPMTModel({required this.id, required this.jadwalId, required this.namaMenu, this.deskripsi});

  factory MenuPMTModel.fromJson(Map<String, dynamic> j) => MenuPMTModel(
    id: j['id'], jadwalId: j['jadwal_id'], namaMenu: j['nama_menu'], deskripsi: j['deskripsi'],
  );
}

// ═══════════════════════════════════════
//  KUNJUNGAN MODEL
// ═══════════════════════════════════════
class KunjunganModel {
  final String id;
  final String wargaId;
  final String jadwalId;
  final String dicatatOleh;
  final String waktuCheckin;
  final String statusPmt; // 'belum' | 'sudah'
  final String? waktuPmt;
  // Joined
  final String? namaWarga;
  final String? kategori;
  final String? tanggalLahir;
  final String? tanggalJadwal;
  final String? jenisKegiatan;
  final String? namaKader;
  final bool sudahDiperiksaBalita;
  final bool sudahDiperiksaPosbindu;
  final String? statusGizi;
  final String? statusTensi;
  final int? nomorUrut;
  final Map<String, bool>? progresMeja;

  KunjunganModel({required this.id, required this.wargaId, required this.jadwalId, required this.dicatatOleh, required this.waktuCheckin, required this.statusPmt, this.waktuPmt, this.namaWarga, this.kategori, this.tanggalLahir, this.tanggalJadwal, this.jenisKegiatan, this.namaKader, this.sudahDiperiksaBalita = false, this.sudahDiperiksaPosbindu = false, this.statusGizi, this.statusTensi, this.nomorUrut, this.progresMeja});

  bool get sudahPMT => statusPmt == 'sudah';

  factory KunjunganModel.fromJson(Map<String, dynamic> j) => KunjunganModel(
    id: j['id'] ?? j['kunjungan_id'], wargaId: j['warga_id'], jadwalId: j['jadwal_id'],
    dicatatOleh: j['dicatat_oleh'] ?? '', waktuCheckin: j['waktu_checkin'],
    statusPmt: j['status_pmt'], waktuPmt: j['waktu_pmt'],
    namaWarga: j['nama_warga'] ?? j['nama'], kategori: j['kategori'],
    tanggalLahir: j['tanggal_lahir'], tanggalJadwal: j['tanggal_jadwal'],
    jenisKegiatan: j['jenis_kegiatan'], namaKader: j['nama_kader'],
    sudahDiperiksaBalita: j['meja2_selesai'] ?? j['sudah_diperiksa_balita'] ?? false,
    sudahDiperiksaPosbindu: j['meja3_selesai'] ?? j['sudah_diperiksa_posbindu'] ?? false,
    statusGizi: j['status_gizi'], statusTensi: j['status_tensi'],
    nomorUrut: j['nomor_urut'] != null ? (j['nomor_urut'] as num).toInt() : null,
    progresMeja: j['progres_meja'] != null ? Map<String, bool>.from(j['progres_meja']) : null,
  );
}

// ═══════════════════════════════════════
//  PEMERIKSAAN BALITA MODEL
// ═══════════════════════════════════════
class PemeriksaanBalitaModel {
  final String id;
  final String kunjunganId;
  final double beratBadanKg;
  final double tinggiBadanCm;
  final double? lingkarKepalaCm;
  final bool vitaminA;
  final String? jenisImunisasi;
  final String? statusGizi;
  final String? dicatatOleh;
  // Analisis
  final int? umurBulan;
  final double? zScoreBBU;
  final double? zScoreTBU;
  final String? labelStatus;

  PemeriksaanBalitaModel({required this.id, required this.kunjunganId, required this.beratBadanKg, required this.tinggiBadanCm, this.lingkarKepalaCm, this.vitaminA = false, this.jenisImunisasi, this.statusGizi, this.dicatatOleh, this.umurBulan, this.zScoreBBU, this.zScoreTBU, this.labelStatus});

  factory PemeriksaanBalitaModel.fromJson(Map<String, dynamic> j) {
    final p = j['pemeriksaan'] ?? j;
    final a = j['analisis'];
    return PemeriksaanBalitaModel(
      id: p['id'], kunjunganId: p['kunjungan_id'],
      beratBadanKg: (p['berat_badan_kg'] as num).toDouble(),
      tinggiBadanCm: (p['tinggi_badan_cm'] as num).toDouble(),
      lingkarKepalaCm: p['lingkar_kepala_cm'] != null ? (p['lingkar_kepala_cm'] as num).toDouble() : null,
      vitaminA: p['vitamin_a'] ?? false,
      jenisImunisasi: p['jenis_imunisasi'],
      statusGizi: p['status_gizi'],
      dicatatOleh: p['dicatat_oleh'],
      umurBulan: a != null ? a['umurBulan'] : null,
      zScoreBBU: a != null && a['zScoreBBU'] != null ? (a['zScoreBBU'] as num).toDouble() : null,
      zScoreTBU: a != null && a['zScoreTBU'] != null ? (a['zScoreTBU'] as num).toDouble() : null,
      labelStatus: a != null ? a['label'] : null,
    );
  }
}

// ═══════════════════════════════════════
//  PEMERIKSAAN POSBINDU MODEL
// ═══════════════════════════════════════
class PemeriksaanPosbinduModel {
  final String id;
  final String kunjunganId;
  final double beratBadanKg;
  final int tensiSistol;
  final int tensiDiastol;
  final String? keluhan;
  final String? faktorRisikoPtm;
  final String? statusTensi;
  final String? labelStatus;

  PemeriksaanPosbinduModel({required this.id, required this.kunjunganId, required this.beratBadanKg, required this.tensiSistol, required this.tensiDiastol, this.keluhan, this.faktorRisikoPtm, this.statusTensi, this.labelStatus});

  factory PemeriksaanPosbinduModel.fromJson(Map<String, dynamic> j) {
    final p = j['pemeriksaan'] ?? j;
    final a = j['analisis'];
    return PemeriksaanPosbinduModel(
      id: p['id'], kunjunganId: p['kunjungan_id'],
      beratBadanKg: (p['berat_badan_kg'] as num).toDouble(),
      tensiSistol: (p['tensi_sistol'] as num).toInt(),
      tensiDiastol: (p['tensi_diastol'] as num).toInt(),
      keluhan: p['keluhan'], faktorRisikoPtm: p['faktor_risiko_ptm'],
      statusTensi: p['status_tensi'],
      labelStatus: a != null ? a['label'] : null,
    );
  }
}

// ═══════════════════════════════════════
//  DASHBOARD MODEL
// ═══════════════════════════════════════
class DashboardModel {
  final int totalBalita;
  final int totalLansia;
  final int totalKader;
  final int kunjunganBulanIni;
  final int wargaBelumVerifikasi;
  final List<JadwalModel> jadwalMendatang;
  final Map<String, dynamic>? rekapBulanIni;

  DashboardModel({required this.totalBalita, required this.totalLansia, required this.totalKader, required this.kunjunganBulanIni, required this.wargaBelumVerifikasi, required this.jadwalMendatang, this.rekapBulanIni});

  factory DashboardModel.fromJson(Map<String, dynamic> j) {
    final s = j['statistik'] ?? {};
    return DashboardModel(
      totalBalita: s['totalBalita'] ?? 0, totalLansia: s['totalLansia'] ?? 0,
      totalKader: s['totalKader'] ?? 0, kunjunganBulanIni: s['kunjunganBulanIni'] ?? 0,
      wargaBelumVerifikasi: s['wargaBelumVerifikasi'] ?? 0,
      jadwalMendatang: (j['jadwalMendatang'] as List? ?? []).map((e) => JadwalModel.fromJson(e)).toList(),
      rekapBulanIni: j['rekapBulanIni'],
    );
  }
}

// ═══════════════════════════════════════
//  PAGINATION MODEL
// ═══════════════════════════════════════
class PaginationModel {
  final int total, page, limit, totalPages;
  PaginationModel({required this.total, required this.page, required this.limit, required this.totalPages});
  factory PaginationModel.fromJson(Map<String, dynamic> j) => PaginationModel(
    total: j['total'] ?? 0, page: j['page'] ?? 1, limit: j['limit'] ?? 10, totalPages: j['totalPages'] ?? 1,
  );
}
