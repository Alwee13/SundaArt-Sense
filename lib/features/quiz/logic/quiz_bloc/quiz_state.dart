part of 'quiz_bloc.dart';

// Menambahkan status 'error' untuk penanganan masalah
enum QuizStatus { initial, loading, loaded, answered, completed, error }

class QuizState extends Equatable {
  final QuizStatus status;
  final List<QuestionModel> questions;
  final int currentQuestionIndex;
  final int score;
  final int? selectedAnswerIndex;
  final bool? isCorrect;
  final String errorMessage; // Field untuk menyimpan pesan error

  const QuizState({
    this.status = QuizStatus.initial,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.selectedAnswerIndex,
    this.isCorrect,
    this.errorMessage = '',
  });

  QuizState copyWith({
    QuizStatus? status,
    List<QuestionModel>? questions,
    int? currentQuestionIndex,
    int? score,
    int? selectedAnswerIndex,
    bool? isCorrect,
    String? errorMessage,
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      selectedAnswerIndex: selectedAnswerIndex,
      isCorrect: isCorrect,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, questions, currentQuestionIndex, score, selectedAnswerIndex, isCorrect, errorMessage];
}