import 'package:flutter/material.dart';
import 'package:kawantumbuh/screens/grafik_lengkap_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_identitas_anak_screen.dart';
import 'catat_pertumbuhan_screen.dart';
import 'daftar_anak_screen.dart';
import 'dart:math';

class AnakScreen extends StatefulWidget {
  const AnakScreen({super.key});

  @override
  State<AnakScreen> createState() => _AnakScreenState();
}

class _AnakScreenState extends State<AnakScreen> {
  // Color Palette
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA); 
  final Color fieldPink = const Color(0xFFF5CBCB); 
  final Color highlightPink = const Color(0xFFEBA9A9); 
  final Color successGreen = const Color(0xFF4CAF50); 
  final Color brightPink = Colors.pinkAccent;

  bool isBeratBadan = true;
  int selectedIndex = 0;
  bool _isLoading = true;
  int? _touchedIndex; 
  
  List<Map<String, dynamic>> _daftarAnak = [];
  List<Map<String, dynamic>> _riwayatPertumbuhan = [];
  Map<String, dynamic>? _prediksiTerbaru; 

  @override
  void initState() {
    super.initState();
    _fetchDataAnak();
  }

  String _formatTanggal(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime date = DateTime.parse(dateStr);
      List<String> bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return "${date.day} ${bulan[date.month]} ${date.year}";
    } catch (e) {
      return dateStr; 
    }
  }

  Future<void> _fetchDataAnak() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final dataAnak = await Supabase.instance.client
          .from('anak')
          .select()
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _daftarAnak = List<Map<String, dynamic>>.from(dataAnak);
        });

        if (_daftarAnak.isNotEmpty) {
          if (selectedIndex >= _daftarAnak.length) selectedIndex = 0;
          await _fetchRiwayat(selectedIndex);
        } else {
            setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Error fetch anak: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRiwayat(int index) async {
    try {
      final childId = _daftarAnak[index]['id'];

      final dataRiwayat = await Supabase.instance.client
          .from('pertumbuhan')
          .select()
          .eq('anak_id', childId)
          .order('tanggal_pengukuran', ascending: false);

      String metrikYangDicari = isBeratBadan ? 'berat_badan' : 'tinggi_badan';

      final dataPrediksi = await Supabase.instance.client
          .from('prediksi_pertumbuhan')
          .select()
          .eq('anak_id', childId)
          .eq('metrik', metrikYangDicari) 
          .order('tanggal_prediksi', ascending: false)
          .limit(1);

      if (mounted) {
        setState(() {
          _riwayatPertumbuhan = List<Map<String, dynamic>>.from(dataRiwayat);
          _prediksiTerbaru = dataPrediksi.isNotEmpty ? dataPrediksi[0] : null;
          _touchedIndex = null; 
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetch riwayat: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<double> _getChartData() {
    if (_riwayatPertumbuhan.isEmpty) return [];
    
    var recentData = _riwayatPertumbuhan.take(60).toList();
    recentData = recentData.reversed.toList(); 

    return recentData.map((e) {
      var val = isBeratBadan ? e['berat_badan'] : e['tinggi_badan'];
      return double.tryParse(val.toString()) ?? 0.0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: softPink, body: Center(child: CircularProgressIndicator(color: navyDark)));
    }
    
    if (_daftarAnak.isEmpty || selectedIndex >= _daftarAnak.length) {
      return Scaffold(backgroundColor: softPink, body: _buildEmptyState());
    }

    final currentChild = _daftarAnak[selectedIndex];

    return Scaffold(
      backgroundColor: softPink,
      body: RefreshIndicator(
        onRefresh: _fetchDataAnak,
        color: navyDark, backgroundColor: softPink,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(currentChild),
              const SizedBox(height: 25),
              _buildToggleSection(),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildDynamicChartCard(),
                    const SizedBox(height: 20),
                    _buildStatusPertumbuhan(currentChild['nama'] ?? "Si Kecil"),
                    const SizedBox(height: 20),
                    _buildPrediksiGizi(),
                    const SizedBox(height: 30),
                    _buildRiwayatHeader(context, currentChild['id'].toString()),
                    const SizedBox(height: 15),
                    _buildRiwayatList(), 
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPertumbuhan(String name) {
    String rawStatus = _prediksiTerbaru?['status_gizi'] ?? "";
    
    bool isInvalid = rawStatus.isEmpty || 
                     rawStatus.toLowerCase().contains("gagal") || 
                     rawStatus.toLowerCase().contains("luar jangkauan");

    String judul = "💡 Hasil Analisis & Prediksi AI";
    String pesan = "";
    Color boxColor = fieldPink;
    IconData iconData = Icons.analytics_outlined;

    if (isInvalid) {
      pesan = "Data belum cukup untuk prediksi AI (Minimal 3 data). Yuk, rutin catat pertumbuhan $name setiap bulan!";
      boxColor = Colors.orangeAccent.withOpacity(0.3);
    } else {
      String statusLower = rawStatus.toLowerCase();
      
      pesan = "Berdasarkan tren grafik $name, AI memprediksi status gizinya bulan depan berpotensi mengarah ke: *$rawStatus*.\n\n";

      if (statusLower.contains("normal") || statusLower.contains("baik")) {
        boxColor = successGreen.withOpacity(0.6);
        iconData = Icons.check_circle_outline;
        pesan += "Saran untuk Bunda:\nWah, hebat Bun! Pertumbuhan $name sangat baik. Terus pertahankan asupan bergizi seimbangnya dan rutin ke Posyandu ya!";
      } else if (statusLower.contains("risiko") || statusLower.contains("lebih") || statusLower.contains("tinggi")) {
        boxColor = Colors.orangeAccent.withOpacity(0.7);
        iconData = Icons.warning_amber_rounded;
        pesan += "Saran untuk Bunda:\nJangan panik Bun, ini baru prediksi awal. Coba mulai kontrol porsi asupannya dan hindari camilan/minuman manis berlebih. Ajak si kecil lebih banyak beraktivitas fisik (seperti merangkak atau bermain aktif). Konsultasikan ke bidan/dokter jika perlu.";
      } else if (statusLower.contains("kurang") || statusLower.contains("buruk") || statusLower.contains("pendek")) {
        boxColor = Colors.redAccent.withOpacity(0.7);
        iconData = Icons.error_outline;
        pesan += "Saran untuk Bunda:\nBunda, yuk kita kejar pertumbuhannya! Tambahkan porsi Protein Hewani (seperti telur, ikan, daging, atau hati ayam) dan lemak tambahan (minyak/mentega/santan) di menu hariannya, pastikan di luar makanan yang bikin alergi ya. Jangan ragu untuk segera konsultasi ke Puskesmas/Dokter Anak.";
      } else {
        boxColor = fieldPink;
        pesan += "Saran untuk Bunda:\nTetap pantau kurva pertumbuhannya dengan teliti dan konsultasikan dengan tenaga kesehatan di Posyandu/Klinik terdekat.";
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(iconData, color: navyDark, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(judul, style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ]),
          const SizedBox(height: 12),
          Text(pesan, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPrediksiGizi() {
    String status = _prediksiTerbaru?['status_gizi'] ?? "Menunggu Data";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: fieldPink, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart, color: brightPink, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Prediksi Status Gizi", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Berdasarkan perhitungan Z-Score AI", style: TextStyle(color: navyDark.withOpacity(0.5), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: softPink, borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status Gizi:", style: TextStyle(fontWeight: FontWeight.bold, color: navyDark)),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: navyDark, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      status.toUpperCase(), 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: softPink, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Kesehatan Anak", style: TextStyle(color: softPink, fontSize: 26, fontWeight: FontWeight.bold)),
          Text("Pantau tumbuh kembang si kecil", style: TextStyle(color: softPink.withOpacity(0.8), fontSize: 14)),
          if (_daftarAnak.length > 1) ...[
            const SizedBox(height: 20),
            _buildChildSelector(),
          ],
          const SizedBox(height: 25),
          _buildMainCard(child),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: softPink.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: softPink.withOpacity(0.3), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedIndex,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: softPink, size: 28),
          dropdownColor: navyDark, 
          style: TextStyle(color: softPink, fontSize: 16, fontWeight: FontWeight.bold),
          items: List.generate(_daftarAnak.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(
                _daftarAnak[index]['nama'] ?? "Anak",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }),
          onChanged: (int? newValue) {
            if (newValue != null && newValue != selectedIndex) {
              setState(() { 
                selectedIndex = newValue; 
                _isLoading = true; 
              });
              _fetchRiwayat(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainCard(Map<String, dynamic> child) {
    final String tanggalLahir = _formatTanggal(child['tanggal_lahir']);
    final int bulanUmur = _hitungUmurBulan(child['tanggal_lahir']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: softPink.withOpacity(0.50), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: highlightPink, shape: BoxShape.circle),
                  child: Icon(Icons.face_retouching_natural, color: softPink, size: 35)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child['nama'] ?? "Tanpa Nama", style: TextStyle(color: softPink, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${child['jenis_kelamin'] ?? '-'}, $tanggalLahir", style: TextStyle(color: softPink.withOpacity(0.7), fontSize: 15)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditDataAnakScreen(dataAnak: child))),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: highlightPink, shape: BoxShape.circle),
                  child: Icon(Icons.edit, color: softPink, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Divider(color: softPink.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProfileStat("Usia", "$bulanUmur Bulan"),
              _buildProfileStat("Berat", _riwayatPertumbuhan.isNotEmpty ? "${_riwayatPertumbuhan[0]['berat_badan']} Kg" : "--"),
              _buildProfileStat("Tinggi", _riwayatPertumbuhan.isNotEmpty ? "${_riwayatPertumbuhan[0]['tinggi_badan']} cm" : "--"),
            ],
          ),
        ],
      ),
    );
  }

  int _hitungUmurBulan(String? tglLahir) {
    if (tglLahir == null) return 0;
    try {
      DateTime birthDate = DateTime.parse(tglLahir);
      DateTime today = DateTime.now();
      int months = (today.year - birthDate.year) * 12 + today.month - birthDate.month;
      return months < 0 ? 0 : months;
    } catch(e){ return 0; }
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: softPink, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: softPink, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildToggleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton("Berat Badan", isBeratBadan)),
          const SizedBox(width: 15),
          Expanded(child: _buildToggleButton("Tinggi Badan", !isBeratBadan)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() { 
          isBeratBadan = (title == "Berat Badan"); 
          _isLoading = true; 
        });
        _fetchRiwayat(selectedIndex); 
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: isActive ? navyDark : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: navyDark, width: 1.5)),
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(color: isActive ? softPink : navyDark, fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDynamicChartCard() {
    List<double> chartData = _getChartData();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: navyDark.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isBeratBadan ? "Kurva Berat Badan" : "Kurva Tinggi Badan", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Text("Standar Pertumbuhan Kemenkes (KIA)", style: TextStyle(color: navyDark.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 14, color: navyDark.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                "Sumbu Y : ${isBeratBadan ? 'Nilai Berat (Kg)' : 'Nilai Tinggi (cm)'}", 
                style: TextStyle(color: navyDark, fontSize: 12, fontWeight: FontWeight.w700)
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanDown: (details) => _handleTouch(details.localPosition.dx, constraints.maxWidth, chartData.length),
                onTapDown: (details) => _handleTouch(details.localPosition.dx, constraints.maxWidth, chartData.length),
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: navyDark.withOpacity(0.5), width: 2.5), 
                      bottom: BorderSide(color: navyDark.withOpacity(0.5), width: 2.5), 
                    )
                  ),
                  height: 200,
                  width: double.infinity,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: DynamicChartPainter(navyDark, chartData, isBeratBadan, _touchedIndex),
                  ),
                ),
              );
            }
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Sumbu X : Waktu (Kiri Lama ➔ Kanan Baru)", 
                style: TextStyle(color: navyDark, fontSize: 12, fontWeight: FontWeight.w700)
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward, size: 14, color: navyDark.withOpacity(0.8)),
            ],
          ),

          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 15),
          
          Text("Panduan Warna Grafik:", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 10, 
            runSpacing: 10, 
            children: [
              SizedBox(width: 140, child: _buildLegendItem(const Color(0xFF4CAF50), "Hijau: Normal")),
              SizedBox(width: 140, child: _buildLegendItem(const Color(0xFFFFEB3B), "Kuning: Waspada")),
              SizedBox(width: 140, child: _buildLegendItem(const Color(0xFFF44336), "Merah: Konsultasi")),
              SizedBox(width: 140, child: _buildLegendItem(navyDark, "Titik: Data Anak")),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // --- TOMBOL MENUJU HALAMAN GRAFIK LENGKAP ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final currentChild = _daftarAnak[selectedIndex]; // Ambil data anak aktif

                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => GrafikLengkapScreen(
                      riwayatData: _riwayatPertumbuhan,
                      isBeratBadan: isBeratBadan,
                      namaAnak: currentChild['nama'] ?? "Si Kecil",
                      tanggalLahir: currentChild['tanggal_lahir'] ?? "",
                      jenisKelamin: currentChild['jenis_kelamin'] ?? "Laki-laki",
                    )
                  )
                );
              },
              icon: Icon(Icons.insights, color: softPink),
              label: Text(
                "Lihat Detail Grafik Lengkap", 
                style: TextStyle(color: softPink, fontWeight: FontWeight.bold)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: navyDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTouch(double dx, double maxWidth, int dataLength) {
    if (dataLength <= 0) return;
    double xStep = dataLength > 1 ? maxWidth / (dataLength - 1) : maxWidth / 2;
    int index = (dx / xStep).round();
    
    if (index >= 0 && index < dataLength) {
      setState(() {
        _touchedIndex = index;
      });
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14, height: 14, 
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 0.5))
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: navyDark, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRiwayatHeader(BuildContext context, String anakId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Riwayat Pengukuran", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CatatPertumbuhanScreen(anakId: anakId))
            );
            if (result == true) _fetchDataAnak(); 
          },
          icon: Icon(Icons.add, size: 16, color: softPink),
          label: Text("Catat", style: TextStyle(color: softPink, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: navyDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        ),
      ],
    );
  }

  Widget _buildRiwayatList() {
    if (_riwayatPertumbuhan.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("Belum ada riwayat pengukuran.", style: TextStyle(color: navyDark))));
    
    return Column(
      children: _riwayatPertumbuhan.map((r) => _buildRiwayatCard(
        _formatTanggal(r['tanggal_pengukuran']?.toString()), 
        "${r['berat_badan']} kg", 
        "${r['tinggi_badan']} cm"
      )).toList(),
    );
  }

  Widget _buildRiwayatCard(String date, String bb, String tb) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: fieldPink, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(date, style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 6),
            Row(children: [
              Text("BB: $bb", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
              const SizedBox(width: 15),
              Text("TB: $tb", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
            ])
          ]),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_friendly, size: 80, color: navyDark.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text("Belum Ada Data Anak", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarAnakScreen())),
            child: const Text("Tambah Data"),
          )
        ],
      ),
    );
  }
}

