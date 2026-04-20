import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class CatatPertumbuhanScreen extends StatefulWidget {
  final String anakId;

  const CatatPertumbuhanScreen({super.key, required this.anakId});

  @override
  State<CatatPertumbuhanScreen> createState() => _CatatPertumbuhanScreenState();
}

class _CatatPertumbuhanScreenState extends State<CatatPertumbuhanScreen> {
  // --- WARNA TEMA POSYANDU ---
  final Color navyDark = const Color(0xFF102C57);
  final Color backgroundPink = const Color(0xFFFAEEEE); 
  final Color cardBackground = const Color(0xFFFFF3F3); 
  final Color cardBorder = const Color(0xFFF2D6D6); 
  final Color minusBtnColor = const Color(0xFFE5A4A4); 
  final Color plusBtnColor = const Color(0xFF1E7FB8); 
  final Color saveBtnColor = const Color(0xFFA6E5A3); 
  final Color dateIconPink = const Color(0xFFEA9494); 
  final Color arrowBlue = const Color(0xFF4CA0D9); 

  late TextEditingController _beratController;
  late TextEditingController _tinggiController;
  late TextEditingController _lingkarController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Pastikan URL ini sesuai dengan yang ada di Hugging Face kamu
  final String hfApiUrl = "https://audreyrey-api-prediksi-kawan.hf.space/trigger-prediksi";

  @override
  void initState() {
    super.initState();
    _beratController = TextEditingController(text: "0.0");
    _tinggiController = TextEditingController(text: "0.0");
    _lingkarController = TextEditingController(text: "0.0");
  }

  @override
  void dispose() {
    _beratController.dispose();
    _tinggiController.dispose();
    _lingkarController.dispose();
    super.dispose();
  }

  // --- FUNGSI PENDUKUNG ---

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), 
      lastDate: DateTime.now(), // Tidak boleh masa depan
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyDark, 
              onPrimary: Colors.white, 
              onSurface: navyDark, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatTanggal(DateTime date) {
    List<String> hari = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
    List<String> bulan = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return "${hari[date.weekday - 1]}, ${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  void _ubahNilai(TextEditingController controller, double amount) {
    double currentVal = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;
    double newVal = currentVal + amount;
    if (newVal < 0) newVal = 0; 
    setState(() {
      controller.text = newVal.toStringAsFixed(1);
    });
  }

  // --- FUNGSI API & DATABASE ---

  Future<bool> _triggerPrediksiHuggingFace() async {
    try {
      // Menggunakan GET agar sinkron dengan setelan server Python (app.py)
      final response = await http.get(
        Uri.parse(hfApiUrl),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Berhasil trigger AI: ${response.body}");
        return true; 
      } else {
        debugPrint("❌ Error Hugging Face: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Exception API: $e");
      return false;
    }
  }

  Future<void> _simpanData() async {
    setState(() => _isLoading = true);
    try {
      final double berat = double.tryParse(_beratController.text.replaceAll(',', '.')) ?? 0;
      final double tinggi = double.tryParse(_tinggiController.text.replaceAll(',', '.')) ?? 0;
      final double lingkar = double.tryParse(_lingkarController.text.replaceAll(',', '.')) ?? 0;

      // Validasi Input
      if (berat <= 0 || tinggi <= 0) {
        throw "Wah, Berat dan Tinggi badannya masih 0 nih Bun. Yuk, diisi dulu yang benar! ✨";
      }

      // 1. Simpan Data ke Supabase
      await Supabase.instance.client.from('pertumbuhan').insert({
        'anak_id': widget.anakId,
        'tanggal_pengukuran': _selectedDate.toIso8601String(),
        'berat_badan': berat,
        'tinggi_badan': tinggi,
        'lingkar_kepala': lingkar,
      });

      // 2. Langsung pancing AI agar hasil prediksi terupdate
      bool suksesAI = await _triggerPrediksiHuggingFace();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(suksesAI 
              ? 'Yey! Data & Prediksi berhasil disimpan, Bun! 🎉' 
              : 'Data tersimpan! Menunggu AI memperbarui prediksi... 😊'), 
            backgroundColor: suksesAI ? Colors.green : Colors.orange
          ),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: minusBtnColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI LAYOUT ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPink,
      body: Column(
        children: [
          // Header Latar Navy
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, 
              left: 20, right: 20, bottom: 30
            ),
            decoration: BoxDecoration(
              color: navyDark,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("Kembali", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text("Catat Tumbuh Kembang", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Isi data pengukuran bulan ini ya, Bun!", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  // --- TANGGAL ---
                  GestureDetector(
                    onTap: () => _pilihTanggal(context), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month, color: dateIconPink, size: 34),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tanggal Pengukuran", style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
                            Text(_formatTanggal(_selectedDate), style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(width: 25),
                        Icon(Icons.keyboard_arrow_down, color: arrowBlue, size: 28),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- KARTU PENGUKURAN ---
                  _buildMeasurementCard(
                    title: "Berat Badan", subtitle: "Dalam Kilogram", icon: Icons.monitor_weight_outlined,
                    controller: _beratController, unit: "Kg",
                    onMinus: () => _ubahNilai(_beratController, -0.1), onPlus: () => _ubahNilai(_beratController, 0.1),
                  ),
                  const SizedBox(height: 15),
                  _buildMeasurementCard(
                    title: "Tinggi Badan", subtitle: "Dalam Centimeter", icon: Icons.straighten,
                    controller: _tinggiController, unit: "Cm",
                    onMinus: () => _ubahNilai(_tinggiController, -1.0), onPlus: () => _ubahNilai(_tinggiController, 1.0),
                  ),
                  const SizedBox(height: 15),
                  _buildMeasurementCard(
                    title: "Lingkar Kepala", subtitle: "Dalam Centimeter", icon: Icons.face_retouching_natural,
                    controller: _lingkarController, unit: "Cm",
                    onMinus: () => _ubahNilai(_lingkarController, -0.5), onPlus: () => _ubahNilai(_lingkarController, 0.5),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // --- TOMBOL SIMPAN ---
                  SizedBox(
                    width: 220, 
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: saveBtnColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _isLoading ? null : _simpanData,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Simpan Data", style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard({
    required String title, required String subtitle, required IconData icon, required TextEditingController controller,
    required String unit, required VoidCallback onMinus, required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2), 
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: dateIconPink, size: 26),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle), color: minusBtnColor, iconSize: 45),
              const Spacer(),
              Column(
                children: [
                  SizedBox(
                    width: 100, 
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: navyDark, fontSize: 36, fontWeight: FontWeight.w900), 
                      decoration: const InputDecoration(border: InputBorder.none),
                      onTap: () {
                        if (controller.text == "0.0") controller.clear();
                      },
                    ),
                  ),
                  Text(unit, style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle), color: plusBtnColor, iconSize: 45),
            ],
          ),
        ],
      ),
    );
  }
}