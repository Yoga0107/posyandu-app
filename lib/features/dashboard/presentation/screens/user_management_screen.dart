// ═══════════════════════════════════════════════════════════════
//  Layar "Kelola Akun" — khusus role RW (admin).
//  Menyediakan CRUD akun kader & warga: List (GET /users),
//  Create (POST /users), Toggle aktif/nonaktif (PATCH /users/:id/toggle).
//  Tidak ada Delete akun sungguhan — dinonaktifkan (toggle) dipakai
//  sebagai soft-delete karena akun terhubung ke data warga & kunjungan
//  (backend memang tidak menyediakan endpoint hard-delete untuk user).
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/providers.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/data/models/models.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});
  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String? _roleFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() => context.read<UserManagementProvider>().fetchAll(role: _roleFilter);

  Future<void> _createSheet() async {
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController();
    final noHpCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'kader';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buat Akun Baru',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Kader'),
                        selected: role == 'kader',
                        onSelected: (_) => setSheetState(() => role = 'kader'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Warga'),
                        selected: role == 'warga',
                        onSelected: (_) => setSheetState(() => role = 'warga'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: namaCtrl,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noHpCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'No. HP'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'No. HP wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email (opsional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password (kosongkan = Posyandu@123)'),
                  ),
                  const SizedBox(height: 20),
                  Consumer<UserManagementProvider>(
                    builder: (_, provider, __) => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final ok = await provider.create({
                                  'nama': namaCtrl.text.trim(),
                                  'no_hp': noHpCtrl.text.trim(),
                                  if (emailCtrl.text.trim().isNotEmpty)
                                    'email': emailCtrl.text.trim(),
                                  if (passCtrl.text.isNotEmpty) 'password': passCtrl.text,
                                  'role': role,
                                });
                                if (!sheetContext.mounted) return;
                                if (ok) {
                                  Navigator.pop(sheetContext);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Akun berhasil dibuat'),
                                          backgroundColor: AppColors.success),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(
                                    content: Text(provider.error ?? 'Gagal membuat akun'),
                                    backgroundColor: AppColors.error,
                                  ));
                                }
                              },
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Simpan'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(UserModel u) async {
    final provider = context.read<UserManagementProvider>();
    final ok = await provider.toggle(u.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? '${u.nama} ${u.isActive ? 'dinonaktifkan' : 'diaktifkan'}'
          : (provider.error ?? 'Gagal mengubah status akun')),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Akun')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createSheet,
        tooltip: 'Buat Akun',
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            _chip(null, 'Semua'),
            const SizedBox(width: 8),
            _chip('kader', 'Kader'),
            const SizedBox(width: 8),
            _chip('warga', 'Warga'),
          ]),
        ),
        Expanded(
          child: Consumer<UserManagementProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) {
                return const ShimmerList(count: 6, itemHeight: 70);
              }
              if (provider.list.isEmpty) {
                return EmptyState(title: 'Belum ada akun', onRetry: _load);
              }
              return RefreshIndicator(
                onRefresh: () async => _load(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.list.length,
                  itemBuilder: (_, i) {
                    final u = provider.list[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              u.isKader ? AppColors.accentLighter : AppColors.primaryLighter,
                          child: Icon(
                            u.isKader ? Icons.badge_rounded : Icons.person_rounded,
                            color: u.isKader ? AppColors.accent : AppColors.primary,
                          ),
                        ),
                        title: Text(u.nama,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: Text('${u.roleLabel} · ${u.noHp}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        trailing: Switch(
                          value: u.isActive,
                          onChanged: (_) => _toggle(u),
                        ),
                      ),
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

  Widget _chip(String? value, String label) {
    final selected = _roleFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _roleFilter = value);
        _load();
      },
    );
  }
}