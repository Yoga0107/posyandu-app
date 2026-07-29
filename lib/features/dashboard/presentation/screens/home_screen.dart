// ═══════════════════════════════════════════════════════════════
//  CATATAN PERBAIKAN:
//  File ini semula memakai model & provider yang TIDAK ADA di
//  project (BalitaModel, PenimbanganModel, NotifikasiProvider, dst)
//  — sisa dari controller backend lama yang sudah mati (tidak
//  terdaftar di routes/index.routes.js). Ditulis ulang total supaya
//  memakai WargaModel/JadwalModel/KunjunganModel/DashboardModel dan
//  WargaProvider/JadwalProvider/KunjunganProvider/PemeriksaanProvider
//  /DashboardProvider/LaporanProvider dari core/utils/providers.dart,
//  yang sudah dicocokkan dengan endpoint backend yang aktif.
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:posyandu_app/features/auth/presentation/screens/formulir_kartu_bantu_screen.dart';
import 'package:posyandu_app/features/auth/presentation/screens/jadwal_kalender_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../auth/data/models/models.dart';
import '../../../auth/presentation/screens/register_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/providers.dart';
import '../../../../core/constants/app_constants.dart';
import 'user_management_screen.dart';


String _fmtTanggal(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    final d = DateTime.parse(iso);
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(d);
  } catch (_) {
    return iso;
  }
}

/// Format singkat untuk label sumbu-x pada grafik (mis. "12 Jul").
String _fmtTanggalSingkat(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    final d = DateTime.parse(iso);
    return DateFormat('d MMM', 'id_ID').format(d);
  } catch (_) {
    return iso;
  }
}

/// Hitung umur dari tanggal lahir. Balita ditampilkan dalam bulan (atau
/// "X thn Y bln" kalau sudah lebih dari setahun), lansia/dewasa dalam tahun.
String hitungUmur(String? tanggalLahirIso, {bool isBalita = true}) {
  if (tanggalLahirIso == null || tanggalLahirIso.isEmpty) return '-';
  try {
    final lahir = DateTime.parse(tanggalLahirIso);
    final now = DateTime.now();
    int totalBulan = (now.year - lahir.year) * 12 + (now.month - lahir.month);
    if (now.day < lahir.day) totalBulan--;
    if (totalBulan < 0) totalBulan = 0;

    if (isBalita) {
      if (totalBulan < 12) return '$totalBulan bulan';
      final tahun = totalBulan ~/ 12;
      final sisaBulan = totalBulan % 12;
      return sisaBulan == 0 ? '$tahun tahun' : '$tahun thn $sisaBulan bln';
    } else {
      final tahun = totalBulan ~/ 12;
      return '$tahun tahun';
    }
  } catch (_) {
    return '-';
  }
}

// ═══════════════════════════════════════
//  HOME SHELL (bottom navigation)
// ═══════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdminLevel;

    final screens = isAdmin
        ? const [_AdminDashboardTab(), _WargaTab(), _JadwalTab(), _ProfileTab()]
        : const [_WargaHomeTab(), _JadwalTab(), _ProfileTab()];

    final items = isAdmin
        ? const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded), label: 'Warga'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profil'),
          ]
        : const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profil'),
          ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: items,
      ),
    );
  }
}

// ═══════════════════════════════════════
//  ADMIN DASHBOARD TAB
// ═══════════════════════════════════════
class _AdminDashboardTab extends StatefulWidget {
  const _AdminDashboardTab();
  @override
  State<_AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<_AdminDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<DashboardProvider>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().fetch(),
        child: CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('Halo, ${user?.nama ?? '-'}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(user?.roleLabel ?? '',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ]),
                  ),
                ),
              ),
            ),
            title: const Text('Dashboard'),
            actions: [
              if (user?.isRW == true)
                IconButton(
                  icon: const Icon(Icons.manage_accounts_rounded),
                  tooltip: 'Manajemen Pengguna',
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                ),
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded),
                tooltip: 'Laporan Bulanan',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LaporanScreen())),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Consumer<DashboardProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading && provider.data == null) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerList(count: 3, itemHeight: 90));
                }
                final data = provider.data;
                if (data == null) {
                  return EmptyState(
                      title: 'Gagal memuat dashboard',
                      subtitle: provider.error,
                      onRetry: () => provider.fetch());
                }
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            StatCard(
                                label: 'Total Balita',
                                value: '${data.totalBalita}',
                                icon: Icons.child_care_rounded,
                                color: AppColors.primary),
                            StatCard(
                                label: 'Total Lansia',
                                value: '${data.totalLansia}',
                                icon: Icons.elderly,
                                color: AppColors.accent),
                            StatCard(
                                label: 'Kunjungan Bulan Ini',
                                value: '${data.kunjunganBulanIni}',
                                icon: Icons.event_available_rounded,
                                color: AppColors.orange),
                            StatCard(
                                label: 'Belum Terverifikasi',
                                value: '${data.wargaBelumVerifikasi}',
                                icon: Icons.verified_user_outlined,
                                color: AppColors.statusBuruk),
                          ],
                        ),
                      ),
                      const SectionHeader(title: 'Jadwal Mendatang'),
                      if (data.jadwalMendatang.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Tidak ada jadwal mendatang',
                              style: TextStyle(color: AppColors.textSecondary)),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: data.jadwalMendatang.length,
                          itemBuilder: (_, i) =>
                              _JadwalCard(jadwal: data.jadwalMendatang[i]),
                        ),
                      const SizedBox(height: 24),
                    ]);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  WARGA TAB (admin/kader) & WARGA CARD
// ═══════════════════════════════════════
class _WargaTab extends StatefulWidget {
  const _WargaTab();
  @override
  State<_WargaTab> createState() => _WargaTabState();
}

class _WargaTabState extends State<_WargaTab> {
  final _searchCtrl = TextEditingController();
  String? _kategoriFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<WargaProvider>().fetchAll());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String v) => context
      .read<WargaProvider>()
      .fetchAll(search: v, kategori: _kategoriFilter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Warga')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()));
          if (added == true && mounted)
            context.read<WargaProvider>().fetchAll();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Cari nama / NIK...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchCtrl.clear();
                        _search('');
                      })
                  : null,
            ),
            onSubmitted: _search,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _filterChip(null, 'Semua'),
            const SizedBox(width: 8),
            _filterChip('balita', 'Balita'),
            const SizedBox(width: 8),
            _filterChip('lansia', 'Lansia'),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Consumer<WargaProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) return const ShimmerList(count: 6);
              if (provider.list.isEmpty) {
                return EmptyState(
                    title: 'Belum ada data warga',
                    onRetry: () => provider.fetchAll());
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.list.length,
                itemBuilder: (_, i) => _WargaCard(warga: provider.list[i]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _filterChip(String? value, String label) {
    final selected = _kategoriFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _kategoriFilter = value);
        context
            .read<WargaProvider>()
            .fetchAll(search: _searchCtrl.text, kategori: value);
      },
    );
  }
}

