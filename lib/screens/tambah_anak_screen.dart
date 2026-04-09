import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahAnakScreen extends StatefulWidget {
  const TambahAnakScreen({super.key});

  @override
  State<TambahAnakScreen> createState() => _TambahAnakScreenState();
}

class _TambahAnakScreenState extends State<TambahAnakScreen> {
  // --- PALET WARNA UTAMA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);      
  final Color softPink = const Color(0xFFFFEAEA);      
  final Color fieldPink = const Color(0xFFF5CBCB);     
  final Color highlightPink = const Color(0xFFEBA9A9); 
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  final TextEditingController _lingkarKepalaController = TextEditingController();
  
  String _genderPilihan = 'Laki-laki'; 
  DateTime? _tanggalPengukuran;
  DateTime? _tanggalLahir; 
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

  // --- FUNGSI BARU: Hitung Usia dalam Bulan ---
  int _hitungUsiaBulan(DateTime birthDate) {
    final today = DateTime.now();
    int months = (today.year - birthDate.year) * 12 + today.month - birthDate.month;
    if (today.day < birthDate.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  // Fungsi Pilihan Tanggal
  Future<void> _pilihTanggal(BuildContext context, {required bool isTanggalLahir}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015), 
      lastDate: DateTime.now(), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyDark, 
              onPrimary: softPink, 
              surface: softPink, 
              onSurface: navyDark, 
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isTanggalLahir) {
          _tanggalLahir = picked;
          // --- LOGIK OTOMATIS HITUNG USIA ---
          int usiaBulan = _hitungUsiaBulan(picked);
          _usiaController.text = usiaBulan.toString(); // Masukkan hasil hitung ke controller
        } else {
          _tanggalPengukuran = picked;
        }
      });
    }
  }

  Future<void> _simpanDataAnak() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Nama anak tidak boleh kosong ya!"), backgroundColor: highlightPink),
      );
      return;
    }

    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Mohon pilih tanggal lahir si kecil!"), backgroundColor: highlightPink),
      );
      return;
    }

    if (_tanggalPengukuran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Mohon pilih tanggal pengukuran terakhir!"), backgroundColor: highlightPink),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Sesi login tidak ditemukan.");

      String formatTglPengukuran = "${_tanggalPengukuran!.year}-${_tanggalPengukuran!.month.toString().padLeft(2, '0')}-${_tanggalPengukuran!.day.toString().padLeft(2, '0')}";
      String formatTglLahir = "${_tanggalLahir!.year}-${_tanggalLahir!.month.toString().padLeft(2, '0')}-${_tanggalLahir!.day.toString().padLeft(2, '0')}";

      int? usiaAngka = int.tryParse(_usiaController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''));
      double? beratAngka = double.tryParse(_beratController.text.trim().replaceAll(',', '.'));
      double? tinggiAngka = double.tryParse(_tinggiController.text.trim().replaceAll(',', '.'));
      double? lingkarKepalaAngka = double.tryParse(_lingkarKepalaController.text.trim().replaceAll(',', '.'));

      final responseAnak = await Supabase.instance.client.from('anak').insert({
        'user_id': user.id,
        'nama': _namaController.text.trim(),
        'jenis_kelamin': _genderPilihan,
        'tanggal_lahir': formatTglLahir,
        'usia': usiaAngka,
        'berat': beratAngka,
        'tinggi': tinggiAngka,
        'lingkar_kepala': lingkarKepalaAngka,
        'tanggal_pengukuran': formatTglPengukuran,
      }).select().single();

      final String idAnakBaru = responseAnak['id'].toString();

      await Supabase.instance.client.from('pertumbuhan').insert({
        'anak_id': idAnakBaru,
        'tanggal_pengukuran': formatTglPengukuran,
        'berat_badan': beratAngka ?? 0.0,
        'tinggi_badan': tinggiAngka ?? 0.0,
        'lingkar_kepala': lingkarKepalaAngka ?? 0.0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Data anak & profil pertumbuhan awal berhasil disimpan! 🎉"), backgroundColor: navyDark),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data: $e"), backgroundColor: Colors.red[400]),
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
      backgroundColor: softPink,
      appBar: AppBar(
        title: Text("Tambah Data Anak", style: TextStyle(color: softPink, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: navyDark,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: softPink),
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
            
            _buildInputLabel("Tanggal Lahir"),
            _buildDatePicker(
              tanggal: _tanggalLahir, 
              hint: "Pilih Tanggal Lahir", 
              onTap: () => _pilihTanggal(context, isTanggalLahir: true)
            ),
            
            // --- KOLOM USIA (OTOMATIS & READ ONLY) ---
            _buildInputLabel("Usia (Otomatis dalam Bulan)"),
            _buildTextField(_usiaController, "Terisi otomatis", Icons.cake_outlined, isNumber: true, readOnly: true),

            _buildInputLabel("Tanggal Pengukuran Terakhir"),
            _buildDatePicker(
              tanggal: _tanggalPengukuran, 
              hint: "Pilih Tanggal Pengukuran", 
              onTap: () => _pilihTanggal(context, isTanggalLahir: false)
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
            
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 4.0),
              child: Text(
                "* Isi berat, tinggi, dan lingkar kepala sesuai dengan hasil pengukuran terakhir ya, Bunda. Data ini akan jadi patokan awal kurva pertumbuhannya.",
                style: TextStyle(color: navyDark.withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),

            _buildInputLabel("Jenis Kelamin"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: fieldPink.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: navyDark.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Laki-laki", style: TextStyle(fontSize: 14, color: navyDark, fontWeight: FontWeight.w500)),
                      value: 'Laki-laki',
                      groupValue: _genderPilihan,
                      activeColor: navyDark,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setState(() => _genderPilihan = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Perempuan", style: TextStyle(fontSize: 14, color: navyDark, fontWeight: FontWeight.w500)),
                      value: 'Perempuan',
                      groupValue: _genderPilihan,
                      activeColor: highlightPink,
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
                  backgroundColor: navyDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: _isLoading 
                    ? CircularProgressIndicator(color: softPink)
                    : Text("Simpan Data", style: TextStyle(color: softPink, fontSize: 16, fontWeight: FontWeight.bold)),
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
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navyDark),
      ),
    );
  }

  // --- UPDATE: Menambahkan properti readOnly di _buildTextField ---
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly, // TextField bisa dikunci
      style: TextStyle(color: navyDark, fontWeight: FontWeight.w500),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: navyDark.withOpacity(0.4), fontSize: 13),
        prefixIcon: Icon(icon, color: navyDark.withOpacity(0.7)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade300 : fieldPink.withOpacity(0.5), // Warna dibedakan sedikit kalau readOnly
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildDatePicker({required DateTime? tanggal, required String hint, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: fieldPink.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: navyDark.withOpacity(0.7)),
            const SizedBox(width: 10),
            Text(
              tanggal == null 
                  ? hint 
                  : "${tanggal.day}/${tanggal.month}/${tanggal.year}",
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w500,
                color: tanggal == null ? navyDark.withOpacity(0.4) : navyDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}