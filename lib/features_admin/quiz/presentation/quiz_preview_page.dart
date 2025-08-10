import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/quiz/logic/quiz_bloc/quiz_bloc.dart';
import 'package:sundaart_sense/features/quiz/presentation/widgets/answer_option_widget.dart';
import 'package:sundaart_sense/features/quiz/presentation/widgets/quiz_progress_bar.dart';

class QuizPreviewPage extends StatelessWidget {
  const QuizPreviewPage({super.key});

  // Fungsi untuk menampilkan dialog hasil
  void _showResultsDialog(BuildContext context, int score, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hasil Simulasi Kuis'),
        content: Text('Anda menjawab $score dari $total soal dengan benar.', style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Tutup dialog
              Navigator.of(context).pop(); // Kembali ke halaman manajemen kuis
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        // Saat kuis selesai, tampilkan dialog hasil
        if (state.status == QuizStatus.completed) {
          _showResultsDialog(context, state.score, state.questions.length);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Pratinjau Kuis'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            if (state.status == QuizStatus.loading || state.status == QuizStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == QuizStatus.error) {
              return Center(child: Text('Gagal memuat pratinjau: ${state.errorMessage}'));
            }

            if (state.questions.isEmpty) {
              return const Center(child: Text('Tidak ada soal untuk ditampilkan.'));
            }

            final question = state.questions[state.currentQuestionIndex];

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  QuizProgressBar(
                    totalQuestions: state.questions.length,
                    currentQuestion: state.currentQuestionIndex + 1,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    question.questionText,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ...List.generate(question.options.length, (index) {
                    return AnswerOption(
                      optionText: question.options[index],
                      index: index,
                      currentState: state,
                      onTap: () => context.read<QuizBloc>().add(AnswerSelected(index)),
                    );
                  }),
                  const Spacer(),
                  if (state.status == QuizStatus.answered)
                    ElevatedButton(
                      onPressed: () => context.read<QuizBloc>().add(NextQuestion()),
                      child: Text(
                        state.currentQuestionIndex == state.questions.length - 1
                            ? 'Lihat Hasil'
                            : 'Lanjut',
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}