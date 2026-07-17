import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/providers.dart';
import '../../../../core/api/api_client.dart';
import '../../../auth/data/models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    final screens = isAdmin
        ? const [AdminDashboardScreen(), BalitaListTab(), JadwalTab(), NotifikasiTab(), ProfileTab()]
        : const [WargaDashboardScreen(), BalitaSayaTab(), JadwalTab(), ArtikelTab(), ProfileTab()];

    final items = isAdmin
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.child_care_rounded), label: 'Balita'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Notif'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.child_care_rounded), label: 'Balita Saya'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
            BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Edukasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: items,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  ADMIN DASHBOARD
// ═══════════════════════════════════════
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      body: CustomScrollView(slivers: [
        _buildSliverAppBar(user),
        SliverToBoxAdapter(
          child: Consumer<DashboardProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) return const ShimmerList(count: 4, itemHeight: 100);
              final data = provider.data;
              if (data == null) return EmptyState(title: 'Gagal memuat data', onRetry: () => provider.fetch());
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 16),
                _buildStatsGrid(data),
                SectionHeader(title: 'Jadwal Mendatang', actionLabel: 'Lihat Semua', onAction: () {}),
                _buildJadwalList(data.jadwalMendatang),
                SectionHeader(title: 'Aktivitas Terbaru', actionLabel: 'Lihat Semua', onAction: () {}),
                _buildAktivitasList(data.aktivitasTerbaru),
                const SizedBox(height: 24),
              ]);
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildSliverAppBar(UserModel? user) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 8),
                Row(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Selamat Datang,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(user?.name ?? '-', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
                  const Spacer(),
                  _NotifBell(),
                ]),
                const SizedBox(height: 16),
                Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
          ),
        ),
        title: const Text('Dashboard Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
      ),
      backgroundColor: AppColors.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => context.read<DashboardProvider>().fetch(),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          StatCard(label: 'Total Balita', value: '${data.totalBalita}', icon: Icons.child_care_rounded, color: AppColors.primary),
          StatCard(label: 'Total Warga', value: '${data.totalWarga}', icon: Icons.people_rounded, color: AppColors.accent),
          StatCard(label: 'Ditimbang Bulan Ini', value: '${data.ditimbangBulanIni}', icon: Icons.monitor_weight_rounded, color: AppColors.orange),
          StatCard(label: 'Gizi Kurang/Buruk', value: '${data.giziKurangBulanIni}', icon: Icons.warning_rounded, color: AppColors.statusBuruk),
        ],
      ),
    );
  }

  Widget _buildJadwalList(List<JadwalModel> list) {
    if (list.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Tidak ada jadwal mendatang', style: TextStyle(color: AppColors.textSecondary)));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (_, i) => _JadwalCard(jadwal: list[i]),
    );
  }

  Widget _buildAktivitasList(List<PenimbanganModel> list) {
    if (list.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Belum ada aktivitas', style: TextStyle(color: AppColors.textSecondary)));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final p = list[i];
        return Card(
          child: ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.statusGiziColor(p.kodeStatus).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.monitor_weight_rounded, color: AppColors.statusGiziColor(p.kodeStatus), size: 22),
            ),
            title: Text(p.namaBalita ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text('${p.beratBadan} kg · ${DateFormat('d MMM yyyy').format(DateTime.parse(p.tanggalPenimbangan))}',
                style: const TextStyle(fontSize: 12)),
            trailing: StatusGiziBadge(kodeStatus: p.kodeStatus),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════
//  WARGA DASHBOARD
// ═══════════════════════════════════════
class WargaDashboardScreen extends StatefulWidget {
  const WargaDashboardScreen({super.key});
  @override
  State<WargaDashboardScreen> createState() => _WargaDashboardScreenState();
}

class _WargaDashboardScreenState extends State<WargaDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BalitaProvider>().fetchAll();
      context.read<JadwalProvider>().fetchAll();
      context.read<NotifikasiProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 160,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 8),
                      const Text('Halo,', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(user?.name ?? '-', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                          style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ])),
                    _NotifBell(),
                  ]),
                ),
              ),
            ),
            title: const Text('Beranda', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
          ),
          backgroundColor: AppColors.primary,
        ),
        SliverToBoxAdapter(child: _buildWargaBody()),
      ]),
    );
  }

  Widget _buildWargaBody() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),

      // Balita saya
      SectionHeader(
        title: 'Balita Saya',
        actionLabel: 'Lihat Semua',
        onAction: () {},
      ),
      Consumer<BalitaProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) return const ShimmerList(count: 2, itemHeight: 80);
          if (provider.list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _EmptyBalitaCard(),
            );
          }
          return SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.list.take(3).length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _BalitaMiniCard(balita: provider.list[i]),
            ),
          );
        },
      ),

      // Jadwal mendatang
      SectionHeader(title: 'Jadwal Posyandu', actionLabel: 'Lihat Semua', onAction: () {}),
      Consumer<JadwalProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) return const ShimmerList(count: 2, itemHeight: 80);
          if (provider.list.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Belum ada jadwal', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.list.take(3).length,
            itemBuilder: (_, i) => _JadwalCard(jadwal: provider.list[i]),
          );
        },
      ),
      const SizedBox(height: 24),
    ]);
  }
}

