import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Jangan lupa tambahkan package intl di pubspec.yaml ya!

class JadwalPosyanduScreen extends StatefulWidget {
  final String anakId;
  final String namaAnak;

  const JadwalPosyanduScreen({
    super.key,
    required this.anakId,
    required this.namaAnak,
  });

  @override
  State<JadwalPosyanduScreen> createState() => _JadwalPosyanduScreenState();
}

class _JadwalPosyanduScreenState extends State<JadwalPosyanduScreen> {
  // --- PALET WARNA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA);
  final Color fieldPink = const Color(0xFFF5CBCB);
  final Color brightPink = Colors.pinkAccent;

  bool _isLoading = true;
  List<Map<String, dynamic>> _jadwalList = [];

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

  Future<void> _fetchJadwal() async {
    try {
      final data = await Supabase.instance.client
          .from('jadwal_posyandu')
          .select()
          .eq('anak_id', widget.anakId)
          .order('tanggal', ascending: true);

      if (mounted) {
        setState(() {
          _jadwalList = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error ambil jadwal: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog untuk tambah jadwal baru
  Future<void> _tambahJadwal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Cuma bisa pilih hari ini atau ke depan
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyDark, 
              onPrimary: Colors.white, 
              onSurface: navyDark, 
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    TextEditingController keteranganController = TextEditingController();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: softPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Detail Jadwal", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: keteranganController,
          decoration: InputDecoration(
            hintText: "Cth: Timbang rutin & Imunisasi PCV",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: TextStyle(color: navyDark.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: navyDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await Supabase.instance.client.from('jadwal_posyandu').insert({
                  'anak_id': widget.anakId,
                  'tanggal': pickedDate.toIso8601String(),
                  'keterangan': keteranganController.text.isNotEmpty ? keteranganController.text : "Jadwal Posyandu",
                  'is_selesai': false,
                });
                _fetchJadwal();
              } catch (e) {
                debugPrint("Error simpan jadwal: $e");
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Menandai jadwal selesai dan mengarahkan ke form input data
  void _tandaiSelesai(Map<String, dynamic> jadwal) async {
    try {
      await Supabase.instance.client
          .from('jadwal_posyandu')
          .update({'is_selesai': true})
          .eq('id', jadwal['id']);
      
      _fetchJadwal();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Hore! Jadwal selesai. Yuk masukkan data pertumbuhannya! 🎉"),
          backgroundColor: brightPink,
          action: SnackBarAction(
            label: "Input Data",
            textColor: Colors.white,
            onPressed: () {
              // TODO: Ganti ini dengan navigasi ke halaman Input Data Pertumbuhan kamu
              // Navigator.push(context, MaterialPageRoute(builder: (context) => InputDataScreen(anakId: widget.anakId)));
              debugPrint("Navigasi ke halaman input data");
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error update jadwal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        title: Text("Jadwal ${widget.namaAnak}", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: softPink,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: navyDark))
          : _jadwalList.isEmpty
              ? _buildEmptyState()
              : _buildJadwalList(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: navyDark,
        onPressed: _tambahJadwal,
        icon: const Icon(Icons.calendar_today, color: Colors.white),
        label: const Text("Tambah Jadwal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Icon(Icons.event_busy, size: 80, color: fieldPink),
            const SizedBox(height: 20),
            Text(
              "Belum Ada Jadwal Posyandu",
              style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Yuk catat jadwal ke Posyandu atau Dokter Anak bulan ini, biar Bunda nggak lupa! 💕",
              textAlign: TextAlign.center,
              style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 80),
      physics: const BouncingScrollPhysics(),
      itemCount: _jadwalList.length,
      itemBuilder: (context, index) {
        final jadwal = _jadwalList[index];
        bool isSelesai = jadwal['is_selesai'] ?? false;
        DateTime tanggal = DateTime.parse(jadwal['tanggal']);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelesai ? Colors.white.withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isSelesai) 
                BoxShadow(color: navyDark.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
            ]
          ),
          child: Row(
            children: [
              // Ikon Kalender Kiri
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelesai ? fieldPink.withOpacity(0.5) : fieldPink,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(DateFormat('dd').format(tanggal), style: TextStyle(color: navyDark, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(DateFormat('MMM').format(tanggal), style: TextStyle(color: navyDark, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              
              // Keterangan Tengah
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jadwal['keterangan'] ?? "Jadwal",
                      style: TextStyle(
                        color: isSelesai ? navyDark.withOpacity(0.5) : navyDark, 
                        fontSize: 15, 
                        fontWeight: FontWeight.bold,
                        decoration: isSelesai ? TextDecoration.lineThrough : null
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isSelesai ? "Sudah Selesai" : "Belum Dilakukan",
                      style: TextStyle(color: isSelesai ? Colors.green : brightPink, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Tombol Checklist Kanan
              if (!isSelesai)
                IconButton(
                  icon: Icon(Icons.check_circle_outline, color: navyDark, size: 28),
                  onPressed: () => _tandaiSelesai(jadwal),
                )
              else
                Icon(Icons.check_circle, color: Colors.green.withOpacity(0.5), size: 28),
            ],
          ),
        );
      },
    );
  }
}