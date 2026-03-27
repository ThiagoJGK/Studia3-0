import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final displayName = _displayNameController.text.trim();

    // 1. Validaciones Básicas
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Completa correo y contraseña.');
      return;
    }

    if (_isSignUp) {
      if (displayName.isEmpty) {
        _showSnackBar('Ingresa tu nombre para el santuario.');
        return;
      }
      if (password != confirmPassword) {
        _showSnackBar('Las contraseñas no coinciden.');
        return;
      }
      if (password.length < 6) {
        _showSnackBar('La contraseña debe tener al menos 6 caracteres.');
        return;
      }
    }

    setState(() => _isLoading = true);
    
    try {
      if (_isSignUp) {
        // --- MODO REGISTRO ---
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'display_name': displayName},
        );
        if (mounted) {
           _showSnackBar('¡Cuenta creada! Verifica tu email o inicia sesión.');
           setState(() => _isSignUp = false);
        }
      } else {
        // --- MODO INICIO SESIÓN ---
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on AuthException catch (e) {
      if (mounted) _showSnackBar(e.message);
    } catch (e) {
      if (mounted) _showSnackBar('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica de Social Login con PopUp (OAuth)
  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? null : 'com.studia3.app://login-callback/',
        authScreenLaunchMode: LaunchMode.platformDefault, // Forzar PopUp
      );
    } catch (e) {
      _showSnackBar('Error al conectar con $provider: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isSignUp ? 'Únete al' : 'Bienvenido al',
                style: const TextStyle(fontSize: 24, color: Colors.black54),
              ),
              const Text(
                'Santuario Académico',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF536D00), height: 1.1),
              ),
              const SizedBox(height: 40),

              // Social Logins (Ahora Clickeables)
              _buildSocialButton(
                'Continuar con Google', 
                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png',
                onTap: () => _signInWithOAuth(OAuthProvider.google),
              ),
              const SizedBox(height: 16),
              _buildAppleButton(
                'Continuar con Apple',
                onTap: () => _signInWithOAuth(OAuthProvider.apple),
              ),

              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(_isSignUp ? 'Crea tu perfil' : 'O usa tu correo', style: const TextStyle(color: Colors.black54)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 32),

              if (_isSignUp) ...[
                _buildTextField('Nombre Completo', Icons.person_outline, controller: _displayNameController),
                const SizedBox(height: 16),
              ],
              _buildTextField('Correo Electrónico', Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              
              // Password 1
              _buildTextField(
                'Contraseña', 
                Icons.lock_outline, 
                obscureText: _obscurePassword, 
                controller: _passwordController,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              
              if (_isSignUp) ...[
                const SizedBox(height: 16),
                // Password 2 (Verificación)
                _buildTextField(
                  'Repetir Contraseña', 
                  Icons.lock_reset_outlined, 
                  obscureText: _obscureConfirmPassword, 
                  controller: _confirmPasswordController,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8DB600),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isLoading ? null : _authenticate,
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text(_isSignUp ? 'Crear mi Cuenta' : 'Acceder a mi Santuario', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isSignUp = !_isSignUp;
                    _isLoading = false;
                  }),
                  child: RichText(
                    text: TextSpan(
                      text: _isSignUp ? '¿Ya tienes cuenta? ' : '¿No tienes cuenta? ',
                      style: const TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: _isSignUp ? 'Inicia Sesión' : 'Regístrate',
                          style: const TextStyle(color: Color(0xFF536D00), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, String assetPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(assetPath, height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 32)),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleButton(String text, {VoidCallback? onTap}) {
     return GestureDetector(
      onTap: onTap,
       child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
       ),
     );
  }

  Widget _buildTextField(String hint, IconData icon, {bool obscureText = false, TextEditingController? controller, Widget? suffixIcon, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF8DB600), width: 2),
        ),
      ),
    );
  }
}
