import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class GrafikLengkapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> riwayatData;
  final bool isBeratBadan;
  final String namaAnak;
  final String tanggalLahir;
  final String jenisKelamin;

  const GrafikLengkapScreen({
    super.key,
    required this.riwayatData,
    required this.isBeratBadan,
    required this.namaAnak,
    required this.tanggalLahir,
    required this.jenisKelamin,
  });

  @override
  State<GrafikLengkapScreen> createState() => _GrafikLengkapScreenState();
}

class _GrafikLengkapScreenState extends State<GrafikLengkapScreen> {
  late Color kmsBackground;
  
  // Warna KMS pekat
  final Color zoneGreenDark = const Color(0xFF4CAF50);
  final Color zoneGreenLight = const Color(0xFF81C784);
  final Color zoneYellow = const Color(0xFFF7C300); 
  final Color zoneRedLine = const Color(0xFFD32F2F);

  List<Map<String, double>> plottedPoints = [];
  
  bool _isPanduanOpen = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    kmsBackground = widget.jenisKelamin.toLowerCase() == 'laki-laki'
        ? const Color(0xFFE3F2FD)
        : const Color(0xFFFCE4EC);

    _calculatePoints();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _calculatePoints() {
    if (widget.tanggalLahir.isEmpty) return;
    DateTime birthDate = DateTime.parse(widget.tanggalLahir);

    for (var data in widget.riwayatData) {
      if (data['tanggal_pengukuran'] == null) continue;
      DateTime measureDate = DateTime.parse(data['tanggal_pengukuran']);
      
      int months = (measureDate.year - birthDate.year) * 12 + measureDate.month - birthDate.month;
      
      var val = widget.isBeratBadan ? data['berat_badan'] : data['tinggi_badan'];
      double value = double.tryParse(val.toString()) ?? 0.0;

      if (months >= 0) {
        plottedPoints.add({'umur': months.toDouble(), 'nilai': value});
      }
    }
    plottedPoints.sort((a, b) => a['umur']!.compareTo(b['umur']!));
  }

  @override
  Widget build(BuildContext context) {
    const double maxAgeMonths = 60;
    final double maxValue = widget.isBeratBadan ? 25.0 : 120.0;
    final double minValue = widget.isBeratBadan ? 0.0 : 40.0;

    return Scaffold(
      backgroundColor: kmsBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double canvasHeight = constraints.maxHeight;
                  double canvasWidth = canvasHeight * 3.5; 

                  return InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(50),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(top: 20, right: 40, bottom: 80, left: 100), 
                      width: canvasWidth,
                      height: canvasHeight,
                      child: CustomPaint(
                        size: Size(canvasWidth, canvasHeight - 100), 
                        painter: BukuKmsPainter(
                          isBerat: widget.isBeratBadan,
                          dataPoints: plottedPoints,
                          maxAge: maxAgeMonths,
                          maxValue: maxValue,
                          minValue: minValue,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: 15, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black87.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text("Zoom & Geser dengan 2 jari", style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: Colors.white.withOpacity(0.9),
                shape: const CircleBorder(),
                elevation: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Kembali',
                ),
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _isPanduanOpen ? 0 : -300, 
              top: 0,
              bottom: 0,
              child: Container(
                width: 300, 
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(-3, 0))]),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      color: kmsBackground.withOpacity(0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.namaAnak, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Buku KIA ${widget.isBeratBadan ? '(BB)' : '(TB)'}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Panduan Membaca KMS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 15),
                            _legendItem(zoneGreenDark, "Pita Hijau Tua", "Pertumbuhan Ideal / Normal."),
                            const SizedBox(height: 12),
                            _legendItem(zoneGreenLight, "Pita Hijau Muda", "Masih Normal, pantau trennya."),
                            const SizedBox(height: 12),
                            _legendItem(zoneYellow, "Pita Kuning", "Waspada! Risiko gizi kurang/lebih."),
                            const SizedBox(height: 12),
                            _legendItem(zoneRedLine, "BGM", "Sangat Kurang! Rujuk ke Faskes.", isLine: true),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                            const Text("Istilah Posyandu:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            _textLegend("N (Naik)", "Grafik memotong garis sejajar di atasnya."),
                            const SizedBox(height: 8),
                            _textLegend("T (Tidak Naik)", "Grafik mendatar/menurun."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _isPanduanOpen ? 300 : 0, 
              top: 16,
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isPanduanOpen = !_isPanduanOpen;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Icon(
                      _isPanduanOpen ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String title, String desc, {bool isLine = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(margin: const EdgeInsets.only(top: 2), width: 14, height: isLine ? 4 : 14, decoration: isLine ? null : BoxDecoration(color: color, shape: BoxShape.rectangle), color: isLine ? color : null),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(desc, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.3))]))
      ],
    );
  }

  Widget _textLegend(String title, String desc) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), Expanded(child: Text(desc, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.3)))]);
  }
}

