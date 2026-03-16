import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math'; // Untuk menghitung nilai max/min di grafik

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
      _kesimpulan = "Halo Bunda! Belum ada data ukuran nih. Yuk catat data pertama ${widget.namaAnak} supaya kita bisa pantau tumbuh kembangnya sama-sama! 💕";
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
      
      _jenisKesimpulan = "Pantauan Gizi: $statusGizi";
      
      if (statusGizi.toLowerCase().contains('normal') || statusGizi.toLowerCase().contains('baik')) {
        _kesimpulan = "Berdasarkan grafik WHO, pertumbuhan ${widget.namaAnak} sangat baik lho, Bun! Berdasarkan pola saat ini, bulan depan beratnya kemungkinan bisa sekitar ${nilaiPrediksi.toStringAsFixed(1)} kg. Pertahankan asupan nutrisi bergizinya ya! 💖";
      } else {
        _kesimpulan = "Dari catatan ini, sepertinya ada indikasi $statusGizi. Berdasarkan tren yang ada, perkiraan berat bulan depan sekitar ${nilaiPrediksi.toStringAsFixed(1)} kg. Jangan panik dulu ya Bun, mari pantau ekstra dan jadwalkan konsultasi dengan bidan atau dokter anak agar penanganannya tepat. Peluk hangat untuk Bunda! 🫂";
      }
      return; 
    }

    if (_riwayat.length == 1) {
      _jenisKesimpulan = "Awal yang Baik";
      _kesimpulan = "Wah, data pertama ${widget.namaAnak} sudah masuk! Terus pantau dan catat ya Bun tiap bulannya untuk melihat grafiknya. Bunda pasti bisa! 💖";
      return;
    }

    double bbSekarang = (_riwayat.last['berat_badan'] ?? 0).toDouble();
    double bbSebelumnya = (_riwayat[_riwayat.length - 2]['berat_badan'] ?? 0).toDouble();
    double selisihBB = bbSekarang - bbSebelumnya;

    if (selisihBB < 0) {
      _jenisKesimpulan = "Berat Badan Turun";
      _kesimpulan = "Bulan ini grafik ${widget.namaAnak} sedikit menurun nih. Wajar kok Bun, anak kadang susah makan atau sedang aktif-aktifnya bergerak. Jangan terlalu stres ya. Coba tawarkan cemilan padat gizi pelan-pelan. Bunda tidak sendirian! 🫂";
    } else if (selisihBB >= 1.0) {
      _jenisKesimpulan = "Naik Signifikan";
      _kesimpulan = "Wah, bulan ini ${widget.namaAnak} melesat pertumbuhannya! Pastikan badannya tetap nyaman ya Bun. Jika Bunda merasa ragu, ngobrol santai dengan bidan atau dokter anak bisa jadi pilihan. Semangat terus! 🚀";
    } else if (bbSekarang < 5.0) { 
      _jenisKesimpulan = "Perlu Perhatian Khusus";
      _kesimpulan = "Grafik ${widget.namaAnak} sedang sedikit di bawah garis. Jangan khawatir atau berkecil hati ya, Bun, setiap anak punya prosesnya sendiri. Yuk, coba pelan-pelan tingkatkan porsi makanannya. Peluk hangat untuk Bunda! ✨";
    } else if (bbSekarang > 18.0) { 
      _jenisKesimpulan = "Pertumbuhan Sangat Aktif";
      _kesimpulan = "${widget.namaAnak} tumbuh dengan sangat antusias! Grafiknya sedikit di atas rata-rata. Tidak perlu panik ya Bun, cukup seimbangkan dengan aktivitas fisik yang menyenangkan. Bunda hebat! 🤸‍♀️";
    } else {
      _jenisKesimpulan = "Pertumbuhan Normal & Aman";
      _kesimpulan = "Alhamdulillah, pertumbuhan ${widget.namaAnak} sangat baik dan stabil di jalur aman. Terus pertahankan asupan nutrisi seimbangnya ya, Bunda. Bunda sudah melakukan yang terbaik! 💖";
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
              "Grafik di bawah ini menunjukkan alur pertumbuhan ${widget.namaAnak} berdasarkan catatan yang Bunda masukkan tiap bulannya.",
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
    List<double> historyPoints = [];
    if (_riwayat.isNotEmpty) {
      historyPoints = _riwayat.map<double>((r) {
        final val = r[isBerat ? 'berat_badan' : 'tinggi_badan'];
        return (val ?? 0).toDouble();
      }).toList();
    }

    String targetMetrik = isBerat ? 'berat_badan' : 'tinggi_badan';
    Map<String, dynamic>? prediksiAktif;
    double? predictionValue;
    try {
      prediksiAktif = _listPrediksi.firstWhere((p) => p['metrik'] == targetMetrik);
      predictionValue = double.tryParse(prediksiAktif['nilai_prediksi'].toString());
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
                   left: BorderSide(color: navyDark.withOpacity(0.3), width: 2), // Garis Sumbu Y
                   bottom: BorderSide(color: navyDark.withOpacity(0.3), width: 2), // Garis Sumbu X
                 )
               ),
               height: 180,
               width: double.infinity,
               child: CustomPaint(
                 painter: PertumbuhanChartPainter(
                   historyPoints: historyPoints,
                   predictionPoint: predictionValue,
                   lineColor: navyDark,
                   dotColor: softPink,
                   predictColor: brightPink,
                   isBerat: isBerat, 
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

          if (prediksiAktif != null && predictionValue != null) ...[
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
                      "Melihat tren pertumbuhannya, bulan depan diperkirakan bisa menyentuh angka ${predictionValue.toStringAsFixed(1)} ${isBerat ? 'kg' : 'cm'} nih, Bun.", 
                      style: TextStyle(color: navyDark, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10), 
            
            // --- DISCLAIMER MEDIS (Lebih Ramah) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: navyDark.withOpacity(0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "*Catatan: Titik merah muda putus-putus pada grafik adalah perkiraan kasar dari alur bulan-bulan sebelumnya ya, Bun. Untuk memastikan kondisi pastinya, tetap jadikan bidan atau dokter anak sebagai rujukan utama.",
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

// --- CLASS UNTUK MENGGAMBAR GRAFIK GARIS & PREDIKSI ---
class PertumbuhanChartPainter extends CustomPainter {
  final List<double> historyPoints;
  final double? predictionPoint;
  final Color lineColor;
  final Color dotColor;
  final Color predictColor;
  final bool isBerat;

  PertumbuhanChartPainter({
    required this.historyPoints, 
    this.predictionPoint, 
    required this.lineColor, 
    required this.dotColor, 
    required this.predictColor,
    required this.isBerat
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historyPoints.isEmpty) return;

    // Gabungkan data historis dan prediksi untuk mencari skala (min & max)
    List<double> allPoints = List.from(historyPoints);
    if (predictionPoint != null) {
      allPoints.add(predictionPoint!);
    }

    double dataMax = allPoints.reduce(max);
    double dataMin = allPoints.reduce(min);
    
    final double gap = isBerat ? 3.0 : 10.0; 
    final double maxVal = dataMax + gap; 
    final double minVal = (dataMin - gap).clamp(0, double.infinity);

    final int totalPoints = allPoints.length;
    final double stepX = totalPoints > 1 ? size.width / (totalPoints - 1) : size.width / 2;

    List<Offset> points = [];

    // Hitung kordinat setiap titik
    for (int i = 0; i < totalPoints; i++) {
      double x = totalPoints == 1 ? size.width / 2 : i * stepX;
      double y = size.height - ((allPoints[i] - minVal) / (maxVal - minVal) * size.height);
      points.add(Offset(x, y));
    }

    // 1. Gambar Garis Historis (Biru Navy Solid)
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

    // 2. Gambar Garis Prediksi (Pink Putus-putus)
    if (predictionPoint != null && historyPoints.isNotEmpty) {
      final paintPredictLine = Paint()
        ..color = predictColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Offset startPoint = points[historyPoints.length - 1];
      Offset endPoint = points.last;

      _drawDashedLine(canvas, startPoint, endPoint, paintPredictLine);
    }

    // 3. Gambar Titik-Titiknya
    final paintDotOuter = Paint()..style = PaintingStyle.fill;
    final paintDotInner = Paint()..color = dotColor..style = PaintingStyle.fill;

    for (int i = 0; i < totalPoints; i++) {
      bool isPredictionDot = (predictionPoint != null && i == totalPoints - 1);
      
      paintDotOuter.color = isPredictionDot ? predictColor : lineColor;
      
      canvas.drawCircle(points[i], isPredictionDot ? 7 : 6, paintDotOuter);
      canvas.drawCircle(points[i], 3, paintDotInner);
    }
  }

  // Fungsi tambahan untuk membuat garis putus-putus (dashed line)
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