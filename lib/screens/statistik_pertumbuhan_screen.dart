import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math'; // Tambahan untuk menghitung nilai max/min di grafik

class StatistikPertumbuhanScreen extends StatefulWidget {
  final String anakId;
  final String namaAnak;

  const StatistikPertumbuhanScreen({
    super.key, 
    required this.anakId, 
    required this.namaAnak
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

  bool _isLoading = true;
  List<Map<String, dynamic>> _riwayat = [];
  List<Map<String, dynamic>> _listPrediksi = []; 
  
  String _kesimpulan = "";
  String _jenisKesimpulan = "Normal";

  @override
  void initState() {
    super.initState();
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
          .order('tanggal_prediksi', ascending: false)
          .limit(10); 

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

  void _tentukanKesimpulan() {
    if (_riwayat.isEmpty) {
      _jenisKesimpulan = "Belum Ada Data";
      _kesimpulan = "Belum ada data pengukuran, Bun. Yuk catat data pertama ${widget.namaAnak} supaya kita bisa pantau tumbuh kembangnya bersama! 💕";
      return;
    }

    Map<String, dynamic>? prediksiBB;
    try {
      prediksiBB = _listPrediksi.firstWhere((p) => p['metrik'] == 'berat_badan');
    } catch (e) {
      prediksiBB = null;
    }

    if (prediksiBB != null) {
      String statusGizi = prediksiBB['status_gizi'] ?? "Normal";
      double nilaiPrediksi = double.tryParse(prediksiBB['nilai_prediksi'].toString()) ?? 0.0;
      
      _jenisKesimpulan = "Analisis AI: $statusGizi";
      
      if (statusGizi.toLowerCase().contains('normal') || statusGizi.toLowerCase().contains('baik')) {
        _kesimpulan = "Berdasarkan Z-Score WHO, pertumbuhan ${widget.namaAnak} sangat baik! AI memprediksi bulan depan beratnya sekitar ${nilaiPrediksi.toStringAsFixed(1)} kg. Terus pertahankan asupan nutrisinya ya, Bun! 💖";
      } else {
        _kesimpulan = "Sistem mendeteksi indikasi $statusGizi. AI memprediksi berat bulan depan sekitar ${nilaiPrediksi.toStringAsFixed(1)} kg. Jangan panik ya Bun, yuk pantau ekstra dan konsultasikan dengan dokter anak agar penanganannya tepat. Peluk hangat untuk Bunda! 🫂";
      }
      return; 
    }

    if (_riwayat.length == 1) {
      _jenisKesimpulan = "Awal yang Baik";
      _kesimpulan = "Data pertama ${widget.namaAnak} sudah tercatat! Terus pantau dan catat pertumbuhannya bulan depan untuk melihat trennya ya. Bunda hebat! 💖";
      return;
    }

    double bbSekarang = (_riwayat.last['berat_badan'] ?? 0).toDouble();
    double bbSebelumnya = (_riwayat[_riwayat.length - 2]['berat_badan'] ?? 0).toDouble();
    double selisihBB = bbSekarang - bbSebelumnya;

    if (selisihBB < 0) {
      _jenisKesimpulan = "Berat Badan Turun";
      _kesimpulan = "Bulan ini grafik ${widget.namaAnak} sedikit menurun. Tidak apa-apa Bun, wajar jika anak kadang susah makan atau sedang aktif-aktifnya. Jangan terlalu keras pada diri sendiri ya. Coba tawarkan cemilan padat gizi pelan-pelan. Bunda tidak sendirian! 🫂";
    } else if (selisihBB >= 1.0) {
      _jenisKesimpulan = "Naik Signifikan";
      _kesimpulan = "Wah, bulan ini ${widget.namaAnak} melesat pertumbuhannya! Pastikan kenaikannya tetap nyaman untuknya ya Bun. Jika Bunda merasa ragu, konsultasi santai dengan dokter anak bisa jadi pilihan. Semangat terus, Bunda hebat! 🚀";
    } else if (bbSekarang < 5.0) { 
      _jenisKesimpulan = "Perlu Perhatian (Underweight)";
      _kesimpulan = "Grafik ${widget.namaAnak} sedang sedikit di bawah rata-rata. Jangan khawatir atau berkecil hati ya, Bun, setiap anak punya prosesnya sendiri. Yuk, coba pelan-pelan tingkatkan kalori dari makanan kesukaannya. Peluk hangat untuk Bunda! ✨";
    } else if (bbSekarang > 18.0) { 
      _jenisKesimpulan = "Di Atas Rata-rata (Overweight)";
      _kesimpulan = "${widget.namaAnak} tumbuh dengan sangat antusias! Grafiknya sedikit di atas rata-rata. Tidak perlu panik ya Bun, cukup seimbangkan dengan aktivitas fisik yang menyenangkan. Bunda pasti bisa! 🤸‍♀️";
    } else {
      _jenisKesimpulan = "Pertumbuhan Normal";
      _kesimpulan = "Wah, pertumbuhan ${widget.namaAnak} sangat baik dan stabil di jalur aman. Terus pertahankan asupan nutrisi seimbangnya ya, Bunda. Bunda sudah melakukan yang terbaik! 💖";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        title: Text("Statistik Pertumbuhan", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: softPink,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: navyDark))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 25),
                _buildSummaryBox(),
                const SizedBox(height: 25),
                _buildChartContainer("Grafik Berat Badan (Kg)", true),
                const SizedBox(height: 25),
                _buildChartContainer("Grafik Tinggi Badan (Cm)", false),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: fieldPink, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(Icons.monitor_heart_outlined, color: navyDark, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Grafik di bawah menunjukkan tren pertumbuhan ${widget.namaAnak} berdasarkan data yang Bunda catat.",
              style: TextStyle(fontSize: 13, color: navyDark.withOpacity(0.8), height: 1.4),
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
        ],
      ),
    );
  }