// ============================================================================
// PELUKIS KANVAS BUKU KIA 
// ============================================================================
class BukuKmsPainter extends CustomPainter {
  final bool isBerat;
  final List<Map<String, double>> dataPoints;
  final double maxAge; 
  final double maxValue; 
  final double minValue; 

  final double headerHeight = 90.0; 

  BukuKmsPainter({
    required this.isBerat,
    required this.dataPoints,
    required this.maxAge,
    required this.maxValue,
    required this.minValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawMilestones(canvas, w); 
    _drawKmsZones(canvas, w, h);
    _drawGridAndLabels(canvas, w, h);
    _plotUserData(canvas, w, h);
  }

  void _drawMilestones(Canvas canvas, double w) {
    final linePaint = Paint()..color = Colors.black54..strokeWidth = 1..style = PaintingStyle.stroke;

    final milestones = [
      {'start': 0, 'end': 3, 'desc': 'Mengangkat\nkepala', 'icon': '👶'},
      {'start': 3, 'end': 6, 'desc': 'Tengkurap\n& Duduk', 'icon': '🧸'},
      {'start': 6, 'end': 9, 'desc': 'Duduk mandiri\nMerangkak', 'icon': '🧎'},
      {'start': 9, 'end': 12, 'desc': 'Berdiri\nberpegangan', 'icon': '🧍'},
      {'start': 12, 'end': 18, 'desc': 'Berjalan\nmandiri', 'icon': '🚶'},
      {'start': 18, 'end': 24, 'desc': 'Berjalan mundur\nNaik tangga', 'icon': '🏃'},
      {'start': 24, 'end': 36, 'desc': 'Melompat\nBersepeda', 'icon': '🚴'},
      {'start': 36, 'end': 60, 'desc': 'Bermain aktif\nMandiri', 'icon': '🤸'},
    ];

    _drawText(canvas, "PANDUAN PERTUMBUHAN & PERKEMBANGAN ANAK", const Offset(0, -15), const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red));

    for (var m in milestones) {
      double startX = ((m['start'] as int) / maxAge) * w;
      double endX = ((m['end'] as int) / maxAge) * w;
      double centerX = startX + ((endX - startX) / 2);
      
      double colWidth = endX - startX; 

      if (m['start'] != 0) {
        canvas.drawLine(Offset(startX, 10), Offset(startX, headerHeight), linePaint);
      }

      double currentFontSize = 9.0;
      TextPainter tpDesc;
      
      while (true) {
        tpDesc = TextPainter(
          text: TextSpan(text: m['desc'] as String, style: TextStyle(fontSize: currentFontSize, color: Colors.black87)),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();

        if (tpDesc.width > colWidth - 6 && currentFontSize > 5.0) {
          currentFontSize -= 0.5;
        } else {
          break; 
        }
      }
      
      tpDesc.paint(canvas, Offset(centerX - (tpDesc.width / 2), 15));

      final tpIcon = TextPainter(
        text: TextSpan(text: m['icon'] as String, style: const TextStyle(fontSize: 24)),
        textDirection: TextDirection.ltr,
      )..layout();
      tpIcon.paint(canvas, Offset(centerX - (tpIcon.width / 2), 40));
      
      final tpBulan = TextPainter(text: TextSpan(text: "${m['start']}-${m['end']} bln", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black54)), textDirection: TextDirection.ltr)..layout();
      tpBulan.paint(canvas, Offset(centerX - (tpBulan.width / 2), 70));
    }
    
    canvas.drawLine(Offset(0, headerHeight), Offset(w, headerHeight), Paint()..color = Colors.black..strokeWidth = 2);
  }

  void _drawGridAndLabels(Canvas canvas, double w, double h) {
    final gridPaint = Paint()..color = Colors.grey.withOpacity(0.5)..strokeWidth = 1;
    final heavyGridPaint = Paint()..color = Colors.black45..strokeWidth = 1.5;
    final boldTextStyle = const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold);

    double yStep = (maxValue - minValue);
    double graphAreaHeight = h - headerHeight; 

