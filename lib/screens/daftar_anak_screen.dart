import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kawantumbuh/utils/app_colors.dart';
import 'anak_screen.dart'; 
import 'tambah_anak_screen.dart'; 

class DaftarAnakScreen extends StatefulWidget {
  const DaftarAnakScreen({super.key});

  @override
  State<DaftarAnakScreen> createState() => _DaftarAnakScreenState();
}

class _DaftarAnakScreenState extends State<DaftarAnakScreen> {
  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color oceanBlue = const Color(0xFF1E88B3);

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
          SnackBar(content: Text("Gagal memuat data: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // 👇 FUNGSI BARU: Menghapus data anak berdasarkan ID
  Future<void> _hapusDataAnak(String idAnak, String namaAnak) async {
    // Memunculkan Pop-up Konfirmasi Dulu
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data Anak"),
        content: Text("Apakah Bunda yakin ingin menghapus data $namaAnak? Data yang dihapus tidak bisa dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Batal
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Yakin hapus
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
            SnackBar(content: Text("Data $namaAnak berhasil dihapus"), backgroundColor: Colors.green),
          );
        }
        _fetchDaftarAnak(); // Refresh daftar anak setelah dihapus
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
          );
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      appBar: AppBar(
        title: const Text("Daftar Anak", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: navyBackground,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) 
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
        backgroundColor: oceanBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Anak", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          Text("Belum ada data anak", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildAnakCard(BuildContext context, Map<String, dynamic> data) {
    // 👇 FIX ERROR: Mengubah angka menjadi string dengan .toString()
    final String id = data['id'].toString(); // Mengambil ID untuk keperluan Hapus
    final String nama = data['nama'] ?? 'Tanpa Nama';
    final String gender = data['jenis_kelamin'] ?? 'Laki-laki';
    final String usia = data['usia'] != null ? "${data['usia'].toString()} Bulan" : '-';
    final String berat = data['berat'] != null ? "${data['berat'].toString()} kg" : '-';
    final String tinggi = data['tinggi'] != null ? "${data['tinggi'].toString()} cm" : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.lightPink,
          child: Icon(
            gender == "Perempuan" ? Icons.face_3 : Icons.face,
            color: navyBackground,
            size: 35,
          ),
        ),
        title: Text(
          nama,
          style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text("$usia • $berat • $tinggi"),
        
        // 👇 UPDATE: Menambahkan Ikon Hapus di samping Ikon Panah
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _hapusDataAnak(id, nama), // Panggil fungsi hapus
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: oceanBlue),
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