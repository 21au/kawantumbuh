import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class StatistikPertumbuhanScreen extends StatefulWidget {
  final String anakId;
  final String namaAnak;
  final String jenisKelamin; 
  final String statusGizi;

  const StatistikPertumbuhanScreen({
    super.key, 
    required this.anakId, 
    required this.namaAnak,
    required this.jenisKelamin, 
    required this.statusGizi,
  });

  @override
  State<StatistikPertumbuhanScreen> createState() => _StatistikPertumbuhanScreenState();
}

class _StatistikPertumbuhanScreenState extends State<StatistikPertumbuhanScreen> {
  // --- PALET WARNA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA);
  final Color fieldPink = const Color(0xFFF5CBCB);
  final Color highlightPink = const Color(0xFFEBA9A9);
  final Color brightPink = Colors.pinkAccent;
  
  final Color safeGreen = const Color(0xFF81C784); 

  bool _isLoading = true;
  List<Map<String, dynamic>> _riwayat = [];
  List<Map<String, dynamic>> _listPrediksi = []; 
  
  String _kesimpulan = "";
  String _jenisKesimpulan = "Normal";

  String _infoKBM = ""; 
  bool _butuhKonsultasi = false; 
  String _statusGiziAktual = ""; 

  // [DITAMBAHKAN] Variabel untuk menampung pesan anomali / deteksi pintar
  String? _pesanAnomali;

  // Default nampilin 1 bulan sesuai standar medis
  int _jumlahBulanDipilih = 1; 

  @override
  void initState() {
    super.initState();
    _statusGiziAktual = widget.statusGizi; 
    _fetchRiwayatPertumbuhan();
  }

