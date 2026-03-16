import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'main_wrapper.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color bgColor = const Color(0xFFFFEAEA);     
  final Color navyDark = const Color(0xFF102C57);    
  final Color fieldColor = const Color(0xFFF5CBCB);  

  bool _rememberMe = false;
  bool _obscureText = true; 
  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('saved_phone') ?? '';
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_phone', _phoneController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_phone');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _login() async {
    // 1. Validasi Input
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("No HP dan Password harus diisi!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Normalisasi No HP (Menghapus spasi/karakter aneh)
      final phone = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      final password = _passwordController.text.trim();
      
      // Sesuaikan dengan format email saat pendaftaran
      final ninjaEmail = '$phone@kawantumbuh.com';

      // 3. Proses Auth
      await supabase.auth.signInWithPassword(
        email: ninjaEmail,
        password: password,
      );

      // 4. Simpan Remember Me
      await _saveCredentials();

      // 5. Navigasi (PASTIKAN MainWrapper tidak pakai const)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainWrapper()), // JANGAN PAKAI CONST
          (route) => false, // Hapus semua halaman sebelumnya agar tidak bisa balik ke login
        );
      }
    } on AuthException catch (e) {
      // Error spesifik dari Supabase (Password salah, user tidak ada, dll)
      String errorMsg = "Gagal masuk: Nomor atau password salah";
      if (e.message.contains("Invalid login credentials")) {
        errorMsg = "Nomor HP atau Password Bunda salah, cek lagi ya!";
      } else if (e.message.contains("Email not confirmed")) {
        errorMsg = "Akun belum dikonfirmasi.";
      }
      _showSnackBar(errorMsg, Colors.red);
    } catch (e) {
      _showSnackBar("Terjadi kesalahan koneksi. Pastikan internet aktif.", Colors.red);
      debugPrint("Login Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Biar lebih cantik melayang
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text("Selamat Datang!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: navyDark)),
                const SizedBox(height: 8),
                Text("Pantau tumbuh kembang si kecil dengan mudah.", style: TextStyle(fontSize: 15, color: navyDark.withOpacity(0.7))),
                const SizedBox(height: 40),
                
                _buildLabel("No HP/Whatsapp"),
                _buildTextField(
                  controller: _phoneController, 
                  hint: "Contoh: 08123456789", 
                  isNumber: true
                ),
                
                const SizedBox(height: 20),
                
                _buildLabel("Password"),
                _buildTextField(
                  controller: _passwordController, 
                  hint: "Masukkan password Bunda", 
                  isPassword: true
                ),
                
                const SizedBox(height: 15),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: navyDark,
                              onChanged: (value) => setState(() => _rememberMe = value!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("Ingatkan Saya", style: TextStyle(color: navyDark, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                      child: Text("Lupa password ?", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 55, 
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyDark, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      disabledBackgroundColor: navyDark.withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 35),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                    child: RichText(
                      text: TextSpan(
                        text: "Belum memiliki akun? ",
                        style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Daftar disini", 
                            style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
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
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navyDark)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isPassword = false, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: navyDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: navyDark.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: navyDark.withOpacity(0.6)),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        ),
      ),
    );
  }
}