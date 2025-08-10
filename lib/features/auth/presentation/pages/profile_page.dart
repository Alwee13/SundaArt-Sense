import 'dart:ui'; // ⬅️ untuk BackdropFilter (blur)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/auth/logic/auth_bloc.dart';
import 'package:sundaart_sense/main.dart'; // untuk AuthGate setelah logout

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.status == AuthStatus.authenticated ? authState.user : null;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: const _GlassAppBar(title: 'Profil Saya'), // tanpa tombol back
        body: Stack(
          children: [
            // BACKGROUND: gradient ungu + overlay putih tipis (bahan blur)
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
            Positioned.fill(child: Container(color: Colors.white.withOpacity(0.85))),

            if (user == null)
              const Center(child: Text('Gagal memuat data pengguna.'))
            else
              SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 0),
                child: Column(
                  children: [
                    // ===== Konten bisa discroll =====
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF9B5BFF).withOpacity(0.12),
                                    Colors.white.withOpacity(0.10),
                                    const Color(0xFF7C3AED).withOpacity(0.10),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.32)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7C3AED).withOpacity(0.16),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // ... avatar, nama, email ...
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white.withOpacity(0.6),
                                    backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                                    child: user.photoURL == null
                                        ? Text(
                                            (user.displayName?.isNotEmpty ?? false)
                                                ? user.displayName!.substring(0, 1).toUpperCase()
                                                : 'A',
                                            style: const TextStyle(
                                              fontSize: 50,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF8A4DFF),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    user.displayName ?? 'Pengguna Baru',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    user.email ?? 'Tidak ada email',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Kartu Nama & Email
                                  _buildInfoCard(
                                    icon: Icons.badge_outlined,
                                    title: 'Nama',
                                    subtitle: user.displayName ?? 'Tidak ada nama',
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoCard(
                                    icon: Icons.email_outlined,
                                    title: 'Email',
                                    subtitle: user.email ?? 'Tidak ada email',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ===== Sticky Logout di atas navbar glass =====
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.only(bottom: 88), // jarak ekstra agar gak ketutup navbar
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _GlassButton(
                          label: 'Keluar (Logout)',
                          icon: Icons.logout,
                          onPressed: () => _confirmAndLogout(context),
                          textColor: Colors.white,
                          gradientColors: [
                            const Color(0xFFEF4444).withOpacity(0.28),
                            Colors.white.withOpacity(0.10),
                            const Color(0xFFDC2626).withOpacity(0.26),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Dialog konfirmasi + trigger event logout
  Future<void> _confirmAndLogout(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35), // overlay gelap tipis
      builder: (_) => const _GlassConfirmDialog(
        title: 'Konfirmasi Logout',
        message: 'Yakin ingin keluar dari akun ini?',
        confirmLabel: 'Logout',
        cancelLabel: 'Batal',
      ),
    );

    if (ok == true) {
      context.read<AuthBloc>().add(AuthSignOutRequested());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sedang logout...')),
      );
    }
  }

  // ====== Glass Info Card (reusable) ======
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9B5BFF).withOpacity(0.12),
                Colors.white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.14),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF8A4DFF)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ====== Glass AppBar tanpa tombol back ======
class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _GlassAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: top, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: preferredSize.height - 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9B5BFF).withOpacity(0.18),
                  Colors.white.withOpacity(0.12),
                  const Color(0xFF7C3AED).withOpacity(0.16),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors ??
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

class _GlassConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  const _GlassConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF9B5BFF).withOpacity(0.14),
                  Colors.white.withOpacity(0.10),
                  const Color(0xFF7C3AED).withOpacity(0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 36, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Tombol Batal (glass abu-abu)
                    Expanded(
                      child: _GlassButton(
                        label: cancelLabel,
                        icon: Icons.close,
                        onPressed: () => Navigator.pop(context, false),
                        textColor: const Color(0xFF1F2937),
                        gradientColors: [
                          Colors.white.withOpacity(0.22),
                          Colors.white.withOpacity(0.10),
                          Colors.white.withOpacity(0.18),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Logout (glass merah)
                    Expanded(
                      child: _GlassButton(
                        label: confirmLabel,
                        icon: Icons.logout,
                        onPressed: () => Navigator.pop(context, true),
                        textColor: Colors.white,
                        gradientColors: [
                          const Color(0xFFEF4444).withOpacity(0.34),
                          Colors.white.withOpacity(0.10),
                          const Color(0xFFDC2626).withOpacity(0.30),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