class _WargaCard extends StatelessWidget {
  final WargaModel warga;
  const _WargaCard({required this.warga});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => WargaDetailScreen(wargaId: warga.id))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: warga.isBalita
                  ? AppColors.primaryLighter
                  : AppColors.accentLighter,
              child: Icon(
                  warga.isBalita ? Icons.child_care_rounded : Icons.elderly,
                  color: warga.isBalita ? AppColors.primary : AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(warga.namaTampilan,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('NIK: ${warga.nik}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    if (warga.namaUser != null) ...[
                      const SizedBox(height: 2),
                      Text('Akun warga: ${warga.namaUser}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(warga.kategoriLabel,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint)),
                      const SizedBox(width: 8),
                      if (!warga.sudahVerifikasi)
                        const Text('Belum diverifikasi',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600)),
                    ]),
                  ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ]),
        ),
      ),
    );
  }
}

class WargaDetailScreen extends StatefulWidget {
  final String wargaId;
  const WargaDetailScreen({super.key, required this.wargaId});
  @override
  State<WargaDetailScreen> createState() => _WargaDetailScreenState();
}

class _WargaDetailScreenState extends State<WargaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WargaProvider>().fetchById(widget.wargaId);
      context.read<WargaProvider>().fetchGrafik(widget.wargaId);
    });
  }

  Future<void> _verify() async {
    final ok = await context.read<WargaProvider>().verify(widget.wargaId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          ok ? 'Data warga berhasil diverifikasi' : 'Gagal memverifikasi data'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdminLevel;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Warga')),
      body: Consumer<WargaProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading && provider.selected == null) {
            return const Padding(
                padding: EdgeInsets.all(16), child: ShimmerList(count: 4));
          }
          final w = provider.selected;
          if (w == null) {
            return EmptyState(
                title: 'Data tidak ditemukan',
                onRetry: () => provider.fetchById(widget.wargaId));
          }
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: w.isBalita
                              ? AppColors.primaryLighter
                              : AppColors.accentLighter,
                          child: Icon(
                              w.isBalita
                                  ? Icons.child_care_rounded
                                  : Icons.elderly,
                              size: 28,
                              color: w.isBalita
                                  ? AppColors.primary
                                  : AppColors.accent),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w.namaTampilan,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                                Text(w.kategoriLabel,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ]),
                        ),
                      ]),
                      const Divider(height: 24),
                      _row('NIK', w.nik),
                      _row('Tanggal Lahir', w.tanggalLahir),
                      _row('Jenis Kelamin', w.jenisKelaminLabel),
                      if (w.namaOrangTua != null)
                        _row('Orang Tua/Wali', w.namaOrangTua!),
                      if (w.alamat != null) _row('Alamat', w.alamat!),
                      if (w.noHp != null) _row('No. HP', w.noHp!),
                      if (w.namaUser != null) _row('Akun Warga', w.namaUser!),
                      _row(
                          'Status',
                          w.sudahVerifikasi
                              ? 'Terverifikasi oleh ${w.namaVerifikator ?? '-'}'
                              : 'Belum diverifikasi'),
                    ]),
              ),
            ),
            if (isAdmin && !w.sudahVerifikasi) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : _verify,
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Verifikasi Data Ini'),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SectionHeader(
                title: w.isBalita ? 'Grafik Tumbuh Kembang' : 'Grafik Tekanan Darah'),
            _GrafikTumbuhKembang(grafik: provider.grafik, isBalita: w.isBalita),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Riwayat Kunjungan'),
            if (provider.riwayat.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('Belum ada riwayat kunjungan',
                    style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              ...provider.riwayat.map((r) => Card(
                    child: ListTile(
                      leading: Icon(
                        r['jenis_kegiatan'] == 'posyandu'
                            ? Icons.child_care_rounded
                            : Icons.elderly,
                        color: AppColors.primary,
                      ),
                      title: Text(_fmtTanggal(r['tanggal']?.toString())),
                      subtitle: Text(r['status_gizi'] != null
                          ? 'Gizi: ${AppConstants.statusGiziLabel[r['status_gizi']] ?? r['status_gizi']}'
                          : r['status_tensi'] != null
                              ? 'Tensi: ${AppConstants.labelStatusTensi[r['status_tensi']] ?? r['status_tensi']}'
                              : (r['status_kehadiran'] == 'terdaftar'
                                  ? 'Menunggu check-in'
                                  : 'Sudah check-in, belum diperiksa')),
                      trailing: Text(
                        r['status_pmt'] == 'sudah' ? 'PMT ✓' : '',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.success),
                      ),
                    ),
                  )),
          ]);
        },
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 130,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary))),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
//  GRAFIK TUMBUH KEMBANG (balita: BB/TB) & GRAFIK TENSI (lansia)
//  Dipakai di WargaDetailScreen sebagai bagian dari use case
//  "Lihat Riwayat & Grafik Tumbuh Kembang" — sumber data dari
//  GET /api/warga/:id/grafik (lihat WargaProvider.fetchGrafik &
//  warga.controller.js `getGrafik`).
// ═══════════════════════════════════════════════════════════════
class _GrafikTumbuhKembang extends StatelessWidget {
  final List<dynamic> grafik;
  final bool isBalita;
  const _GrafikTumbuhKembang({required this.grafik, required this.isBalita});