// ─── Placeholders for tab screens ───
class BalitaListTab extends StatelessWidget {
  const BalitaListTab({super.key});
  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (s) => MaterialPageRoute(builder: (_) => const _BalitaListScreen(isAdmin: true)),
  );
}

class BalitaSayaTab extends StatelessWidget {
  const BalitaSayaTab({super.key});
  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (s) => MaterialPageRoute(builder: (_) => const _BalitaListScreen(isAdmin: false)),
  );
}

class JadwalTab extends StatelessWidget {
  const JadwalTab({super.key});
  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (s) => MaterialPageRoute(builder: (_) => const _JadwalScreen()),
  );
}

class NotifikasiTab extends StatelessWidget {
  const NotifikasiTab({super.key});
  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (s) => MaterialPageRoute(builder: (_) => const _NotifikasiScreen()),
  );
}

class ArtikelTab extends StatelessWidget {
  const ArtikelTab({super.key});
  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (s) => MaterialPageRoute(builder: (_) => const _ArtikelScreen()),
  );
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (s) => MaterialPageRoute(builder: (_) => const _ProfileScreen()),
  );
}

// ═══════════════════════════════════════
//  BALITA LIST SCREEN
// ═══════════════════════════════════════
class _BalitaListScreen extends StatefulWidget {
  final bool isAdmin;
  const _BalitaListScreen({required this.isAdmin});
  @override
  State<_BalitaListScreen> createState() => _BalitaListScreenState();
}

class _BalitaListScreenState extends State<_BalitaListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BalitaProvider>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Data Balita' : 'Balita Saya'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => context.read<BalitaProvider>().fetchAll()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _TambahBalitaScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Balita'),
        backgroundColor: AppColors.accent,
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Cari nama balita...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _searchCtrl.clear();
                      context.read<BalitaProvider>().fetchAll();
                    })
                  : null,
            ),
            onSubmitted: (v) => context.read<BalitaProvider>().fetchAll(search: v),
          ),
        ),
        Expanded(
          child: Consumer<BalitaProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) return const ShimmerList();
              if (provider.list.isEmpty) return EmptyState(
                icon: Icons.child_care_rounded,
                title: 'Belum ada data balita',
                subtitle: 'Tekan tombol + untuk mendaftarkan balita baru',
              );
              return RefreshIndicator(
                onRefresh: () => provider.fetchAll(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.list.length,
                  itemBuilder: (_, i) {
                    final b = provider.list[i];
                    return _BalitaCard(
                      balita: b,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => _BalitaDetailScreen(balitaId: b.id),
                      )),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════
//  BALITA CARD
// ═══════════════════════════════════════
class _BalitaCard extends StatelessWidget {
  final BalitaModel balita;
  final VoidCallback? onTap;
  const _BalitaCard({required this.balita, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBoy = balita.jenisKelamin == 'L';
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isBoy ? AppColors.primaryLighter : const Color(0xFFFFE4F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.child_care_rounded, color: isBoy ? AppColors.primary : Colors.pink, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(balita.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text('${balita.jenisKelaminLabel} · ${balita.umurBulan ?? '-'} bulan',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (balita.namaOrangTua != null) ...[
                const SizedBox(height: 2),
                Text('Orang tua: ${balita.namaOrangTua}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ])),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  BALITA DETAIL SCREEN
// ═══════════════════════════════════════
class _BalitaDetailScreen extends StatefulWidget {
  final String balitaId;
  const _BalitaDetailScreen({required this.balitaId});
  @override
  State<_BalitaDetailScreen> createState() => _BalitaDetailScreenState();
}

class _BalitaDetailScreenState extends State<_BalitaDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BalitaProvider>().fetchById(widget.balitaId);
      context.read<PenimbanganProvider>().fetchAll(balitaId: widget.balitaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BalitaProvider>(
      builder: (_, provider, __) {
        final b = provider.selected;
        return Scaffold(
          appBar: AppBar(
            title: Text(b?.nama ?? 'Detail Balita'),
            flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
            actions: [
              if (context.watch<AuthProvider>().isAdmin)
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'timbang') {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => _TambahPenimbanganScreen(balita: b!),
                      ));
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'timbang', child: Text('Rekam Penimbangan')),
                  ],
                ),
            ],
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [Tab(text: 'Info'), Tab(text: 'Penimbangan'), Tab(text: 'Imunisasi')],
            ),
          ),
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _InfoBalitaTab(balita: b),
              _PenimbanganTab(balitaId: widget.balitaId),
              _ImunisasiTabPlaceholder(),
            ],
          ),
        );
      },
    );
  }
}

class _InfoBalitaTab extends StatelessWidget {
  final BalitaModel? balita;
  const _InfoBalitaTab({this.balita});

  @override
  Widget build(BuildContext context) {
    if (balita == null) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Icon(balita!.jenisKelamin == 'L' ? Icons.boy_rounded : Icons.girl_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(balita!.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text(balita!.jenisKelaminLabel, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text('${balita!.umurBulan ?? '-'} bulan', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        _InfoSection('Data Kelahiran', [
          _InfoRow('NIK', balita!.nik ?? '-'),
          _InfoRow('Tanggal Lahir', balita!.tanggalLahir),
          _InfoRow('Tempat Lahir', balita!.tempatLahir ?? '-'),
          _InfoRow('Status Kelahiran', balita!.statusKelahiran ?? '-'),
          _InfoRow('Berat Lahir', balita!.beratLahir != null ? '${balita!.beratLahir} kg' : '-'),
          _InfoRow('Panjang Lahir', balita!.panjangLahir != null ? '${balita!.panjangLahir} cm' : '-'),
          _InfoRow('Gol. Darah', balita!.golonganDarah ?? '-'),
        ]),
        const SizedBox(height: 12),
        _InfoSection('Data Orang Tua', [
          _InfoRow('Nama Ayah', balita!.namaAyah ?? '-'),
          _InfoRow('Nama Ibu', balita!.namaIbu ?? '-'),
          _InfoRow('Orang Tua', balita!.namaOrangTua ?? '-'),
          _InfoRow('No. HP', balita!.phoneOrangTua ?? '-'),
        ]),
      ]),
    );
  }

  Widget _InfoSection(String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
          const Divider(height: 16),
          ...rows,
        ]),
      ),
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      ]),
    );
  }
}

