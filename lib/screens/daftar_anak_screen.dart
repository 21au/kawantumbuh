import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:kawantumbuh/utils/app_colors.dart'; // Boleh di-comment karena kita pakai warna lokal
import 'anak_screen.dart'; 
import 'tambah_anak_screen.dart'; 

class DaftarAnakScreen extends StatefulWidget {
  const DaftarAnakScreen({super.key});

  @override
  State<DaftarAnakScreen> createState() => _DaftarAnakScreenState();
}

class _DaftarAnakScreenState extends State<DaftarAnakScreen> {
  // --- PALET WARNA UTAMA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);      
  final Color softPink = const Color(0xFFFFEAEA);      
  final Color fieldPink = const Color(0xFFF5CBCB);     
  final Color highlightPink = const Color(0xFFEBA9A9); 

  List<Map<String, dynamic>> daftarAnak = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDaftarAnak(); 
  }

  // Fungsi untuk mengambil data anak dari Supabase
  Future<void> _fetchDaftarAnak() async {
    setState(() => isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('anak')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: true);

        setState(() {
          daftarAnak = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e"), backgroundColor: Colors.red[400]),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // FUNGSI BARU: Menghapus data anak berdasarkan ID
  Future<void> _hapusDataAnak(String idAnak, String namaAnak) async {
    // Memunculkan Pop-up Konfirmasi Dulu
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: softPink, // Tema warna senada
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Hapus Data Anak", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
        content: Text(
          "Apakah Bunda yakin ingin menghapus data $namaAnak? Data yang dihapus tidak bisa dikembalikan.",
          style: TextStyle(color: navyDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Batal
            child: Text("Batal", style: TextStyle(color: navyDark.withOpacity(0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Yakin hapus
            child: Text("Hapus", style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    // Jika pilih 'Hapus', proses hapus ke Supabase
    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        await Supabase.instance.client.from('anak').delete().eq('id', idAnak);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data $namaAnak berhasil dihapus"), backgroundColor: navyDark),
          );
        }
        _fetchDaftarAnak(); // Refresh daftar anak setelah dihapus
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red[400]),
          );
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink, // Background layar
      appBar: AppBar(
        title: Text("Daftar Anak", style: TextStyle(color: softPink, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: navyDark, // Warna header
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: softPink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: navyDark)) 
          : daftarAnak.isEmpty
              ? _buildEmptyState() 
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: daftarAnak.length,
                  itemBuilder: (context, index) {
                    final anak = daftarAnak[index];
                    return _buildAnakCard(context, anak);
                  },
                ),
                
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahAnakScreen()),
          );
          _fetchDaftarAnak(); // Refresh otomatis jika kembali dari layar tambah
        },
        backgroundColor: navyDark, // Warna tombol FAB
        icon: Icon(Icons.add_reaction_outlined, color: softPink),
        label: Text("Tambah Anak", style: TextStyle(color: softPink, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care_rounded, size: 80, color: highlightPink),
          const SizedBox(height: 15),
          Text("Belum ada data anak, Bunda.", style: TextStyle(fontSize: 16, color: navyDark.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildAnakCard(BuildContext context, Map<String, dynamic> data) {
    final String id = data['id'].toString(); 
    final String nama = data['nama'] ?? 'Tanpa Nama';
    final String gender = data['jenis_kelamin'] ?? 'Laki-laki';
    final String usia = data['usia'] != null ? "${data['usia'].toString()} Bulan" : '-';
    final String berat = data['berat'] != null ? "${data['berat'].toString()} kg" : '-';
    final String tinggi = data['tinggi'] != null ? "${data['tinggi'].toString()} cm" : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: fieldPink.withOpacity(0.5), // Warna background card senada dengan menu profile
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: navyDark, borderRadius: BorderRadius.circular(15)),
          child: Icon(
            gender == "Perempuan" ? Icons.face_3_rounded : Icons.face_rounded,
            color: softPink,
            size: 30,
          ),
        ),
        title: Text(
          nama,
          style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "$usia • $berat • $tinggi", 
            style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 13)
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400]),
              onPressed: () => _hapusDataAnak(id, nama), 
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: navyDark),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnakScreen(), 
            ),
          );
        },
      ),
    );
  }
}