  double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());

  @override
  Widget build(BuildContext context) {
    if (grafik.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.show_chart_rounded, color: AppColors.textHint),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                grafik.isEmpty
                    ? 'Grafik akan muncul setelah warga pernah diperiksa di Meja 2/3'
                    : 'Grafik akan muncul setelah minimal 2 kali pemeriksaan',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ]),
        ),
      );
    }
    return isBalita ? _buildBalita() : _buildLansia();
  }

  Widget _buildBalita() {
    final tanggal = grafik.map((e) => _fmtTanggalSingkat(e['tanggal']?.toString())).toList();

    final bbSpots = <FlSpot>[];
    final bbColors = <Color>[];
    final tbSpots = <FlSpot>[];
    final tbColors = <Color>[];
    for (var i = 0; i < grafik.length; i++) {
      final e = grafik[i];
      final warna = AppColors.statusGiziColor(e['status_gizi']?.toString());
      final b = _num(e['berat_badan_kg']);
      if (b != null) { bbSpots.add(FlSpot(i.toDouble(), b)); bbColors.add(warna); }
      final t = _num(e['tinggi_badan_cm']);
      if (t != null) { tbSpots.add(FlSpot(i.toDouble(), t)); tbColors.add(warna); }
    }

    final terakhir = grafik.last;
    final sebelumnya = grafik[grafik.length - 2];
    final deltaBB = (_num(terakhir['berat_badan_kg']) ?? 0) - (_num(sebelumnya['berat_badan_kg']) ?? 0);
    final deltaTB = (_num(terakhir['tinggi_badan_cm']) ?? 0) - (_num(sebelumnya['tinggi_badan_cm']) ?? 0);

    return Column(children: [
      Row(children: [
        Expanded(
            child: _ringkasanTren('Berat Badan',
                '${_num(terakhir['berat_badan_kg'])?.toStringAsFixed(1) ?? '-'} kg', deltaBB, 'kg')),
        const SizedBox(width: 10),
        Expanded(
            child: _ringkasanTren('Tinggi Badan',
                '${_num(terakhir['tinggi_badan_cm'])?.toStringAsFixed(1) ?? '-'} cm', deltaTB, 'cm')),
      ]),
      const SizedBox(height: 10),
      _chartCard('Berat Badan (kg)', bbSpots, bbColors, tanggal),
      const SizedBox(height: 12),
      _chartCard('Tinggi Badan (cm)', tbSpots, tbColors, tanggal),
      const SizedBox(height: 8),
      _legendStatusGizi(),
    ]);
  }

  Widget _buildLansia() {
    final tanggal = grafik.map((e) => _fmtTanggalSingkat(e['tanggal']?.toString())).toList();
    final sistol = <FlSpot>[];
    final diastol = <FlSpot>[];
    for (var i = 0; i < grafik.length; i++) {
      final e = grafik[i];
      final s = _num(e['tensi_sistol']);
      if (s != null) sistol.add(FlSpot(i.toDouble(), s));
      final d = _num(e['tensi_diastol']);
      if (d != null) diastol.add(FlSpot(i.toDouble(), d));
    }

    final terakhir = grafik.last;
    final sebelumnya = grafik[grafik.length - 2];
    final deltaSistol = (_num(terakhir['tensi_sistol']) ?? 0) - (_num(sebelumnya['tensi_sistol']) ?? 0);

    return Column(children: [
      _ringkasanTren(
        'Tekanan Darah Terakhir',
        '${_num(terakhir['tensi_sistol'])?.toStringAsFixed(0) ?? '-'}/${_num(terakhir['tensi_diastol'])?.toStringAsFixed(0) ?? '-'} mmHg',
        deltaSistol,
        'mmHg',
      ),
      const SizedBox(height: 10),
      _tensiChartCard(sistol, diastol, tanggal),
    ]);
  }

  Widget _ringkasanTren(String label, String nilaiTerkini, double delta, String satuan) {
    final naik = delta > 0.05;
    final turun = delta < -0.05;
    final warna = naik ? AppColors.info : (turun ? AppColors.orange : AppColors.textSecondary);
    final ikon = naik
        ? Icons.arrow_upward_rounded
        : (turun ? Icons.arrow_downward_rounded : Icons.remove_rounded);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(nilaiTerkini,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(ikon, size: 13, color: warna),
            const SizedBox(width: 3),
            Text('${delta.abs().toStringAsFixed(1)} $satuan dari sebelumnya',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: warna)),
          ]),
        ]),
      ),
    );
  }

  Widget _chartCard(String title, List<FlSpot> spots, List<Color> dotColors, List<String> tanggalLabels) {
    if (spots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Belum ada data $title', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
      );
    }
    final ys = spots.map((s) => s.y).toList();
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final range = (maxY - minY).abs();
    final pad = range < 1 ? 1.0 : range * 0.25;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(LineChartData(
              minY: (minY - pad).clamp(0, double.infinity).toDouble(),
              maxY: maxY + pad,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => const FlLine(color: AppColors.divider, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 9, color: AppColors.textHint)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= tanggalLabels.length) return const SizedBox.shrink();
                      final step = tanggalLabels.length > 6 ? (tanggalLabels.length / 5).ceil() : 1;
                      if (i % step != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(tanggalLabels[i],
                            style: const TextStyle(fontSize: 9, color: AppColors.textHint)),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touched) => touched
                      .map((s) => LineTooltipItem(s.y.toStringAsFixed(1),
                          const TextStyle(color: Colors.white, fontSize: 11)))
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 4,
                      color: index < dotColors.length ? dotColors[index] : AppColors.primary,
                      strokeWidth: 1.5,
                      strokeColor: AppColors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.08)),
                ),
              ],
            )),
          ),
        ]),
      ),
    );
  }

  Widget _tensiChartCard(List<FlSpot> sistol, List<FlSpot> diastol, List<String> tanggalLabels) {
    final allY = [...sistol.map((s) => s.y), ...diastol.map((s) => s.y), 140.0, 90.0];
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
              child: Text('Tekanan Darah (mmHg)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            _legendDot(AppColors.statusBuruk, 'Sistol'),
            const SizedBox(width: 10),
            _legendDot(AppColors.primary, 'Diastol'),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: LineChart(LineChartData(
              minY: (minY - 10).clamp(0, double.infinity).toDouble(),
              maxY: maxY + 10,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => const FlLine(color: AppColors.divider, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 9, color: AppColors.textHint)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= tanggalLabels.length) return const SizedBox.shrink();
                      final step = tanggalLabels.length > 6 ? (tanggalLabels.length / 5).ceil() : 1;
                      if (i % step != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(tanggalLabels[i],
                            style: const TextStyle(fontSize: 9, color: AppColors.textHint)),
                      );
                    },
                  ),
                ),
              ),
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: 140,
                  color: AppColors.statusBuruk.withOpacity(0.5),
                  strokeWidth: 1,
                  dashArray: const [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: const TextStyle(fontSize: 9, color: AppColors.statusBuruk),
                    labelResolver: (_) => 'Sistol >140',
                  ),
                ),
                HorizontalLine(
                  y: 90,
                  color: AppColors.primary.withOpacity(0.5),
                  strokeWidth: 1,
                  dashArray: const [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.bottomRight,
                    style: const TextStyle(fontSize: 9, color: AppColors.primary),
                    labelResolver: (_) => 'Diastol >90',
                  ),
                ),
              ]),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touched) => touched
                      .map((s) => LineTooltipItem(s.y.toStringAsFixed(0),
                          const TextStyle(color: Colors.white, fontSize: 11)))
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: sistol,
                  isCurved: true,
                  color: AppColors.statusBuruk,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: diastol,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            )),
          ),
        ]),
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]);

  Widget _legendStatusGizi() {
    const kode = ['normal', 'underweight', 'stunting', 'overweight'];
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: kode
          .map((k) => _legendDot(AppColors.statusGiziColor(k), AppConstants.statusGiziLabel[k] ?? k))
          .toList(),
    );
  }
}

// ═══════════════════════════════════════
//  JADWAL TAB, FORM, DETAIL (TRANSAKSI)
// ═══════════════════════════════════════
class _JadwalTab extends StatefulWidget {
  const _JadwalTab();
  @override
  State<_JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<_JadwalTab> {
  String? _jenisFilter;
  bool _upcomingOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() => context
      .read<JadwalProvider>()
      .fetchAll(jenis: _jenisFilter, upcoming: _upcomingOnly);

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdminLevel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kegiatan'),
        actions: [
          IconButton(
            tooltip: 'Lihat Kalender',
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const JadwalKalenderScreen()));
              // JadwalProvider dipakai bersama (shared state) — kembalikan
              // ke filter tab ini (mis. "Mendatang"/jenis) setelah kembali
              // dari kalender, karena kalender memuat semua data tanpa filter.
              if (mounted) _load();
            },
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const JadwalFormScreen()));
                if (created == true && mounted) _load();
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            _chip(null, 'Semua'),
            const SizedBox(width: 8),
            _chip('posyandu', 'Posyandu'),
            const SizedBox(width: 8),
            _chip('posbindu', 'Posbindu'),
            const Spacer(),
            FilterChip(
              label: const Text('Mendatang'),
              selected: _upcomingOnly,
              onSelected: (v) {
                setState(() => _upcomingOnly = v);
                _load();
              },
            ),
          ]),
        ),
        Expanded(
          child: Consumer<JadwalProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading)
                return const ShimmerList(count: 6, itemHeight: 90);

              // Filter defensif: JadwalProvider dipakai bersama beberapa
              // layar (Beranda, Kalender) yang kadang memuat data dengan
              // filter berbeda. Kalau toggle "Mendatang" aktif di tab ini,
              // pastikan tidak ada jadwal yang sudah lewat ikut tampil,
              // walau isi provider.list saat ini kebetulan tidak terfilter.
              final displayList = !_upcomingOnly
                  ? provider.list
                  : (provider.list.where((j) {
                      try {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final d = DateTime.parse(j.tanggal);
                        final dateOnly = DateTime(d.year, d.month, d.day);
                        return !dateOnly.isBefore(today);
                      } catch (_) {
                        return false;
                      }
                    }).toList()
                      ..sort((a, b) => a.tanggal.compareTo(b.tanggal)));

              if (displayList.isEmpty)
                return EmptyState(
                  title: 'Tidak ada jadwal',
                  subtitle: provider.error, // ← tambahkan ini
                  onRetry: _load,
                );
              return RefreshIndicator(
                onRefresh: () async => _load(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayList.length,
                  itemBuilder: (_, i) => _JadwalCard(jadwal: displayList[i]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _chip(String? value, String label) {
    final selected = _jenisFilter == value;
    return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _jenisFilter = value);
          _load();
        });
  }
}

