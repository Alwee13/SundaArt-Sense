import 'dart:ui'; // ⬅️ untuk ImageFilter (blur)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sundaart_sense/features/events/data/models/event_model.dart';
import 'package:sundaart_sense/features/events/presentation/pages/event_detail_page.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        // Glass card
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // efek kaca
            child: Container(
              decoration: BoxDecoration(
                // lapisan semi-transparan (ungu + putih)
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9B5BFF).withOpacity(0.12),
                    Colors.white.withOpacity(0.10),
                    const Color(0xFF7C3AED).withOpacity(0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Utama
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                    child: Image.network(
                      event.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
                        );
                      },
                    ),
                  ),
                  // Informasi Teks
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('d MMMM yyyy').format(event.date),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
