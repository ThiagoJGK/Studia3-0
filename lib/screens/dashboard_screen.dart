import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      extendBody: true, // Required for floating HUD effect
      extendBodyBehindAppBar: true, // Required for blurred header effect
      appBar: AppBar(
        title: const Text('Studia 3.0', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF536D00))),
        backgroundColor: Colors.white.withOpacity(0.6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF536D00)),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: _HUD_BLUR,
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF536D00)),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF8DB600),
              child: Text('T', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola de nuevo!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            
            // Weekly Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8DB600), Color(0xFFB8E43F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8DB600).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sigue así, estás brillando.',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Racha actual: 5 días',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
                      const SizedBox(height: 4),
                      const Text(
                        '140',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 48),
            const Text(
              'Tus Objetivos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 16),

            // Goal Cards
            _buildGoalCard(
              context,
              title: 'Aprobar Álgebra',
              subtitle: 'Faltan 2 módulos para completar',
              progress: 0.8,
              onTap: () => Navigator.pushNamed(context, '/trajectory'),
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              context,
              title: 'Gym',
              subtitle: '2 de 5 sesiones esta semana',
              progress: 0.4,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              context,
              title: 'Proyecto Final Bio',
              subtitle: 'Sigue trabajando en la sección de citología. Estás muy cerca de terminar.',
              progress: 0.9,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: _HUD_BLUR, // Performant blur limited to the container bounds
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavIcon(Icons.home_filled, true, () {}),
                    _buildNavIcon(Icons.calendar_month_rounded, false, () => Navigator.pushNamed(context, '/calendar')),
                    _buildNavIcon(Icons.add_circle, false, () => Navigator.pushNamed(context, '/add_goal')),
                    _buildNavIcon(Icons.emoji_events_outlined, false, () => Navigator.pushNamed(context, '/mastery')),
                    _buildNavIcon(Icons.person_outline, false, () => Navigator.pushNamed(context, '/profile')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Define blur globally to avoid rebuild costs
  static final _HUD_BLUR = _getBlurFilter();
  static _getBlurFilter() => dart_ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15);

  Widget _buildNavIcon(IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8DB600).withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF8DB600) : Colors.grey.shade500,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, {required String title, required String subtitle, required double progress, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF8DB600)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF8DB600).withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8DB600)),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
