import 'dart:ui'; // Diperlukan untuk ImageFilter (efek blur)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/auth/presentation/pages/profile_page.dart';
import 'package:sundaart_sense/features/events/logic/events_bloc.dart';
import 'package:sundaart_sense/features/events/presentation/pages/event_list_page.dart';
import 'package:sundaart_sense/features/quiz/logic/leaderboard_bloc/leaderboard_bloc.dart';
import 'package:sundaart_sense/features/quiz/presentation/pages/leaderboard_page.dart';
import 'package:sundaart_sense/features/quiz/presentation/pages/quiz_home_page.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  // Daftar halaman utama yang akan ditampilkan di dalam shell
  static const List<Widget> _pages = <Widget>[
    EventListPage(),
    QuizHomePage(),
    LeaderboardPage(),
    ProfilePage(),
  ];

  // Fungsi yang dipanggil saat item navigasi ditekan
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Mencegah reload jika tab yang sama ditekan

    // Memuat data yang relevan saat tab diaktifkan
    if (index == 0) {
      context.read<EventsBloc>().add(FetchEvents());
    } else if (index == 2) {
      context.read<LeaderboardBloc>().add(FetchLeaderboard());
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Stack untuk menumpuk halaman utama dan navigation bar
      body: Stack(
        children: [
          // 1. Konten Utama (Halaman yang sedang aktif)
          // IndexedStack menjaga state setiap halaman agar tidak hilang saat berpindah tab
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // 2. Floating Bottom Navigation Bar dengan Efek Buram
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk membangun navigation bar yang melayang (floating).
  Widget _buildFloatingNavBar() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        // Blur lebih kuat untuk efek kaca
        filter: ImageFilter.blur(sigmaX: 22.0, sigmaY: 22.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            // Lapisan warna sangat tipis: ungu + putih untuk “frosted”
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF9B5BFF).withOpacity(0.18), // ungu tipis
                const Color(0xFFFFFFFF).withOpacity(0.12), // putih tipis
                const Color(0xFF7C3AED).withOpacity(0.16), // ungu tipis lagi
              ],
            ),
            borderRadius: BorderRadius.circular(24.0),
            // Border lebih jelas biar kaca “kelihatan tebal”
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
            // Shadow lembut untuk kesan melayang
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.18),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,

            // ⬇️ ungu untuk item/label yang terpilih
            selectedItemColor: const Color(0xFF8A4DFF),
            selectedIconTheme: const IconThemeData(color: Color(0xFF8A4DFF)),
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF8A4DFF),
            ),

            // ⬇️ tetap putih transparan untuk yang belum dipilih
            unselectedItemColor: Colors.white.withOpacity(0.78),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white.withOpacity(0.78),
            ),

            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.celebration_outlined),
                activeIcon: Icon(Icons.celebration),
                label: 'Event',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz),
                label: 'Kuis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                activeIcon: Icon(Icons.emoji_events),
                label: 'Peringkat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}