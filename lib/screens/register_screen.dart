import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:kawantumbuh/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- PALET WARNA REVISI SESUAI LOGIN ---
  final Color bgColor = const Color(0xFFFFEAEA);     // Background Soft Pink
  final Color navyDark = const Color(0xFF102C57);    // Navy Gelap
  final Color fieldColor = const Color(0xFFF5CBCB);  // Pink Input Field

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true; // Untuk fitur intip password
  final supabase = Supabase.instance.client;

  Future<void> _register() async {
    if (_phoneController.text.isEmpty || 
        _nameController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom harus diisi!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final name = _nameController.text.trim();
      final password = _passwordController.text.trim();
      
      final ninjaEmail = '$phone@kawantumbuh.com';

      await supabase.auth.signUp(
        email: ninjaEmail,
        password: password,
        data: {'full_name': name, 'phone': phone},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pendaftaran berhasil! Silakan Login."), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendaftar: ${e.message}"), backgroundColor: Colors.red),
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
    _nameController.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Silakan Daftar!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: navyDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Daftarkan akun anda untuk mulai memantau tumbuh kembang si kecil.',
                  style: TextStyle(
                    fontSize: 15,
                    color: navyDark.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // Form No HP
                _buildLabel('No HP/Whatsapp'),
                _buildTextField(
                  hintText: '081234567890', 
                  controller: _phoneController, 
                  isPhone: true,
                ),
                const SizedBox(height: 20),

                // Form Nama
                _buildLabel('Nama Bunda'),
                _buildTextField(
                  hintText: 'Bunda Sarah', 
                  controller: _nameController, 
                ),
                const SizedBox(height: 20),

                // Form Password
                _buildLabel('Password'),
                _buildTextField(
                  hintText: 'minimal 6 karakter', 
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 40),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      shadowColor: navyDark.withOpacity(0.4),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading 
                      ? const SizedBox(
                          height: 24, width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
                
                const SizedBox(height: 30),

                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah memiliki akun? ',
                        style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: navyDark, 
                            fontSize: 14, 
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: navyDark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText, 
    bool isPassword = false, 
    bool isPhone = false,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        keyboardType: isPhone ? TextInputType.number : TextInputType.text,
        inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: TextStyle(color: navyDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: navyDark.withOpacity(0.4), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          // --- ICON MATA DISINI ---
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: navyDark.withOpacity(0.6),
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        ),
      ),
    );
  }
}