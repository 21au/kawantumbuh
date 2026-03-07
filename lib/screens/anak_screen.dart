import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_identitas_anak_screen.dart';
import 'catat_pertumbuhan_screen.dart';
import 'daftar_anak_screen.dart';

class AnakScreen extends StatefulWidget {
  const AnakScreen({super.key});

  @override
  State<AnakScreen> createState() => _AnakScreenState();
}

class _AnakScreenState extends State<AnakScreen> {
  // --- PALET WARNA UTAMA (100% TANPA WARNA PUTIH) ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA); // Background utama
  final Color fieldPink = const Color(0xFFF5CBCB); // Pengganti putih untuk kartu
  final Color highlightPink = const Color(0xFFEBA9A9); // Dusty pink
  final Color successGreen = const Color(0xFFA5D6A7); // Hijau untuk status
  final Color brightPink = Colors.pinkAccent;

  bool isBeratBadan = true;
  int selectedIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _daftarAnak = [];
  List<Map<String, dynamic>> _riwayatPertumbuhan = [];

  @override
  void initState() {
    super.initState();
    _fetchDataAnak();
  }

  // --- FUNGSI FORMAT TANGGAL KE BAHASA INDONESIA ---
  String _formatTanggal(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Tanggal lahir belum diatur";
    try {
      DateTime date = DateTime.parse(dateStr);
      List<String> bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return "${date.day} ${bulan[date.month]} ${date.year}";
    } catch (e) {
      return dateStr; // Jika gagal diparse, tampilkan data aslinya
    }
  }