class DynamicChartPainter extends CustomPainter {
  final Color lineColor;
  final List<double> dataPoints;
  final bool isBerat;
  final int? touchedIndex; 

  DynamicChartPainter(this.lineColor, this.dataPoints, this.isBerat, this.touchedIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    _drawCurvedZone(canvas, size, const Color(0xFFFFEB3B).withOpacity(0.2), 0.1, 0.3); 
    _drawCurvedZone(canvas, size, const Color(0xFF4CAF50).withOpacity(0.3), 0.3, 0.7); 
    _drawCurvedZone(canvas, size, const Color(0xFFFFEB3B).withOpacity(0.2), 0.7, 0.85); 
    _drawCurvedZone(canvas, size, const Color(0xFFF44336).withOpacity(0.2), 0.85, 1.0); 

    if (dataPoints.isEmpty) return;

    double maxVal = dataPoints.reduce(max) + (isBerat ? 4 : 15);
    double minVal = (dataPoints.reduce(min) - (isBerat ? 4 : 15)).clamp(0, double.infinity);

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = lineColor..style = PaintingStyle.fill;
    final dotOutline = Paint()..color = Colors.white..style = PaintingStyle.fill;

    final path = Path();
    double xStep = dataPoints.length > 1 ? w / (dataPoints.length - 1) : w / 2;

    List<Offset> pointOffsets = [];

    for (int i = 0; i < dataPoints.length; i++) {
      double x = dataPoints.length > 1 ? i * xStep : w / 2;
      double normalizedY = (dataPoints[i] - minVal) / (maxVal - minVal);
      double y = h - (normalizedY * h);

      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      
      pointOffsets.add(Offset(x, y));
      
      canvas.drawCircle(Offset(x, y), 6, dotOutline);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    canvas.drawPath(path, paintLine);

    if (touchedIndex != null && touchedIndex! >= 0 && touchedIndex! < dataPoints.length) {
      final x = pointOffsets[touchedIndex!].dx;
      final y = pointOffsets[touchedIndex!].dy;
      final val = dataPoints[touchedIndex!];
      
      final textSpan = TextSpan(
        text: "$val ${isBerat ? 'kg' : 'cm'}",
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();

      final rectWidth = textPainter.width + 16;
      final rectHeight = textPainter.height + 10;
      double rectX = x - (rectWidth / 2);
      if (rectX < 0) rectX = 0;
      if (rectX + rectWidth > w) rectX = w - rectWidth;
      
      final rect = Rect.fromLTWH(rectX, y - rectHeight - 10, rectWidth, rectHeight);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()..color = lineColor,
      );
      
      textPainter.paint(canvas, Offset(rectX + 8, y - rectHeight - 5));
      
      canvas.drawCircle(Offset(x, y), 8, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3);
    }
  }

  void _drawCurvedZone(Canvas canvas, Size size, Color color, double top, double bottom) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * bottom);
    path.quadraticBezierTo(size.width * 0.5, size.height * (bottom - 0.1), size.width, size.height * (bottom - 0.2));
    path.lineTo(size.width, size.height * (top - 0.2));
    path.quadraticBezierTo(size.width * 0.5, size.height * (top - 0.1), 0, size.height * top);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DynamicChartPainter oldDelegate) {
    return oldDelegate.touchedIndex != touchedIndex || oldDelegate.dataPoints != dataPoints;
  }
}