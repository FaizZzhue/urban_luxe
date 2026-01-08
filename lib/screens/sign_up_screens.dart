import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_luxe/services/user_profile_service.dart';
import 'package:urban_luxe/services/auth_cipher.dart';
import 'package:urban_luxe/widgets/auth_glass_shell.dart';
import 'package:urban_luxe/utils/app_snackbar.dart';

class SignUpScreens extends StatefulWidget {
  const SignUpScreens({super.key});

  @override
  State<SignUpScreens> createState() => _SignUpScreensState();
}

class _SignUpScreensState extends State<SignUpScreens> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorText = '';

  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus memiliki 1 huruf besar (A-Z)';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password harus memiliki 1 angka (0-9)';
    }
    final special = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]');
    if (!special.hasMatch(password)) {
      return 'Password harus memiliki 1 karakter khusus (contoh: !@#*)';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _errorText = '';
      _isLoading = true;
    });

    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorText = 'Semua field wajib diisi';
      });
      return;
    }

    final passErr = _validatePassword(password);
    if (passErr != null) {
      setState(() {
        _isLoading = false;
        _errorText = passErr;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final existingUsernameEnc = prefs.getString('username_enc');
      final existingIv = prefs.getString('user_iv');
      if (existingUsernameEnc != null && existingIv != null) {
      }

      final iv = AuthCipher.newIv();
      final encUsername = AuthCipher.encryptText(username, iv);
      final encPassword = AuthCipher.encryptText(password, iv);

      await prefs.setString('full_name', fullName);
      await prefs.setString('username_enc', encUsername);
      await prefs.setString('password_enc', encPassword);
      await prefs.setString('user_iv', iv.base64);
      await prefs.setBool('is_logged_in', false);

      await UserProfileService.saveSignupProfile(
        username: username,
        fullname: fullName,
        email: "",
      );

      if (!mounted) return;
      AppSnackBar.success(context, "Registrasi berhasil, silakan login");

      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGlassShell(
      title: "Sign Up",
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Full Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _fullNameController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Masukkan Nama Lengkap',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Username',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Masukkan Username',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.black87),
            onChanged: (v) {
              final err = _validatePassword(v);
              setState(() => _errorText = err ?? '');
            },
            decoration: InputDecoration(
              hintText: 'Masukkan Password',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[700],
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const SizedBox(height: 12),

          if (_errorText.isNotEmpty) ...[
            Text(
              _errorText,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
            const SizedBox(height: 10),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: const Color(0xFF008A4E),
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              onPressed: _isLoading ? null : _handleSignUp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Sign Up',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah Punya Akun? ',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/signin'),
                child: const Text(
                  'Login Di Sini',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}