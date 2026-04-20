import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _namaIbuController = TextEditingController();
  final TextEditingController _namaAyahController = TextEditingController();
  final TextEditingController _pekerjaanIbuController = TextEditingController();
  final TextEditingController _pekerjaanAyahController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
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
          _namaIbuController.text = (data['full_name'] ?? '').toString();
          _namaAyahController.text = (data['nama_ayah'] ?? '').toString();
          _pekerjaanIbuController.text = (data['pekerjaan_ibu'] ?? '').toString();
          _pekerjaanAyahController.text = (data['pekerjaan_ayah'] ?? '').toString();
          _alamatController.text = (data['alamat'] ?? '').toString();
          _teleponController.text = phone;
        });
      } catch (e) {
        setState(() {
          _namaIbuController.text = (user.userMetadata?['nama'] ?? '').toString();
          _teleponController.text = phone;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_namaIbuController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Nama Ibu tidak boleh kosong"), 
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
        'full_name': _namaIbuController.text.trim(),
        'nama_ayah': _namaAyahController.text.trim(),
        'pekerjaan_ibu': _pekerjaanIbuController.text.trim(),
        'pekerjaan_ayah': _pekerjaanAyahController.text.trim(),
        'alamat': _alamatController.text.trim(),
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
          "Ubah Identitas Orang Tua", 
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
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: fieldPink.withOpacity(0.4),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: highlightPink),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: navyDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Data ini disesuaikan dengan format Buku KIA untuk kelengkapan rekam medis anak.",
                      style: TextStyle(color: navyDark, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            
            // --- DATA IBU ---
            const Divider(),
            const SizedBox(height: 10),
            Text("Data Ibu", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            _buildLabel("Nama Lengkap Ibu"),
            _buildTextField(_namaIbuController, "Masukkan nama Ibu", Icons.face_3_outlined),
            const SizedBox(height: 15),
            
            _buildLabel("Pekerjaan Ibu"),
            _buildTextField(_pekerjaanIbuController, "Contoh: Ibu Rumah Tangga, Guru...", Icons.work_outline),
            const SizedBox(height: 25),

            // --- DATA AYAH ---
            const Divider(),
            const SizedBox(height: 10),
            Text("Data Ayah", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            _buildLabel("Nama Lengkap Ayah"),
            _buildTextField(_namaAyahController, "Masukkan nama Ayah", Icons.face_6_outlined),
            const SizedBox(height: 15),

            _buildLabel("Pekerjaan Ayah"),
            _buildTextField(_pekerjaanAyahController, "Contoh: Karyawan Swasta, PNS...", Icons.work_outline),
            const SizedBox(height: 25),

            // --- KONTAK & ALAMAT ---
            const Divider(),
            const SizedBox(height: 10),
            Text("Informasi Kontak & Domisili", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            _buildLabel("Alamat Lengkap"),
            TextField(
              controller: _alamatController,
              maxLines: 3,
              style: TextStyle(color: navyDark, fontWeight: FontWeight.w600),
              decoration: _inputDecoration("Masukkan alamat domisili saat ini").copyWith(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40), // Align icon to top
                  child: Icon(Icons.home_outlined, color: navyDark),
                ),
              ),
            ),
            const SizedBox(height: 15),

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
            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
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
            ),
            const SizedBox(height: 20),
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

  // Widget helper untuk TextField biar kode gak kepanjangan
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: TextStyle(color: navyDark, fontWeight: FontWeight.w600),
      decoration: _inputDecoration(hint).copyWith(
        prefixIcon: Icon(icon, color: navyDark),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      hintText: hint,
      hintStyle: TextStyle(color: navyDark.withOpacity(0.3)),
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
    );
  }
}