import 'package:flutter/material.dart';

class CatatPertumbuhanScreen extends StatefulWidget {
  const CatatPertumbuhanScreen({super.key});

  @override
  State<CatatPertumbuhanScreen> createState() => _CatatPertumbuhanScreenState();
}

class _CatatPertumbuhanScreenState extends State<CatatPertumbuhanScreen> {
  // --- PALET WARNA SERAGAM ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA); 
  final Color highlightPink = const Color(0xFFD6B5B5); 
  final Color whiteCard = Colors.white; 

  // Controller untuk input ketik manual
  late TextEditingController _beratController;
  late TextEditingController _tinggiController;
  late TextEditingController _lingkarController;

  // Variabel Tanggal (Default hari ini)
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Mengisi nilai awal ke dalam kolom teks
    _beratController = TextEditingController(text: "10.4");
    _tinggiController = TextEditingController(text: "80.0");
    _lingkarController = TextEditingController(text: "45.0");
  }

  @override
  void dispose() {
    // Membersihkan memori saat halaman ditutup
    _beratController.dispose();
    _tinggiController.dispose();
    _lingkarController.dispose();
    super.dispose();
  }

  // Fungsi memunculkan pop-up Kalender
  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030), 
      builder: (context, child) {
        // Mengubah warna tema kalender agar sesuai desain aplikasi
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi merapikan format tanggal agar tampil "13 Februari 2026"
  String _formatTanggal(DateTime date) {
    List<String> bulan = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  // Fungsi untuk tombol plus minus yang terhubung dengan controller text
  void _ubahNilai(TextEditingController controller, double amount) {
    // Ambil angka dari teks (ganti koma jadi titik jika user pakai keyboard indo)
    double currentVal = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;
    double newVal = currentVal + amount;
    if (newVal < 0) newVal = 0; // Cegah angka minus
    
    setState(() {
      controller.text = newVal.toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink, // Background utama jadi pink terang
      body: Column(
        children: [
          // 1. HEADER (Disamakan dengan EditDataAnakScreen -> Navy)
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
                      Text(
                        "Kembali",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Catat Tumbuh Kembang",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Isi data pengukuran bulan ini ya, Bun!",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),

          // 2. KONTEN UTAMA
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Kartu Tanggal Pengukuran (Bisa Diklik)
                  GestureDetector(
                    onTap: () => _pilihTanggal(context), 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: whiteCard,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: navyDark.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month, color: navyDark, size: 28),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tanggal Pengukuran",
                                  style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTanggal(_selectedDate), 
                                  style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: navyDark.withOpacity(0.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Kartu Berat Badan
                  _buildMeasurementCard(
                    title: "Berat Badan",
                    subtitle: "Dalam Kilogram",
                    icon: Icons.monitor_weight_outlined,
                    controller: _beratController,
                    unit: "Kg",
                    onMinus: () => _ubahNilai(_beratController, -0.1),
                    onPlus: () => _ubahNilai(_beratController, 0.1),
                  ),
                  const SizedBox(height: 15),

                  // Kartu Tinggi Badan
                  _buildMeasurementCard(
                    title: "Tinggi Badan",
                    subtitle: "Dalam Sentimeter",
                    icon: Icons.height,
                    controller: _tinggiController,
                    unit: "cm",
                    onMinus: () => _ubahNilai(_tinggiController, -1.0),
                    onPlus: () => _ubahNilai(_tinggiController, 1.0),
                  ),
                  const SizedBox(height: 15),

                  // Kartu Lingkar Kepala
                  _buildMeasurementCard(
                    title: "Lingkar Kepala",
                    subtitle: "Dalam Sentimeter",
                    icon: Icons.face_retouching_natural,
                    controller: _lingkarController,
                    unit: "cm",
                    onMinus: () => _ubahNilai(_lingkarController, -0.5),
                    onPlus: () => _ubahNilai(_lingkarController, 0.5),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navyDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: navyDark.withOpacity(0.3),
                      ),
                      onPressed: () {
                        // Tampilkan nilai asli yang diinput ke console (sebagai bukti untuk backend nanti)
                        print("Tanggal: ${_selectedDate.toIso8601String()}");
                        print("Berat: ${_beratController.text}");
                        print("Tinggi: ${_tinggiController.text}");
                        print("Lingkar Kepala: ${_lingkarController.text}");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Data berhasil disimpan!',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Simpan Data",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

  // --- WIDGET BANTUAN UNTUK KARTU PENGUKURAN ---
  Widget _buildMeasurementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required TextEditingController controller,
    required String unit,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: navyDark.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
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
                  Text(
                    title,
                    style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Minus
              InkWell(
                onTap: onMinus,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: highlightPink.withOpacity(0.3), 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(Icons.remove, color: navyDark),
                ),
              ),
              const SizedBox(width: 20),
              
              // Nilai Angka (TextField yang bisa diketik)
              Column(
                children: [
                  SizedBox(
                    width: 80, 
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: navyDark, fontSize: 32, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none, 
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              
              // Tombol Plus
              InkWell(
                onTap: onPlus,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: navyDark, 
                    borderRadius: BorderRadius.circular(12)
                  ),
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