class _PenimbanganTab extends StatelessWidget {
  final String balitaId;
  const _PenimbanganTab({required this.balitaId});

  @override
  Widget build(BuildContext context) {
    return Consumer<PenimbanganProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return const ShimmerList();
        if (provider.list.isEmpty) return const EmptyState(title: 'Belum ada data penimbangan', icon: Icons.monitor_weight_outlined);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.list.length,
          itemBuilder: (_, i) {
            final p = provider.list[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(DateFormat('d MMMM yyyy').format(DateTime.parse(p.tanggalPenimbangan)),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const Spacer(),
                    StatusGiziBadge(kodeStatus: p.kodeStatus),
                  ]),
                  const Divider(height: 12),
                  Row(children: [
                    _MeasureChip('BB', '${p.beratBadan} kg', Icons.monitor_weight_outlined, AppColors.primary),
                    const SizedBox(width: 8),
                    if (p.tinggiBadan != null)
                      _MeasureChip('TB', '${p.tinggiBadan} cm', Icons.height_rounded, AppColors.accent),
                    const SizedBox(width: 8),
                    if (p.lila != null)
                      _MeasureChip('LiLA', '${p.lila} cm', Icons.straighten_rounded, AppColors.orange),
                  ]),
                  const SizedBox(height: 8),
                  Text('Umur: ${p.umurBulan} bulan · Petugas: ${p.namaPetugas ?? '-'}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _MeasureChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}

class _ImunisasiTabPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const EmptyState(icon: Icons.vaccines_outlined, title: 'Belum ada riwayat imunisasi');
  }
}

// ═══════════════════════════════════════
//  TAMBAH BALITA SCREEN
// ═══════════════════════════════════════
class _TambahBalitaScreen extends StatefulWidget {
  const _TambahBalitaScreen();
  @override
  State<_TambahBalitaScreen> createState() => _TambahBalitaScreenState();
}

class _TambahBalitaScreenState extends State<_TambahBalitaScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _namaCtrl    = TextEditingController();
  final _nikCtrl     = TextEditingController();
  final _kkCtrl      = TextEditingController();
  final _tempatCtrl  = TextEditingController();
  final _ayahCtrl    = TextEditingController();
  final _ibuCtrl     = TextEditingController();
  final _beratCtrl   = TextEditingController();
  final _panjangCtrl = TextEditingController();
  String _jk         = 'L';
  DateTime? _tglLahir;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _tglLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data wajib')));
      return;
    }
    final provider = context.read<BalitaProvider>();
    final ok = await provider.create({
      'nama': _namaCtrl.text.trim(),
      'jenis_kelamin': _jk,
      'tanggal_lahir': DateFormat('yyyy-MM-dd').format(_tglLahir!),
      if (_nikCtrl.text.isNotEmpty) 'nik': _nikCtrl.text.trim(),
      if (_kkCtrl.text.isNotEmpty) 'nomor_kk': _kkCtrl.text.trim(),
      if (_tempatCtrl.text.isNotEmpty) 'tempat_lahir': _tempatCtrl.text.trim(),
      if (_ayahCtrl.text.isNotEmpty) 'nama_ayah': _ayahCtrl.text.trim(),
      if (_ibuCtrl.text.isNotEmpty) 'nama_ibu': _ibuCtrl.text.trim(),
      if (_beratCtrl.text.isNotEmpty) 'berat_lahir': double.tryParse(_beratCtrl.text),
      if (_panjangCtrl.text.isNotEmpty) 'panjang_lahir': double.tryParse(_panjangCtrl.text),
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Balita berhasil didaftarkan'), backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gagal'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Balita'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              const Align(alignment: Alignment.centerLeft, child: Text('Data Balita', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
              const SizedBox(height: 12),
              _field(_namaCtrl, 'Nama Lengkap *', required: true),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Jenis Kelamin: ', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Laki-laki'), selected: _jk == 'L', onSelected: (_) => setState(() => _jk = 'L'),
                    selectedColor: AppColors.primaryLighter),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Perempuan'), selected: _jk == 'P', onSelected: (_) => setState(() => _jk = 'P'),
                    selectedColor: const Color(0xFFFFE4F0)),
              ]),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context, initialDate: DateTime.now().subtract(const Duration(days: 365)),
                    firstDate: DateTime(2018), lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _tglLahir = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12), color: Colors.white),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _tglLahir == null ? 'Pilih tanggal lahir *' : DateFormat('d MMMM yyyy').format(_tglLahir!),
                      style: TextStyle(color: _tglLahir == null ? AppColors.textHint : AppColors.textPrimary, fontSize: 13),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              _field(_tempatCtrl, 'Tempat Lahir'),
              const SizedBox(height: 12),
              _field(_nikCtrl, 'NIK Balita', type: TextInputType.number),
              const SizedBox(height: 12),
              _field(_kkCtrl, 'Nomor KK', type: TextInputType.number),
            ]))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              const Align(alignment: Alignment.centerLeft, child: Text('Data Lahir & Orang Tua', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_beratCtrl, 'Berat Lahir (kg)', type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _field(_panjangCtrl, 'Panjang Lahir (cm)', type: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              _field(_ayahCtrl, 'Nama Ayah'),
              const SizedBox(height: 12),
              _field(_ibuCtrl, 'Nama Ibu'),
            ]))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: Consumer<BalitaProvider>(
                builder: (_, p, __) => ElevatedButton(
                  onPressed: p.isLoading ? null : _submit,
                  child: p.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Data Balita'),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType type = TextInputType.text, bool required = false}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
      validator: required ? (v) => (v == null || v.isEmpty) ? '$label wajib diisi' : null : null,
    );
  }
}

