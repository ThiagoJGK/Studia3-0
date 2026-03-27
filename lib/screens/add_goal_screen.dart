import 'package:flutter/material.dart';

class AddGoalScreen extends StatelessWidget {
  const AddGoalScreen({super.key});

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
                await showDatePicker(
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
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Seleccionar fecha...', style: TextStyle(color: Colors.black54, fontSize: 16)),
                    Icon(Icons.calendar_today_rounded, color: Color(0xFF8DB600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Syllabus Upload
            const Text('Syllabus / Material Base', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF8DB600).withOpacity(0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF8DB600).withOpacity(0.3), width: 2, style: BorderStyle.solid),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_upload_rounded, size: 48, color: Color(0xFF8DB600)),
                  SizedBox(height: 16),
                  Text(
                    'Subir PDF',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF536D00)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'La IA analizará el temario para calibrar tus bases.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
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
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: const Color(0xFF8DB600),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            label: const Text('Generar Trayectoria', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
