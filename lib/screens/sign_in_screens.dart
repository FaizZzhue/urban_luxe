import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_luxe/services/user_profile_service.dart';
import 'package:urban_luxe/services/auth_cipher.dart';
import 'package:urban_luxe/widgets/auth_glass_shell.dart';
import 'package:urban_luxe/utils/app_snackbar.dart';


class SignInScreens extends StatefulWidget {
  const SignInScreens({super.key});

  @override
  State<SignInScreens> createState() => _SignInScreensState();
}

class _SignInScreensState extends State<SignInScreens> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorText = '';

  Future<void> _handleLogin() async {
    setState(() {
      _errorText = '';
      _isLoading = true;
    });

    final inputUsername = _usernameController.text.trim();
    final inputPassword = _passwordController.text;

    if (inputUsername.isEmpty || inputPassword.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorText = 'Username dan password tidak boleh kosong';
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final usernameEnc = prefs.getString('username_enc');
      final passwordEnc = prefs.getString('password_enc');
      final ivBase64 = prefs.getString('user_iv');

      if (usernameEnc == null || passwordEnc == null || ivBase64 == null) {
        setState(() => _errorText = 'Belum ada data akun. Silakan Sign Up terlebih dahulu.');
        return;
      }

      final savedUsername = AuthCipher.decryptText(usernameEnc, ivBase64);
      final savedPassword = AuthCipher.decryptText(passwordEnc, ivBase64);

      if (inputUsername == savedUsername && inputPassword == savedPassword) {
        await prefs.setBool('is_logged_in', true);

        await UserProfileService.setCurrentUser(inputUsername);

        final legacyFullName = prefs.getString('full_name') ?? '';
        if (legacyFullName.isNotEmpty) {
          await UserProfileService.saveSignupProfile(
            username: inputUsername,
            fullname: legacyFullName,
            email: "",
          );
        }

        if (!mounted) return;
        AppSnackBar.success(context, "Login berhasil");

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        setState(() => _errorText = 'Username atau password salah');
      }
    } catch (e) {
      setState(() => _errorText = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGlassShell(
      title: "Sign In",
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Username',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Password',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Masukkan Password',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[700],
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_errorText.isNotEmpty) ...[
            Text(_errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                backgroundColor: const Color(0xFF008A4E),
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum Punya Akun? ', style: TextStyle(color: Colors.white, fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: const Text(
                  'Daftar Di Sini',
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