// ═══════════════════════════════════════
//  TAMBAH PENIMBANGAN SCREEN
// ═══════════════════════════════════════
class _TambahPenimbanganScreen extends StatefulWidget {
  final BalitaModel balita;
  const _TambahPenimbanganScreen({required this.balita});
  @override
  State<_TambahPenimbanganScreen> createState() => _TambahPenimbanganScreenState();
}

class _TambahPenimbanganScreenState extends State<_TambahPenimbanganScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _bbCtrl    = TextEditingController();
  final _tbCtrl    = TextEditingController();
  final _lkCtrl    = TextEditingController();
  final _lilaCtrl  = TextEditingController();
  final _catatCtrl = TextEditingController();
  DateTime _tgl    = DateTime.now();
  bool _vitA = false, _cacing = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PenimbanganProvider>();
    final ok = await provider.create({
      'balita_id': widget.balita.id,
      'tanggal_penimbangan': DateFormat('yyyy-MM-dd').format(_tgl),
      'berat_badan': double.parse(_bbCtrl.text),
      if (_tbCtrl.text.isNotEmpty) 'tinggi_badan': double.tryParse(_tbCtrl.text),
      if (_lkCtrl.text.isNotEmpty) 'lingkar_kepala': double.tryParse(_lkCtrl.text),
      if (_lilaCtrl.text.isNotEmpty) 'lila': double.tryParse(_lilaCtrl.text),
      'vitamin_a': _vitA,
      'obat_cacing': _cacing,
      if (_catatCtrl.text.isNotEmpty) 'catatan': _catatCtrl.text,
    });
    if (!mounted) return;
    if (ok) {
      final result = provider.lastResult;
      Navigator.pop(context);
      if (result != null) {
        _showStatusGizi(result);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Penimbangan berhasil direkam'), backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gagal'), backgroundColor: AppColors.error));
    }
  }

  void _showStatusGizi(Map<String, dynamic> result) {
    final statusGizi = result['statusGizi'];
    if (statusGizi == null) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Hasil Penimbangan', textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${widget.balita.nama}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 12),
        StatusGiziBadge(kodeStatus: statusGizi['bbuStatus']?['kode'], label: statusGizi['bbuStatus']?['kategori']),
        const SizedBox(height: 12),
        Text('Z-Score BB/U: ${statusGizi['bbuZScore']}', style: const TextStyle(fontSize: 13)),
        if (statusGizi['umurBulan'] != null)
          Text('Umur: ${statusGizi['umurBulan']} bulan', style: const TextStyle(fontSize: 13)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timbang: ${widget.balita.nama}'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Header balita info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.child_care_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.balita.nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text('${widget.balita.jenisKelaminLabel} · ${widget.balita.umurBulan ?? '-'} bulan',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              const Align(alignment: Alignment.centerLeft, child: Text('Tanggal Penimbangan', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _tgl, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (d != null) setState(() => _tgl = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12), color: Colors.white),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(DateFormat('d MMMM yyyy').format(_tgl), style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text('Pengukuran', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bbCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Berat Badan (kg) *', prefixIcon: Icon(Icons.monitor_weight_rounded, color: AppColors.primary)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Berat badan wajib diisi';
                  if (double.tryParse(v) == null) return 'Format angka tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(
                  controller: _tbCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)', prefixIcon: Icon(Icons.height_rounded, color: AppColors.accent)),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _lkCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Lingkar Kepala (cm)', prefixIcon: Icon(Icons.circle_outlined, color: AppColors.orange)),
                )),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lilaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'LiLA (cm)', prefixIcon: Icon(Icons.straighten_rounded, color: AppColors.primary)),
              ),
              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text('Pemberian', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
              SwitchListTile(
                value: _vitA,
                onChanged: (v) => setState(() => _vitA = v),
                title: const Text('Vitamin A', style: TextStyle(fontSize: 13)),
                activeColor: AppColors.accent,
                dense: true,
              ),
              SwitchListTile(
                value: _cacing,
                onChanged: (v) => setState(() => _cacing = v),
                title: const Text('Obat Cacing', style: TextStyle(fontSize: 13)),
                activeColor: AppColors.accent,
                dense: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _catatCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)', prefixIcon: Icon(Icons.notes_rounded, color: AppColors.primary)),
              ),
            ]))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: Consumer<PenimbanganProvider>(
                builder: (_, p, __) => ElevatedButton(
                  onPressed: p.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: p.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Penimbangan'),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  JADWAL SCREEN
// ═══════════════════════════════════════
class _JadwalScreen extends StatefulWidget {
  const _JadwalScreen();
  @override
  State<_JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<_JadwalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<JadwalProvider>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Posyandu'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () => _showTambahJadwal(context),
        icon: const Icon(Icons.add),
        label: const Text('Buat Jadwal'),
        backgroundColor: AppColors.primary,
      ) : null,
      body: Consumer<JadwalProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) return const ShimmerList();
          if (provider.list.isEmpty) return const EmptyState(title: 'Belum ada jadwal', icon: Icons.calendar_today_rounded);
          return RefreshIndicator(
            onRefresh: () => provider.fetchAll(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.list.length,
              itemBuilder: (_, i) => _JadwalCard(jadwal: provider.list[i], showActions: isAdmin),
            ),
          );
        },
      ),
    );
  }

  void _showTambahJadwal(BuildContext context) {
    final judulCtrl = TextEditingController();
    final descrCtrl = TextEditingController();
    final lokasiCtrl = TextEditingController();
    DateTime tgl = DateTime.now().add(const Duration(days: 7));
    String jenis = 'penimbangan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Buat Jadwal Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 16),
            TextField(controller: judulCtrl, decoration: const InputDecoration(labelText: 'Judul Kegiatan *')),
            const SizedBox(height: 12),
            TextField(controller: descrCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 2),
            const SizedBox(height: 12),
            TextField(controller: lokasiCtrl, decoration: const InputDecoration(labelText: 'Lokasi *')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: jenis,
              decoration: const InputDecoration(labelText: 'Jenis Kegiatan'),
              items: AppConstants.jenisJadwal.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) => setModal(() => jenis = v!),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: tgl, firstDate: DateTime.now(), lastDate: DateTime(2030));
                if (d != null) setModal(() => tgl = d);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12), color: Colors.white),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(DateFormat('d MMMM yyyy').format(tgl)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (judulCtrl.text.isEmpty || lokasiCtrl.text.isEmpty) return;
                  final ok = await context.read<JadwalProvider>().create({
                    'judul': judulCtrl.text,
                    'deskripsi': descrCtrl.text,
                    'lokasi': lokasiCtrl.text,
                    'tanggal': DateFormat('yyyy-MM-dd').format(tgl),
                    'jam_mulai': '08:00:00',
                    'jenis': jenis,
                    'is_published': true,
                  });
                  if (ok && context.mounted) Navigator.pop(context);
                },
                child: const Text('Simpan Jadwal'),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  NOTIFIKASI SCREEN
