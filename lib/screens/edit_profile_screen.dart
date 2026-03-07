import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  bool _isLoading = false;

  // --- PALET WARNA UTAMA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);      
  final Color softPink = const Color(0xFFFFEAEA);      
  final Color fieldPink = const Color(0xFFF5CBCB);     
  final Color highlightPink = const Color(0xFFEBA9A9); 

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      String phone = (user.email?.replaceAll('@kawantumbuh.com', '') ?? '').toString();
      
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        setState(() {
          _namaController.text = (data['full_name'] ?? '').toString();
          _teleponController.text = phone;
        });
      } catch (e) {
        setState(() {
          _namaController.text = (user.userMetadata?['nama'] ?? '').toString();
          _teleponController.text = phone;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Nama tidak boleh kosong"), 
          backgroundColor: highlightPink,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'full_name': _namaController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui! 🎉"), 
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: navyDark,
        title: Text(
          "Ubah Data Profil", 
          style: TextStyle(color: softPink, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        iconTheme: IconThemeData(color: softPink),
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildLabel("Nama Lengkap Bunda"),
            TextField(
              controller: _namaController,
              style: TextStyle(color: navyDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                hintText: "Masukkan nama Bunda",
                hintStyle: TextStyle(color: navyDark.withOpacity(0.3)),
                prefixIcon: Icon(Icons.person_outline_rounded, color: navyDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: fieldPink),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: fieldPink),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: highlightPink, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildLabel("Nomor Telepon (ID)"),
            TextField(
              controller: _teleponController,
              enabled: false, 
              style: TextStyle(color: navyDark.withOpacity(0.5)),
              decoration: InputDecoration(
                filled: true,
                fillColor: fieldPink.withOpacity(0.3),
                prefixIcon: Icon(Icons.phone_android_rounded, color: navyDark.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                helperText: "*Nomor telepon tidak dapat diubah",
                helperStyle: TextStyle(color: navyDark.withOpacity(0.4), fontSize: 11),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyDark,
                  foregroundColor: softPink,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading 
                    ? SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: softPink, strokeWidth: 3)
                      )
                    : const Text(
                        "Simpan Perubahan", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 8.0),
      child: Text(
        text, 
        style: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: navyDark
        )
      ),
    );
  }
}