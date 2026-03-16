import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatatPertumbuhanScreen extends StatefulWidget {
  final String anakId;

  const CatatPertumbuhanScreen({super.key, required this.anakId});

  @override
  State<CatatPertumbuhanScreen> createState() => _CatatPertumbuhanScreenState();
}

class _CatatPertumbuhanScreenState extends State<CatatPertumbuhanScreen> {
  // --- WARNA DIAMBIL PERSIS DARI GAMBAR DESAIN ---
  final Color navyDark = const Color(0xFF102C57);
  final Color backgroundPink = const Color(0xFFFAEEEE); // Background utama blush pink
  final Color cardBackground = const Color(0xFFFFF3F3); // Background card (putih pinkish)
  final Color cardBorder = const Color(0xFFF2D6D6); // Garis pinggir card
  final Color minusBtnColor = const Color(0xFFE5A4A4); // Merah muda pastel/salmon
  final Color plusBtnColor = const Color(0xFF1E7FB8); // Biru ocean
  final Color saveBtnColor = const Color(0xFFA6E5A3); // Hijau pastel
  final Color dateIconPink = const Color(0xFFEA9494); // Pink untuk icon kalender
  final Color arrowBlue = const Color(0xFF4CA0D9); // Biru untuk icon panah bawah

  late TextEditingController _beratController;
  late TextEditingController _tinggiController;
  late TextEditingController _lingkarController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _beratController = TextEditingController(text: "40.0");
    _tinggiController = TextEditingController(text: "60.0");
    _lingkarController = TextEditingController(text: "45.0");
  }

  @override
  void dispose() {
    _beratController.dispose();
    _tinggiController.dispose();
    _lingkarController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyDark, 
              onPrimary: Colors.white, 
              onSurface: navyDark, 
            ),
            dialogBackgroundColor: backgroundPink,
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

  Future<void> _simpanData() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('pertumbuhan').insert({
        'anak_id': widget.anakId,
        'tanggal_pengukuran': _selectedDate.toIso8601String(),
        'berat_badan': double.tryParse(_beratController.text.replaceAll(',', '.')) ?? 0,
        'tinggi_badan': double.tryParse(_tinggiController.text.replaceAll(',', '.')) ?? 0,
        'lingkar_kepala': double.tryParse(_lingkarController.text.replaceAll(',', '.')) ?? 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                      Text("Kembali", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text("Catat Tumbuh Kembang", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Isi data pengukuran bulan ini ya, Bun!", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  // --- TANGGAL TANPA KOTAK (PERSIS DESAIN) ---
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
                            const SizedBox(height: 2),
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
                  
                  // --- TOMBOL SIMPAN DATA (HIJAU PASTEL) ---
                  SizedBox(
                    width: 220, 
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: saveBtnColor,
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _isLoading ? null : _simpanData,
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Simpan Data", style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: cardBackground, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2), // Garis pinggir tipis persis desain
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Circle Background Putih
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))]
                ),
                child: Icon(icon, color: dateIconPink, size: 26),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Minus (Salmon Pink)
              InkWell(
                onTap: onMinus, borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(color: minusBtnColor, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.remove, color: Colors.white, size: 32),
                ),
              ),
              
              const Spacer(),
              
              // Angka dan Satuan ditumpuk
              Column(
                children: [
                  SizedBox(
                    width: 100, 
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: navyDark, fontSize: 36, fontWeight: FontWeight.w900), // Angka dibuat tebal dan besar
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  Text(unit, style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              
              const Spacer(),
              
              // Tombol Plus (Biru Ocean)
              InkWell(
                onTap: onPlus, borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(color: plusBtnColor, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}