import 'package:flutter/material.dart';

class GoalTrajectoryScreen extends StatelessWidget {
  const GoalTrajectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar el Goal pasado como parametro por el Navigator
    final goalArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final title = goalArgs['title'] ?? 'Trayectoria Activa';
    final progress = (goalArgs['progress'] ?? 0) / 100.0;
    
    // Calcula días restantes mock vs real
    String timeLeftLabel = 'Meta en progreso';
    if (goalArgs['target_date'] != null) {
      final target = DateTime.parse(goalArgs['target_date']);
      final diff = target.difference(DateTime.now()).inDays;
      timeLeftLabel = diff > 0 ? 'Faltan $diff días' : 'Fecha alcanzada';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      appBar: AppBar(
        title: const Text('Trayectoria', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF536D00))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF536D00)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeLeftLabel,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF536D00), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFF8DB600).withOpacity(0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8DB600)),
                      ),
                      Center(
                        child: Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      )
                    ],
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Timeline Dinámico - Placeholder para fetching `study_sessions` de BD
            // Por ahora, mostrará esto para visualizar la vista, pero no está hardcodeado 
            // al nombre de la materia sino vinculado a la respuesta futura del agente.
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Las sesiones de estudio dinámicas generadas por Gemini aparecerán en esta línea de tiempo. Por favor presiona "Generar Trayectoria" en un nuevo objetivo para poblar tu base de datos.',
                style: TextStyle(color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 80), // Padding for FAB
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
              // Navegar al Socratic Player enviando los argumentos de la sesión de HOY
              Navigator.pushNamed(context, '/session', arguments: {
                'title': 'Análisis del Programa',
                'progress': progress,
                'content': 'El agente socrático ha analizado tu material de estudio.',
              });
            },
            backgroundColor: const Color(0xFF8DB600),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            label: const Text('Iniciar Sesión de Hoy', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