// ═══════════════════════════════════════
class _NotifikasiScreen extends StatefulWidget {
  const _NotifikasiScreen();
  @override
  State<_NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<_NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NotifikasiProvider>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.read<NotifikasiProvider>().markAllRead(),
            child: const Text('Baca Semua', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: Consumer<NotifikasiProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) return const ShimmerList();
          if (provider.list.isEmpty) return const EmptyState(title: 'Belum ada notifikasi', icon: Icons.notifications_off_rounded);
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.list.length,
            itemBuilder: (_, i) {
              final n = provider.list[i];
              return Card(
                color: n.isRead ? null : AppColors.primaryLighter.withOpacity(0.3),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _notifColor(n.tipe).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_notifIcon(n.tipe), color: _notifColor(n.tipe), size: 22),
                  ),
                  title: Text(n.judul, style: TextStyle(fontSize: 13, fontWeight: n.isRead ? FontWeight.normal : FontWeight.w700)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.pesan, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(n.createdAt != null ? DateFormat('d MMM · HH:mm').format(DateTime.parse(n.createdAt!)) : '',
                        style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                  ]),
                  onTap: () => provider.markRead(n.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _notifColor(String tipe) {
    switch (tipe) {
      case 'jadwal':    return AppColors.primary;
      case 'gizi':      return AppColors.statusBuruk;
      case 'imunisasi': return AppColors.accent;
      case 'peringatan': return AppColors.orange;
      default:          return AppColors.textSecondary;
    }
  }

  IconData _notifIcon(String tipe) {
    switch (tipe) {
      case 'jadwal':    return Icons.calendar_month_rounded;
      case 'gizi':      return Icons.warning_rounded;
      case 'imunisasi': return Icons.vaccines_rounded;
      default:          return Icons.notifications_rounded;
    }
  }
}

// ═══════════════════════════════════════
//  ARTIKEL SCREEN
// ═══════════════════════════════════════
class _ArtikelScreen extends StatefulWidget {
  const _ArtikelScreen();
  @override
  State<_ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<_ArtikelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ArtikelProvider>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Edukasi'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ArtikelProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) return const ShimmerList(itemHeight: 100);
          if (provider.list.isEmpty) return const EmptyState(title: 'Belum ada artikel', icon: Icons.article_rounded);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.list.length,
            itemBuilder: (_, i) {
              final a = provider.list[i];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ArtikelDetailScreen(artikelId: a.id))),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(color: AppColors.accentLighter, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.article_rounded, color: AppColors.accent, size: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.judul, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.accentLighter, borderRadius: BorderRadius.circular(20)),
                            child: Text(AppConstants.kategoriArtikel[a.kategori] ?? a.kategori,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
                          ),
                          const SizedBox(width: 8),
                          Text('${a.viewCount} views', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                        ]),
                      ])),
                      const Icon(Icons.chevron_right, color: AppColors.textHint),
                    ]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Artikel Detail ───
