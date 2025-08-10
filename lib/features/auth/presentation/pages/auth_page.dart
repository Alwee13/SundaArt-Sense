import 'dart:ui'; // untuk BackdropFilter (blur)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/auth/data/repositories/auth_repository.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Submit form (login/register)
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authRepo = context.read<AuthRepository>();
        if (_isLogin) {
          await authRepo.signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          await authRepo.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi Kesalahan: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // BACKGROUND: gradient ungu untuk bahan blur
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9B5BFF), Color(0xFF7C3AED)],
                ),
              ),
            ),
          ),
          // Overlay putih tipis supaya konten nyaman dibaca
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF9B5BFF).withOpacity(0.12),
                              Colors.white.withOpacity(0.10),
                              const Color(0xFF7C3AED).withOpacity(0.10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.16),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Judul
                              Text(
                                _isLogin
                                    ? 'Selamat Datang Kembali!'
                                    : 'Buat Akun Baru',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _isLogin
                                    ? 'Silakan masukkan data Anda.!'
                                    : 'Mulai petualangan budayamu sekarang.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Nama (hanya registrasi)
                              if (!_isLogin) ...[
                                _GlassTextField(
                                  controller: _nameController,
                                  hintText: 'Nama Lengkap',
                                  icon: Icons.person_outline,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Nama tidak boleh kosong'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Email
                              _GlassTextField(
                                controller: _emailController,
                                hintText: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                    (v == null || v.isEmpty || !v.contains('@'))
                                    ? 'Format email tidak valid'
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              // Password
                              _GlassTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Password minimal 6 karakter'
                                    : null,
                              ),
                              const SizedBox(height: 22),

                              // Tombol Aksi Utama
                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _GlassButton(
                                      label: _isLogin ? 'Masuk' : 'Daftar',
                                      onPressed: _submitForm,
                                      textColor: Colors.white,
                                      gradientColors: [
                                        const Color(0xFFFD5B71).withOpacity(
                                          0.34,
                                        ), // pink/merah lembut
                                        Colors.white.withOpacity(0.10),
                                        const Color(
                                          0xFFF43F5E,
                                        ).withOpacity(0.30),
                                      ],
                                    ),
                              const SizedBox(height: 24),

                              // Divider "atau lanjutkan"
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.35),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'atau lanjutkan dengan',
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.35),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Tombol Google (logo PNG asli, tidak diubah)
                              _GlassGoogleButton(
                                onPressed: () => context
                                    .read<AuthRepository>()
                                    .signInWithGoogle(),
                              ),
                              const SizedBox(height: 20),

                              // Switch mode
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin
                                        ? 'Belum punya akun?'
                                        : 'Sudah punya akun?',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _isLogin = !_isLogin),
                                    child: Text(
                                      _isLogin ? 'Daftar sekarang' : 'Masuk',
                                      style: const TextStyle(
                                        color: Color(0xFF8A4DFF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== Glass TextField ======
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GlassTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9B5BFF).withOpacity(0.12),
                Colors.white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF8A4DFF)),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.45)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ====== Glass Button reusable ======
class _GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final List<Color>? gradientColors;
  final Color textColor;

  const _GlassButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.gradientColors,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            splashColor: const Color(0xFF8A4DFF).withOpacity(0.25),
            highlightColor: Colors.white.withOpacity(0.06),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      gradientColors ??
                      [
                        const Color(0xFF9B5BFF).withOpacity(0.28),
                        Colors.white.withOpacity(0.10),
                        const Color(0xFF7C3AED).withOpacity(0.26),
                      ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.30)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ====== Glass Google Button (logo PNG asli, tanpa tint) ======
class _GlassGoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GlassGoogleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            splashColor: Colors.black.withOpacity(0.06),
            highlightColor: Colors.white.withOpacity(0.04),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.28),
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.22),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo PNG asli — TANPA tint
                  Image.asset(
                    'assets/images/google_logo.png',
                    height: 22,
                    width: 22,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
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
}
