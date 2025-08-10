import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sundaart_sense/features/quiz/data/models/score_model.dart';
import 'package:sundaart_sense/features/quiz/data/repositories/quiz_repository.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final QuizRepository _quizRepository;

  LeaderboardBloc({required QuizRepository quizRepository})
    : _quizRepository = quizRepository,
      super(LeaderboardInitial()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
  }

  void _onFetchLeaderboard(
    FetchLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    try {
      final scores = await _quizRepository.getLeaderboard();
      emit(LeaderboardLoaded(scores));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}