class _ArtikelDetailScreen extends StatefulWidget {
  final String artikelId;
  const _ArtikelDetailScreen({required this.artikelId});
  @override
  State<_ArtikelDetailScreen> createState() => _ArtikelDetailScreenState();
}

class _ArtikelDetailScreenState extends State<_ArtikelDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ArtikelProvider>().fetchById(widget.artikelId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtikelProvider>(
      builder: (_, provider, __) {
        final a = provider.selected;
        return Scaffold(
          appBar: AppBar(
            title: Text(a?.judul ?? 'Artikel'),
            flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : a == null
                  ? const EmptyState(title: 'Artikel tidak ditemukan')
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.judul, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.accentLighter, borderRadius: BorderRadius.circular(20)),
                            child: Text(AppConstants.kategoriArtikel[a.kategori] ?? a.kategori,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
                          ),
                          const SizedBox(width: 8),
                          Text('${a.viewCount} kali dibaca', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                          const Spacer(),
                          if (a.createdAt != null)
                            Text(DateFormat('d MMM yyyy').format(DateTime.parse(a.createdAt!)),
                                style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                        ]),
                        const Divider(height: 24),
                        Text(a.konten ?? '', style: const TextStyle(fontSize: 14, height: 1.7, color: AppColors.textPrimary)),
                      ]),
                    ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════
//  PROFILE SCREEN
// ═══════════════════════════════════════
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: SafeArea(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user?.name ?? '-', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(user?.isAdmin == true ? '👑 Admin' : '👤 Warga',
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ]),
              ),
            ),
            title: const Text('Profil Saya', style: TextStyle(color: Colors.white, fontSize: 16)),
            titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
          ),
          backgroundColor: AppColors.primary,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _ProfileCard(user),
              const SizedBox(height: 12),
              Card(child: Column(children: [
                _ProfileMenuItem(Icons.lock_outline, 'Ganti Password', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _GantiPasswordScreen()))),
                const Divider(height: 1, indent: 56),
                if (user?.isAdmin == true) ...[
                  _ProfileMenuItem(Icons.people_outline, 'Manajemen User', AppColors.accent, () {}),
                  const Divider(height: 1, indent: 56),
                  _ProfileMenuItem(Icons.bar_chart_rounded, 'Laporan', AppColors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _LaporanScreen()))),
                  const Divider(height: 1, indent: 56),
                ],
                _ProfileMenuItem(Icons.logout_rounded, 'Keluar', AppColors.error, () => _confirmLogout(context)),
              ])),
              const SizedBox(height: 24),
              const Text('POS Yandu v1.0.0', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _ProfileCard(UserModel? user) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      _ProfileRow(Icons.email_outlined, 'Email', user?.email ?? '-'),
      const Divider(height: 20),
      _ProfileRow(Icons.phone_outlined, 'Telepon', user?.phone ?? '-'),
      const Divider(height: 20),
      _ProfileRow(Icons.badge_outlined, 'NIK', user?.nik ?? '-'),
      const Divider(height: 20),
      _ProfileRow(Icons.home_outlined, 'Alamat', user?.address ?? '-'),
      if (user?.kelurahan != null) ...[
        const Divider(height: 20),
        _ProfileRow(Icons.location_city_outlined, 'Kelurahan', user!.kelurahan!),
      ],
    ])));
  }

  Widget _ProfileRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppColors.primary, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ])),
    ]);
  }

  Widget _ProfileMenuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Keluar'),
      content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); context.read<AuthProvider>().logout(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Keluar'),
        ),
      ],
    ));
  }
}

