import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      appBar: AppBar(
        title: const Text('Cronograma', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF536D00))),
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
              'Próximas Pruebas de Esfuerzo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu IA ha modificado este calendario dinámicamente según tus déficits.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            // Mock week calendar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayBubble('L', '12', false),
                _buildDayBubble('M', '13', false),
                _buildDayBubble('M', '14', true), // Today
                _buildDayBubble('J', '15', false),
                _buildDayBubble('V', '16', false),
              ],
            ),

            const SizedBox(height: 48),

            // Timeline Items
            _buildTimelineCard('Nivelación: Álgebra', 'Mar 14 • 14:00', true),
            const SizedBox(height: 16),
            _buildTimelineCard('Sesión Profunda: Derivadas', 'Mar 15 • 10:00', false),
            const SizedBox(height: 16),
            _buildTimelineCard('Simulacro: Stress Test', 'Mar 20 • 09:00', false, isAlert: true),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBubble(String dayName, String dayNum, bool isSelected) {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8DB600) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dayName, style: TextStyle(fontSize: 14, color: isSelected ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 4),
          Text(dayNum, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(String title, String subtitle, bool isDone, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAlert ? Colors.red.shade200 : Colors.black12),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : (isAlert ? Icons.warning_rounded : Icons.circle_outlined),
            color: isDone ? const Color(0xFF8DB600) : (isAlert ? Colors.redAccent : Colors.grey),
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAlert ? Colors.redAccent : const Color(0xFF333333),
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
