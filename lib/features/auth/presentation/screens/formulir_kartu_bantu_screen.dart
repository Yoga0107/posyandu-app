// ═══════════════════════════════════════════════════════════════
//  FORMULIR KARTU BANTU (statis)
//  Daftar formulir/kartu bantu resmi (Sasaran, Formulir, Link Download).
//  Semua link Google Drive di bawah masih PLACEHOLDER — ganti setiap
//  `url` pada `_kartuBantuList` dengan link Google Drive asli
//  masing-masing formulir sebelum dipakai produksi.
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class KartuBantuItem {
  final int no;
  final String sasaran;
  final String formulir;
  final String url;
  const KartuBantuItem({
    required this.no,
    required this.sasaran,
    required this.formulir,
    required this.url,
  });
}

// TODO: link untuk "Kartu Pemeriksaan Usia Produktif dan Lansia" belum
// diberikan — ganti placeholder ini kalau linknya sudah ada.
const String _placeholderDriveUrl =
    'https://drive.google.com/drive/folders/GANTI_DENGAN_ID_FOLDER_ANDA';

const List<KartuBantuItem> _kartuBantuList = [
  KartuBantuItem(no: 1, sasaran: 'Bumil, Bufas, dan Busui', formulir: 'Data Sasaran Ibu Hamil, Nifas, dan Menyusui', url: 'https://drive.google.com/file/d/1KLR0Q8OapH3NMPXmGlxA6b0qJaH4AT8h/view?usp=drive_link'),
  KartuBantuItem(no: 2, sasaran: 'Bumil, Bufas, dan Busui', formulir: 'Kartu Pemeriksaan Ibu Hamil, Nifas, dan Menyusui', url: 'https://drive.google.com/file/d/1zTKSTnFitskIOTUTuL__eDv8Ev0COmrK/view?usp=drive_link'),
  KartuBantuItem(no: 3, sasaran: 'Bumil, Bufas, dan Busui', formulir: 'Rekapitulasi Hasil Pemeriksaan Ibu Hamil, Nifas, dan Menyusui', url: 'https://drive.google.com/file/d/1AqJKR8JuqhYw2BqKUgDM4Wjn4QyVXHin/view?usp=drive_link'),
  KartuBantuItem(no: 4, sasaran: 'Bayi, Balita, dan Apras', formulir: 'Data Sasaran Bayi, Balita, dan Anak Pra-Sekolah', url: 'https://drive.google.com/file/d/1SSaOi03DiYQqogLwEyoUsPh8P5Gfj6vU/view?usp=drive_link'),
  KartuBantuItem(no: 5, sasaran: 'Bayi, Balita, dan Apras', formulir: 'Kartu Pemeriksaan Bayi, Balita, dan Anak Pra-Sekolah', url: 'https://drive.google.com/file/d/165vtbN-4tmX9OtSziesvnmLnvxHPzEJo/view?usp=drive_link'),
  KartuBantuItem(no: 6, sasaran: 'Bayi, Balita, dan Apras', formulir: 'Rekapitulasi Hasil Pemeriksaan Bayi, Balita, dan Anak Pra-Sekolah', url: 'https://drive.google.com/file/d/1SsXFiUy8mqhFR2jWZCk1c59gGtxyvsKQ/view?usp=drive_link'),
  KartuBantuItem(no: 7, sasaran: 'Usia Sekolah dan Remaja', formulir: 'Data Sasaran Usia Sekolah dan Remaja', url: 'https://drive.google.com/file/d/1aSWmz-hwP0nfpUUXjHvaC_94Mb9LiJV8/view?usp=drive_link'),
  KartuBantuItem(no: 8, sasaran: 'Usia Sekolah dan Remaja', formulir: 'Kartu Pemeriksaan Usia Sekolah dan Remaja', url: 'https://drive.google.com/file/d/1QoQG7gMImDeTj0YXMkCitXER29epFnra/view?usp=drive_link'),
  KartuBantuItem(no: 9, sasaran: 'Usia Sekolah dan Remaja', formulir: 'Rekapitulasi Hasil Pemeriksaan Usia Sekolah dan Remaja', url: 'https://drive.google.com/file/d/1AAdAv4oyzXfGuE7uLluIxRvxhQMSL5th/view?usp=drive_link'),
  KartuBantuItem(no: 10, sasaran: 'Dewasa dan Lansia', formulir: 'Data Sasaran Usia Produktif dan Lansia', url: 'https://drive.google.com/file/d/1iC8zRbRD1G76nWL-6l3PZFf6efyvTnbI/view?usp=drive_link'),
  KartuBantuItem(no: 11, sasaran: 'Dewasa dan Lansia', formulir: 'Kartu Pemeriksaan Usia Produktif dan Lansia', url: _placeholderDriveUrl),
  KartuBantuItem(no: 12, sasaran: 'Lansia', formulir: 'Kartu Pemeriksaan Lansia (ASK dan SKILAS)', url: 'https://drive.google.com/file/d/1PYc3Zjj423i2rHP8K_hM-pxRNi3AQenn/view?usp=drive_link'),
  KartuBantuItem(no: 13, sasaran: 'Dewasa dan Lansia', formulir: 'Rekapitulasi Hasil Pemeriksaan Usia Produktif dan Lansia', url: 'https://drive.google.com/file/d/1G2tRqtooyvn70WIDXJUUTAAJmuBdVVEM/view?usp=drive_link'),
];

class FormulirKartuBantuScreen extends StatelessWidget {
  const FormulirKartuBantuScreen({super.key});

  Color _colorFor(String sasaran) {
    switch (sasaran) {
      case 'Bumil, Bufas, dan Busui':
        return AppColors.accent;
      case 'Bayi, Balita, dan Apras':
        return AppColors.primary;
      case 'Usia Sekolah dan Remaja':
        return AppColors.orange;
      default: // Dewasa dan Lansia / Lansia
        return AppColors.error;
    }
  }

  Future<void> _download(BuildContext context, KartuBantuItem item) async {
    final uri = Uri.parse(item.url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tidak dapat membuka link. Pastikan ada aplikasi browser/Google Drive terpasang.'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulir Kartu Bantu')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _kartuBantuList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = _kartuBantuList[i];
          final color = _colorFor(item.sasaran);
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _download(context, item),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${item.no}',
                          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(item.sasaran,
                                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 6),
                          Text(item.formulir,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.3)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Download',
                      onPressed: () => _download(context, item),
                      icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}