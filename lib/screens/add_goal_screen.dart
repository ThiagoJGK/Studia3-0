import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  Future<void> _generateTrajectory() async {
    final title = _titleController.text.trim();
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Usuario no autenticado.')));
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, ingresa el nombre de la materia.')));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona la fecha del parcial.')));
      return;
    }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, sube el Syllabus o PDF base.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Insert Goal into Database
      final goalResponse = await Supabase.instance.client.from('goals').insert({
        'user_id': user.id,
        'title': title,
        'target_date': _selectedDate!.toIso8601String(),
        'type': 'study',
        'status': 'active',
      }).select().single();

      final goalId = goalResponse['id'];

      // 2. Upload Syllabus to Storage
      // Sanitize filename: remove accented/special chars and replace spaces with underscores
      final rawName = _selectedFile!.name;
      final sanitized = rawName
          .replaceAll(RegExp(r'[áàäâã]', caseSensitive: false), 'a')
          .replaceAll(RegExp(r'[éèëê]', caseSensitive: false), 'e')
          .replaceAll(RegExp(r'[íìïî]', caseSensitive: false), 'i')
          .replaceAll(RegExp(r'[óòöôõ]', caseSensitive: false), 'o')
          .replaceAll(RegExp(r'[úùüû]', caseSensitive: false), 'u')
          .replaceAll(RegExp(r'[ñ]', caseSensitive: false), 'n')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');
      final storagePath = '${user.id}/$goalId/$sanitized';

      if (kIsWeb) {
        // En entorno Web, usamos los bytes directamente
        await Supabase.instance.client.storage.from('syllabus').uploadBinary(
          storagePath,
          _selectedFile!.bytes!,
          fileOptions: const FileOptions(contentType: 'application/pdf'),
        );
      } else {
        // En entorno Móvil, usamos el File Path
        final file = File(_selectedFile!.path!);
        await Supabase.instance.client.storage.from('syllabus').upload(
          storagePath,
          file,
        );
      }

      // 3. Trigger Socratic Agent (Edge Function) with explicit JWT
      try {
        final session = Supabase.instance.client.auth.currentSession;
        final jwt = session?.accessToken;
        await Supabase.instance.client.functions.invoke(
           'socratic-agent',
           body: {
              'goal_id': goalId,
              'file_path': storagePath
           },
           headers: jwt != null ? {'Authorization': 'Bearer $jwt'} : {},
        );
      } catch (funcError) {
         // Log the error but don't block the UI
         print('Error invoke function: $funcError');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Objetivo creado! La IA está generando tu trayectoria.')),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear objetivo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      appBar: AppBar(
        title: const Text('Nuevo Objetivo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF536D00))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF536D00)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evita el Efecto Mateo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 8),
            const Text(
              'La IA detectará posibles debilidades en tus bases desde el día 1.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),

            // Text Input
            const Text('Materia o Meta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Ej. Aprobar Álgebra Lineal',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // Date Selection
            const Text('Fecha del Parcial Final', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF8DB600),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null 
                          ? 'Seleccionar fecha...'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(
                        color: _selectedDate == null ? Colors.black54 : Colors.black87,
                        fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                        fontSize: 16
                      )
                    ),
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF8DB600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Syllabus Upload
            const Text('Syllabus / Material Base', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: _selectedFile != null ? const Color(0xFF8DB600).withOpacity(0.1) : const Color(0xFF8DB600).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: _selectedFile != null ? const Color(0xFF8DB600) : const Color(0xFF8DB600).withOpacity(0.3), 
                    width: 2, 
                    style: BorderStyle.solid
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.picture_as_pdf : Icons.cloud_upload_rounded, 
                      size: 48, 
                      color: const Color(0xFF8DB600)
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFile != null ? _selectedFile!.name : 'Subir PDF',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF536D00)),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFile == null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'La IA analizará el temario para calibrar tus bases.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 100), // FAB padding
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SizedBox(
          width: double.infinity,
          height: 64,
          child: FloatingActionButton.extended(
            onPressed: _isLoading ? null : _generateTrajectory,
            backgroundColor: const Color(0xFF8DB600),
            elevation: _isLoading ? 0 : 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            label: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Generar Trayectoria', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
