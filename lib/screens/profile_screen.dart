import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Cargando...';
  String _initial = '';
  int _points = 0;
  int _level = 1;
  String _tone = 'Sócrates Motivador';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client.from('users').select().eq('id', user.id).single();
        if (mounted) {
          setState(() {
            _name = data['display_name'] ?? user.email?.split('@')[0] ?? 'Usuario';
            _initial = _name.isNotEmpty ? _name[0].toUpperCase() : 'U';
            _points = data['points'] ?? 0;
            _level = data['level'] ?? 1;
            _tone = data['study_tone'] ?? 'Sócrates Motivador';
          });
        }
      } catch (e) {
         if (mounted) setState(() => _name = 'Usuario');
      }
    }
  }

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
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF8DB600),
              child: Text(_initial, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
            ),
            Text(
              'Estudiante Nivel $_level • $_points Puntos',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 48),

            // Settings Section
            _buildSettingsCard(
              title: 'Configuraciones Generales',
              children: [
                _buildSettingRow(Icons.psychology_outlined, 'Tono del Agente', _tone,
                    onTap: () => Navigator.pushNamed(context, '/onboarding')),
                _buildSettingRow(Icons.access_time, 'Organizador Base', 'Ver Calendario',
                    onTap: () => Navigator.pushNamed(context, '/calendar')),
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
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) Navigator.pushReplacementNamed(context, '/splash');
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

  Widget _buildSettingRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
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
            Icon(Icons.chevron_right,
                color: onTap != null ? const Color(0xFF536D00) : Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