class _JadwalCard extends StatelessWidget {
  final JadwalModel jadwal;
  const _JadwalCard({required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => JadwalDetailScreen(jadwalId: jadwal.id))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.event_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(jadwal.lokasi,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      JenisJadwalChip(jenis: jadwal.jenisKegiatan),
                    ]),
                    const SizedBox(height: 4),
                    Text('${_fmtTanggal(jadwal.tanggal)} · ${jadwal.jam}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    if (jadwal.keterangan != null &&
                        jadwal.keterangan!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(jadwal.keterangan!,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ]),
        ),
      ),
    );
  }
}

class JadwalFormScreen extends StatefulWidget {
  const JadwalFormScreen({super.key});
  @override
  State<JadwalFormScreen> createState() => _JadwalFormScreenState();
}

class _JadwalFormScreenState extends State<JadwalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lokasiCtrl = TextEditingController(text: AppConstants.lokasiDefault);
  final _keteranganCtrl = TextEditingController();
  final _menuCtrl = TextEditingController();
  DateTime? _tanggal;
  TimeOfDay? _jam;
  String _jenis = 'posyandu';
  final List<String> _menuList = [];

  @override
  void dispose() {
    _lokasiCtrl.dispose();
    _keteranganCtrl.dispose();
    _menuCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pickJam() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _jam = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggal == null || _jam == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tanggal dan jam wajib diisi'),
          backgroundColor: AppColors.error));
      return;
    }
    final tglStr =
        '${_tanggal!.year.toString().padLeft(4, '0')}-${_tanggal!.month.toString().padLeft(2, '0')}-${_tanggal!.day.toString().padLeft(2, '0')}';
    final jamStr =
        '${_jam!.hour.toString().padLeft(2, '0')}:${_jam!.minute.toString().padLeft(2, '0')}';

    final provider = context.read<JadwalProvider>();
    final ok = await provider.create({
      'tanggal': tglStr,
      'jam': jamStr,
      'lokasi': _lokasiCtrl.text.trim(),
      'jenis_kegiatan': _jenis,
      'keterangan': _keteranganCtrl.text.trim().isNotEmpty
          ? _keteranganCtrl.text.trim()
          : null,
      if (_menuList.isNotEmpty)
        'menu_pmt': _menuList.map((m) => {'nama_menu': m}).toList(),
    });

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.error ?? 'Gagal membuat jadwal'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Jadwal Baru')),
      body: Consumer<JadwalProvider>(
        builder: (_, provider, __) => Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Row(children: [
              Expanded(
                  child: _jenisChip(
                      'posyandu', 'Posyandu', Icons.child_care_rounded)),
              const SizedBox(width: 12),
              Expanded(
                  child: _jenisChip('posbindu', 'Posbindu', Icons.elderly)),
            ]),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickTanggal,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: Icon(Icons.calendar_month_outlined,
                        color: AppColors.primary)),
                child: Text(_tanggal == null
                    ? 'Pilih tanggal'
                    : '${_tanggal!.day}/${_tanggal!.month}/${_tanggal!.year}'),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickJam,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Jam',
                    prefixIcon: Icon(Icons.access_time_rounded,
                        color: AppColors.primary)),
                child: Text(_jam == null ? 'Pilih jam' : _jam!.format(context)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lokasiCtrl,
              decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  prefixIcon: Icon(Icons.location_on_outlined,
                      color: AppColors.primary)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Lokasi wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keteranganCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                  prefixIcon:
                      Icon(Icons.notes_outlined, color: AppColors.primary)),
            ),
            const SizedBox(height: 20),
            const Text('Menu PMT (opsional)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: _menuCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Nama menu...', isDense: true))),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: () {
                  if (_menuCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _menuList.add(_menuCtrl.text.trim());
                    _menuCtrl.clear();
                  });
                },
              ),
            ]),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _menuList
                  .map((m) => Chip(
                      label: Text(m),
                      onDeleted: () => setState(() => _menuList.remove(m))))
                  .toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _submit,
                child: provider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Simpan Jadwal'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _jenisChip(String value, String label, IconData icon) {
    final selected = _jenis == value;
    return InkWell(
      onTap: () => setState(() => _jenis = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ]),
      ),
    );
  }
}

class JadwalDetailScreen extends StatefulWidget {
  final String jadwalId;
  const JadwalDetailScreen({super.key, required this.jadwalId});
  @override
  State<JadwalDetailScreen> createState() => _JadwalDetailScreenState();
}

