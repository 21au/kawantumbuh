import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 
import 'catat_pertumbuhan_screen.dart';
// TAMBAHAN: Import notification helper
import '../notification_helper.dart'; 

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

  // --- DIALOG TAMBAH JADWAL ---
  Future<void> _tambahJadwal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
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

    TextEditingController catatanController = TextEditingController();
    
    List<String> pilihanKegiatan = [
      "Timbang & Ukur Rutin",
      "Imunisasi",
      "Pemberian Vitamin A",
      "Obat Cacing",
      "Konsultasi Bidan/Dokter",
      "Lainnya"
    ];
    String kegiatanTerpilih = pilihanKegiatan.first;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: softPink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Detail Jadwal Posyandu", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Agenda Utama", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: kegiatanTerpilih,
                      icon: Icon(Icons.arrow_drop_down, color: navyDark),
                      items: pilihanKegiatan.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: navyDark)));
                      }).toList(),
                      onChanged: (newValue) => setStateDialog(() => kegiatanTerpilih = newValue!),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text("Catatan (Opsional)", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: catatanController,
                  decoration: InputDecoration(
                    hintText: "Cth: Imunisasi DPT / Bawa KIA",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: navyDark.withOpacity(0.6)))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: navyDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  
                  String hasilKeterangan = kegiatanTerpilih;
                  if (catatanController.text.isNotEmpty) hasilKeterangan += " - ${catatanController.text}";

                  try {
                    await Supabase.instance.client.from('jadwal_posyandu').insert({
                      'anak_id': widget.anakId,
                      'tanggal': pickedDate.toIso8601String(),
                      'keterangan': hasilKeterangan,
                      'is_selesai': false,
                    });

                    // --- 1. TES NOTIFIKASI INSTAN (BIAR LANGSUNG BUNYI) ---
                    await NotificationHelper.tampilkanNotifikasiInstan();

                    // --- 2. JADWALKAN ALARM ASLI (H-1 JAM 8 PAGI) ---
                    DateTime waktuNotif = DateTime(
                      pickedDate.year, 
                      pickedDate.month, 
                      pickedDate.day, 
                      8, 0 
                    ).subtract(const Duration(days: 1));

                    // Jika H-1 sudah lewat, set untuk 2 menit lagi sebagai pengingat cadangan
                    if (waktuNotif.isBefore(DateTime.now())) {
                      waktuNotif = DateTime.now().add(const Duration(minutes: 2));
                    }

                    int notifId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

                    await NotificationHelper.scheduleNotification(
                      id: notifId,
                      title: "Pengingat Posyandu! 🗓️",
                      body: "Besok ada jadwal $hasilKeterangan untuk ${widget.namaAnak}.",
                      scheduledDate: waktuNotif,
                    );

                    _fetchJadwal();
                  } catch (e) {
                    debugPrint("Error simpan jadwal: $e");
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _tandaiSelesai(Map<String, dynamic> jadwal) async {
    try {
      await Supabase.instance.client.from('jadwal_posyandu').update({'is_selesai': true}).eq('id', jadwal['id']);
      _fetchJadwal();

      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: softPink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration, color: brightPink, size: 60),
              const SizedBox(height: 15),
              Text("Hore! Jadwal Selesai 🎉", style: TextStyle(color: navyDark, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Yuk langsung masukkan data pertumbuhan si Kecil!", 
                textAlign: TextAlign.center, 
                style: TextStyle(color: navyDark.withOpacity(0.8), height: 1.5)
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Nanti Saja", style: TextStyle(color: navyDark.withOpacity(0.6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: navyDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => CatatPertumbuhanScreen(anakId: widget.anakId)));
              },
              child: const Text("Input Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _konfirmasiHapus(dynamic idJadwal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: softPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Hapus Jadwal?", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
        content: Text("Jadwal tidak bisa dikembalikan ya, Bunda.", style: TextStyle(color: navyDark)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: navyDark.withOpacity(0.6)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await Supabase.instance.client.from('jadwal_posyandu').delete().eq('id', idJadwal);
                _fetchJadwal();
              } catch (e) {
                debugPrint("Error: $e");
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            Text("Belum Ada Jadwal", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Yuk catat jadwal ke Posyandu atau Dokter Anak! 💕", textAlign: TextAlign.center, style: TextStyle(color: navyDark.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 80),
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
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: fieldPink,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jadwal['keterangan'] ?? "Jadwal",
                      style: TextStyle(
                        color: navyDark, 
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
              if (!isSelesai)
                IconButton(
                  icon: Icon(Icons.check_circle_outline, color: navyDark, size: 28),
                  onPressed: () => _tandaiSelesai(jadwal),
                )
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _konfirmasiHapus(jadwal['id']),
                ),
            ],
          ),
        );
      },
    );
  }
}