    for (int i = 0; i <= yStep; i++) {
      double y = h - ((i / yStep) * graphAreaHeight);
      
      bool isMajorLine = i % 5 == 0; 
      canvas.drawLine(Offset(0, y), Offset(w, y), isMajorLine ? heavyGridPaint : gridPaint);
      
      if (isMajorLine) { 
        final tp = TextPainter(text: TextSpan(text: "${(minValue + i).toInt()}", style: boldTextStyle), textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(-30, y - (tp.height / 2))); 
      }
    }

    final yAxisLabel = TextPainter(text: TextSpan(text: isBerat ? "Berat (kg)" : "Tinggi (cm)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13)), textDirection: TextDirection.ltr)..layout();
    canvas.save();
    canvas.translate(-65, headerHeight + (graphAreaHeight / 2) + (yAxisLabel.width/2));
    canvas.rotate(-pi / 2);
    yAxisLabel.paint(canvas, const Offset(0, 0));
    canvas.restore();

    double boxHeight = 25.0;
    double startYBoxes = h + 10;
    
    _drawText(canvas, "Umur (Bulan)", Offset(-90, startYBoxes + 6), boldTextStyle);
    if (isBerat) _drawText(canvas, "Keterangan", Offset(-90, startYBoxes + boxHeight + 6), boldTextStyle);

    for (int i = 0; i <= maxAge; i++) {
      double x = (i / maxAge) * w;
      double colWidth = w / maxAge;

      bool isYearLine = i % 12 == 0; 
      canvas.drawLine(Offset(x, headerHeight), Offset(x, h), isYearLine ? heavyGridPaint : gridPaint);

      if (i < maxAge) {
        final rectBulan = Rect.fromLTWH(x, startYBoxes, colWidth, boxHeight);
        canvas.drawRect(rectBulan, Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawRect(rectBulan, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 1);
        final tpBulan = TextPainter(text: TextSpan(text: "$i", style: boldTextStyle), textDirection: TextDirection.ltr)..layout();
        tpBulan.paint(canvas, Offset(x + (colWidth / 2) - (tpBulan.width / 2), startYBoxes + 6));

        if (isBerat) {
          final rectKeterangan = Rect.fromLTWH(x, startYBoxes + boxHeight, colWidth, boxHeight);
          Color boxColor = Colors.white; 
          
          if (i < 6) {
             boxColor = const Color(0xFFF48FB1); 
          } else if (i < 24) {
             double fadeOpacity = 1.0 - ((i - 6) / (24 - 6)) * 0.85; 
             boxColor = const Color(0xFFF48FB1).withOpacity(fadeOpacity.clamp(0.15, 1.0)); 
          }

          canvas.drawRect(rectKeterangan, Paint()..color = boxColor..style = PaintingStyle.fill);
          canvas.drawRect(rectKeterangan, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 1);
        }
      }
    }

    if (isBerat) {
      double asiWidth = (24 / maxAge) * w; 
      String textMotivasi = "ASI EKSKLUSIF (0-6 BLN) & LANJUT MENYUSUI HINGGA 2 TAHUN. AYO IBU SEMANGAT BERIKAN HAK TERBAIK ANAK!";
      
      double currentFontSize = 10.0;
      TextPainter tpAsi;
      
      while (true) {
        tpAsi = TextPainter(
          text: TextSpan(
            text: textMotivasi, 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentFontSize, color: Colors.pink.shade900)
          ), 
          textDirection: TextDirection.ltr
        )..layout();

        if (tpAsi.width > asiWidth - 10 && currentFontSize > 5.0) {
          currentFontSize -= 0.5;
        } else {
          break; 
        }
      }

      tpAsi.paint(canvas, Offset((asiWidth / 2) - (tpAsi.width / 2), startYBoxes + boxHeight + ((boxHeight - tpAsi.height) / 2)));
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, offset);
  }

  void _drawKmsZones(Canvas canvas, double w, double h) {
    double graphAreaHeight = h - headerHeight;

    Offset getCoord(double month, double value) {
      double x = (month / maxAge) * w;
      double y = h - (((value - minValue) / (maxValue - minValue)) * graphAreaHeight);
      return Offset(x, y);
    }

    // 6 Garis batas untuk membuat 5 Pita Area yang TEBAL
    List<Offset> linePlus3SD = [], linePlus2SD = [], linePlus1SD = [];
    List<Offset> lineMinus1SD = [], lineMinus2SD = [], lineMinus3SD = [];

    for (int month = 0; month <= maxAge; month++) {
      // Base growth direvisi sedikit agar pas di tengah-tengah rentang standar KIA
      double baseGrowth = isBerat 
          ? 3.3 + (1.8 * sqrt(month)) + (0.015 * month)  
          : 50.0 + (7.0 * sqrt(month)) + (0.08 * month); 
      
      // Variansi dilebarkan drastis menggunakan fungsi sqrt agar pita sangat tebal memenuhi grid
      double sdVariance = isBerat 
          ? 0.6 + (0.25 * sqrt(month)) 
          : 2.0 + (0.5 * sqrt(month));

      // Multiplier ditarik lebar ke atas dan ke bawah
      linePlus3SD.add(getCoord(month.toDouble(), baseGrowth + (sdVariance * 3.5)));
      linePlus2SD.add(getCoord(month.toDouble(), baseGrowth + (sdVariance * 2.0)));
      linePlus1SD.add(getCoord(month.toDouble(), baseGrowth + (sdVariance * 0.6))); // Batas atas Hijau Tua
      
      lineMinus1SD.add(getCoord(month.toDouble(), baseGrowth - (sdVariance * 0.6))); // Batas bawah Hijau Tua
      lineMinus2SD.add(getCoord(month.toDouble(), baseGrowth - (sdVariance * 2.0)));
      lineMinus3SD.add(getCoord(month.toDouble(), baseGrowth - (sdVariance * 3.5)));
    }

    void drawZone(List<Offset> topList, List<Offset> bottomList, Color color) {
      final path = Path();
      path.moveTo(topList.first.dx, topList.first.dy);
      for (var point in topList) { path.lineTo(point.dx, point.dy); }
      for (var point in bottomList.reversed) { path.lineTo(point.dx, point.dy); }
      path.close();
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    }

    // 5 Lapis Pita Lebar persis seperti Buku KMS
    drawZone(linePlus3SD, linePlus2SD, const Color(0xFFF7C300));   // Pita Kuning Atas
    drawZone(linePlus2SD, linePlus1SD, const Color(0xFF81C784));   // Pita Hijau Muda Atas
    drawZone(linePlus1SD, lineMinus1SD, const Color(0xFF4CAF50));  // Pita Hijau Tua (Tengah)
    drawZone(lineMinus1SD, lineMinus2SD, const Color(0xFF81C784)); // Pita Hijau Muda Bawah
    drawZone(lineMinus2SD, lineMinus3SD, const Color(0xFFF7C300)); // Pita Kuning Bawah

    // Garis Merah BGM di bagian paling bawah
    final redPath = Path();
    redPath.moveTo(lineMinus3SD.first.dx, lineMinus3SD.first.dy);
    for (var point in lineMinus3SD) { redPath.lineTo(point.dx, point.dy); }
    canvas.drawPath(redPath, Paint()..color = Colors.red..strokeWidth = 3.5..style = PaintingStyle.stroke);

    if (lineMinus3SD.isNotEmpty && lineMinus3SD.length > 20) {
      Offset bgmTextPos = lineMinus3SD[20]; 
      canvas.save();
      canvas.translate(bgmTextPos.dx, bgmTextPos.dy + 15);
      canvas.rotate(-0.1);
      
      final tpBgm = TextPainter(
        text: const TextSpan(
          text: "BGM (Bawah Garis Merah)", 
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)
        ), 
        textDirection: TextDirection.ltr
      )..layout();
      tpBgm.paint(canvas, const Offset(0, 0));
      canvas.restore();
    }
  }

  void _plotUserData(Canvas canvas, double w, double h) {
    if (dataPoints.isEmpty) return;
    double graphAreaHeight = h - headerHeight;

    // Garis data anak tetap TEBAL dan HITAM
    final linePaint = Paint()
      ..color = Colors.black 
      ..strokeWidth = 5 
      ..style = PaintingStyle.stroke;
    
    // Titik ditambahkan outline putih tipis agar kontras menyala (seperti screenshot Anda)
    final dotOutlinePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final dotPaint = Paint()..color = Colors.black..style = PaintingStyle.fill; 

    final path = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      double monthAge = dataPoints[i]['umur']!;
      double val = dataPoints[i]['nilai']!;
      double x = (monthAge / maxAge) * w;
      double y = h - (((val - minValue) / (maxValue - minValue)) * graphAreaHeight);

      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);

      canvas.drawCircle(Offset(x, y), 6.5, dotOutlinePaint); // Border putih
      canvas.drawCircle(Offset(x, y), 4.5, dotPaint);        // Titik hitam pekat
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant BukuKmsPainter oldDelegate) => true; 
}