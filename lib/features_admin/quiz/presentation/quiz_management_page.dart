import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/quiz/data/models/question_model.dart';
import 'package:sundaart_sense/features/quiz/data/repositories/quiz_repository.dart';
import 'package:sundaart_sense/features_admin/shared/delete_confirmation_dialog.dart';
import 'package:sundaart_sense/features/quiz/logic/quiz_bloc/quiz_bloc.dart';
import 'package:sundaart_sense/features_admin/quiz/presentation/quiz_preview_page.dart';
import 'package:sundaart_sense/features_admin/quiz/presentation/quiz_form_page.dart';

class QuizManagementPage extends StatelessWidget {
  const QuizManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quizRepo = context.read<QuizRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Soal Kuis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => QuizBloc(quizRepository: quizRepo)..add(FetchQuiz()),
                      child: const QuizPreviewPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: const Text('Simulasi Kuis'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            ),
          )
        ],
      ),
      body: StreamBuilder<List<QuestionModel>>(
        stream: quizRepo.getQuizQuestionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada soal kuis. Silakan tambahkan.'));
          }
          final questions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(question.questionText, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Jawaban: ${question.options[question.correctAnswerIndex]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit Soal',
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => QuizFormPage(question: question),
                          ));
                        },
                      ),
                      IconButton(
                        tooltip: 'Hapus Soal',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDeleteConfirmationDialog(
                            context: context,
                            itemName: question.questionText,
                            onConfirm: () {
                              context.read<QuizRepository>().deleteQuestion(question.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const QuizFormPage(),
          ));
        },
        tooltip: 'Tambah Soal Baru',
        child: const Icon(Icons.add),
      ),
    );
  }
}