// ─── Ganti Password Screen ───
class _GantiPasswordScreen extends StatefulWidget {
  const _GantiPasswordScreen();
  @override
  State<_GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<_GantiPasswordScreen> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _o = true, _n = true, _c = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _pwField(_oldCtrl, 'Password Lama', _o, () => setState(() => _o = !_o)),
          const SizedBox(height: 12),
          _pwField(_newCtrl, 'Password Baru', _n, () => setState(() => _n = !_n)),
          const SizedBox(height: 12),
          _pwField(_confCtrl, 'Konfirmasi Password Baru', _c, () => setState(() => _c = !_c)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: Consumer<AuthProvider>(
              builder: (_, auth, __) => ElevatedButton(
                onPressed: auth.isLoading ? null : () async {
                  if (_newCtrl.text != _confCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password tidak sama')));
                    return;
                  }
                  final ok = await auth.changePassword(_oldCtrl.text, _newCtrl.text);
                  if (!mounted) return;
                  if (ok) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Password berhasil diubah'), backgroundColor: AppColors.success));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Gagal'), backgroundColor: AppColors.error));
                  }
                },
                child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Password Baru'),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _pwField(TextEditingController c, String label, bool obs, VoidCallback toggle) {
    return TextFormField(
      controller: c,
      obscureText: obs,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(icon: Icon(obs ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: toggle),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  LAPORAN SCREEN (Admin)
// ═══════════════════════════════════════
class _LaporanScreen extends StatefulWidget {
  const _LaporanScreen();
  @override
  State<_LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<_LaporanScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  int _bulan = DateTime.now().month;
  int _tahun = DateTime.now().year;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.instance.get('/laporan/bulanan', params: {'bulan': _bulan, 'tahun': _tahun});
      setState(() { _data = res.data['data']; _isLoading = false; });
    } catch (_) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? EmptyState(title: 'Gagal memuat laporan', onRetry: _fetch)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Pilih bulan/tahun
                    Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                      Expanded(child: DropdownButtonFormField<int>(
                        value: _bulan,
                        decoration: const InputDecoration(labelText: 'Bulan', isDense: true),
                        items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(2024, i + 1))))),
                        onChanged: (v) => setState(() => _bulan = v!),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: DropdownButtonFormField<int>(
                        value: _tahun,
                        decoration: const InputDecoration(labelText: 'Tahun', isDense: true),
                        items: [2023, 2024, 2025].map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                        onChanged: (v) => setState(() => _tahun = v!),
                      )),
                      const SizedBox(width: 12),
                      ElevatedButton(onPressed: _fetch, child: const Text('Lihat')),
                    ]))),
                    const SizedBox(height: 12),

                    // Ringkasan
                      final r = _data!['ringkasan'] as Map<String, dynamic>;
                    _LaporanSection('Ringkasan', [
                      _LaporanRow('Total Balita Terdaftar', '${r['totalBalitaTerdaftar']}'),
                      _LaporanRow('Balita Ditimbang', '${r['balitaDitimbang']}'),
                      _LaporanRow('Cakupan', '${r['cakupanPersen']}%'),
                      _LaporanRow('Gizi Baik', '${r['gizi_baik'] ?? 0}'),
                      _LaporanRow('Gizi Kurang', '${r['gizi_kurang'] ?? 0}'),
                      _LaporanRow('Gizi Buruk', '${r['gizi_buruk'] ?? 0}'),
                      _LaporanRow('Dapat Vitamin A', '${r['dapat_vitamin_a'] ?? 0}'),
                    ]),
                  ]),
                ),
    );
  }

  Widget _LaporanSection(String title, List<Widget> rows) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
      const Divider(height: 16),
      ...rows,
    ])));
  }

  Widget _LaporanRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]));
  }
}