class _JadwalDetailScreenState extends State<JadwalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<JadwalProvider>().fetchById(widget.jadwalId);
    final isAdmin = context.read<AuthProvider>().isAdminLevel;
    if (isAdmin) {
      // Kader/RW: lihat seluruh antrian (yang menunggu check-in maupun
      // yang sudah check-in) untuk jadwal ini.
      context.read<KunjunganProvider>().fetchStatusHariIni(widget.jadwalId);
    } else {
      // Warga: lihat status pendaftaran milik keluarganya sendiri saja
      // pada jadwal ini (backend otomatis memfilter berdasar akun login).
      context.read<KunjunganProvider>().fetchAll(jadwalId: widget.jadwalId);
    }
  }

  Future<void> _checkinDialog(JadwalModel jadwal) async {
    final kategori = jadwal.isPosyandu ? 'balita' : 'lansia';
    await context.read<WargaProvider>().fetchAll(kategori: kategori);
    if (!mounted) return;
    final warga = await showModalBottomSheet<WargaModel>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PilihWargaSheet(kategori: kategori),
    );
    if (warga == null || !mounted) return;
    final ok = await context
        .read<KunjunganProvider>()
        .checkin(warga.id, widget.jadwalId);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Check-in berhasil'),
          backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(context.read<KunjunganProvider>().error ?? 'Check-in gagal'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  /// KADER: konfirmasi kehadiran satu baris pendaftaran yang sudah ada di
  /// antrian ("Menunggu Check-in" -> "Sudah Check-in").
  Future<void> _checkinById(String kunjunganId) async {
    final ok = await context.read<KunjunganProvider>().checkinById(kunjunganId);
    if (!mounted) return;
    if (ok) _load();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Check-in berhasil'
          : (context.read<KunjunganProvider>().error ?? 'Check-in gagal')),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  /// WARGA: mendaftarkan salah satu data balita/lansia miliknya (yang
  /// sudah pernah dibuat sebelumnya) ke jadwal ini.
  Future<void> _daftarDialog(JadwalModel jadwal) async {
    final kategori = jadwal.isPosyandu ? 'balita' : 'lansia';
    await context.read<WargaProvider>().fetchAll(kategori: kategori);
    if (!mounted) return;

    final pilihan = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _PilihanDaftarSheet(),
    );
    if (pilihan == null || !mounted) return;

    if (pilihan == 'baru') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterScreen(
            jadwalId: jadwal.id,
            jadwalLabel: '${jadwal.lokasi} · ${_fmtTanggal(jadwal.tanggal)} · ${jadwal.jam}',
          ),
        ),
      );
      if (result == true && mounted) _load();
      return;
    }

    // pilihan == 'lama' -> pilih dari data yang sudah ada
    final warga = await showModalBottomSheet<WargaModel>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _PilihWargaMilikSendiriSheet(),
    );
    if (warga == null || !mounted) return;

    final ok = await context.read<KunjunganProvider>().daftar(warga.id, jadwal.id);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pendaftaran berhasil. Datang sesuai jadwal untuk check-in di lokasi.'),
          backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<KunjunganProvider>().error ?? 'Pendaftaran gagal'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _batalkanPendaftaran(String kunjunganId) async {
    final ok = await context.read<KunjunganProvider>().batalkan(kunjunganId);
    if (!mounted) return;
    if (ok) _load();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Pendaftaran dibatalkan'
          : (context.read<KunjunganProvider>().error ?? 'Gagal membatalkan pendaftaran')),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  Future<void> _konfirmasiPMT(String kunjunganId) async {
    final ok =
        await context.read<KunjunganProvider>().konfirmasiPMT(kunjunganId);
    if (!mounted) return;
    if (ok) _load();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'PMT dikonfirmasi'
          : (context.read<KunjunganProvider>().error ??
              'Gagal konfirmasi PMT')),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdminLevel;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Jadwal')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final j = context.read<JadwalProvider>().selected;
                if (j != null) await _checkinDialog(j);
              },
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('Checkin Warga'),
            )
          : FloatingActionButton.extended(
              onPressed: () async {
                final j = context.read<JadwalProvider>().selected;
                if (j != null) await _daftarDialog(j);
              },
              icon: const Icon(Icons.app_registration_rounded),
              label: const Text('Daftar ke Jadwal Ini'),
            ),
      body: Consumer<JadwalProvider>(
        builder: (_, jp, __) {
          if (jp.isLoading && jp.selected == null)
            return const Padding(
                padding: EdgeInsets.all(16), child: ShimmerList(count: 4));
          final jadwal = jp.selected;
          if (jadwal == null)
            return EmptyState(title: 'Jadwal tidak ditemukan', onRetry: _load);
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          JenisJadwalChip(jenis: jadwal.jenisKegiatan),
                          const Spacer(),
                          Text(_fmtTanggal(jadwal.tanggal),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ]),
                        const SizedBox(height: 8),
                        Text(jadwal.lokasi,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('Pukul ${jadwal.jam}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        if (jadwal.keterangan != null &&
                            jadwal.keterangan!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(jadwal.keterangan!,
                              style: const TextStyle(fontSize: 13)),
                        ],
                        if (jp.menu.isNotEmpty) ...[
                          const Divider(height: 24),
                          const Text('Menu PMT',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: jp.menu
                                  .map((m) => Chip(label: Text(m.namaMenu)))
                                  .toList()),
                        ],
                      ]),
                ),
              ),
              const SizedBox(height: 16),
              if (isAdmin) ...[
                const SectionHeader(title: 'Antrian Pendaftaran & Kunjungan'),
                Consumer<KunjunganProvider>(builder: (_, kp, __) {
                  if (kp.isLoading)
                    return const ShimmerList(count: 3, itemHeight: 70);
                  if (kp.hariIni.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('Belum ada warga yang mendaftar/check-in',
                          style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return Column(children: [
                    if (kp.ringkasanHariIni != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            _ringkasanItem('Menunggu',
                                '${kp.ringkasanHariIni!['total_terdaftar'] ?? 0}'),
                            _ringkasanItem('Hadir',
                                '${kp.ringkasanHariIni!['total_hadir'] ?? 0}'),
                            _ringkasanItem('Diperiksa',
                                '${kp.ringkasanHariIni!['sudah_periksa'] ?? 0}'),
                            _ringkasanItem('PMT',
                                '${kp.ringkasanHariIni!['sudah_pmt'] ?? 0}'),
                          ]),
                        ),
                      ),
                    const SizedBox(height: 8),
                    ...kp.hariIni.map((k) => _KunjunganRow(
                          kunjungan: k,
                          onCheckin:
                              k.masihMenunggu ? () => _checkinById(k.id) : null,
                          onPeriksa: k.sudahCheckin
                              ? () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => k.kategori == 'balita'
                                          ? PemeriksaanBalitaFormScreen(
                                              kunjunganId: k.id,
                                              namaWarga: k.namaWarga ?? '-',
                                              tanggalLahir: k.tanggalLahir)
                                          : PemeriksaanPosbinduFormScreen(
                                              kunjunganId: k.id,
                                              namaWarga: k.namaWarga ?? '-',
                                              tanggalLahir: k.tanggalLahir),
                                    ),
                                  );
                                  if (result == true && mounted) _load();
                                }
                              : null,
                          onKonfirmasiPmt:
                              k.sudahCheckin ? () => _konfirmasiPMT(k.id) : null,
                        )),
                  ]);
                }),
              ] else ...[
                const SectionHeader(title: 'Status Pendaftaran Saya'),
                Consumer<KunjunganProvider>(builder: (_, kp, __) {
                  if (kp.isLoading)
                    return const ShimmerList(count: 2, itemHeight: 70);
                  final punyaSaya =
                      kp.list.where((k) => !k.dibatalkan).toList();
                  if (punyaSaya.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                          'Belum ada balita/lansia yang didaftarkan ke jadwal ini',
                          style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return Column(
                      children: punyaSaya
                          .map((k) => _PendaftaranSayaCard(
                                kunjungan: k,
                                onBatalkan: k.masihMenunggu
                                    ? () => _batalkanPendaftaran(k.id)
                                    : null,
                              ))
                          .toList());
                }),
              ],
              const SizedBox(height: 24),
            ]),
          );
        },
      ),
    );
  }

  Widget _ringkasanItem(String label, String value) => Expanded(
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.primary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ]),
      );
}

class _KunjunganRow extends StatelessWidget {
  final KunjunganModel kunjungan;
  final VoidCallback? onCheckin;
  final VoidCallback? onPeriksa;
  final VoidCallback? onKonfirmasiPmt;
  const _KunjunganRow(
      {required this.kunjungan, this.onCheckin, this.onPeriksa, this.onKonfirmasiPmt});

