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
  final _topicsController = TextEditingController();
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  bool _autoExtract = true; // true = IA extrae temas del PDF automáticamente

  static const _primary   = Color(0xFF536D00);
  static const _primaryC  = Color(0xFF8DB600);
  static const _surface   = Color(0xFFFFF7FB);

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) setState(() => _selectedFile = result.files.single);
  }

  Future<void> _generateTrajectory() async {
    final title  = _titleController.text.trim();
    final topics = _topicsController.text.trim();
    final user   = Supabase.instance.client.auth.currentUser;

    if (user == null) { _snack('Error: Usuario no autenticado.'); return; }
    if (title.isEmpty) { _snack('Ingresa el nombre de la materia.'); return; }
    if (_selectedDate == null) { _snack('Selecciona la fecha del parcial.'); return; }
    if (_selectedFile == null) { _snack('Adjunta el programa o PDF del profe.'); return; }
    if (!_autoExtract && topics.isEmpty) { _snack('Escribe los temas que entran al examen.'); return; }

    setState(() => _isLoading = true);
    try {
      // 1. Insert Goal
      final goalResponse = await Supabase.instance.client.from('goals').insert({
        'user_id': user.id,
        'title': title,
        'target_date': _selectedDate!.toIso8601String(),
        'type': 'study',
        'status': 'active',
        'manual_topics': _autoExtract ? null : topics,
      }).select().single();

      final goalId = goalResponse['id'];

      // 2. Upload file to Storage (sanitize filename)
      final sanitized = _selectedFile!.name
          .replaceAll(RegExp(r'[áàäâã]', caseSensitive: false), 'a')
          .replaceAll(RegExp(r'[éèëê]', caseSensitive: false), 'e')
          .replaceAll(RegExp(r'[íìïî]', caseSensitive: false), 'i')
          .replaceAll(RegExp(r'[óòöôõ]', caseSensitive: false), 'o')
          .replaceAll(RegExp(r'[úùüû]', caseSensitive: false), 'u')
          .replaceAll(RegExp(r'[ñ]', caseSensitive: false), 'n')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');
      final storagePath = '${user.id}/$goalId/$sanitized';

      if (kIsWeb) {
        await Supabase.instance.client.storage.from('syllabus').uploadBinary(
          storagePath, _selectedFile!.bytes!,
          fileOptions: const FileOptions(contentType: 'application/pdf'),
        );
      } else {
        await Supabase.instance.client.storage.from('syllabus').upload(
          storagePath, File(_selectedFile!.path!),
        );
      }

      // 3. Trigger Socratic Agent
      try {
        final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
        await Supabase.instance.client.functions.invoke(
          'socratic-agent',
          body: {
            'goal_id': goalId,
            'file_path': storagePath,
            'auto_extract': _autoExtract,
            'manual_topics': _autoExtract ? null : topics,
          },
          headers: jwt != null ? {'Authorization': 'Bearer $jwt'} : {},
        );
      } catch (funcError) {
        print('Error invoke function: $funcError');
      }

      if (mounted) {
        _snack('¡Objetivo creado! La IA está generando tu plan de estudio.');
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) _snack('Error al crear objetivo: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    _titleController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Text('Nuevo Objetivo',
            style: TextStyle(fontWeight: FontWeight.bold, color: _primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva trayectoria',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
            const SizedBox(height: 6),
            const Text('Configura tu objetivo y la IA armará tu plan.',
                style: TextStyle(fontSize: 15, color: Colors.black54)),
            const SizedBox(height: 36),

            // ── Materia ──────────────────────────────────────
            _label('Materia o Meta'),
            const SizedBox(height: 10),
            _textField(_titleController, 'Ej. Aprobar Álgebra Lineal'),

            const SizedBox(height: 28),

            // ── Fecha ────────────────────────────────────────
            _label('Fecha del examen'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(primary: _primaryC),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Seleccionar fecha...'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null ? Colors.black45 : Colors.black87,
                        fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.calendar_today_rounded, color: _primaryC),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Programa del profe (PDF) ──────────────────────
            _label('Programa / PDF del profe'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: _selectedFile != null
                      ? _primaryC.withOpacity(0.08)
                      : _primaryC.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _selectedFile != null
                        ? _primaryC
                        : _primaryC.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(children: [
                  Icon(
                    _selectedFile != null ? Icons.picture_as_pdf : Icons.cloud_upload_rounded,
                    size: 44, color: _primaryC,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedFile != null ? _selectedFile!.name : 'Subir PDF',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primary),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedFile == null) ...[
                    const SizedBox(height: 6),
                    const Text('La IA leerá el programa para armar tu plan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black45)),
                  ],
                ]),
              ),
            ),

            const SizedBox(height: 28),

            // ── Toggle: Extracción automática ────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Extracción automática de temas',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      const SizedBox(height: 2),
                      Text(
                        _autoExtract ? 'La IA detecta los temas del PDF.' : 'Ingresarás los temas manualmente.',
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ]),
                  ),
                  Switch.adaptive(
                    value: _autoExtract,
                    onChanged: (v) => setState(() => _autoExtract = v),
                    activeColor: _primaryC,
                  ),
                ],
              ),
            ),

            // ── Manual topics (visible solo si autoExtract = false) ──
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _autoExtract
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Temas que entran al examen'),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _topicsController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Ej:\n• Matrices y determinantes\n• Espacios vectoriales\n• Autovalores',
                            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: _primaryC, width: 2),
                            ),
                          ),
                        ),
                      ]),
                    ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 64,
          child: FloatingActionButton.extended(
            onPressed: _isLoading ? null : _generateTrajectory,
            backgroundColor: _primaryC,
            elevation: _isLoading ? 0 : 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            label: _isLoading
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Generar Plan de Estudio',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            icon: _isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333)));

  Widget _textField(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _primaryC, width: 2),
      ),
    ),
  );
}
