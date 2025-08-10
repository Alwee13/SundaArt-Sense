import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sundaart_sense/features/quiz/data/models/question_model.dart';
import 'package:sundaart_sense/features/quiz/data/repositories/quiz_repository.dart';

class QuizFormPage extends StatefulWidget {
  final QuestionModel? question;

  const QuizFormPage({super.key, this.question});

  @override
  State<QuizFormPage> createState() => _QuizFormPageState();
}

class _QuizFormPageState extends State<QuizFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  int _correctAnswerIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question?.questionText ?? '');
    _optionControllers = widget.question?.options.map((opt) => TextEditingController(text: opt)).toList() ??
        [TextEditingController(), TextEditingController()];
    _correctAnswerIndex = widget.question?.correctAnswerIndex ?? 0;
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 5) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index);
        if (_correctAnswerIndex == index) {
          _correctAnswerIndex = 0;
        } else if (_correctAnswerIndex > index) {
          _correctAnswerIndex--;
        }
      });
    }
  }

  // Fungsi ini dipanggil saat tombol "Simpan" ditekan
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final options = _optionControllers.map((c) => c.text).toList();
      final questionData = {
        'questionText': _questionController.text,
        'options': options,
        'correctAnswerIndex': _correctAnswerIndex,
      };

      try {
        final repo = context.read<QuizRepository>();
        // Karena widget.question adalah null, kode akan menjalankan addQuestion
        if (widget.question == null) {
          await repo.addQuestion(questionData); // <-- MENAMBAHKAN DATA BARU
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soal berhasil ditambahkan!')));
        } else {
          // (Logika untuk mode edit)
          await repo.updateQuestion(widget.question!.id, questionData);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soal berhasil diperbarui!')));
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI Lengkap dari TextFormField, Radio Button, dan Tombol Simpan)
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question == null ? 'Tambah Soal Baru' : 'Edit Soal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Teks Pertanyaan', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              Text('Pilihan Jawaban (Pilih satu jawaban yang benar)', style: Theme.of(context).textTheme.titleMedium),
              const Divider(),
              ..._buildOptionFields(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Pilihan'),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Soal'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptionFields() {
    // ... (kode untuk generate pilihan jawaban dengan radio button)
    return List.generate(_optionControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _correctAnswerIndex,
              onChanged: (int? value) {
                setState(() {
                  _correctAnswerIndex = value!;
                });
              },
            ),
            Expanded(
              child: TextFormField(
                controller: _optionControllers[index],
                decoration: InputDecoration(labelText: 'Pilihan ${index + 1}', border: const OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => _removeOption(index),
            ),
          ],
        ),
      );
    });
  }
}