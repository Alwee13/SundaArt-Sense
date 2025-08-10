import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/auth/data/repositories/auth_repository.dart';
import 'package:sundaart_sense/features/auth/logic/auth_bloc.dart';
import 'package:sundaart_sense/features/auth/presentation/pages/auth_page.dart';
import 'package:sundaart_sense/features/core/main_navigation_shell.dart';
import 'package:sundaart_sense/features/core/splash_screen.dart';
import 'package:sundaart_sense/features/events/data/repositories/event_repository.dart';
import 'package:sundaart_sense/features/events/logic/events_bloc.dart';
import 'package:sundaart_sense/features/quiz/data/repositories/quiz_repository.dart';
import 'package:sundaart_sense/features/quiz/logic/leaderboard_bloc/leaderboard_bloc.dart';
import 'package:sundaart_sense/features/quiz/logic/quiz_bloc/quiz_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SundaArtSenseApp());
}

class SundaArtSenseApp extends StatelessWidget {
  const SundaArtSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => EventRepository()),
        RepositoryProvider(create: (context) => QuizRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                EventsBloc(eventRepository: context.read<EventRepository>())
                  ..add(FetchEvents()),
          ),
          BlocProvider(
            create: (context) =>
                QuizBloc(quizRepository: context.read<QuizRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                LeaderboardBloc(quizRepository: context.read<QuizRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'SundaArt Sense',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Poppins',
            // --- INI BAGIAN YANG DIPERBAIKI ---
            cardTheme: CardThemeData(
              // Menggunakan CardThemeData, bukan CardTheme
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // ------------------------------------
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          return const MainNavigationShell();
        } else {
          return const AuthPage();
        }
      },
    );
  }
}