  bool get _sudahDiperiksa =>
      kunjungan.sudahDiperiksaBalita || kunjungan.sudahDiperiksaPosbindu;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLighter,
              child: Text('${kunjungan.nomorUrut ?? '-'}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kunjungan.namaWarga ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(
                    'Umur: ${hitungUmur(kunjungan.tanggalLahir, isBalita: kunjungan.kategori != 'lansia')}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            )),
            if (kunjungan.masihMenunggu)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Menunggu',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700)),
              )
            else if (kunjungan.kategori == 'balita' && kunjungan.statusGizi != null)
              StatusGiziBadge(kode: kunjungan.statusGizi)
            else if (kunjungan.kategori == 'lansia' &&
                kunjungan.statusTensi != null)
              StatusTensiBadge(kode: kunjungan.statusTensi),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _mejaDot('1', kunjungan.sudahCheckin),
            _mejaDot('2-3', _sudahDiperiksa),
            _mejaDot('4', kunjungan.sudahPMT),
            const Spacer(),
            if (kunjungan.masihMenunggu && onCheckin != null)
              ElevatedButton(
                  onPressed: onCheckin,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 32)),
                  child: const Text('Check-in', style: TextStyle(fontSize: 12)))
            else if (!_sudahDiperiksa && onPeriksa != null)
              TextButton(onPressed: onPeriksa, child: const Text('Periksa'))
            else if (_sudahDiperiksa &&
                !kunjungan.sudahPMT &&
                onKonfirmasiPmt != null)
              TextButton(
                  onPressed: onKonfirmasiPmt,
                  child: const Text('Konfirmasi PMT'))
            else if (kunjungan.sudahPMT)
              const Text('Selesai ✓',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  Widget _mejaDot(String label, bool done) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
                color: done ? AppColors.success : AppColors.divider,
                shape: BoxShape.circle),
            child: done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 4),
          Text('Meja $label',
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ]),
      );
}

class _PilihWargaSheet extends StatelessWidget {
  final String kategori;
  const _PilihWargaSheet({required this.kategori});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Text('Pilih Warga untuk Check-in',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<WargaProvider>(builder: (_, provider, __) {
              if (provider.isLoading) return const ShimmerList(count: 5);
              final list =
                  provider.list.where((w) => w.sudahVerifikasi).toList();
              if (list.isEmpty) {
                return const EmptyState(
                    title: 'Tidak ada warga terverifikasi',
                    subtitle: 'Verifikasi data warga terlebih dahulu');
              }
              return ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final w = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLighter,
                      child: Icon(
                          w.isBalita ? Icons.child_care_rounded : Icons.elderly,
                          color: AppColors.primary),
                    ),
                    title: Text(w.namaTampilan),
                    subtitle: Text(
                        'NIK: ${w.nik} · Umur: ${hitungUmur(w.tanggalLahir, isBalita: w.isBalita)}${w.namaUser != null ? ' · Akun: ${w.namaUser}' : ''}'),
                    onTap: () => Navigator.pop(context, w),
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }
}

// ─── Bottom sheet: pilih cara mendaftar (data lama vs data baru) ───
class _PilihanDaftarSheet extends StatelessWidget {
  const _PilihanDaftarSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Daftarkan Siapa?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 4),
        const Text('Pilih data balita/lansia yang sudah ada, atau isi formulir baru',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'lama'),
            icon: const Icon(Icons.people_outline),
            label: const Text('Pilih Data yang Sudah Ada'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'baru'),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Isi Formulir Data Baru'),
          ),
        ),
      ]),
    );
  }
}

// ─── Bottom sheet: pilih salah satu data balita/lansia milik akun sendiri ───
class _PilihWargaMilikSendiriSheet extends StatelessWidget {
  const _PilihWargaMilikSendiriSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Text('Pilih Data Balita/Lansia',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<WargaProvider>(builder: (_, provider, __) {
              if (provider.isLoading) return const ShimmerList(count: 4);
              final list = provider.list;
              if (list.isEmpty) {
                return const EmptyState(
                    title: 'Belum ada data balita/lansia',
                    subtitle: 'Isi formulir data baru terlebih dahulu');
              }
              return ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final w = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLighter,
                      child: Icon(
                          w.isBalita ? Icons.child_care_rounded : Icons.elderly,
                          color: AppColors.primary),
                    ),
                    title: Text(w.namaTampilan),
                    subtitle: Text(
                        'NIK: ${w.nik} · Umur: ${hitungUmur(w.tanggalLahir, isBalita: w.isBalita)}'),
                    onTap: () => Navigator.pop(context, w),
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }
}

// ─── Kartu status pendaftaran milik warga sendiri di suatu jadwal ───
class _PendaftaranSayaCard extends StatelessWidget {
  final KunjunganModel kunjungan;
  final VoidCallback? onBatalkan;
  const _PendaftaranSayaCard({required this.kunjungan, this.onBatalkan});

