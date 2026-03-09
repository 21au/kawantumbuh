import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  bool _isLoading = true;
  List<Map<String, dynamic>> _riwayat = [];
  String _kesimpulan = "";
  String _jenisKesimpulan = "Normal";

  @override
  void initState() {
    super.initState();
    _fetchRiwayatPertumbuhan();
  }

  Future<void> _fetchRiwayatPertumbuhan() async {
    try {
      // Ambil data urut dari yang terlama ke terbaru (untuk grafik)
      final data = await Supabase.instance.client
          .from('pertumbuhan')
          .select()
          .eq('anak_id', widget.anakId)
          .order('tanggal_pengukuran', ascending: true);

      if (mounted) {
        setState(() {
          _riwayat = List<Map<String, dynamic>>.from(data);
          _tentukanKesimpulan();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error grafik: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA EMPATI & 5 TEMPLATE KESIMPULAN ---
  void _tentukanKesimpulan() {
    if (_riwayat.isEmpty) {
      _jenisKesimpulan = "Belum Ada Data";
      _kesimpulan = "Belum ada data pengukuran, Bun. Yuk catat data pertama ${widget.namaAnak} supaya kita bisa pantau tumbuh kembangnya bersama! 💕";
      return;
    }

    if (_riwayat.length == 1) {
      _jenisKesimpulan = "Awal yang Baik";
      _kesimpulan = "Data pertama ${widget.namaAnak} sudah tercatat! Terus pantau dan catat pertumbuhannya bulan depan untuk melihat trennya ya. Bunda hebat! 💖";
      return;
    }

    // Ambil 2 data terakhir untuk membandingkan tren
    double bbSekarang = (_riwayat.last['berat_badan'] ?? 0).toDouble();
    double bbSebelumnya = (_riwayat[_riwayat.length - 2]['berat_badan'] ?? 0).toDouble();
    double selisihBB = bbSekarang - bbSebelumnya;

    /* Catatan: Ini adalah logika tren sederhana. 
      Nantinya bisa disesuaikan dengan Z-Score WHO jika ada perhitungan usianya.
    */
    if (selisihBB < 0) {
      _jenisKesimpulan = "Berat Badan Turun";
      _kesimpulan = "Bulan ini grafik ${widget.namaAnak} sedikit menurun. Tidak apa-apa Bun, wajar jika anak kadang susah makan atau sedang aktif-aktifnya. Jangan terlalu keras pada diri sendiri ya. Coba tawarkan cemilan padat gizi pelan-pelan. Bunda tidak sendirian! 🫂";
    } else if (selisihBB >= 1.0) {
      _jenisKesimpulan = "Naik Signifikan";
      _kesimpulan = "Wah, bulan ini ${widget.namaAnak} melesat pertumbuhannya! Pastikan kenaikannya tetap nyaman untuknya ya Bun. Jika Bunda merasa ragu, konsultasi santai dengan dokter anak bisa jadi pilihan. Semangat terus, Bunda hebat! 🚀";
    } else if (bbSekarang < 5.0) { // Angka Mockup untuk Underweight
      _jenisKesimpulan = "Perlu Perhatian (Underweight)";
      _kesimpulan = "Grafik ${widget.namaAnak} sedang sedikit di bawah rata-rata. Jangan khawatir atau berkecil hati ya, Bun, setiap anak punya prosesnya sendiri. Yuk, coba pelan-pelan tingkatkan kalori dari makanan kesukaannya. Peluk hangat untuk Bunda! ✨";
    } else if (bbSekarang > 18.0) { // Angka Mockup untuk Overweight
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
              Text(_jenisKesimpulan, style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 16)),
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
          const SizedBox(height: 25),
          if (dataPoints.isEmpty)
             SizedBox(
               height: 150,
               child: Center(child: Text("Belum ada data grafik", style: TextStyle(color: navyDark.withOpacity(0.5)))),
             )
          else
             SizedBox(
               height: 180,
               width: double.infinity,
               child: CustomPaint(
                 painter: SimpleLineChartPainter(
                   dataPoints: dataPoints,
                   lineColor: navyDark,
                   dotColor: softPink,
                 ),
               ),
             ),
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

  SimpleLineChartPainter({required this.dataPoints, required this.lineColor, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double maxVal = dataPoints.reduce((a, b) => a > b ? a : b) * 1.2; // Kasih ruang di atas
    final double minVal = 0; // Mulai dari 0

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