  Future<void> _fetchRiwayatPertumbuhan() async {
    try {
      final data = await Supabase.instance.client
          .from('pertumbuhan')
          .select()
          .eq('anak_id', widget.anakId)
          .order('tanggal_pengukuran', ascending: true);

      final dataPrediksi = await Supabase.instance.client
          .from('prediksi_pertumbuhan')
          .select()
          .eq('anak_id', widget.anakId)
          .order('tanggal_prediksi', ascending: true); 

      if (mounted) {
        setState(() {
          _riwayat = List<Map<String, dynamic>>.from(data);
          _listPrediksi = List<Map<String, dynamic>>.from(dataPrediksi);
          _tentukanKesimpulan();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error grafik: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI STANDAR KBM KEMENKES ---
  double _getTargetKBM(int usiaBulan) {
    if (usiaBulan <= 1) return 0.8; // 800 gram
    if (usiaBulan == 2) return 0.9; 
    if (usiaBulan == 3) return 0.8;
    if (usiaBulan == 4) return 0.6;
    if (usiaBulan == 5) return 0.5;
    if (usiaBulan == 6) return 0.4;
    if (usiaBulan >= 7 && usiaBulan <= 10) return 0.3;
    if (usiaBulan >= 11 && usiaBulan <= 24) return 0.2;
    return 0.2; // Default untuk di atas 2 tahun (rata-rata)
  }

  void _tentukanKesimpulan() {
    _pesanAnomali = null; // Reset pesan anomali setiap kali refresh

    if (_riwayat.isEmpty) {
      _jenisKesimpulan = "Belum Ada Data";
      _kesimpulan = "Halo Bunda! Belum ada data ukuran nih. Yuk catat data pertama ${widget.namaAnak} supaya kita bisa pantau tumbuh kembangnya sama-sama! 💕";
      _infoKBM = "";
      _butuhKonsultasi = false;
      return;
    }

    double bbSekarang = (_riwayat.last['berat_badan'] ?? 0).toDouble();
    int usiaBulanSekarang = int.tryParse(_riwayat.last['usia_bulan']?.toString() ?? '12') ?? 12;

    // --- [DITAMBAHKAN] LOGIKA DETEKSI ANOMALI / MESIN PINTAR ---
    if (_riwayat.length >= 2) {
      double bbSebelumnya = (_riwayat[_riwayat.length - 2]['berat_badan'] ?? 0).toDouble();
      double selisihBB = bbSekarang - bbSebelumnya;
      double selisihAbs = selisihBB.abs();

      // 1. Cek kemungkinan salah ketik (Lonjakan ekstrem > 4 kg sebulan)
      if (selisihAbs >= 4.0) {
        String status = selisihBB > 0 ? "naik" : "turun";
        _pesanAnomali = "Wah Bun, berat badannya tiba-tiba $status drastis banget nih (${selisihAbs.toStringAsFixed(1)} kg). Coba pastikan tidak ada salah ketik angka ya saat mencatat tadi! ✨";
      } 
      // 2. Cek penurunan (Mungkin sakit atau nafsu makan turun)
      else if (selisihBB <= -0.5) {
        _pesanAnomali = "Bun, berat badan ${widget.namaAnak} turun ${selisihAbs.toStringAsFixed(1)} kg nih dibanding bulan lalu. Kalau si Kecil habis sakit atau kurang nafsu makan, yuk jangan ragu konsultasi ke Bidan atau Dokter Anak biar cepat pulih! 💖";
      } 
      // 3. Cek kenaikan terlalu ekstrem (Risiko overweight jika bukan typo)
      else if (selisihBB >= 2.0) {
        _pesanAnomali = "Wah, berat badannya naik cepat sekali bulan ini (naik ${selisihBB.toStringAsFixed(1)} kg), Bun! Pastikan tetap seimbang ya. Boleh banget didiskusikan ke Bidan atau Dokter biar pertumbuhannya tetap terpantau ideal! 🌟";
      }
    }
    // -------------------------------------------------------------

    List<Map<String, dynamic>> prediksiBBList = _listPrediksi
        .where((p) => p['metrik'] == 'berat_badan')
        .take(_jumlahBulanDipilih) 
        .toList();

    if (prediksiBBList.isNotEmpty) {
      _statusGiziAktual = prediksiBBList.first['status_gizi'] ?? widget.statusGizi;
      
      double prediksiBulanPertama = double.tryParse(prediksiBBList.first['nilai_prediksi'].toString()) ?? 0.0;
      double selisihPrediksi = prediksiBulanPertama - bbSekarang;
      
      double targetKBM = _getTargetKBM(usiaBulanSekarang + 1); 
      
      if (selisihPrediksi >= targetKBM) {
        _infoKBM = "Hebat! Prediksi kenaikan bulan depan (+${selisihPrediksi.toStringAsFixed(1)} kg) memenuhi target Kenaikan Berat Minimal (KBM) Kemenkes. 🎯";
      } else if (selisihPrediksi > 0) {
        _infoKBM = "Prediksi bulan depan naik (+${selisihPrediksi.toStringAsFixed(1)} kg), tapi belum mencapai target ideal KBM Kemenkes (+${targetKBM.toStringAsFixed(1)} kg). Yuk kejar lagi! 💪";
      } else {
        _infoKBM = "Awas Bunda, tren menunjukkan potensi penurunan berat atau stagnan. Mari tingkatkan asupan nutrisinya! ⚠️";
      }

      List<String> teksAngka = prediksiBBList.map((e) {
        double val = double.tryParse(e['nilai_prediksi'].toString()) ?? 0.0;
        return "${val.toStringAsFixed(1)}";
      }).toList();
      
      String deretPrediksi = "${bbSekarang.toStringAsFixed(1)} kg ➔ ${teksAngka.join(" kg ➔ ")}";
      
      _jenisKesimpulan = "Pantauan Gizi: $_statusGiziAktual";
      if (_statusGiziAktual.toLowerCase().contains('normal') || _statusGiziAktual.toLowerCase().contains('baik')) {
        _butuhKonsultasi = false; 
        _kesimpulan = "Berdasarkan standar Kemenkes, pertumbuhan ${widget.namaAnak} sangat baik lho, Bun! Berdasarkan pola saat ini, perkiraan berat hingga $_jumlahBulanDipilih bulan ke depan adalah $deretPrediksi kg. Pertahankan asupan nutrisi bergizinya ya! 💖";
      } else {
        _butuhKonsultasi = true; 
        _kesimpulan = "Dari catatan ini, sepertinya ada indikasi $_statusGiziAktual. Perkiraan berat $_jumlahBulanDipilih bulan ke depan sekitar $deretPrediksi kg. Jangan panik dulu ya Bun, mari pantau ekstra dan jadwalkan konsultasi dengan tenaga medis. Peluk hangat untuk Bunda! 🫂";
      }
      return; 
    }
    _infoKBM = "";
    _butuhKonsultasi = false;
    if (_riwayat.length == 1) {
      _jenisKesimpulan = "Awal yang Baik";
      _kesimpulan = "Wah, data pertama ${widget.namaAnak} sudah masuk! Terus pantau dan catat ya Bun tiap bulannya untuk melihat grafiknya. Bunda pasti bisa! 💖";
      return;
    }
    
    // Logika fallback jika tidak ada prediksi
    double bbSebelumnya = (_riwayat[_riwayat.length - 2]['berat_badan'] ?? 0).toDouble();
    double selisihBBSekarang = bbSekarang - bbSebelumnya;

    if (selisihBBSekarang < 0) {
      _jenisKesimpulan = "Berat Badan Turun";
      _kesimpulan = "Bulan ini grafik ${widget.namaAnak} sedikit menurun nih. Wajar kok Bun, anak kadang susah makan. Jangan terlalu stres ya. Coba tawarkan cemilan padat gizi pelan-pelan. 🫂";
    } else if (selisihBBSekarang >= 1.0) {
      _jenisKesimpulan = "Naik Signifikan";
      _kesimpulan = "Wah, bulan ini ${widget.namaAnak} melesat pertumbuhannya! Pastikan badannya tetap nyaman ya Bun. Semangat terus! 🚀";
    } else if (bbSekarang < 5.0) { 
      _jenisKesimpulan = "Perlu Perhatian Khusus";
      _kesimpulan = "Grafik ${widget.namaAnak} sedang sedikit di bawah garis. Jangan khawatir atau berkecil hati ya, Bun. Yuk, coba pelan-pelan tingkatkan porsi makanannya! ✨";
    } else if (bbSekarang > 18.0) { 
      _jenisKesimpulan = "Pertumbuhan Sangat Aktif";
      _kesimpulan = "${widget.namaAnak} tumbuh dengan sangat antusias! Grafiknya sedikit di atas rata-rata. Bunda hebat! 🤸‍♀️";
    } else {
      _jenisKesimpulan = "Pertumbuhan Normal & Aman";
      _kesimpulan = "Alhamdulillah, pertumbuhan ${widget.namaAnak} sangat baik dan stabil di jalur aman. Terus pertahankan asupan nutrisi seimbangnya ya, Bunda! 💖";
    }
  }

  @override
  Widget build(BuildContext context) {
    String genderText = widget.jenisKelamin.toUpperCase().startsWith('L') ? 'Laki-laki' : 'Perempuan';

    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        title: Text("Statistik Pertumbuhan", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: softPink,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: navyDark))
        : RefreshIndicator(
            color: brightPink,
            backgroundColor: softPink,
            onRefresh: _fetchRiwayatPertumbuhan,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), 
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(genderText), 
                  const SizedBox(height: 15),

                  // --- [DITAMBAHKAN] KARTU INSIGHT ANOMALI ---
                  _buildInsightCard(),
                  
                  _buildStatusGiziBox(),
                  const SizedBox(height: 25),
                  
                  _buildDropdownPrediksi(), 
                  const SizedBox(height: 20),

                  _buildSummaryBox(),
                  
                  const SizedBox(height: 15),
                  _buildActionInsight(),

                  const SizedBox(height: 25),
                  _buildChartContainer("Grafik Berat Badan (Kg)", true),
                  const SizedBox(height: 25),
                  _buildChartContainer("Grafik Tinggi Badan (Cm)", false),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  // --- [DITAMBAHKAN] WIDGET KARTU PESAN ANOMALI BUNDA ---
  Widget _buildInsightCard() {
    if (_pesanAnomali == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: highlightPink, width: 1.5), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_rounded, 
            color: brightPink, 
            size: 28
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pesan Khusus untuk Bunda",
                  style: TextStyle(
                    color: navyDark, 
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pesanAnomali!,
                  style: TextStyle(
                    color: navyDark.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGiziBox() {
    String status = _statusGiziAktual.isNotEmpty ? _statusGiziAktual : "Belum Ada Data";
    String statusLower = status.toLowerCase();
    
    Color boxColor;
    Color textColor;
    IconData iconStatus;

    if (statusLower.contains('normal') || statusLower.contains('baik')) {
      boxColor = safeGreen;
      textColor = Colors.green[800]!;
      iconStatus = Icons.check_circle_outline;
    } else if (statusLower.contains('buruk') || statusLower.contains('overweight') || statusLower.contains('stunting') || statusLower.contains('obesitas') || statusLower.contains('lebih')) {
      boxColor = Colors.redAccent;
      textColor = Colors.red[900]!;
      iconStatus = Icons.warning_amber_rounded;
    } else if (status == "Belum Ada Data") {
      boxColor = Colors.grey;
      textColor = Colors.grey[800]!;
      iconStatus = Icons.help_outline;
    } else {
      boxColor = Colors.orange;
      textColor = Colors.orange[900]!;
      iconStatus = Icons.error_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: boxColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: boxColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(iconStatus, color: boxColor, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status Gizi Saat Ini", style: TextStyle(fontSize: 11, color: navyDark.withOpacity(0.7), fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionInsight() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_butuhKonsultasi ? "Membuka halaman konsultasi..." : "Membuka ide resep makanan sehat..."))
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _butuhKonsultasi ? Colors.redAccent : safeGreen,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
        icon: Icon(_butuhKonsultasi ? Icons.medical_services : Icons.restaurant_menu, color: Colors.white),
        label: Text(
          _butuhKonsultasi ? "Jadwalkan Konsultasi Medis" : "Lihat Ide Resep Penambah Gizi",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownPrediksi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: highlightPink, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.timeline, color: brightPink),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Tampilkan Prediksi:",
              style: TextStyle(color: navyDark, fontWeight: FontWeight.bold),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _jumlahBulanDipilih,
              icon: Icon(Icons.keyboard_arrow_down, color: navyDark),
              dropdownColor: softPink,
              style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 15),
              items: [1, 2, 3].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value Bulan"),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _jumlahBulanDipilih = newValue;
                    _tentukanKesimpulan();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String genderText) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: fieldPink, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(Icons.monitor_heart_outlined, color: navyDark, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: navyDark.withOpacity(0.8), height: 1.4, fontFamily: 'Roboto'),
                children: [
                  const TextSpan(text: "Grafik di bawah ini menunjukkan alur pertumbuhan "),
                  TextSpan(text: widget.namaAnak, style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: " ($genderText) ", style: TextStyle(fontWeight: FontWeight.bold, color: brightPink)),
                  const TextSpan(text: "berdasarkan catatan yang Bunda masukkan tiap bulannya."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: navyDark, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: navyDark.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.volunteer_activism, color: softPink, size: 22),
              const SizedBox(width: 10),
              Flexible(
                child: Text(_jenisKesimpulan, style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _kesimpulan,
            textAlign: TextAlign.center,
            style: TextStyle(color: softPink.withOpacity(0.9), fontSize: 13, height: 1.5),
          ),
          if (_infoKBM.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white38),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _infoKBM,
                      style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildChartContainer(String title, bool isBerat) {
    List<double> historyPoints = [];
    if (_riwayat.isNotEmpty) {
      historyPoints = _riwayat.map<double>((r) {
        final val = r[isBerat ? 'berat_badan' : 'tinggi_badan'];
        return (val ?? 0).toDouble();
      }).toList();
    }

    String targetMetrik = isBerat ? 'berat_badan' : 'tinggi_badan';
    
    List<double> predictionPoints = [];
    var metricPreds = _listPrediksi.where((p) => p['metrik'] == targetMetrik).take(_jumlahBulanDipilih).toList();
    for(var p in metricPreds) {
      double val = double.tryParse(p['nilai_prediksi'].toString()) ?? 0.0;
      predictionPoints.add(val);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: fieldPink, 
        borderRadius: BorderRadius.circular(25), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: navyDark, fontSize: 15)),
          const SizedBox(height: 15),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_upward, size: 12, color: navyDark.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    "Sumbu Y : ${isBerat ? 'Nilai Berat (Kg)' : 'Nilai Tinggi (cm)'}", 
                    style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              Row(
                children: [
                  Container(width: 12, height: 12, color: safeGreen.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text("Area Normal Kemenkes", style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 10)),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),

          if (historyPoints.isEmpty)
              SizedBox(
                height: 150,
                child: Center(child: Text("Belum ada data grafik", style: TextStyle(color: navyDark.withOpacity(0.5)))),
              )
          else
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: navyDark.withOpacity(0.3), width: 2), 
                    bottom: BorderSide(color: navyDark.withOpacity(0.3), width: 2), 
                  )
                ),
                height: 180,
                width: double.infinity,
                child: CustomPaint(
                  painter: PertumbuhanChartPainter(
                    historyPoints: historyPoints,
                    predictionPoints: predictionPoints, 
                    lineColor: navyDark,
                    dotColor: softPink,
                    predictColor: brightPink,
                    safeColor: safeGreen, 
                    isBerat: isBerat, 
                  ),
                ),
              ),
              
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Sumbu X : Waktu (Kiri: Awal ➔ Kanan: Terbaru)", 
                style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold)
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 12, color: navyDark.withOpacity(0.6)),
            ],
          ),

          if (predictionPoints.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(color: softPink, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Icon(Icons.child_care_rounded, color: brightPink, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Melihat tren pertumbuhannya, $_jumlahBulanDipilih bulan ke depan diperkirakan: ${predictionPoints.map((e) => e.toStringAsFixed(1)).join(" ➔ ")} ${isBerat ? 'kg' : 'cm'} nih, Bun.", 
                      style: TextStyle(color: navyDark, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10), 
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: navyDark.withOpacity(0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "*Catatan: Titik merah muda putus-putus pada grafik adalah perkiraan kasar berdasarkan bulan sebelumnya. Untuk kepastian medis, tetap rujuk ke tenaga kesehatan terdekat.",
                    style: TextStyle(
                      color: navyDark.withOpacity(0.7), 
                      fontSize: 11, 
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}

class PertumbuhanChartPainter extends CustomPainter {
  final List<double> historyPoints;
  final List<double> predictionPoints; 
  final Color lineColor;
  final Color dotColor;
  final Color predictColor;
  final Color safeColor; 
  final bool isBerat;

  PertumbuhanChartPainter({
    required this.historyPoints, 
    required this.predictionPoints, 
    required this.lineColor, 
    required this.dotColor, 
    required this.predictColor,
    required this.safeColor, 
    required this.isBerat
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historyPoints.isEmpty) return;

    List<double> allPoints = [...historyPoints, ...predictionPoints];

    double dataMax = allPoints.reduce(max);
    double dataMin = allPoints.reduce(min);
    
    final double gap = isBerat ? 3.0 : 10.0; 
    final double maxVal = dataMax + gap; 
    final double minVal = (dataMin - gap).clamp(0, double.infinity);

    final int totalPoints = allPoints.length;
    final double stepX = totalPoints > 1 ? size.width / (totalPoints - 1) : size.width / 2;

    List<Offset> points = [];

    for (int i = 0; i < totalPoints; i++) {
      double x = totalPoints == 1 ? size.width / 2 : i * stepX;
      double y = size.height - ((allPoints[i] - minVal) / (maxVal - minVal) * size.height);
      points.add(Offset(x, y));
    }

    final Path pitaPath = Path();
    final double pitaMarginY = (1.5 / (maxVal - minVal)) * size.height; 

    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        pitaPath.moveTo(points[i].dx, points[i].dy - pitaMarginY); 
      } else {
        pitaPath.lineTo(points[i].dx, points[i].dy - pitaMarginY);
      }
    }
    for (int i = points.length - 1; i >= 0; i--) {
      pitaPath.lineTo(points[i].dx, points[i].dy + pitaMarginY); 
    }
    pitaPath.close();

    final paintPita = Paint()
      ..color = safeColor.withOpacity(0.3) 
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(pitaPath, paintPita); 

    final paintHistoryLine = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final historyPath = Path();
    for (int i = 0; i < historyPoints.length; i++) {
      if (i == 0) {
        historyPath.moveTo(points[i].dx, points[i].dy);
      } else {
        historyPath.lineTo(points[i].dx, points[i].dy);
      }
    }
    if (historyPoints.length > 1) {
      canvas.drawPath(historyPath, paintHistoryLine);
    }

    if (predictionPoints.isNotEmpty && historyPoints.isNotEmpty) {
      final paintPredictLine = Paint()
        ..color = predictColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Offset startPoint = points[historyPoints.length - 1];
      
      for (int i = 0; i < predictionPoints.length; i++) {
        int pointIndex = historyPoints.length + i; 
        Offset endPoint = points[pointIndex];
        
        _drawDashedLine(canvas, startPoint, endPoint, paintPredictLine);
        startPoint = endPoint;
      }
    }

    final paintDotOuter = Paint()..style = PaintingStyle.fill;
    final paintDotInner = Paint()..color = dotColor..style = PaintingStyle.fill;

    for (int i = 0; i < totalPoints; i++) {
      bool isPredictionDot = i >= historyPoints.length;
      paintDotOuter.color = isPredictionDot ? predictColor : lineColor;
      canvas.drawCircle(points[i], isPredictionDot ? 7 : 6, paintDotOuter);
      canvas.drawCircle(points[i], 3, paintDotInner);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 6;
    const double dashSpace = 4;
    double distance = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    double start = 0;

    while (start < distance) {
      double end = start + dashWidth;
      if (end > distance) end = distance;
      canvas.drawLine(
        Offset(p1.dx + dx * start, p1.dy + dy * start),
        Offset(p1.dx + dx * end, p1.dy + dy * end),
        paint,
      );
      start += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}