import 'dart:ui'; // ⬅️ untuk ImageFilter (blur)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/events/logic/events_bloc.dart';
import 'package:sundaart_sense/features/events/presentation/widgets/event_card_widget.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    const appBarHeight = 72.0;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true, // ⬅️ wajib agar blur AppBar bekerja
      // Glass AppBar kustom
      appBar: const _GlassAppBar(title: 'Jelajahi Event'),
      body: Stack(
        children: [
          // ⬇️ Background lembut (gradient) — jadi ada yang “ter-blur” di bawah AppBar
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9B5BFF), // ungu
                    Color(0xFF7C3AED), // ungu gelap
                  ],
                ),
              ),
            ),
          ),
          // Overlay putih tipis supaya konten nyaman dibaca
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),

          // ⬇️ Konten utama (digeser turun agar tidak tertutup AppBar kaca)
          BlocBuilder<EventsBloc, EventsState>(
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildBodyForState(
                  context,
                  state,
                  paddingTop: topPad + appBarHeight + 8,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBodyForState(
    BuildContext context,
    EventsState state, {
    required double paddingTop,
  }) {
    if (state is EventsLoading || state is EventsInitial) {
      return Center(
        key: const ValueKey('loading'),
        child: Padding(
          padding: EdgeInsets.only(top: paddingTop),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (state is EventsLoaded) {
      if (state.events.isEmpty) {
        return Padding(
          key: const ValueKey('empty'),
          padding: EdgeInsets.only(top: paddingTop),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Belum Ada Event',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Coba cek lagi di lain waktu untuk jadwal terbaru.',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      return RefreshIndicator(
        key: const ValueKey('loaded'),
        onRefresh: () async {
          context.read<EventsBloc>().add(FetchEvents());
        },
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(16, paddingTop, 16, 16),
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemCount: state.events.length,
          itemBuilder: (context, index) {
            final event = state.events[index];
            return EventCard(event: event); // EventCard kamu sudah bergaya glass ✨
          },
        ),
      );
    }

    if (state is EventsError) {
      return SingleChildScrollView(
        key: const ValueKey('error'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, paddingTop + 20, 20, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('Oops, Gagal Terhubung',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<EventsBloc>().add(FetchEvents());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A4DFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink(key: ValueKey('unknown'));
  }
}

/// AppBar kaca dengan blur + ungu transparan
class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _GlassAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: top, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: preferredSize.height - 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF9B5BFF).withOpacity(0.18),
                  Colors.white.withOpacity(0.12),
                  const Color(0xFF7C3AED).withOpacity(0.16),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white, // kontras di atas ungu kaca
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
