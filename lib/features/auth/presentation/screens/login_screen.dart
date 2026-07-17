import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _identifierCtrl = TextEditingController();
  final _passCtrl       = TextEditingController();
  bool _obscure = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); _identifierCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_identifierCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No. HP dan password wajib diisi'), backgroundColor: AppColors.error));
      return;
    }
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(_identifierCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Login gagal'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Gradient header
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(52), bottomRight: Radius.circular(52)),
          ),
        ),
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                const SizedBox(height: 36),
                // Logo
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.local_hospital_rounded, size: 54, color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                const Text('POS Yandu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                const Text('Posyandu & Posbindu RW 05', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 36),

                // Form card
                Card(
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Masuk', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Masukkan No. HP dan password Anda', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _identifierCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'No. HP / Email',
                          prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.primary),
                          hintText: '08xxxxxxxxxx',
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      Consumer<AuthProvider>(
                        builder: (_, auth, __) => SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            child: auth.isLoading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : const Text('Masuk'),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 28),
                // Role info chips
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _roleChip(Icons.admin_panel_settings_rounded, 'RW', AppColors.primary),
                  const SizedBox(width: 8),
                  _roleChip(Icons.badge_rounded, 'Kader', AppColors.accent),
                  const SizedBox(width: 8),
                  _roleChip(Icons.person_rounded, 'Warga', AppColors.orange),
                ]),
                const SizedBox(height: 20),
                const Text('v2.0.0 — Skripsi Ryan', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _roleChip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}
