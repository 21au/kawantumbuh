import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatatPertumbuhanScreen extends StatefulWidget {
  final String anakId; // WAJIB ADA: Untuk tahu ini data anak yang mana

  const CatatPertumbuhanScreen({super.key, required this.anakId});

  @override
  State<CatatPertumbuhanScreen> createState() => _CatatPertumbuhanScreenState();
}

class _CatatPertumbuhanScreenState extends State<CatatPertumbuhanScreen> {
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA); 
  final Color highlightPink = const Color(0xFFD6B5B5); 
  final Color whiteCard = Colors.white; 

  late TextEditingController _beratController;
  late TextEditingController _tinggiController;
  late TextEditingController _lingkarController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

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
            dialogBackgroundColor: softPink,
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
    List<String> bulan = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  void _ubahNilai(TextEditingController controller, double amount) {
    double currentVal = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;
    double newVal = currentVal + amount;
    if (newVal < 0) newVal = 0; 
    setState(() {
      controller.text = newVal.toStringAsFixed(1);
    });
  }

  // --- FUNGSI SIMPAN KE SUPABASE ---
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
        Navigator.pop(context, true); // Kembali dan beri sinyal untuk refresh
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
      backgroundColor: softPink,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, 
              left: 20, right: 20, bottom: 30
            ),
            decoration: BoxDecoration(
              color: navyDark,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
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
                const SizedBox(height: 20),
                const Text("Catat Tumbuh Kembang", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Isi data pengukuran bulan ini ya, Bun!", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pilihTanggal(context), 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: whiteCard,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: navyDark.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month, color: navyDark, size: 28),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tanggal Pengukuran", style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(_formatTanggal(_selectedDate), style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: navyDark.withOpacity(0.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildMeasurementCard(
                    title: "Berat Badan", subtitle: "Dalam Kilogram", icon: Icons.monitor_weight_outlined,
                    controller: _beratController, unit: "Kg",
                    onMinus: () => _ubahNilai(_beratController, -0.1), onPlus: () => _ubahNilai(_beratController, 0.1),
                  ),
                  const SizedBox(height: 15),
                  _buildMeasurementCard(
                    title: "Tinggi Badan", subtitle: "Dalam Sentimeter", icon: Icons.height,
                    controller: _tinggiController, unit: "cm",
                    onMinus: () => _ubahNilai(_tinggiController, -1.0), onPlus: () => _ubahNilai(_tinggiController, 1.0),
                  ),
                  const SizedBox(height: 15),
                  _buildMeasurementCard(
                    title: "Lingkar Kepala", subtitle: "Dalam Sentimeter", icon: Icons.face_retouching_natural,
                    controller: _lingkarController, unit: "cm",
                    onMinus: () => _ubahNilai(_lingkarController, -0.5), onPlus: () => _ubahNilai(_lingkarController, 0.5),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navyDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _isLoading ? null : _simpanData,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Simpan Data", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteCard, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: navyDark.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: softPink, shape: BoxShape.circle),
                child: Icon(icon, color: navyDark, size: 22),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: onMinus, borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(color: highlightPink.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.remove, color: navyDark),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  SizedBox(
                    width: 80, 
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: navyDark, fontSize: 32, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  Text(unit, style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: onPlus, borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(color: navyDark, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}