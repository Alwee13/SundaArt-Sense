import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sundaart_sense/features/quiz/data/models/question_model.dart';
import 'package:sundaart_sense/features/quiz/data/models/score_model.dart';
import 'package:sundaart_sense/features/quiz/data/repositories/quiz_repository.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository _quizRepository;

  QuizBloc({required QuizRepository quizRepository})
    : _quizRepository = quizRepository,
      super(const QuizState()) {
    on<FetchQuiz>(_onFetchQuiz);
    on<AnswerSelected>(_onAnswerSelected);
    on<NextQuestion>(_onNextQuestion);
    on<SubmitQuiz>(_onSubmitQuiz);
  }

  void _onFetchQuiz(FetchQuiz event, Emitter<QuizState> emit) async {
    emit(state.copyWith(status: QuizStatus.loading));
    try {
      final questions = await _quizRepository.getQuizQuestions();
      if (questions.isEmpty) {
        emit(
          state.copyWith(
            status: QuizStatus.error,
            errorMessage: 'Tidak ada soal kuis yang ditemukan.',
          ),
        );
        return;
      }

      // RESET state saat mulai kuis baru
      emit(
        QuizState(
          status: QuizStatus.loaded,
          questions: questions,
          currentQuestionIndex: 0,
          score: 0,
          selectedAnswerIndex: null,
          isCorrect: null,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: QuizStatus.error,
          errorMessage: 'Gagal memuat kuis: $e',
        ),
      );
    }
  }

  void _onAnswerSelected(AnswerSelected event, Emitter<QuizState> emit) {
    final question = state.questions[state.currentQuestionIndex];
    final isCorrect = event.selectedIndex == question.correctAnswerIndex;
    int newScore = state.score;
    if (isCorrect) {
      newScore++;
    }
    emit(
      state.copyWith(
        status: QuizStatus.answered,
        selectedAnswerIndex: event.selectedIndex,
        isCorrect: isCorrect,
        score: newScore,
      ),
    );
  }

  void _onNextQuestion(NextQuestion event, Emitter<QuizState> emit) {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      emit(
        state.copyWith(
          status: QuizStatus.loaded,
          currentQuestionIndex: state.currentQuestionIndex + 1,
          selectedAnswerIndex: null,
          isCorrect: null,
        ),
      );
    } else {
      emit(state.copyWith(status: QuizStatus.completed));
    }
  }

  void _onSubmitQuiz(SubmitQuiz event, Emitter<QuizState> emit) async {
    final scoreModel = ScoreModel(
      userId: event.userId,
      userName: event.userName,
      score: state.score,
      timestamp: DateTime.now(),
    );
    await _quizRepository.submitScore(scoreModel);
  }
}
