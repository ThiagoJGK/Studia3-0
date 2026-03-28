import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ── Colors ──────────────────────────────────
  static const _primary    = Color(0xFF536D00);
  static const _primaryC   = Color(0xFFC6F34C);
  static const _surface    = Color(0xFFFFFBFF);
  static const _surfaceLow = Color(0xFFFFFDB2);
  static const _surfaceHi  = Color(0xFFF3F29E);
  static const _onSurf     = Color(0xFF3A3A07);
  static const _onSurfVar  = Color(0xFF676731);
  static const _outlineVar = Color(0xFFBEBD7D);

  Future<void> _authenticate() async {
    final email       = _emailController.text.trim();
    final password    = _passwordController.text;
    final confirmPwd  = _confirmPasswordController.text;
    final displayName = _displayNameController.text.trim();

    if (email.isEmpty || password.isEmpty) { _snack('Completa correo y contraseña.'); return; }
    if (_isSignUp) {
      if (displayName.isEmpty) { _snack('Ingresa tu nombre.'); return; }
      if (password != confirmPwd) { _snack('Las contraseñas no coinciden.'); return; }
      if (password.length < 6)   { _snack('Mínimo 6 caracteres.'); return; }
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(email: email, password: password, data: {'display_name': displayName});
        if (mounted) { _snack('¡Cuenta creada! Inicia sesión.'); setState(() => _isSignUp = false); }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on AuthException catch (e) {
      if (mounted) _snack(e.message);
    } catch (e) {
      if (mounted) _snack('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? null : 'com.studia3.app://login-callback/',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
    } catch (e) { _snack('Error al conectar: $e'); }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    _emailController.dispose(); _passwordController.dispose();
    _confirmPasswordController.dispose(); _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned(top: -80, left: -80, child: _blob(380, _primaryC.withOpacity(0.12))),
          Positioned(bottom: -80, right: -80, child: _blob(320, const Color(0xFFE9E958).withOpacity(0.15))),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero heading
                        Text(
                          'Bienvenido a tu',
                          style: TextStyle(fontSize: 16, color: _onSurfVar, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, height: 1.1, color: _onSurf),
                            children: [
                              TextSpan(text: 'Santuario\n'),
                              TextSpan(text: 'Académico', style: TextStyle(color: _primary, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Un espacio diseñado para tu enfoque y crecimiento personal.',
                          style: TextStyle(fontSize: 16, color: _onSurfVar, height: 1.5),
                        ),
                        const SizedBox(height: 40),

                        // Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: _outlineVar.withOpacity(0.3)),
                            boxShadow: [BoxShadow(color: _primary.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))],
                          ),
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              // Social buttons
                              Row(
                                children: [
                                  Expanded(child: _buildGoogleBtn()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildAppleBtn()),
                                ],
                              ),
                              const SizedBox(height: 28),
                              _divider(_isSignUp ? 'Crea tu perfil' : 'O usa tu correo'),
                              const SizedBox(height: 28),

                              if (_isSignUp) ...[
                                _buildField('Tu nombre completo', Icons.person_outline, controller: _displayNameController),
                                const SizedBox(height: 16),
                              ],
                              _buildField('Tu correo electrónico', Icons.mail_outline, controller: _emailController, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _buildField(
                                'Contraseña', Icons.lock_outline,
                                controller: _passwordController,
                                obscure: _obscurePassword,
                                toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              if (_isSignUp) ...[
                                const SizedBox(height: 16),
                                _buildField(
                                  'Repetir contraseña', Icons.lock_reset_outlined,
                                  controller: _confirmPasswordController,
                                  obscure: _obscureConfirmPassword,
                                  toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                              ],
                              if (!_isSignUp) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/forgot_password'),
                                    child: const Text('¿Olvidaste tu contraseña?',
                                      style: TextStyle(fontSize: 13, color: _primary, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 28),

                              // Main CTA
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [_primary, Color(0xFF7B9F00)]),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                    ),
                                    onPressed: _isLoading ? null : _authenticate,
                                    child: _isLoading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                      : Text(_isSignUp ? 'Crear mi Cuenta' : 'Acceder a mi Santuario',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                              // Toggle
                              GestureDetector(
                                onTap: () => setState(() { _isSignUp = !_isSignUp; _isLoading = false; }),
                                child: RichText(
                                  text: TextSpan(
                                    text: _isSignUp ? '¿Ya tienes cuenta?  ' : '¿No tienes cuenta?  ',
                                    style: const TextStyle(color: _onSurfVar),
                                    children: [TextSpan(
                                      text: _isSignUp ? 'Inicia Sesión' : 'Crea una aquí',
                                      style: const TextStyle(color: _primary, fontWeight: FontWeight.bold),
                                    )],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: _primary),
              onPressed: () => Navigator.maybePop(context),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            const Text('Santuario Académico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primary)),
          ]),
          Row(children: [
            GestureDetector(
              onTap: () => setState(() => _isSignUp = false),
              child: Text('Acceder', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _isSignUp ? _onSurfVar : _primary)),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => setState(() => _isSignUp = true),
              child: Text('Registro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _isSignUp ? _primary : _onSurfVar)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildGoogleBtn() {
    return GestureDetector(
      onTap: () => _signInWithOAuth(OAuthProvider.google),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _outlineVar.withOpacity(0.5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
            height: 20,
            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
          ),
          const SizedBox(width: 8),
          const Text('Google', style: TextStyle(fontWeight: FontWeight.w600, color: _onSurf, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildAppleBtn() {
    return GestureDetector(
      onTap: () => _signInWithOAuth(OAuthProvider.apple),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _outlineVar.withOpacity(0.5)),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.apple, size: 22, color: _onSurf),
          SizedBox(width: 8),
          Text('Apple', style: TextStyle(fontWeight: FontWeight.w600, color: _onSurf, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _divider(String label) {
    return Row(children: [
      Expanded(child: Divider(color: _outlineVar.withOpacity(0.3))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: _onSurfVar)),
      ),
      Expanded(child: Divider(color: _outlineVar.withOpacity(0.3))),
    ]);
  }

  Widget _buildField(String hint, IconData icon, {
    bool obscure = false,
    TextEditingController? controller,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _onSurf),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _onSurfVar, fontSize: 14),
        prefixIcon: Icon(icon, color: _onSurfVar, size: 20),
        suffixIcon: toggleObscure != null
          ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: _onSurfVar, size: 20), onPressed: toggleObscure)
          : null,
        filled: true,
        fillColor: _surfaceLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60)),
    );
  }
}
