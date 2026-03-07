import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kawantumbuh/utils/app_colors.dart';

class TambahAnakScreen extends StatefulWidget {
  const TambahAnakScreen({super.key});

  @override
  State<TambahAnakScreen> createState() => _TambahAnakScreenState();
}

class _TambahAnakScreenState extends State<TambahAnakScreen> {
  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color oceanBlue = const Color(0xFF1E88B3);
  // Warna pengganti putih (Pink sangat muda agar senada dengan background)
  final Color softInputColor = const Color(0xFFFDEEF1); 
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  final TextEditingController _lingkarKepalaController = TextEditingController();
  
  String _genderPilihan = 'Laki-laki'; 
  DateTime? _tanggalPengukuran;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    _lingkarKepalaController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyBackground,
              onPrimary: softInputColor, // Teks di atas tombol kalender
              onSurface: navyBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggalPengukuran) {
      setState(() {
        _tanggalPengukuran = picked;
      });
    }
  }

  Future<void> _simpanDataAnak() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama anak tidak boleh kosong ya!"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_tanggalPengukuran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon pilih tanggal pengukuran terakhir!"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Sesi login tidak ditemukan.");

      String formattedDate = "${_tanggalPengukuran!.year}-${_tanggalPengukuran!.month.toString().padLeft(2, '0')}-${_tanggalPengukuran!.day.toString().padLeft(2, '0')}";

      int? usiaAngka = int.tryParse(_usiaController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''));
      double? beratAngka = double.tryParse(_beratController.text.trim().replaceAll(',', '.'));
      double? tinggiAngka = double.tryParse(_tinggiController.text.trim().replaceAll(',', '.'));
      double? lingkarKepalaAngka = double.tryParse(_lingkarKepalaController.text.trim().replaceAll(',', '.'));

      await Supabase.instance.client.from('anak').insert({
        'user_id': user.id,
        'nama': _namaController.text.trim(),
        'jenis_kelamin': _genderPilihan,
        'usia': usiaAngka,
        'berat': beratAngka,
        'tinggi': tinggiAngka,
        'lingkar_kepala': lingkarKepalaAngka,
        'tanggal_pengukuran': formattedDate,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data anak berhasil ditambahkan! 🎉"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      appBar: AppBar(
        title: const Text("Tambah Data Anak", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: navyBackground,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputLabel("Nama Lengkap Anak"),
            _buildTextField(_namaController, "Masukkan nama anak", Icons.person_outline),
            
            _buildInputLabel("Usia (dalam Bulan)"),
            _buildTextField(_usiaController, "Contoh: 18", Icons.cake_outlined, isNumber: true),

            _buildInputLabel("Tanggal Pengukuran Terakhir"),
            GestureDetector(
              onTap: () => _pilihTanggal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: softInputColor, // Ganti putih jadi pink muda
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: navyBackground.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: oceanBlue),
                    const SizedBox(width: 10),
                    Text(
                      _tanggalPengukuran == null 
                          ? "Pilih Tanggal Pengukuran" 
                          : "${_tanggalPengukuran!.day}/${_tanggalPengukuran!.month}/${_tanggalPengukuran!.year}",
                      style: TextStyle(
                        fontSize: 14, 
                        color: _tanggalPengukuran == null ? Colors.grey.shade500 : navyBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Berat (kg)"),
                      _buildTextField(_beratController, "Contoh: 10.5", Icons.monitor_weight_outlined, isNumber: true),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Tinggi (cm)"),
                      _buildTextField(_tinggiController, "Contoh: 80", Icons.height, isNumber: true),
                    ],
                  ),
                ),
              ],
            ),

            _buildInputLabel("Lingkar Kepala (cm)"),
            _buildTextField(_lingkarKepalaController, "Contoh: 45.5", Icons.face, isNumber: true),
            
            const Padding(
              padding: EdgeInsets.only(top: 10.0, left: 4.0),
              child: Text(
                "* Isi berat, tinggi, dan lingkar kepala sesuai dengan hasil pengukuran terakhir ya, Bunda.",
                style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),

            _buildInputLabel("Jenis Kelamin"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: softInputColor, // Ganti putih jadi pink muda
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: navyBackground.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Laki-laki", style: TextStyle(fontSize: 14, color: navyBackground)),
                      value: 'Laki-laki',
                      groupValue: _genderPilihan,
                      activeColor: oceanBlue,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setState(() => _genderPilihan = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Perempuan", style: TextStyle(fontSize: 14, color: navyBackground)),
                      value: 'Perempuan',
                      groupValue: _genderPilihan,
                      activeColor: Colors.pinkAccent,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setState(() => _genderPilihan = value!),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanDataAnak,
                style: ElevatedButton.styleFrom(
                  backgroundColor: oceanBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Data", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navyBackground),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: navyBackground),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(icon, color: oceanBlue),
        filled: true,
        fillColor: softInputColor, // Warna input pink sangat muda
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: navyBackground.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: navyBackground.withOpacity(0.05)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}