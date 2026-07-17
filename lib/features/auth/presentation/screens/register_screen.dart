import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _nikCtrl       = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _rtRwCtrl      = TextEditingController();
  final _kelurahanCtrl = TextEditingController();
  bool _obscure    = true;
  bool _obscure2   = true;
  int  _currentStep = 0;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _passCtrl, _confirmCtrl, _phoneCtrl, _nikCtrl, _addressCtrl, _rtRwCtrl, _kelurahanCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      nik: _nikCtrl.text.trim().isNotEmpty ? _nikCtrl.text.trim() : null,
      address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
      rtRw: _rtRwCtrl.text.trim().isNotEmpty ? _rtRwCtrl.text.trim() : null,
      kelurahan: _kelurahanCtrl.text.trim().isNotEmpty ? _kelurahanCtrl.text.trim() : null,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'Registrasi gagal'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) {
              // Validasi step 1
              if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty ||
                  _passCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lengkapi data akun terlebih dahulu')));
                return;
              }
              setState(() => _currentStep = 1);
            } else {
              _register();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
            else Navigator.pop(context);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(children: [
                Expanded(
                  child: Consumer<AuthProvider>(
                    builder: (_, auth, __) => ElevatedButton(
                      onPressed: auth.isLoading ? null : details.onStepContinue,
                      child: auth.isLoading && _currentStep == 1
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_currentStep == 0 ? 'Lanjut' : 'Daftar Sekarang'),
                    ),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Kembali'),
                    ),
                  ),
                ],
              ]),
            );
          },
          steps: [
            Step(
              title: const Text('Data Akun'),
              subtitle: const Text('Email & password'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(children: [
                _buildField(_nameCtrl, 'Nama Lengkap', Icons.person_outline, required: true),
                const SizedBox(height: 12),
                _buildField(_emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress, required: true),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Password tidak sama';
                    return null;
                  },
                ),
              ]),
            ),
            Step(
              title: const Text('Data Pribadi'),
              subtitle: const Text('Opsional'),
              isActive: _currentStep >= 1,
              content: Column(children: [
                _buildField(_phoneCtrl, 'No. HP', Icons.phone_outlined, type: TextInputType.phone),
                const SizedBox(height: 12),
                _buildField(_nikCtrl, 'NIK (16 digit)', Icons.badge_outlined, type: TextInputType.number),
                const SizedBox(height: 12),
                _buildField(_addressCtrl, 'Alamat', Icons.home_outlined, maxLines: 2),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildField(_rtRwCtrl, 'RT/RW', Icons.map_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_kelurahanCtrl, 'Kelurahan', Icons.location_city_outlined)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? '$label wajib diisi' : null
          : null,
    );
  }
}
