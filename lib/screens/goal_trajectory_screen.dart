import 'package:flutter/material.dart';

class GoalTrajectoryScreen extends StatelessWidget {
  const GoalTrajectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aprobar Álgebra',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Faltan 21 días para el Parcial',
                      style: TextStyle(fontSize: 16, color: Color(0xFF536D00), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 0.8,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFF8DB600).withOpacity(0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8DB600)),
                      ),
                      const Center(
                        child: Text('80%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      )
                    ],
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Timeline
            _buildTimelineItem(
              context,
              date: 'HOY',
              title: 'Teoría: Matrices',
              duration: '45 min',
              isToday: true,
              isCompleted: false,
            ),
            _buildTimelineItem(
              context,
              date: 'Mañana',
              title: 'Práctica: Operaciones',
              duration: '60 min',
              isToday: false,
              isCompleted: false,
            ),
            _buildTimelineItem(
              context,
              date: 'Jueves',
              title: 'Quiz de Retención',
              duration: '20 min',
              isToday: false,
              isCompleted: false,
            ),
            _buildTimelineItem(
              context,
              date: 'Ayer',
              title: 'Introducción a Matrices',
              duration: '30 min',
              isToday: false,
              isCompleted: true,
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
              // Start study session
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Iniciando sesión de estudio...'), backgroundColor: Color(0xFF536D00)),
              );
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

  Widget _buildTimelineItem(BuildContext context, {required String date, required String title, required String duration, required bool isToday, required bool isCompleted}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF8DB600) : (isToday ? const Color(0xFF536D00) : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted || isToday ? Colors.transparent : Colors.grey.shade400,
                    width: 3,
                  ),
                ),
                child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              Expanded(
                child: Container(
                  width: 3,
                  color: isCompleted ? const Color(0xFF8DB600) : Colors.grey.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          
          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isToday ? const Color(0xFF8DB600) : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isToday ? const Color(0xFF8DB600).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isToday ? const Color(0xFF8DB600).withOpacity(0.5) : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.grey : const Color(0xFF333333),
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 16, color: isCompleted ? Colors.grey : const Color(0xFF536D00)),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: TextStyle(color: isCompleted ? Colors.grey : const Color(0xFF536D00), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
