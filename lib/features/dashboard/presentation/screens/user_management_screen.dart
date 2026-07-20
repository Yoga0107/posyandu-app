// ═══════════════════════════════════════════════════════════════
//  MANAJEMEN PENGGUNA (khusus RW)
//  Kelola akun Kader & Warga: lihat daftar, buat akun baru, dan
//  aktifkan/nonaktifkan akun. Memakai endpoint yang sudah ada di
//  backend: GET/POST /api/users, PATCH /api/users/:id/toggle.
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/providers.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../auth/data/models/models.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchCtrl = TextEditingController();
  String? _roleFilter; // null = semua, 'kader', 'warga'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _fetch() => context.read<UserManagementProvider>().fetchAll(
      search: _searchCtrl.text.trim(), role: _roleFilter);

  Future<void> _toggle(UserModel u) async {
    final myId = context.read<AuthProvider>().user?.id;
    if (u.id == myId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tidak bisa menonaktifkan akun sendiri')));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(u.isActive ? 'Nonaktifkan Akun?' : 'Aktifkan Akun?'),
        content: Text(
            '${u.isActive ? 'Nonaktifkan' : 'Aktifkan'} akun "${u.nama}" (${u.roleLabel})?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya')),
        ],
      ),
    );
    if (confirm != true) return;
    final provider = context.read<UserManagementProvider>();
    final ok = await provider.toggleActive(u.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Status akun "${u.nama}" berhasil diubah'
          : (provider.error ?? 'Gagal mengubah status akun')),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  Future<void> _openCreateForm() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateUserSheet(),
    );
    if (created == true) _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pengguna')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateForm,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Akun'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama atau no. HP...',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          _fetch();
                        },
                      ),
              ),
              onSubmitted: (_) => _fetch(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _roleChip('Semua', null),
                const SizedBox(width: 8),
                _roleChip('Kader', 'kader'),
                const SizedBox(width: 8),
                _roleChip('Warga', 'warga'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<UserManagementProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading && provider.list.isEmpty) {
                  return const ShimmerList(count: 6, itemHeight: 76);
                }
                if (provider.list.isEmpty) {
                  return EmptyState(
                    title: 'Belum ada akun',
                    subtitle: provider.error ?? 'Tidak ada akun yang cocok',
                    onRetry: _fetch,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _fetch(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: provider.list.length,
                    itemBuilder: (_, i) =>
                        _UserTile(user: provider.list[i], onToggle: _toggle),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String label, String? value) {
    final selected = _roleFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _roleFilter = value);
        _fetch();
      },
      selectedColor: AppColors.primaryLighter,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      ),
    );
  }
}

// ─── Satu baris akun user ───
class _UserTile extends StatelessWidget {
  final UserModel user;
  final ValueChanged<UserModel> onToggle;
  const _UserTile({required this.user, required this.onToggle});

  Color get _roleColor {
    switch (user.role) {
      case 'rw':
        return AppColors.primary;
      case 'kader':
        return AppColors.orange;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _roleColor.withOpacity(0.15),
              child: Text(
                user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                style: TextStyle(color: _roleColor, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(user.noHp,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(user.roleLabel,
                          style: TextStyle(fontSize: 10, color: _roleColor, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (user.isActive ? AppColors.success : AppColors.error).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(user.isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                              fontSize: 10,
                              color: user.isActive ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ],
              ),
            ),
            Switch(
              value: user.isActive,
              activeTrackColor: AppColors.primary,
              onChanged: (_) => onToggle(user),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form bottom sheet: tambah akun kader/warga ───
class _CreateUserSheet extends StatefulWidget {
  const _CreateUserSheet();

  @override
  State<_CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends State<_CreateUserSheet> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'kader';

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noHpCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<UserManagementProvider>();
    final ok = await provider.createUser(
      nama: _namaCtrl.text.trim(),
      noHp: _noHpCtrl.text.trim(),
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      role: _role,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Akun berhasil dibuat'), backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.error ?? 'Gagal membuat akun'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: AppColors.border, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const Text('Tambah Akun Baru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),

                // Pilihan role
                Row(children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Kader'),
                      selected: _role == 'kader',
                      onSelected: (_) => setState(() => _role = 'kader'),
                      selectedColor: AppColors.primaryLighter,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Warga'),
                      selected: _role == 'warga',
                      onSelected: (_) => setState(() => _role = 'warga'),
                      selectedColor: AppColors.primaryLighter,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _namaCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noHpCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No. HP'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'No. HP wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email (opsional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (opsional)',
                    helperText: 'Kosongkan untuk pakai default: Posyandu@123',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Consumer<UserManagementProvider>(
                    builder: (_, provider, __) => FilledButton(
                      onPressed: provider.isSubmitting ? null : _submit,
                      child: provider.isSubmitting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}