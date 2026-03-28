import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedTone = 'Resumido al Punto';
  final Set<String> _selectedTools = {'Flashcards'};
  bool _isLoading = false;

  // ── Colors ───────────────────────────────────
  static const _primary    = Color(0xFF536D00);
  static const _primaryC   = Color(0xFFC6F34C);
  static const _surface    = Color(0xFFFFFBFF);
  static const _surfaceLow = Color(0xFFFFFDB2);
  static const _surfaceHi  = Color(0xFFEEED94);
  static const _onSurf     = Color(0xFF3A3A07);
  static const _onSurfVar  = Color(0xFF676731);

  final _toneOptions = [
    _ToneOption('Riguroso',         Icons.gavel,         'Disciplina técnica y precisión académica.'),
    _ToneOption('Resumido al Punto', Icons.bolt,          'Sin rodeos. Solo la esencia necesaria.'),
    _ToneOption('Motivador',         Icons.auto_awesome,  'Apoyo constante y refuerzo positivo.'),
  ];

  final _toolOptions = [
    _ToolOption('Flashcards',         Icons.style),
    _ToolOption('Quizzes',            Icons.quiz),
    _ToolOption('Simulacros',         Icons.assignment),
    _ToolOption('Lectura con Analogías', Icons.menu_book),
  ];

  Future<void> _finalize() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('users').upsert({
          'id': user.id,
          'guide_tone': _selectedTone,
          'preferred_tools': _selectedTools.toList(),
        });
      }
    } catch (_) { /* No bloqueamos si falla el guardado */ }
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned(top: -80, right: -40,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(color: _primaryC.withOpacity(0.12), shape: BoxShape.circle))),
          Positioned(bottom: -60, left: -40,
            child: Container(width: 240, height: 240,
              decoration: BoxDecoration(color: const Color(0xFFE9E958).withOpacity(0.18), shape: BoxShape.circle))),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        // Hero heading
                        const Text(
                          '¿Cómo funciona\nmejor tu cerebro?',
                          style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, height: 1.1, color: _onSurf),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Personaliza tu santuario de estudio para que la inteligencia artificial se adapte a tu ritmo cognitivo.',
                          style: TextStyle(fontSize: 16, color: _onSurfVar, height: 1.5),
                        ),
                        const SizedBox(height: 56),

                        // Tone section
                        _sectionLabel(Icons.psychology, 'Tono del Guía'),
                        const SizedBox(height: 20),
                        ...(_toneOptions.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildToneCard(t),
                        ))),

                        const SizedBox(height: 48),

                        // Tools section
                        _sectionLabel(Icons.inventory_2_outlined, 'Mis Herramientas Favoritas'),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10, runSpacing: 10,
                          children: _toolOptions.map((t) => _buildToolChip(t)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky bottom CTA
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_surface.withOpacity(0), _surface],
                ),
              ),
              child: GestureDetector(
                onTap: _isLoading ? null : _finalize,
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primary, Color(0xFFA0C832)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isLoading ? 'Configurando...' : 'Configurar mi motor de estudio',
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.east, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _primary),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Text('Initial Diagnosis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primary)),
          const Text('Paso 1 de 5',
            style: TextStyle(fontSize: 13, color: _onSurfVar, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String label) {
    return Row(children: [
      Icon(icon, color: _primary, size: 20),
      const SizedBox(width: 8),
      Text(label.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.8, color: _onSurfVar)),
    ]);
  }

  Widget _buildToneCard(_ToneOption opt) {
    final isSelected = _selectedTone == opt.label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTone = opt.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? _surfaceHi : _surfaceLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _primary : Colors.transparent, width: 2),
          boxShadow: isSelected
            ? [BoxShadow(color: _primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))]
            : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isSelected ? _primary : _surfaceHi,
                shape: BoxShape.circle,
              ),
              child: Icon(opt.icon, color: isSelected ? Colors.white : _primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(opt.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _onSurf)),
                const SizedBox(height: 2),
                Text(opt.subtitle, style: const TextStyle(fontSize: 12, color: _onSurfVar)),
              ],
            )),
            if (isSelected) const Icon(Icons.check_circle, color: _primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToolChip(_ToolOption opt) {
    final isSelected = _selectedTools.contains(opt.label);
    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) _selectedTools.remove(opt.label);
        else _selectedTools.add(opt.label);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _primary : _surfaceLow,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
            ? [BoxShadow(color: _primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(opt.icon, size: 18, color: isSelected ? Colors.white : _onSurfVar),
          const SizedBox(width: 8),
          Text(opt.label, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _onSurfVar,
          )),
        ]),
      ),
    );
  }
}

class _ToneOption {
  final String label, subtitle;
  final IconData icon;
  _ToneOption(this.label, this.icon, this.subtitle);
}

class _ToolOption {
  final String label;
  final IconData icon;
  _ToolOption(this.label, this.icon);
}
