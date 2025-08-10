import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/quiz/logic/quiz_bloc/quiz_bloc.dart';
import 'package:sundaart_sense/features/quiz/presentation/pages/quiz_results_page.dart';
import 'package:sundaart_sense/features/quiz/presentation/widgets/answer_option_widget.dart';
import 'package:sundaart_sense/features/quiz/presentation/widgets/quiz_progress_bar.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state.status == QuizStatus.completed) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => QuizResultsPage(
                score: state.score,
                totalQuestions: state.questions.length,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == QuizStatus.loading || state.status == QuizStatus.initial) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == QuizStatus.error) {
          return Scaffold(
            appBar: AppBar(title: const Text('Terjadi Kesalahan')),
            body: const Center(child: Text('Gagal memuat kuis')),
          );
        }

        final question = state.questions[state.currentQuestionIndex];

        final bool showResult = state.status == QuizStatus.answered;
        final int? selectedIndex = state.selectedAnswerIndex;
        final int correctIndex = question.correctAnswerIndex;

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: _GlassTopBar(
            title: 'Pertanyaan ${state.currentQuestionIndex + 1}/${state.questions.length}',
            titleColor: Colors.black,
            onClose: () => Navigator.of(context).pop(),
          ),
          body: Stack(
            children: [
              // BACKGROUND bahan blur
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
              // Overlay putih tipis
              Positioned.fill(
                child: Container(color: Colors.white.withOpacity(0.85)),
              ),

              // KONTEN
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24 + 56, 24, 24), // 56 ~ tinggi AppBar kaca
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QuizProgressBar(
                        totalQuestions: state.questions.length,
                        currentQuestion: state.currentQuestionIndex + 1,
                      ),
                      const SizedBox(height: 32),

                      // PANEL PERTANYAAN (glass)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF9B5BFF).withOpacity(0.12),
                                  Colors.white.withOpacity(0.10),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withOpacity(0.30)),
                            ),
                            child: Text(
                              question.questionText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // OPSI JAWABAN (logika tetap, hanya styling di AnswerOption)
                      ...List.generate(question.options.length, (index) {
                        final bool isSelected = selectedIndex == index;
                        final bool isCorrect  = index == correctIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnswerOption(
                            optionText: question.options[index],
                            index: index,
                            currentState: state,
                            onTap: () => context.read<QuizBloc>().add(AnswerSelected(index)),
                            isSelected: isSelected,
                            isCorrect: isCorrect,
                            showResult: showResult,
                          ),
                        );
                      }),

                      const Spacer(),

                      // ⬇️ TOMBOL GLASS "Lanjut / Lihat Hasil"
                      if (state.status == QuizStatus.answered)
                        _GlassActionButton(
                          label: _isLastQuestion(state) ? 'Lihat Hasil' : 'Lanjut',
                          onPressed: () => context.read<QuizBloc>().add(NextQuestion()),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isLastQuestion(QuizState state) {
    return state.currentQuestionIndex == state.questions.length - 1;
  }
}

/// AppBar kaca (blur) — titleColor bisa diubah (hitam/putih)
class _GlassTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color titleColor;
  final VoidCallback onClose;
  const _GlassTopBar({
    required this.title,
    required this.onClose,
    this.titleColor = Colors.white,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: top, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: preferredSize.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.30),
                  const Color(0xFF9B5BFF).withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: titleColor),
                  onPressed: onClose,
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol aksi utama bergaya glass (blur + gradient ungu tipis + border)
class _GlassActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GlassActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
                    const Color(0xFF9B5BFF).withOpacity(0.26),
                    Colors.white.withOpacity(0.10),
                    const Color(0xFF7C3AED).withOpacity(0.24),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.30)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
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
