import 'dart:ui'; // ⬅️ perlu untuk BackdropFilter (blur)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/quiz/logic/quiz_bloc/quiz_bloc.dart';
import 'package:sundaart_sense/features/quiz/presentation/pages/quiz_page.dart';

class QuizHomePage extends StatelessWidget {
  const QuizHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true, // agar AppBar kaca benar2 blur
      appBar: const _GlassAppBar(title: 'Asah Wawasan'),
      body: Stack(
        children: [
          // BACKGROUND untuk bahan blur
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
          // Overlay putih tipis supaya konten nyaman dibaca
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),

          // PANEL KONTEN BERGAYA GLASS
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Gambar dari asset lokal
                        Image.asset(
                          'assets/images/quiz2.png',
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Uji Pengetahuan Budayamu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Jawab pertanyaan seputar sejarah, tradisi, dan kesenian Sunda untuk meraih skor tertinggi!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // TOMBOL GLASS "Mulai Kuis Sekarang"
                        _GlassButton(
                          label: 'Mulai Kuis Sekarang',
                          onPressed: () {
                            context.read<QuizBloc>().add(FetchQuiz());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const QuizPage()),
                            );
                          },
                          // ungu saat dipilih/tekan akan tetap kontras
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          gradientColors: [
                            const Color(0xFF9B5BFF).withOpacity(0.28),
                            Colors.white.withOpacity(0.10),
                            const Color(0xFF7C3AED).withOpacity(0.26),
                          ],
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

/// AppBar kaca dengan blur + ungu transparan
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
            child: const Center(
              child: Text(
                'Asah Wawasan',
                style: TextStyle(
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

/// Tombol bergaya glass (blur + gradient tipis + border putih)
class _GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final TextStyle? textStyle;
  final List<Color>? gradientColors;

  const _GlassButton({
    required this.onPressed,
    required this.label,
    this.textStyle,
    this.gradientColors,
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
                  colors: gradientColors ??
                      [
                        const Color(0xFF9B5BFF).withOpacity(0.24),
                        Colors.white.withOpacity(0.10),
                        const Color(0xFF7C3AED).withOpacity(0.22),
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
                child: Text(
                  label,
                  style: textStyle ??
                      const TextStyle(
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
