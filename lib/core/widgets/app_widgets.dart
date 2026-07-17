import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

// ─── Loading Shimmer List ───
class ShimmerList extends StatelessWidget {
  final int count;
  final double itemHeight;
  const ShimmerList({super.key, this.count = 5, this.itemHeight = 80});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          height: itemHeight,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

// ─── Empty State ───
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRetry;

  const EmptyState({super.key, required this.title, this.subtitle, this.icon = Icons.inbox_rounded, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.primaryLighter, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─── Status Gizi Badge ───
class StatusGiziBadge extends StatelessWidget {
  final String? kode;
  final String? label;
  const StatusGiziBadge({super.key, this.kode, this.label});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusGiziColor(kode);
    final text  = label ?? AppConstants.statusGiziLabel[kode] ?? kode ?? '-';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ─── Stat Card ───
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: Colors.white, size: 28),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
      ),
    );
  }
}

// ─── Section Header ───
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Icon(Icons.chevron_right, size: 16),
            ]),
          ),
      ]),
    );
  }
}

// ─── Jenis Jadwal Chip ───
class JenisJadwalChip extends StatelessWidget {
  final String jenis;
  const JenisJadwalChip({super.key, required this.jenis});

  Color get _color {
    switch (jenis) {
      case 'penimbangan': return AppColors.primary;
      case 'imunisasi':   return AppColors.accent;
      case 'penyuluhan':  return AppColors.orange;
      default:            return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (jenis) {
      case 'penimbangan': return Icons.monitor_weight_outlined;
      case 'imunisasi':   return Icons.vaccines_outlined;
      case 'penyuluhan':  return Icons.school_outlined;
      case 'pemeriksaan': return Icons.medical_services_outlined;
      default:            return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = AppConstants.jenisJadwal[jenis] ?? jenis;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_icon, size: 12, color: _color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _color)),
      ]),
    );
  }
}

// ─── Network image with fallback ───
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const AppNetworkImage({super.key, this.url, this.width = 60, this.height = 60, this.fit = BoxFit.cover, this.borderRadius, this.placeholder});

  @override
  Widget build(BuildContext context) {
    final fullUrl = url != null ? '${AppConstants.uploadBaseUrl}$url' : null;
    final child   = fullUrl != null
        ? CachedNetworkImage(
            imageUrl: fullUrl,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, __) => _fallback,
            errorWidget: (_, __, ___) => _fallback,
          )
        : _fallback;

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget get _fallback => placeholder ?? Container(
    width: width, height: height, color: AppColors.primaryLighter,
    child: const Icon(Icons.child_care, color: AppColors.primary),
  );
}

// ─── Custom AppBar with gradient ───
PreferredSizeWidget gradientAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = true,
  BuildContext? context,
}) {
  return AppBar(
    title: Text(title),
    flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
    actions: actions,
    leading: showBack && context != null
        ? IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context))
        : null,
    backgroundColor: Colors.transparent,
  );
}

// ─── Status Tensi Badge ───
class StatusTensiBadge extends StatelessWidget {
  final String? kode;
  final String? label;
  const StatusTensiBadge({super.key, this.kode, this.label});

  Color get _color {
    switch (kode) {
      case 'normal':         return AppColors.statusBaik;
      case 'pra-hipertensi': return AppColors.statusWarning;
      case 'hipertensi-1':   return AppColors.statusKurang;
      case 'hipertensi-2':   return AppColors.statusBuruk;
      default:               return AppColors.textSecondary;
    }
  }

  String get _label {
    if (label != null) return label!;
    switch (kode) {
      case 'normal':         return 'Normal';
      case 'pra-hipertensi': return 'Pra-Hipertensi';
      case 'hipertensi-1':   return 'Hipertensi 1';
      case 'hipertensi-2':   return 'Hipertensi 2';
      default:               return kode ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.monitor_heart_rounded, size: 10, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(_label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
