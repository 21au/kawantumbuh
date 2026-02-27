import 'package:flutter/material.dart';
import 'package:kawantumbuh/utils/app_colors.dart';
import 'anak_screen.dart'; // Import halaman kesehatan anak

class DaftarAnakScreen extends StatelessWidget {
  const DaftarAnakScreen({super.key});

  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color oceanBlue = const Color(0xFF1E88B3);

  // Simulasi data dari Database (List Map)
  final List<Map<String, dynamic>> listAnak = const [
    {
      "nama": "Fatimah Azzahra",
      "usia": "18 Bulan",
      "berat": "10 kg",
      "tinggi": "80 cm",
      "gender": "Perempuan"
    },
    {
      "nama": "Zaidan Ahmad",
      "usia": "5 Bulan",
      "berat": "6.5 kg",
      "tinggi": "62 cm",
      "gender": "Laki-laki"
    },
  ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: listAnak.length,
        itemBuilder: (context, index) {
          final anak = listAnak[index];
          return _buildAnakCard(context, anak);
        },
      ),
      // Tombol tambah anak jika nanti dibutuhkan
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aksi tambah anak baru
        },
        backgroundColor: oceanBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Anak", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAnakCard(BuildContext context, Map<String, dynamic> data) {
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
            data['gender'] == "Perempuan" ? Icons.face_3 : Icons.face,
            color: navyBackground,
            size: 35,
          ),
        ),
        title: Text(
          data['nama'],
          style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text("${data['usia']} • ${data['berat']} • ${data['tinggi']}"),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: oceanBlue),
        onTap: () {
          // KIRIM DATA KE ANAK_SCREEN
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnakScreen(), 
              // Catatan: Nanti di AnakScreen kamu perlu update Constructor-nya 
              // agar bisa menerima kiriman data: AnakScreen(data: data)
            ),
          );
        },
      ),
    );
  }
}