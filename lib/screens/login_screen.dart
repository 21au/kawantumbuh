import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kawantumbuh/screens/main_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // <--- Import ini
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
    _loadSavedCredentials(); // <--- Cek apakah ada nomor yang pernah disimpan
  }

  // FUNGSI 1: Mengambil nomor HP yang tersimpan saat aplikasi dibuka
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('saved_phone') ?? '';
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  // FUNGSI 2: Menyimpan atau menghapus nomor HP berdasarkan status checkbox
  Future<void> _handleRememberMe() async {
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
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No HP dan Password harus diisi!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final ninjaEmail = '$phone@kawantumbuh.com';

      await supabase.auth.signInWithPassword(
        email: ninjaEmail,
        password: password,
      );

      // JIKA LOGIN BERHASIL, JALANKAN LOGIKA INGATKAN SAYA
      await _handleRememberMe();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()), 
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal masuk: ${e.message}"), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan sistem"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                Text(
                  "Selamat Datang!",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: navyDark),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pantau tumbuh kembang si kecil dengan mudah.",
                  style: TextStyle(fontSize: 15, color: navyDark.withOpacity(0.7)),
                ),
                const SizedBox(height: 40),
                
                _buildLabel("No HP/Whatsapp"),
                _buildTextField(
                  controller: _phoneController,
                  hint: "08XXXXXXXXX",
                  isNumber: true,
                ),
                
                const SizedBox(height: 20),
                
                _buildLabel("Password"),
                _buildTextField(
                  controller: _passwordController,
                  hint: "*********",
                  isPassword: true,
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
                            height: 30, width: 30,
                            child: Transform.scale(
                              scale: 1.3, 
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: navyDark, 
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: BorderSide(color: navyDark.withOpacity(0.6), width: 1.5),
                                onChanged: (value) => setState(() => _rememberMe = value!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text("Ingatkan Saya", style: TextStyle(color: navyDark, fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                      child: Text("Lupa password ?", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 14)),
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
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
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
                            style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navyDark)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: navyDark.withOpacity(0.4), fontSize: 14),
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