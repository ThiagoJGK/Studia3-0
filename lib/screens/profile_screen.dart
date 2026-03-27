import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF536D00))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF536D00)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Hero
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF8DB600),
              child: Text('T', style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thiago',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
            ),
            const Text(
              'Estudiante Nivel 5 • 140 Puntos',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 48),

            // Settings Section
            _buildSettingsCard(
              title: 'Configuraciones Generales',
              children: [
                _buildSettingRow(Icons.psychology_outlined, 'Tono del Agente', 'Sócrates Motivador'),
                _buildSettingRow(Icons.access_time, 'Horarios de Disponibilidad', 'L, M, J (14:00 - 18:00)'),
                _buildSettingRow(Icons.notifications_outlined, 'Notificaciones de Racha', 'Activadas'),
                _buildSettingRow(Icons.color_lens_outlined, 'Tema Académico', 'Modo Claro'),
              ],
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  // Logout
                  Navigator.pushReplacementNamed(context, '/auth');
                },
                child: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF536D00), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
