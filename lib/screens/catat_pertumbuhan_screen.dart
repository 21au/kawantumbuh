import 'package:flutter/material.dart';

class CatatPertumbuhanScreen extends StatefulWidget {
  const CatatPertumbuhanScreen({super.key});

  @override
  State<CatatPertumbuhanScreen> createState() => _CatatPertumbuhanScreenState();
}

class _CatatPertumbuhanScreenState extends State<CatatPertumbuhanScreen> {
  // Warna khusus halaman ini
  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color pinkCard = const Color(0xFFFFD6D9);
  final Color greyDateCard = const Color(0xFF867E96);
  final Color offWhitePink = const Color(0xFFFCE8E9); 

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
      firstDate: DateTime(2020), // Batas tahun termuda
      lastDate: DateTime(2030), // Batas tahun tertua
      builder: (context, child) {
        // Mengubah warna tema kalender agar sesuai desain aplikasi
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyBackground, 
              onPrimary: offWhitePink, 
              onSurface: navyBackground, 
            ),
            dialogBackgroundColor: offWhitePink,
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
      backgroundColor: navyBackground,
      body: Column(
        children: [
          // 1. HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
            decoration: BoxDecoration(
              color: pinkCard,
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
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: navyBackground, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Kembali",
                        style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Catat Tumbuh Kembang",
                  style: TextStyle(color: navyBackground, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Isi data pengukuran bulan ini ya, Bun!",
                  style: TextStyle(color: navyBackground.withOpacity(0.8), fontSize: 16),
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
                    onTap: () => _pilihTanggal(context), // Panggil kalender saat ditekan
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: greyDateCard,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Color(0xFFFFA8B6), size: 30),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tanggal Pengukuran",
                                  style: TextStyle(color: offWhitePink.withOpacity(0.8), fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTanggal(_selectedDate), // Tampilkan tanggal yang dipilih
                                  style: const TextStyle(color: Color(0xFFFFA8B6), fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          // Ikon panah sebagai petunjuk bisa diedit
                          Icon(Icons.keyboard_arrow_down, color: offWhitePink.withOpacity(0.8)),
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
                        backgroundColor: pinkCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        // Tampilkan nilai asli yang diinput ke console (sebagai bukti untuk backend nanti)
                        print("Tanggal: ${_selectedDate.toIso8601String()}");
                        print("Berat: ${_beratController.text}");
                        print("Tinggi: ${_tinggiController.text}");
                        print("Lingkar Kepala: ${_lingkarController.text}");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Data berhasil disimpan!',
                              style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: pinkCard,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Simpan Data",
                        style: TextStyle(color: navyBackground, fontSize: 18, fontWeight: FontWeight.bold),
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
        color: pinkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: navyBackground, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: pinkCard, size: 24),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: navyBackground, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: navyBackground.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Minus
              InkWell(
                onTap: onMinus,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: navyBackground, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.remove, color: offWhitePink),
                ),
              ),
              const SizedBox(width: 20),
              
              // Nilai Angka (Sekarang berupa TextField yang bisa diketik)
              Column(
                children: [
                  SizedBox(
                    width: 70, // Lebar area ketik
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: navyBackground, fontSize: 32, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none, // Hilangkan garis bawah default TextField
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(color: navyBackground, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              
              // Tombol Plus
              InkWell(
                onTap: onPlus,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: navyBackground, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.add, color: offWhitePink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}