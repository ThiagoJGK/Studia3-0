import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();

    if (email.isEmpty || password.isEmpty || (_isSignUp && displayName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      if (_isSignUp) {
        // Mode: Sign Up
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'display_name': displayName},
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Cuenta creada! Revisa tu correo o inicia sesión.')),
           );
           setState(() => _isSignUp = false);
        }
      } else {
        // Mode: Login
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

              // Social Logins
              _buildGoogleButton('Continuar con Google'),
              const SizedBox(height: 16),
              _buildAppleButton('Continuar con Apple'),

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
              _buildTextField('Correo Electrónico', Icons.email_outlined, controller: _emailController),
              const SizedBox(height: 16),
              _buildTextField('Contraseña', Icons.lock_outline, obscureText: true, controller: _passwordController),

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
                  onTap: () => setState(() => _isSignUp = !_isSignUp),
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
              
              if (!_isSignUp)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/forgot_password'),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.black38, fontSize: 13),
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

  Widget _buildGoogleButton(String text) {
    return Container(
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
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png', 
            height: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 32),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAppleButton(String text) {
     return Container(
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
    );
  }

  Widget _buildTextField(String hint, IconData icon, {bool obscureText = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF8DB600), width: 2),
        ),
      ),
    );
  }
}