  @override
  Widget build(BuildContext context) {
    final warna = kunjungan.sudahCheckin
        ? AppColors.success
        : (kunjungan.masihMenunggu ? AppColors.warning : AppColors.textHint);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLighter,
            child: Icon(
                kunjungan.kategori == 'balita'
                    ? Icons.child_care_rounded
                    : Icons.elderly,
                color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kunjungan.namaWarga ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(kunjungan.statusKehadiranLabel,
                    style: TextStyle(fontSize: 11, color: warna, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (onBatalkan != null)
            TextButton(
              onPressed: onBatalkan,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Batalkan'),
            ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  PEMERIKSAAN BALITA (MEJA 2-3)
// ═══════════════════════════════════════
class PemeriksaanBalitaFormScreen extends StatefulWidget {
  final String kunjunganId;
  final String namaWarga;
  final String? tanggalLahir;
  const PemeriksaanBalitaFormScreen(
      {super.key, required this.kunjunganId, required this.namaWarga, this.tanggalLahir});
  @override
  State<PemeriksaanBalitaFormScreen> createState() =>
      _PemeriksaanBalitaFormScreenState();
}

class _PemeriksaanBalitaFormScreenState
    extends State<PemeriksaanBalitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _beratCtrl = TextEditingController();
  final _tinggiCtrl = TextEditingController();
  final _lingkarKepalaCtrl = TextEditingController();
  bool _vitaminA = false;
  String? _jenisImunisasi;

  @override
  void dispose() {
    _beratCtrl.dispose();
    _tinggiCtrl.dispose();
    _lingkarKepalaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PemeriksaanProvider>();
    final ok = await provider.createBalita({
      'kunjungan_id': widget.kunjunganId,
      'berat_badan_kg': double.parse(_beratCtrl.text.replaceAll(',', '.')),
      if (_tinggiCtrl.text.isNotEmpty)
        'tinggi_badan_cm': double.parse(_tinggiCtrl.text.replaceAll(',', '.')),
      if (_lingkarKepalaCtrl.text.isNotEmpty)
        'lingkar_kepala_cm':
            double.parse(_lingkarKepalaCtrl.text.replaceAll(',', '.')),
      'vitamin_a': _vitaminA,
      if (_jenisImunisasi != null) 'jenis_imunisasi': _jenisImunisasi,
    });
    if (!mounted) return;
    if (ok) {
      final hasil = provider.lastBalita;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Pemeriksaan Tersimpan'),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasil?.labelStatus != null)
                  Text('Status Gizi: ${hasil!.labelStatus}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                if (hasil?.zScoreBBU != null)
                  Text('Z-Score BB/U: ${hasil!.zScoreBBU!.toStringAsFixed(2)}'),
                if (hasil?.zScoreTBU != null)
                  Text('Z-Score TB/U: ${hasil!.zScoreTBU!.toStringAsFixed(2)}'),
              ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.error ?? 'Gagal menyimpan pemeriksaan'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Periksa: ${widget.namaWarga}')),
      body: Consumer<PemeriksaanProvider>(
        builder: (_, provider, __) => Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Card(
              color: AppColors.primaryLighter,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.child_care_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.namaWarga,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                            'Umur: ${hitungUmur(widget.tanggalLahir, isBalita: true)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _beratCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  prefixIcon: Icon(Icons.monitor_weight_outlined,
                      color: AppColors.primary)),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Berat badan wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tinggiCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  prefixIcon: Icon(Icons.height, color: AppColors.primary)),
              // Wajib diisi — kolom tinggi_badan_cm bersifat NOT NULL di database,
              // sebelumnya tidak ada validator sehingga insert bisa gagal kalau dikosongkan.
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Tinggi badan wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lingkarKepalaCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Lingkar Kepala (cm) - opsional',
                  prefixIcon:
                      Icon(Icons.face_outlined, color: AppColors.primary)),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              value: _vitaminA,
              onChanged: (v) => setState(() => _vitaminA = v),
              title: const Text('Mendapat Vitamin A',
                  style: TextStyle(fontSize: 13)),
              contentPadding: EdgeInsets.zero,
            ),
            DropdownButtonFormField<String>(
              value: _jenisImunisasi,
              decoration: const InputDecoration(
                  labelText: 'Jenis Imunisasi (opsional)',
                  prefixIcon:
                      Icon(Icons.vaccines_outlined, color: AppColors.primary)),
              items: AppConstants.daftarImunisasi
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
              onChanged: (v) => setState(() => _jenisImunisasi = v),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _submit,
                child: provider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Simpan Pemeriksaan'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  PEMERIKSAAN POSBINDU (MEJA 2-3)
// ═══════════════════════════════════════
class PemeriksaanPosbinduFormScreen extends StatefulWidget {
  final String kunjunganId;
  final String namaWarga;
  final String? tanggalLahir;
  const PemeriksaanPosbinduFormScreen(
      {super.key, required this.kunjunganId, required this.namaWarga, this.tanggalLahir});
  @override
  State<PemeriksaanPosbinduFormScreen> createState() =>
      _PemeriksaanPosbinduFormScreenState();
}

class _PemeriksaanPosbinduFormScreenState
    extends State<PemeriksaanPosbinduFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _beratCtrl = TextEditingController();
  final _sistolCtrl = TextEditingController();
  final _diastolCtrl = TextEditingController();
  final _keluhanCtrl = TextEditingController();
  final Set<String> _faktorRisiko = {};

  @override
  void dispose() {
    _beratCtrl.dispose();
    _sistolCtrl.dispose();
    _diastolCtrl.dispose();
    _keluhanCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PemeriksaanProvider>();
    final ok = await provider.createPosbindu({
      'kunjungan_id': widget.kunjunganId,
      'berat_badan_kg': double.parse(_beratCtrl.text.replaceAll(',', '.')),
      'tensi_sistol': int.parse(_sistolCtrl.text),
      'tensi_diastol': int.parse(_diastolCtrl.text),
      if (_keluhanCtrl.text.trim().isNotEmpty)
        'keluhan': _keluhanCtrl.text.trim(),
      if (_faktorRisiko.isNotEmpty)
        'faktor_risiko_ptm': _faktorRisiko.join(', '),
    });
    if (!mounted) return;
    if (ok) {
      final hasil = provider.lastPosbindu;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Pemeriksaan Tersimpan'),
          content: Text('Status Tensi: ${hasil?.labelStatus ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.error ?? 'Gagal menyimpan pemeriksaan'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Periksa: ${widget.namaWarga}')),
      body: Consumer<PemeriksaanProvider>(
        builder: (_, provider, __) => Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Card(
              color: AppColors.primaryLighter,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.elderly, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.namaWarga,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                            'Umur: ${hitungUmur(widget.tanggalLahir, isBalita: false)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _beratCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  prefixIcon: Icon(Icons.monitor_weight_outlined,
                      color: AppColors.primary)),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Berat badan wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _sistolCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sistol (mmHg)'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Wajib' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _diastolCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Diastol (mmHg)'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Wajib' : null,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keluhanCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Keluhan (opsional)',
                  prefixIcon:
                      Icon(Icons.info_outline, color: AppColors.primary)),
            ),
            const SizedBox(height: 16),
            const Text('Faktor Risiko PTM (opsional)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.faktorRisikoPTM
                  .map((f) => FilterChip(
                        label: Text(f, style: const TextStyle(fontSize: 12)),
                        selected: _faktorRisiko.contains(f),
                        onSelected: (v) => setState(() =>
                            v ? _faktorRisiko.add(f) : _faktorRisiko.remove(f)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _submit,
                child: provider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Simpan Pemeriksaan'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  PROFILE TAB
// ═══════════════════════════════════════
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted)
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama'),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal')),
          Consumer<AuthProvider>(
              builder: (_, auth, __) => TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final ok = await auth.changePassword(
                                oldCtrl.text, newCtrl.text);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok
                                  ? 'Password berhasil diubah'
                                  : (auth.errorMessage ??
                                      'Gagal mengubah password')),
                              backgroundColor:
                                  ok ? AppColors.success : AppColors.error,
                            ));
                          },
                    child: const Text('Simpan'),
                  )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryLighter,
                  child: Icon(Icons.person_rounded,
                      size: 36, color: AppColors.primary)),
              const SizedBox(height: 12),
              Text(user?.nama ?? '-',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(height: 2),
              Text(user?.roleLabel ?? '-',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const Divider(height: 28),
              _infoRow(Icons.phone_outlined, user?.noHp ?? '-'),
              if (user?.email != null)
                _infoRow(Icons.email_outlined, user!.email!),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.primary),
              title: const Text('Formulir Kartu Bantu'),
              subtitle: const Text('Download formulir & kartu pemeriksaan'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FormulirKartuBantuScreen()))),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(children: [
            ListTile(
                leading:
                    const Icon(Icons.lock_outline, color: AppColors.primary),
                title: const Text('Ubah Password'),
                onTap: () => _changePassword(context)),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Keluar',
                  style: TextStyle(color: AppColors.error)),
              onTap: () => _logout(context),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 13))
        ]),
      );
}

// ═══════════════════════════════════════
//  BERANDA WARGA (role: warga)
// ═══════════════════════════════════════
class _WargaHomeTab extends StatefulWidget {
  const _WargaHomeTab();
  @override
  State<_WargaHomeTab> createState() => _WargaHomeTabState();
}

