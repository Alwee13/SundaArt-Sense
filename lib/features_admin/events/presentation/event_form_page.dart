import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/events/data/models/event_model.dart';
import 'package:sundaart_sense/features/events/data/repositories/event_repository.dart';
import 'package:intl/intl.dart';

class EventFormPage extends StatefulWidget {
  final EventModel? event; // event akan null jika ini mode 'tambah baru'

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _imageController;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descController = TextEditingController(text: widget.event?.description ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _imageController = TextEditingController(text: widget.event?.imageUrl ?? '');
    _selectedDate = widget.event?.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Fungsi ini dipanggil saat tombol "Simpan" ditekan
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);

      final eventData = {
        'title': _titleController.text,
        'description': _descController.text,
        'location': _locationController.text,
        'imageUrl': _imageController.text,
        'date': Timestamp.fromDate(_selectedDate!),
      };

      try {
        final repo = context.read<EventRepository>();
        // Karena widget.event adalah null, kode akan menjalankan addEvent
        if (widget.event == null) {
          await repo.addEvent(eventData); // <-- MENAMBAHKAN DATA BARU
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event berhasil ditambahkan!')));
        } else {
          // (Ini adalah logika untuk mode edit)
          await repo.updateEvent(widget.event!.id, eventData);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event berhasil diperbarui!')));
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal wajib diisi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI Lengkap dari TextFormField, DatePicker, dan Tombol Simpan)
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Tambah Event Baru' : 'Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Event', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lokasi', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'URL Gambar', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                title: Text(_selectedDate == null
                    ? 'Pilih Tanggal'
                    : 'Tanggal: ${DateFormat('d MMMM yyyy').format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Data'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
            ],
          ),
        ),
      ),
    );
  }
}