import 'package:flutter/material.dart';

class SessionPlayerScreen extends StatelessWidget {
  const SessionPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic values from routing
    final sessionArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final title = sessionArgs['title'] ?? 'Deep Work Session';
    final content = sessionArgs['content'] ?? 'Esperando indicaciones de la IA...';
    final progress = sessionArgs['progress'] ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF333333))),
            const SizedBox(height: 4),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8DB600)),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF536D00)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Socratic Agent Card (Dynamic Content)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF8DB600).withOpacity(0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.psychology, color: Color(0xFF8DB600)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'El Agente Socrático',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Analogía / Reto Generado',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Interaction Section (Deep Processing)
              const Text(
                'Tu Turno: Auto-explicación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF536D00)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Demuestra entendimiento profundo sobre el tema expuesto arriba.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu razonamiento aquí para demostrar procesamiento...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF8DB600), width: 2),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8DB600),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    // Cierra pantalla actual y actualiza score en base
                    Navigator.pop(context);
                  },
                  child: const Text('Validar y Continuar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
