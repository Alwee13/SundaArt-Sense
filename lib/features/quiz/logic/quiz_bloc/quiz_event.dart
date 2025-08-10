part of 'quiz_bloc.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object> get props => [];
}

class FetchQuiz extends QuizEvent {}

class AnswerSelected extends QuizEvent {
  final int selectedIndex;
  const AnswerSelected(this.selectedIndex);
  @override
  List<Object> get props => [selectedIndex];
}

class NextQuestion extends QuizEvent {}

class SubmitQuiz extends QuizEvent {
  // Asumsi kita punya userId dan userName dari Firebase Auth
  final String userId;
  final String userName;

  const SubmitQuiz({required this.userId, required this.userName});
}
