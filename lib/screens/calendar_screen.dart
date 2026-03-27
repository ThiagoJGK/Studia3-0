import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as dart_ui;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isLoading = true;
  List<dynamic> _schedule = [];
  
  final List<String> _days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('weekly_schedule')
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _schedule = data['weekly_schedule'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      // Ignoramos si la columna no existe aún
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addBlock(String day) async {
    // Valores por defecto
    TimeOfDay start = const TimeOfDay(hour: 14, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 16, minute: 0);
    String category = 'study';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nuevo Bloque: $day', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF536D00))),
                  const SizedBox(height: 24),
                  
                  const Text('Categoría de Esfuerzo', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCategoryChip('Estudio', 'study', category, (c) => setModalState(() => category = c)),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Salud', 'health', category, (c) => setModalState(() => category = c)),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Trabajo', 'work', category, (c) => setModalState(() => category = c)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Horario', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(context: context, initialTime: start);
                            if (time != null) setModalState(() => start = time);
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text('${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF8DB600),
                            elevation: 0,
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('hasta')),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(context: context, initialTime: end);
                            if (time != null) setModalState(() => end = time);
                          },
                          icon: const Icon(Icons.access_time_filled),
                          label: Text('${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'),
                           style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF8DB600),
                            elevation: 0,
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DB600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _saveBlock(day, start, end, category);
                      },
                      child: const Text('Insertar Bloque', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildCategoryChip(String label, String value, String current, Function(String) onSelect) {
    final isSelected = value == current;
    Color baseColor;
    if (value == 'study') baseColor = const Color(0xFF8DB600);
    else if (value == 'health') baseColor = Colors.orange;
    else baseColor = Colors.blue;

    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? baseColor : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _saveBlock(String day, TimeOfDay start, TimeOfDay end, String category) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final newBlock = {
      'day': day,
      'start': '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
      'end': '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
      'category': category,
    };

    final updatedSchedule = List.from(_schedule)..add(newBlock);

    try {
      await Supabase.instance.client
          .from('users')
          .update({'weekly_schedule': updatedSchedule})
          .eq('id', user.id);
      
      setState(() {
        _schedule = updatedSchedule;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error guardando: $e\n¿Agregaste la columna JSONB en la base de datos?')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB), // Light surface
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Organizador', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF536D00))),
        backgroundColor: Colors.white.withOpacity(0.6),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: dart_ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8DB600)))
          : ListView.builder(
              padding: const EdgeInsets.all(24.0).copyWith(bottom: 120),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final dayBlocks = _schedule.where((b) => b['day'] == day).toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(day, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFF8DB600)),
                            onPressed: () => _addBlock(day),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (dayBlocks.isEmpty)
                        const Text('Día sin enfocar.', style: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic))
                      else
                        ...dayBlocks.map((block) => _buildTimeBlock(block)).toList(),
                      const Divider(height: 32, color: Colors.black12),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildTimeBlock(Map<String, dynamic> block) {
    Color baseColor;
    String label;
    IconData icon;

    if (block['category'] == 'study') {
      baseColor = const Color(0xFF8DB600);
      label = 'Bloque de Estudio (Dinámico)';
      icon = Icons.menu_book_rounded;
    } else if (block['category'] == 'health') {
      baseColor = Colors.orange;
      label = 'Bloque de Salud (Ancla Fija)';
      icon = Icons.favorite_rounded;
    } else {
      baseColor = Colors.blue;
      label = 'Bloque de Trabajo';
      icon = Icons.work_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: baseColor.withOpacity(0.8))),
                Text('${block['start']} - ${block['end']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ),
          if (block['category'] == 'study')
             const Icon(Icons.auto_awesome, color: Color(0xFF8DB600), size: 16)
        ],
      ),
    );
  }
}