class _WargaHomeTabState extends State<_WargaHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WargaProvider>().fetchAll();
      context.read<JadwalProvider>().fetchAll(upcoming: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: Text('Halo, ${user?.nama ?? '-'}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()));
          if (added == true && mounted)
            context.read<WargaProvider>().fetchAll();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<WargaProvider>().fetchAll();
          await context.read<JadwalProvider>().fetchAll(upcoming: true);
        },
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const SectionHeader(title: 'Data Balita/Lansia Saya'),
          Consumer<WargaProvider>(builder: (_, provider, __) {
            if (provider.isLoading)
              return const ShimmerList(count: 2, itemHeight: 80);
            if (provider.list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('Belum ada data terdaftar',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return Column(
                children:
                    provider.list.map((w) => _WargaCard(warga: w)).toList());
          }),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Jadwal Mendatang',
            actionLabel: 'Lihat Kalender',
            onAction: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const JadwalKalenderScreen()));
              // JadwalProvider dipakai bersama (shared state) — kalender
              // memuat semua jadwal tanpa filter, jadi kembalikan lagi
              // ke daftar "mendatang" supaya tab ini tetap konsisten.
              if (context.mounted) {
                context.read<JadwalProvider>().fetchAll(upcoming: true);
              }
            },
          ),
          Consumer<JadwalProvider>(builder: (_, provider, __) {
            if (provider.isLoading)
              return const ShimmerList(count: 2, itemHeight: 90);

            // Filter defensif: JadwalProvider dipakai bersama beberapa layar
            // (tab Jadwal, Kalender) yang kadang memuat SEMUA jadwal tanpa
            // filter. Supaya section ini selalu benar walau provider sedang
            // menyimpan data tak terfilter, saring ulang di sini berdasarkan
            // tanggal — bukan cuma percaya provider.list sudah "mendatang saja".
            final today = DateTime.now();
            final todayDate = DateTime(today.year, today.month, today.day);
            final upcoming = provider.list.where((j) {
              try {
                final d = DateTime.parse(j.tanggal);
                final dateOnly = DateTime(d.year, d.month, d.day);
                return !dateOnly.isBefore(todayDate);
              } catch (_) {
                return false;
              }
            }).toList()
              ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

            if (upcoming.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('Tidak ada jadwal mendatang',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return Column(
                children:
                    upcoming.map((j) => _JadwalCard(jadwal: j)).toList());
          }),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  LAPORAN BULANAN (admin/kader)
// ═══════════════════════════════════════
class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});
  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  int _bulan = DateTime.now().month;
  int _tahun = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch() => context.read<LaporanProvider>().fetchBulanan(_bulan, _tahun);

  Future<void> _exportExcel() async {
    final provider = context.read<LaporanProvider>();
    final path = await provider.exportExcel(tahun: _tahun);
    if (!mounted) return;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.error ?? 'Gagal mengexport laporan'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (kIsWeb) {
      // Di web, browser sudah otomatis memicu download (lihat file_saver_web.dart)
      // — tidak ada path lokal untuk dibuka lewat aplikasi lain seperti di mobile.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Laporan berhasil diunduh ke folder Downloads browser'),
        backgroundColor: AppColors.success,
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Laporan berhasil diexport'),
      backgroundColor: AppColors.success,
      action: SnackBarAction(
        label: 'Buka',
        textColor: Colors.white,
        onPressed: () => OpenFilex.open(path),
      ),
    ));
    // Langsung coba buka file-nya dengan aplikasi spreadsheet di HP.
    OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
        actions: [
          Consumer<LaporanProvider>(builder: (_, provider, __) {
            if (provider.isExporting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              );
            }
            return IconButton(
              tooltip: 'Export Excel',
              icon: const Icon(Icons.file_download_outlined),
              onPressed: _exportExcel,
            );
          }),
        ],
      ),
      body: Consumer<LaporanProvider>(builder: (_, provider, __) {
        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _bulan,
                  decoration:
                      const InputDecoration(labelText: 'Bulan', isDense: true),
                  items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(DateFormat('MMMM', 'id_ID')
                              .format(DateTime(2024, i + 1))))),
                  onChanged: (v) {
                    setState(() => _bulan = v!);
                    _fetch();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _tahun,
                  decoration:
                      const InputDecoration(labelText: 'Tahun', isDense: true),
                  items: [_tahun - 1, _tahun, _tahun + 1]
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _tahun = v!);
                    _fetch();
                  },
                ),
              ),
            ]),
          ),
          Expanded(
            child: provider.isLoading
                ? const ShimmerList(count: 4, itemHeight: 100)
                : provider.data == null
                    ? EmptyState(
                        title: 'Belum ada data',
                        subtitle: provider.error,
                        onRetry: _fetch)
                    : _buildContent(provider.data!),
          ),
        ]);
      }),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final rekap = (data['rekap'] as List?) ?? [];
    final detailStunting = (data['detailStunting'] as List?) ?? [];
    final detailHipertensi = (data['detailHipertensi'] as List?) ?? [];

    return ListView(padding: const EdgeInsets.all(16), children: [
      if (rekap.isEmpty)
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Tidak ada kegiatan pada periode ini',
                style: TextStyle(color: AppColors.textSecondary)))
      else
        ...rekap.map((r) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppConstants.jenisKegiatan[r['jenis_kegiatan']] ??
                              '${r['jenis_kegiatan']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const Divider(height: 16),
                      _rekapRow('Total Hadir', '${r['total_hadir'] ?? 0}'),
                      _rekapRow(
                          'Total Terima PMT', '${r['total_terima_pmt'] ?? 0}'),
                      if (r['jenis_kegiatan'] == 'posyandu') ...[
                        _rekapRow('Diperiksa (Balita)',
                            '${r['total_diperiksa_balita'] ?? 0}'),
                        _rekapRow('Gizi Normal', '${r['balita_normal'] ?? 0}'),
                        _rekapRow('Stunting', '${r['balita_stunting'] ?? 0}'),
                        _rekapRow(
                            'Berat Kurang', '${r['balita_underweight'] ?? 0}'),
                        _rekapRow(
                            'Dapat Vitamin A', '${r['balita_vitamin_a'] ?? 0}'),
                        if (r['rata_berat_balita'] != null)
                          _rekapRow('Rata-rata Berat',
                              '${r['rata_berat_balita']} kg'),
                        if (r['rata_tinggi_balita'] != null)
                          _rekapRow('Rata-rata Tinggi',
                              '${r['rata_tinggi_balita']} cm'),
                      ] else ...[
                        _rekapRow('Diperiksa (Lansia)',
                            '${r['total_diperiksa_lansia'] ?? 0}'),
                        _rekapRow(
                            'Hipertensi', '${r['lansia_hipertensi'] ?? 0}'),
                        _rekapRow(
                            'Tensi Normal', '${r['lansia_normal_tensi'] ?? 0}'),
                        if (r['rata_sistol'] != null)
                          _rekapRow('Rata-rata Sistol', '${r['rata_sistol']}'),
                        if (r['rata_diastol'] != null)
                          _rekapRow(
                              'Rata-rata Diastol', '${r['rata_diastol']}'),
                      ],
                    ]),
              ),
            )),
      if (detailStunting.isNotEmpty) ...[
        const SectionHeader(title: 'Balita Stunting'),
        ...detailStunting.map((d) => Card(
              child: ListTile(
                title: Text('${d['nama']}'),
                subtitle: Text(
                    'BB: ${d['berat_badan_kg']} kg, TB: ${d['tinggi_badan_cm']} cm'),
              ),
            )),
      ],
      if (detailHipertensi.isNotEmpty) ...[
        const SectionHeader(title: 'Lansia Hipertensi'),
        ...detailHipertensi.map((d) => Card(
              child: ListTile(
                title: Text('${d['nama']}'),
                subtitle: Text(
                    'Tensi: ${d['tensi_sistol']}/${d['tensi_diastol']} — ${d['keluhan'] ?? '-'}'),
              ),
            )),
      ],
    ]);
  }

  Widget _rekapRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary))),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      );
}