// ─── Helper Widgets ───
class _JadwalCard extends StatelessWidget {
  final JadwalModel jadwal;
  final bool showActions;
  const _JadwalCard({required this.jadwal, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.primaryLighter, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.event_rounded, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(jadwal.judul, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
              JenisJadwalChip(jenis: jadwal.jenis),
            ]),
            const SizedBox(height: 4),
            Text('${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(jadwal.tanggal))} · ${jadwal.jamMulai.substring(0, 5)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textHint),
              const SizedBox(width: 2),
              Expanded(child: Text(jadwal.lokasi, style: const TextStyle(fontSize: 11, color: AppColors.textHint), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class _BalitaMiniCard extends StatelessWidget {
  final BalitaModel balita;
  const _BalitaMiniCard({required this.balita});

  @override
  Widget build(BuildContext context) {
    final isBoy = balita.jenisKelamin == 'L';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _BalitaDetailScreen(balitaId: balita.id))),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isBoy ? AppColors.primaryGradient : AppColors.orangeGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: (isBoy ? AppColors.primary : AppColors.orange).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(isBoy ? Icons.boy_rounded : Icons.girl_rounded, color: Colors.white, size: 32),
          const Spacer(),
          Text(balita.nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          Text('${balita.umurBulan ?? '-'} bln', style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
      ),
    );
  }
}

class _EmptyBalitaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _TambahBalitaScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryLighter, width: 2, style: BorderStyle.none),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primaryLighter.withOpacity(0.3),
        ),
        child: Row(children: [
          const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          const Expanded(child: Text('Daftarkan balita Anda', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }
}



// ═══════════════════════════════════════
//  NOTIFICATION BELL WIDGET
// ═══════════════════════════════════════
class _NotifBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotifikasiProvider>(
      builder: (_, provider, __) {
        return Stack(children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
            onPressed: () {
              // Navigate to notifications - handled by bottom nav
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buka tab Notifikasi untuk melihat semua'), duration: Duration(seconds: 2)),
              );
            },
          ),
          if (provider.unreadCount > 0)
            Positioned(
              right: 8, top: 8,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    provider.unreadCount > 9 ? '9+' : '${provider.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ]);
      },
    );
  }
}
