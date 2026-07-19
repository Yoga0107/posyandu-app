// ═══════════════════════════════════════════════════════════════
//  CATATAN PERBAIKAN:
//  Layar ini semula adalah "Register" (buat akun baru: nama, email,
//  password, dst) dan memanggil AuthProvider.register(...) — method
//  yang TIDAK ADA di AuthProvider maupun di backend (tidak ada route
//  POST /auth/register di routes/index.routes.js). Akun kader/warga
//  hanya bisa dibuat oleh RW lewat endpoint admin (POST /users),
//  bukan self sign-up.
//
//  Yang benar-benar didukung backend untuk warga/kader yang SUDAH
//  login adalah mendaftarkan data warga (balita/lansia) lewat
//  POST /warga — makanya layar ini diubah menjadi form "Tambah Data
//  Warga", memakai WargaProvider.create() yang sudah sesuai dengan
//  warga.controller.js.
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/providers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _namaCtrl         = TextEditingController();
  final _nikCtrl          = TextEditingController();
  final _alamatCtrl       = TextEditingController();
  final _namaOrangTuaCtrl = TextEditingController();

  DateTime? _tanggalLahir;
  String _jenisKelamin = 'L';   // 'L' | 'P'
  String _kategori     = 'balita'; // 'balita' | 'lansia'

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _alamatCtrl.dispose();
    _namaOrangTuaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTanggalLahir() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 1),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir wajib diisi'), backgroundColor: AppColors.error),
      );
      return;
    }

    final warga = context.read<WargaProvider>();
    final tglStr =
        '${_tanggalLahir!.year.toString().padLeft(4, '0')}-${_tanggalLahir!.month.toString().padLeft(2, '0')}-${_tanggalLahir!.day.toString().padLeft(2, '0')}';

    final ok = await warga.create({
      'nama': _namaCtrl.text.trim(),
      'nik': _nikCtrl.text.trim(),
      'tanggal_lahir': tglStr,
      'jenis_kelamin': _jenisKelamin,
      'kategori': _kategori,
      'nama_orang_tua': _namaOrangTuaCtrl.text.trim().isNotEmpty ? _namaOrangTuaCtrl.text.trim() : null,
      'alamat': _alamatCtrl.text.trim().isNotEmpty ? _alamatCtrl.text.trim() : null,
    });

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data warga berhasil didaftarkan'), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(warga.error ?? 'Gagal mendaftarkan data warga'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tambah Data Warga')),
      body: Consumer<WargaProvider>(
        builder: (_, warga, __) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Kategori
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: _kategoriChip('balita', 'Balita', Icons.child_care_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kategoriChip('lansia', 'Lansia', Icons.elderly_rounded),
                ),
              ]),
              const SizedBox(height: 20),

              TextFormField(
                controller: _namaCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _kategori == 'balita' ? 'Nama Balita' : 'Nama Lansia',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? '${_kategori == 'balita' ? 'Nama balita' : 'Nama lansia'} wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nikCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'NIK (16 digit)', prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'NIK wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickTanggalLahir,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal Lahir', prefixIcon: Icon(Icons.cake_outlined, color: AppColors.primary)),
                  child: Text(
                    _tanggalLahir == null
                        ? 'Pilih tanggal'
                        : '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}',
                    style: TextStyle(color: _tanggalLahir == null ? AppColors.textHint : AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
              Row(children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'L', groupValue: _jenisKelamin, dense: true, contentPadding: EdgeInsets.zero,
                    title: const Text('Laki-laki', style: TextStyle(fontSize: 13)),
                    onChanged: (v) => setState(() => _jenisKelamin = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'P', groupValue: _jenisKelamin, dense: true, contentPadding: EdgeInsets.zero,
                    title: const Text('Perempuan', style: TextStyle(fontSize: 13)),
                    onChanged: (v) => setState(() => _jenisKelamin = v!),
                  ),
                ),
              ]),
              const SizedBox(height: 8),

              if (_kategori == 'balita') ...[
                TextFormField(
                  controller: _namaOrangTuaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Orang Tua/Wali', prefixIcon: Icon(Icons.people_outline, color: AppColors.primary)),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _alamatCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Alamat', prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary)),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: warga.isLoading ? null : _submit,
                  child: warga.isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kategoriChip(String value, String label, IconData icon) {
    final selected = _kategori == value;
    return InkWell(
      onTap: () => setState(() => _kategori = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }
}
