part of 'leaderboard_bloc.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

// Event untuk memerintahkan BLoC mengambil data leaderboard
class FetchLeaderboard extends LeaderboardEvent {}
