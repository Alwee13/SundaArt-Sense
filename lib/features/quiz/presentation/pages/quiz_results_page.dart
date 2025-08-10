import 'dart:ui'; // ⬅️ untuk BackdropFilter (blur)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/auth/logic/auth_bloc.dart';
import 'package:sundaart_sense/features/quiz/logic/leaderboard_bloc/leaderboard_bloc.dart';
import 'package:sundaart_sense/features/quiz/logic/quiz_bloc/quiz_bloc.dart';
import 'package:sundaart_sense/features/quiz/presentation/pages/leaderboard_page.dart';

class QuizResultsPage extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultsPage({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    // Submit skor (logika asli) — biarkan seperti sebelumnya
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated) {
      final user = authState.user!;
      context.read<QuizBloc>().add(
            SubmitQuiz(
              userId: user.uid,
              userName: user.displayName ?? 'Pengguna Tanpa Nama',
            ),
          );
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // BACKGROUND: gradient ungu
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9B5BFF),
                    Color(0xFF7C3AED),
                  ],
                ),
              ),
            ),
          ),
          // Overlay putih tipis agar konten nyaman dibaca (bahan blur juga)
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),

          // PANEL HASIL (glass)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    width: 560, // biar bagus di tablet juga; di ponsel akan penuh max parent
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                      border: Border.all(color: Colors.white.withOpacity(0.32), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Ilustrasi
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/success.gif',
                              height: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(Icons.check_circle, size: 120, color: Colors.white.withOpacity(0.9)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Kuis Selesai!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skor Akhir Kamu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$score / $totalQuestions',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8A4DFF),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Tombol glass ke Leaderboard
                        _GlassButton(
                          label: 'Lihat Papan Peringkat',
                          onPressed: () {
                            context.read<LeaderboardBloc>().add(FetchLeaderboard());
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LeaderboardPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Teks kembali
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: Text(
                            'Kembali ke Beranda',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.55),
                            ),
                          ),
                        ),
                      ],
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

/// Tombol bergaya glass (blur + gradient tipis + border putih)
class _GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _GlassButton({
    required this.onPressed,
    required this.label,
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
                  colors: [
                    const Color(0xFF9B5BFF).withOpacity(0.28),
                    Colors.white.withOpacity(0.10),
                    const Color(0xFF7C3AED).withOpacity(0.26),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Lihat Papan Peringkat',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
