import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/events/data/models/event_model.dart';
import 'package:sundaart_sense/features/events/data/repositories/event_repository.dart';
import 'package:sundaart_sense/features_admin/events/presentation/event_form_page.dart';
import 'package:sundaart_sense/features_admin/shared/delete_confirmation_dialog.dart';
import 'package:intl/intl.dart';

class EventManagementPage extends StatelessWidget {
  const EventManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Event'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: context.read<EventRepository>().getEventsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada event. Silakan tambahkan.'));
          }
          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('d MMMM yyyy').format(event.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit Event',
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => EventFormPage(event: event),
                          ));
                        },
                      ),
                      IconButton(
                        tooltip: 'Hapus Event',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDeleteConfirmationDialog(
                            context: context,
                            itemName: event.title,
                            onConfirm: () {
                              context.read<EventRepository>().deleteEvent(event.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const EventFormPage(),
          ));
        },
        tooltip: 'Tambah Event Baru',
        child: const Icon(Icons.add),
      ),
    );
  }
}