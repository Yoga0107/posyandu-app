// ═══════════════════════════════════════════════════════════════
//  KALENDER JADWAL (WARGA)
//  Fitur sederhana: hanya melihat jadwal kegiatan (mendatang &
//  sudah lewat) dalam tampilan kalender bulanan + daftar. Tidak
//  ada aksi tambah/ubah/hapus di sini — murni shortcut untuk
//  melihat jadwal, memakai endpoint & provider yang sudah ada
//  (GET /api/jadwal via JadwalProvider.fetchAll()).
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posyandu_app/features/dashboard/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/providers.dart';
import '../../../auth/data/models/models.dart';

String _fmtTanggalPanjang(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}

DateTime? _asDate(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  try {
    final d = DateTime.parse(iso);
    return DateTime(d.year, d.month, d.day);
  } catch (_) {
    return null;
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class JadwalKalenderScreen extends StatefulWidget {
  const JadwalKalenderScreen({super.key});

  @override
  State<JadwalKalenderScreen> createState() => _JadwalKalenderScreenState();
}

class _JadwalKalenderScreenState extends State<JadwalKalenderScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    // Ambil semua jadwal (tanpa filter upcoming) supaya dapat
    // data mendatang maupun yang sudah lewat sekaligus.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() => context.read<JadwalProvider>().fetchAll();

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Jadwal')),
      body: Consumer<JadwalProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const ShimmerList(count: 6, itemHeight: 70);
          }

          final all = provider.list;

          // Kelompokkan jadwal per tanggal (untuk penanda titik di kalender)
          final Map<DateTime, List<JadwalModel>> byDate = {};
          for (final j in all) {
            final d = _asDate(j.tanggal);
            if (d == null) continue;
            byDate.putIfAbsent(d, () => []).add(j);
          }

          final todayDate = DateTime(_today.year, _today.month, _today.day);

          // Mendatang: >= hari ini, urut naik. Sudah lewat: < hari ini, urut turun.
          final upcoming = all.where((j) {
            final d = _asDate(j.tanggal);
            return d != null && !d.isBefore(todayDate);
          }).toList()
            ..sort((a, b) => a.tanggal.compareTo(b.tanggal));
          final past = all.where((j) {
            final d = _asDate(j.tanggal);
            return d != null && d.isBefore(todayDate);
          }).toList()
            ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

          final selectedList = _selectedDay == null
              ? null
              : (byDate[_selectedDay!] ?? const <JadwalModel>[]);

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _MonthHeader(
                  focusedMonth: _focusedMonth,
                  onPrev: () => _changeMonth(-1),
                  onNext: () => _changeMonth(1),
                ),
                _CalendarGrid(
                  focusedMonth: _focusedMonth,
                  today: todayDate,
                  selectedDay: _selectedDay,
                  markedDays: byDate.keys.toSet(),
                  onSelectDay: (d) {
                    setState(() {
                      _selectedDay = (_selectedDay != null && _isSameDay(_selectedDay!, d)) ? null : d;
                    });
                  },
                ),
                const SizedBox(height: 8),
                if (selectedList != null) ...[
                  SectionHeader(
                    title: DateFormat('EEEE, d MMM yyyy', 'id_ID').format(_selectedDay!),
                    actionLabel: 'Lihat semua',
                    onAction: () => setState(() => _selectedDay = null),
                  ),
                  if (selectedList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Tidak ada jadwal pada tanggal ini',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ...selectedList.map((j) => _JadwalListTile(jadwal: j)),
                ] else ...[
                  SectionHeader(title: 'Jadwal Mendatang (${upcoming.length})'),
                  if (upcoming.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Tidak ada jadwal mendatang',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ...upcoming.map((j) => _JadwalListTile(jadwal: j)),
                  const SizedBox(height: 8),
                  SectionHeader(title: 'Jadwal Sudah Lewat (${past.length})'),
                  if (past.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Belum ada riwayat jadwal',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ...past.map((j) => _JadwalListTile(jadwal: j, isPast: true)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Header bulan + navigasi ───
class _MonthHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthHeader({required this.focusedMonth, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left_rounded)),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(focusedMonth),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded)),
        ],
      ),
    );
  }
}

// ─── Grid kalender bulanan sederhana ───
class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime today;
  final DateTime? selectedDay;
  final Set<DateTime> markedDays;
  final ValueChanged<DateTime> onSelectDay;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.today,
    required this.selectedDay,
    required this.markedDays,
    required this.onSelectDay,
  });

  static const _hariLabel = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    // 0 = Minggu ... 6 = Sabtu
    final leadingBlanks = firstDayOfMonth.weekday % 7;

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final isToday = _isSameDay(date, today);
      final isSelected = selectedDay != null && _isSameDay(date, selectedDay!);
      final hasJadwal = markedDays.contains(date);
      final isPastDay = date.isBefore(today);

      cells.add(
        GestureDetector(
          onTap: () => onSelectDay(date),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isToday
                      ? AppColors.primaryLighter
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isPastDay
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                  ),
                ),
                if (hasJadwal)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : AppColors.orange,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: _hariLabel
                  .map((h) => Expanded(
                        child: Center(
                          child: Text(h,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1,
              children: cells,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Baris ringkas untuk satu jadwal (view-only) ───
class _JadwalListTile extends StatelessWidget {
  final JadwalModel jadwal;
  final bool isPast;
  const _JadwalListTile({required this.jadwal, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => JadwalDetailScreen(jadwalId: jadwal.id))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPast ? AppColors.border.withOpacity(0.4) : AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPast ? Icons.history_rounded : Icons.event_rounded,
                  color: isPast ? AppColors.textHint : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(jadwal.lokasi,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                        JenisJadwalChip(jenis: jadwal.jenisKegiatan),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${_fmtTanggalPanjang(jadwal.tanggal)} · ${jadwal.jam}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}