  Widget _buildChartContainer(String title, bool isBerat) {
    List<double> dataPoints = [];
    if (_riwayat.isNotEmpty) {
      dataPoints = _riwayat.map<double>((r) {
        final val = r[isBerat ? 'berat_badan' : 'tinggi_badan'];
        return (val ?? 0).toDouble();
      }).toList();
    }

    String targetMetrik = isBerat ? 'berat_badan' : 'tinggi_badan';
    Map<String, dynamic>? prediksiAktif;
    try {
      prediksiAktif = _listPrediksi.firstWhere((p) => p['metrik'] == targetMetrik);
    } catch (e) {
      prediksiAktif = null;
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
          
          // --- KETERANGAN SUMBU Y ---
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
          const SizedBox(height: 10),

          if (dataPoints.isEmpty)
             SizedBox(
               height: 150,
               child: Center(child: Text("Belum ada data grafik", style: TextStyle(color: navyDark.withOpacity(0.5)))),
             )
          else
             Container(
               padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
               decoration: BoxDecoration(
                 border: Border(
                   left: BorderSide(color: navyDark.withOpacity(0.3), width: 2), // Garis Sumbu Y
                   bottom: BorderSide(color: navyDark.withOpacity(0.3), width: 2), // Garis Sumbu X
                 )
               ),
               height: 180,
               width: double.infinity,
               child: CustomPaint(
                 painter: SimpleLineChartPainter(
                   dataPoints: dataPoints,
                   lineColor: navyDark,
                   dotColor: softPink,
                   isBerat: isBerat, // Lempar status berat/tinggi untuk hitung min-max
                 ),
               ),
             ),
             
          const SizedBox(height: 8),

          // --- KETERANGAN SUMBU X ---
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

          if (prediksiAktif != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(color: softPink, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: brightPink, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Berdasarkan AI, bulan depan diprediksi menyentuh angka ${double.tryParse(prediksiAktif['nilai_prediksi'].toString())?.toStringAsFixed(1) ?? '-'} ${isBerat ? 'kg' : 'cm'}", 
                      style: TextStyle(color: navyDark, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10), // Jarak kecil antara kotak AI dan teks catatan
            
            // --- TAMBAHAN DISCLAIMER MEDIS DI SINI ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: navyDark.withOpacity(0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "*Catatan: Angka ini adalah estimasi sistem berdasarkan tren grafik sebelumnya. Tetap jadikan dokter anak sebagai rujukan utama ya, Bun.",
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

// --- CLASS UNTUK MENGGAMBAR GRAFIK GARIS OTOMATIS ---
class SimpleLineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color dotColor;
  final bool isBerat;

  SimpleLineChartPainter({required this.dataPoints, required this.lineColor, required this.dotColor, required this.isBerat});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Hitung dinamis agar grafik tidak flat/menggantung di atas
    double dataMax = dataPoints.reduce(max);
    double dataMin = dataPoints.reduce(min);
    
    final double gap = isBerat ? 3.0 : 10.0; 
    final double maxVal = dataMax + gap; 
    final double minVal = (dataMin - gap).clamp(0, double.infinity);

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final paintDotOuter = Paint()..color = lineColor..style = PaintingStyle.fill;
    final paintDotInner = Paint()..color = dotColor..style = PaintingStyle.fill;

    final path = Path();
    final double stepX = dataPoints.length > 1 ? size.width / (dataPoints.length - 1) : size.width / 2;

    List<Offset> points = [];

    for (int i = 0; i < dataPoints.length; i++) {
      double x = dataPoints.length == 1 ? size.width / 2 : i * stepX;
      double y = size.height - ((dataPoints[i] - minVal) / (maxVal - minVal) * size.height);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (dataPoints.length > 1) {
      canvas.drawPath(path, paintLine);
    }

    // Gambar titik
    for (var point in points) {
      canvas.drawCircle(point, 6, paintDotOuter);
      canvas.drawCircle(point, 3, paintDotInner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}