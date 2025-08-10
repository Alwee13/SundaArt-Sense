import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/auth/data/repositories/auth_repository.dart';
import 'package:sundaart_sense/features_admin/events/presentation/event_management_page.dart';
import 'package:sundaart_sense/features_admin/quiz/presentation/quiz_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan berdasarkan navigasi
  static const List<Widget> _adminPages = <Widget>[
    EventManagementPage(), // Halaman CRUD Event
    QuizManagementPage(), // Halaman CRUD Kuis
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Menu Navigasi di sisi kiri
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Tooltip(
              message: 'SundaArt Sense Admin',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: () {},
                  child: const Icon(Icons.shield_moon),
                ),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: () {
                      // Fungsi Logout dari AuthRepository
                      context.read<AuthRepository>().signOut();
                    },
                  ),
                ),
              ),
            ),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.celebration_outlined),
                selectedIcon: Icon(Icons.celebration),
                label: Text('Events'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.quiz_outlined),
                selectedIcon: Icon(Icons.quiz),
                label: Text('Kuis'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Konten utama yang akan berubah sesuai menu yang dipilih
          Expanded(child: _adminPages[_selectedIndex]),
        ],
      ),
    );
  }
}
