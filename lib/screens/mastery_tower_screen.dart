import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MasteryTowerScreen extends StatefulWidget {
  const MasteryTowerScreen({super.key});

  @override
  State<MasteryTowerScreen> createState() => _MasteryTowerScreenState();
}

class _MasteryTowerScreenState extends State<MasteryTowerScreen> {
  int _points = 0;
  int _streak = 0;
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
              });
           }
        }
      });

      Supabase.instance.client
          .from('goals')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .listen((List<Map<String, dynamic>> data) {
        if (mounted) {
          setState(() {
            _goals = data;
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
    // Determine if any goal is struggling (below 80% progress)
    final strugglingGoal = _goals.firstWhere(
      (g) => g['status'] == 'active' && ((g['progress'] ?? 0) < 80), 
      orElse: () => null
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      appBar: AppBar(
        title: const Text('Torre de Maestría', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF536D00))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF536D00)),
        actions: [
          _buildHudBadge(Icons.local_fire_department, '$_streak', Colors.orange),
          const SizedBox(width: 8),
          _buildHudBadge(Icons.star_rounded, '$_points', const Color(0xFF8DB600)),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Tu Arquitectura Cognitiva',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 48),

            if (_isLoading)
               const Center(child: CircularProgressIndicator(color: Color(0xFF8DB600)))
            else
               Center(
                 child: Column(
                   children: [
                     if (_goals.isEmpty)
                        const Text('Tu torre aún no tiene cimientos. Crea un objetivo.', style: TextStyle(color: Colors.black54))
                     else
                        ..._goals.map((goal) {
                          final progress = goal['progress'] ?? 0;
                          final isCracked = progress < 80;
                          
                          if (isCracked) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: _buildCrackedBlock(title: goal['title'] ?? 'Materia', mastery: '$progress% Dominio'),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: _buildBlock(title: goal['title'] ?? 'Materia', mastery: '$progress%', isSolid: true, opacity: 1.0),
                            );
                          }
                        }).toList(),
                   ],
                 ),
               ),

            const SizedBox(height: 48),

            if (strugglingGoal != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Riesgo de Colapso Analítico',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tus cimientos en ${strugglingGoal['title']} presentan grietas (${strugglingGoal['progress']}%). El conocimiento inerte impedirá avanzar a herramientas superiores. Se detectó riesgo por el Efecto Mateo.',
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: strugglingGoal != null 
       ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generando sesión de Nivelación (Práctica Espaciada)...')),
                );
              },
              backgroundColor: const Color(0xFF8DB600),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              label: const Text('Sellar las Grietas', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.build_rounded, color: Colors.white, size: 28),
            ),
          ),
        )
       : const SizedBox.shrink(),
    );
  }

  Widget _buildHudBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBlock({required String title, required String mastery, required bool isSolid, required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 220,
        height: 60,
        decoration: BoxDecoration(
          color: isSolid ? const Color(0xFF8DB600) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          border: isSolid ? null : Border.all(color: Colors.grey.shade400, width: 2, style: BorderStyle.solid),
          boxShadow: isSolid ? [
            BoxShadow(color: const Color(0xFF8DB600).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Center(
          child: Text(
            '$title ($mastery)',
            style: TextStyle(
              color: isSolid ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrackedBlock({required String title, required String mastery}) {
    return Container(
      width: 240,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Stack(
        children: [
          // Simulated cracks
          Positioned(
            left: 20,
            top: 10,
            child: Icon(Icons.flash_on, color: Colors.orange.shade300, size: 40),
          ),
          Positioned(
            right: 40,
            bottom: 5,
            child: Icon(Icons.flash_on, color: Colors.orange.shade300, size: 30),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  mastery,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
