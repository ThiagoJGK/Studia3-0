import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as dart_ui;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _points = 0;
  int _streak = 0;
  String _firstName = 'Usuario';
  List<dynamic> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      Supabase.instance.client
          .from('users')
          .stream(primaryKey: ['id'])
          .listen((List<Map<String, dynamic>> data) {
        if (data.isNotEmpty && mounted) {
          final profile = data.firstWhere((element) => element['id'] == user.id, orElse: () => {});
          if (profile.isNotEmpty) {
             setState(() {
                _points = profile['points'] ?? 0;
                _streak = profile['current_streak'] ?? 0;
                _firstName = (profile['display_name'] ?? 'Usuario').split(' ')[0];
             });
          }
        }
      });

      Supabase.instance.client
          .from('goals')
          .stream(primaryKey: ['id'])
          .listen((List<Map<String, dynamic>> data) {
        if (mounted) {
          setState(() {
            _goals = data.where((g) => g['user_id'] == user.id && g['status'] == 'active').toList();
            _isLoading = false;
          });
        }
      });
    } else {
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      extendBody: true, // Required for floating HUD effect
      extendBodyBehindAppBar: true,
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
              radius: 16,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0, top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Buenos días, $_firstName',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu radar de aprendizaje está activo. Tienes hitos críticos esta semana.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: _buildStatCard('Racha', '$_streak días', Icons.local_fire_department, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Puntos', 'Pts $_points', Icons.star_rounded, const Color(0xFF8DB600))),
                ],
              ),

              const SizedBox(height: 48),
              const Text(
                'Trayectorias Activas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF536D00)),
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                 const Center(child: CircularProgressIndicator(color: Color(0xFF8DB600)))
              else if (_goals.isEmpty)
                 const Center(child: Text('No hay trayectorias activas aún. Crea un nuevo objetivo.', style: TextStyle(color: Colors.black54)))
              else
                 ..._goals.map((goal) => Padding(
                   padding: const EdgeInsets.only(bottom: 16.0),
                   child: _buildGoalCard(
                     context,
                     title: goal['title'] ?? 'Sin Título',
                     subtitle: 'Meta Activa',
                     progress: (goal['progress'] ?? 0) / 100.0,
                     onTap: () => Navigator.pushNamed(context, '/trajectory', arguments: goal),
                   ),
                 )).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: _HUD_BLUR,
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
                    _buildNavIcon(Icons.calendar_month_rounded, false, () {
                      if (ModalRoute.of(context)?.settings.name != '/calendar') {
                        Navigator.pushNamed(context, '/calendar');
                      }
                    }),
                    _buildNavIcon(Icons.add_circle, false, () {
                      if (ModalRoute.of(context)?.settings.name != '/add_goal') {
                        Navigator.pushNamed(context, '/add_goal');
                      }
                    }),
                    _buildNavIcon(Icons.emoji_events_outlined, false, () {
                      if (ModalRoute.of(context)?.settings.name != '/mastery') {
                        Navigator.pushNamed(context, '/mastery');
                      }
                    }),
                    _buildNavIcon(Icons.person_outline, false, () {
                      if (ModalRoute.of(context)?.settings.name != '/profile') {
                        Navigator.pushNamed(context, '/profile');
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static final _HUD_BLUR = dart_ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15);

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

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, {required String title, required String subtitle, required double progress, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      const SizedBox(height: 8),
                      Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF8DB600).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF8DB600), size: 16),
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8DB600))),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8DB600)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