  // --- LOGIKA AMBIL DATA ---
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
          _isLoading = false;
        });

        if (_daftarAnak.isNotEmpty) {
          _fetchRiwayat(selectedIndex);
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
          .from('growth_records')
          .select()
          .eq('child_id', childId)
          .order('date', ascending: false);

      if (mounted) {
        setState(() {
          _riwayatPertumbuhan = List<Map<String, dynamic>>.from(dataRiwayat);
        });
      }
    } catch (e) {
      debugPrint("Error fetch riwayat: $e");
    }
  }

  // --- FUNGSI TAMPILKAN DETAIL ANAK (BOTTOM SHEET) ---
  void _tampilkanDetailAnak(BuildContext context, Map<String, dynamic> dataAnak) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, 
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: softPink, // Menggunakan palet Bunda
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indikator geser (Pull bar)
                Center(
                  child: Container(
                    width: 50, height: 5,
                    decoration: BoxDecoration(color: navyDark.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Kartu Identitas Anak", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navyDark)
                ),
                const SizedBox(height: 20),

                // --- INFO ANAK ---
                _buildInfoRow(Icons.child_care, "Nama Anak", dataAnak['nama'] ?? '-'),
                _buildInfoRow(Icons.cake, "Tanggal Lahir", _formatTanggal(dataAnak['tanggal_lahir'])),
                _buildInfoRow(Icons.location_on, "Tempat Lahir", dataAnak['tempat_lahir'] ?? '-'),
                _buildInfoRow(Icons.bloodtype, "Golongan Darah", dataAnak['golongan_darah'] ?? 'Belum Tahu'),
                
                Divider(height: 30, thickness: 1, color: highlightPink), 

                // --- INFO ORANG TUA ---
                _buildInfoRow(Icons.favorite, "Nama Ibu", dataAnak['nama_ibu'] ?? '-'),
                _buildInfoRow(Icons.person, "Nama Ayah", dataAnak['nama_ayah'] ?? '-'),
                _buildInfoRow(Icons.phone, "Nomor Telepon", dataAnak['no_telp'] ?? '-'),
                _buildInfoRow(Icons.home, "Alamat", dataAnak['alamat'] ?? '-'),

                Divider(height: 30, thickness: 1, color: highlightPink),

                // --- CATATAN ALERGI ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: fieldPink, 
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: highlightPink),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_information, color: navyDark, size: 20),
                          const SizedBox(width: 8),
                          Text("Catatan Alergi / Medis", style: TextStyle(fontWeight: FontWeight.bold, color: navyDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (dataAnak['catatan_alergi'] == null || dataAnak['catatan_alergi'].toString().isEmpty) 
                            ? 'Tidak ada catatan khusus.' 
                            : dataAnak['catatan_alergi'],
                        style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget Bantuan untuk Bottom Sheet
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: navyDark.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: navyDark.withOpacity(0.6))),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: navyDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: softPink,
        body: Center(child: CircularProgressIndicator(color: navyDark)),
      );
    }

    if (_daftarAnak.isEmpty) {
      return Scaffold(backgroundColor: softPink, body: _buildEmptyState());
    }

    final currentChild = _daftarAnak[selectedIndex];

    return Scaffold(
      backgroundColor: softPink,
      body: RefreshIndicator(
        onRefresh: _fetchDataAnak,
        color: navyDark,
        backgroundColor: softPink,
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
                    _buildFauxChartCard(),
                    const SizedBox(height: 20),
                    _buildStatusPertumbuhan(currentChild['nama'] ?? "Si Kecil"),
                    const SizedBox(height: 20),
                    _buildPrediksiGizi(currentChild),
                    const SizedBox(height: 30),
                    _buildRiwayatHeader(context),
                    const SizedBox(height: 15),
                    _buildRiwayatList(),
                    const SizedBox(height: 120), // Spasi untuk Bottom Nav
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildHeader(Map<String, dynamic> child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Kesehatan Anak",
              style: TextStyle(
                  color: softPink, fontSize: 26, fontWeight: FontWeight.bold)),
          Text("Pantau tumbuh kembang si kecil",
              style: TextStyle(color: softPink.withOpacity(0.8), fontSize: 14)),
          if (_daftarAnak.length > 1) ...[
            const SizedBox(height: 20),
            _buildChildSelector(),
          ],
          const SizedBox(height: 25),
          
          // ---> DIBUNGKUS GESTURE DETECTOR AGAR BISA DITEKAN <---
          // FIX: Di sini sebelumnya terpanggil ikon edit dua kali.
          // Sekarang memanggil _buildMainCard yang memang sudah Anda buat di bawah.
          GestureDetector(
            onTap: () => _tampilkanDetailAnak(context, child),
            child: _buildMainCard(child),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _daftarAnak.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
              _fetchRiwayat(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? highlightPink : softPink.withOpacity(0.25),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Text(_daftarAnak[index]['nama'] ?? "Anak",
                  style: TextStyle(
                      color: isSelected ? navyDark : softPink.withOpacity(0.8),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainCard(Map<String, dynamic> child) {
    final String usiaAnak = child['usia']?.toString() ?? "0";
    final String tanggalLahir = _formatTanggal(child['tanggal_lahir']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: softPink.withOpacity(0.50), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: highlightPink, shape: BoxShape.circle),
                  child: Icon(Icons.face_retouching_natural, color: softPink, size: 35)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child['nama'] ?? "Tanpa Nama",
                        style: TextStyle(
                            color: softPink,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${child['jenis_kelamin'] ?? '-'}, $tanggalLahir",
                        style: TextStyle(color: softPink.withOpacity(0.7), fontSize: 15)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditDataAnakScreen(dataAnak: child))),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: highlightPink,
                    shape: BoxShape.circle,
                  ),
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
              _buildProfileStat("Usia", "$usiaAnak Bulan"),
              _buildProfileStat("Berat",
                  _riwayatPertumbuhan.isNotEmpty ? "${_riwayatPertumbuhan[0]['weight']} Kg" : "--"),
              _buildProfileStat("Tinggi",
                  _riwayatPertumbuhan.isNotEmpty ? "${_riwayatPertumbuhan[0]['height']} cm" : "--"),
            ],
          ),
        ],
      ),
    );
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
      onTap: () => setState(() => isBeratBadan = (title == "Berat Badan")),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: isActive ? navyDark : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: navyDark, width: 1.5)),
        alignment: Alignment.center,
        child: Text(title,
            style: TextStyle(
                color: isActive ? softPink : navyDark,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFauxChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: softPink,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: navyDark.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isBeratBadan ? "Prediksi Berat Badan" : "Prediksi Tinggi Badan",
              style: TextStyle(
                  color: navyDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          
          Text("↑ Sumbu Y: ${isBeratBadan ? 'Nilai Berat (kg)' : 'Nilai Tinggi (cm)'}",
              style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _chartLabel("Max"),
                    _chartLabel("Mid"),
                    _chartLabel("Min"),
                    _chartLabel("0"),
                  ],
                ),
                const SizedBox(width: 10),
                
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: navyDark.withOpacity(0.3), width: 2),
                              bottom: BorderSide(color: navyDark.withOpacity(0.3), width: 2),
                            ),
                          ),
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: KIAChartPainter(navyDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _chartLabel("t1"),
                          _chartLabel("t2"),
                          _chartLabel("t3"),
                          _chartLabel("t4"),
                          _chartLabel("t5"),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text("Sumbu X: Periode Waktu →",
                style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _chartLabel(String text) {
    return Text(text, style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold));
  }

  Widget _buildStatusPertumbuhan(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: successGreen,
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.check_circle, color: navyDark, size: 22),
            const SizedBox(width: 10),
            Text("Status Pertumbuhan",
                style: TextStyle(
                    color: navyDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))
          ]),
          const SizedBox(height: 10),
          Text("Pertumbuhan si kecil normal dan sesuai dengan kurva pertumbuhan WHO. Terus berikan nutrisi seimbang ya bun!",
              style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildPrediksiGizi(Map<String, dynamic> child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: fieldPink,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart, color: brightPink, size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Prediksi Status Gizi",
                      style: TextStyle(
                          color: navyDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text("Berdasarkan data terbaru",
                      style: TextStyle(color: navyDark.withOpacity(0.5), fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: softPink,
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status Gizi:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: navyDark)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: navyDark, borderRadius: BorderRadius.circular(10)),
                  child: Text("Normal",
                      style: TextStyle(color: softPink, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Riwayat Pengukuran",
            style: TextStyle(
                color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CatatPertumbuhanScreen()));
            _fetchDataAnak();
          },
          icon: Icon(Icons.add, size: 16, color: softPink),
          label: Text("Catat",
              style:
                  TextStyle(color: softPink, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              backgroundColor: navyDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
        ),
      ],
    );
  }

  Widget _buildRiwayatList() {
    if (_riwayatPertumbuhan.isEmpty) return Center(child: Text("Belum ada riwayat.", style: TextStyle(color: navyDark)));
    return Column(
      children: _riwayatPertumbuhan
          .map((r) => _buildRiwayatCard(r['date'].toString(),
              "${r['weight']} kg", "${r['height']} cm"))
          .toList(),
    );
  }

  Widget _buildRiwayatCard(String date, String bb, String tb) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: fieldPink,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: navyDark.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(date, style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 6),
            Row(children: [
              Text("BB: $bb",
                  style: TextStyle(
                      color: navyDark, fontWeight: FontWeight.bold)),
              const SizedBox(width: 15),
              Text("TB: $tb",
                  style: TextStyle(
                      color: navyDark, fontWeight: FontWeight.bold)),
            ])
          ]),
          Icon(Icons.arrow_forward_ios,
              color: navyDark.withOpacity(0.3), size: 14),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_friendly_rounded,
                size: 100, color: navyDark.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text("Belum Ada Data Anak",
                style: TextStyle(
                    color: navyDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
                "Yuk, tambahkan data si kecil untuk mulai memantau tumbuh kembangnya.",
                textAlign: TextAlign.center, style: TextStyle(color: navyDark.withOpacity(0.7))),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DaftarAnakScreen()));
                _fetchDataAnak();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: navyDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text("Tambah Data Anak",
                  style: TextStyle(color: softPink, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CLASS UNTUK MENGGAMBAR GRAFIK ALA BUKU KIA (CUSTOM PAINT) ---
class KIAChartPainter extends CustomPainter {
  final Color lineColor;
  KIAChartPainter(this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paintZone = Paint()..style = PaintingStyle.fill;

    paintZone.color = const Color(0xFFFDE68A).withOpacity(0.6); 
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height * 0.25), paintZone);

    paintZone.color = const Color(0xFFA5D6A7).withOpacity(0.6); 
    canvas.drawRect(Rect.fromLTRB(0, size.height * 0.25, size.width, size.height * 0.75), paintZone);

    paintZone.color = const Color(0xFFFCA5A5).withOpacity(0.6); 
    canvas.drawRect(Rect.fromLTRB(0, size.height * 0.75, size.width, size.height), paintZone);

    final borderPaint = Paint()
      ..color = const Color(0xFF102C57).withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), borderPaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), borderPaint);

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    path.moveTo(0, size.height * 0.85); 
    path.lineTo(size.width * 0.25, size.height * 0.65); 
    path.lineTo(size.width * 0.5, size.height * 0.50); 
    path.lineTo(size.width * 0.75, size.height * 0.40); 
    path.lineTo(size.width, size.height * 0.15); 

    canvas.drawPath(path, paintLine);

    final dotPaint = Paint()..color = lineColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, size.height * 0.85), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.50), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.40), 5, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.15), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}