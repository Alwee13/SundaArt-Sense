import 'dart:ui'; // untuk ImageFilter (blur)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sundaart_sense/features/events/data/models/event_model.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // transisi halus ke bg image
      body: Stack(
        children: [
          // ===== BACKGROUND: full-screen, responsive =====
          Positioned.fill(
            child: _BackgroundImage(
              url: event.imageUrl,
              fitMode: BackgroundFit.cover, // ganti ke BackgroundFit.contain bila ingin tanpa crop
              darkenOpacity: 0.01,         // atur gelap-terangnya overlay
            ),
          ),

          // ===== Tombol Kembali (glass) =====
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF9B5BFF).withOpacity(0.16),
                          Colors.white.withOpacity(0.12),
                        ],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ===== Konten Detail (Draggable, glass) =====
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF9B5BFF).withOpacity(0.14),
                          Colors.white.withOpacity(0.10),
                          const Color(0xFF7C3AED).withOpacity(0.12),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                      border: Border.all(color: Colors.white.withOpacity(0.32), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        // Judul
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tanggal
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          title: 'Tanggal Acara',
                          subtitle: DateFormat('EEEE, d MMMM yyyy').format(event.date),
                        ),
                        const SizedBox(height: 16),

                        // Lokasi
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          title: 'Lokasi',
                          subtitle: event.location,
                        ),

                        const SizedBox(height: 24),
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Deskripsi
                        const Text(
                          'Tentang Acara',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.description,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            height: 1.6,
                            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper untuk baris info (Tanggal & Lokasi)
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF8A4DFF), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

/// ===== Helper: Background image full-screen dengan overlay =====

enum BackgroundFit { cover, contain }

class _BackgroundImage extends StatelessWidget {
  final String url;
  final BackgroundFit fitMode;
  final double darkenOpacity;

  const _BackgroundImage({
    required this.url,
    this.fitMode = BackgroundFit.cover,
    this.darkenOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: fitMode == BackgroundFit.cover ? BoxFit.cover : BoxFit.contain,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high, // scaling lebih halus
            errorBuilder: (_, __, ___) => Container(color: Colors.black12),
          ),
          if (darkenOpacity > 0)
            Container(color: Colors.black.withOpacity(darkenOpacity)),
        ],
      ),
    );
  }
}
