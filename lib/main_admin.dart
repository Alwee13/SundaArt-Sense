import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/auth/data/repositories/auth_repository.dart';
import 'package:sundaart_sense/features/auth/logic/auth_bloc.dart';
import 'package:sundaart_sense/features/events/data/repositories/event_repository.dart';
import 'package:sundaart_sense/features_admin/auth/admin_login_page.dart';
import 'package:sundaart_sense/features_admin/core/admin_dashboard_page.dart';
import 'package:sundaart_sense/firebase_options.dart';
import 'package:sundaart_sense/features/quiz/data/repositories/quiz_repository.dart';

// Titik masuk khusus untuk Admin Panel
void main() async { // Ubah nama fungsi agar unik jika diperlukan
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(
          create: (context) => EventRepository(firestore: FirebaseFirestore.instance),
        ),
        // --- TAMBAHKAN BARIS INI UNTUK MEMPERBAIKI ERROR ---
        RepositoryProvider(
          create: (context) => QuizRepository(firestore: FirebaseFirestore.instance),
        ),
        // ----------------------------------------------------
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          // Anda bisa menambahkan BLoC lain di sini jika diperlukan oleh admin panel
        ],
        child: MaterialApp(
          title: 'SundaArt Sense - Admin Panel',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            useMaterial3: true,
          ),
          home: const AdminAuthGate(),
        ),
      ),
    );
  }
}

// Gerbang Keamanan untuk Admin Panel
class AdminAuthGate extends StatelessWidget {
  const AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AdminLoginPage();
        }

        return FutureBuilder<IdTokenResult>(
          future: snapshot.data!.getIdTokenResult(true),
          builder: (context, tokenSnapshot) {
            if (tokenSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (tokenSnapshot.hasError) {
              return const Scaffold(body: Center(child: Text("Error memverifikasi akses.")));
            }

            final isAdmin = tokenSnapshot.data?.claims?['admin'] == true;

            if (isAdmin) {
              return const AdminDashboardPage();
            } else {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Akses Ditolak.", style: TextStyle(fontSize: 24, color: Colors.red)),
                      const Text("Anda tidak memiliki hak untuk mengakses halaman ini."),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.read<AuthRepository>().signOut(),
                        child: const Text('Logout'),
                      )
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
