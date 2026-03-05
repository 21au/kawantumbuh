import 'package:flutter/material.dart';
import 'package:kawantumbuh/utils/app_colors.dart';
import 'edit_identitas_anak_screen.dart';
import 'catat_pertumbuhan_screen.dart';

// --- 1. MODEL DATA ---
class ChildData {
  final String name;
  final String birthDate;
  final String age;
  final String weight;
  final String height;
  final String gender;

  ChildData({
    required this.name,
    required this.birthDate,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
  });
}

class AnakScreen extends StatefulWidget {
  const AnakScreen({super.key});

  @override
  State<AnakScreen> createState() => _AnakScreenState();
}

class _AnakScreenState extends State<AnakScreen> {
  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color oceanBlue = const Color(0xFF1E88B3);
  final Color softPinkCard = const Color(0xFFB88E9B);
  final Color offWhitePink = const Color(0xFFFCE8E9);

  bool isBeratBadan = true;
  int selectedIndex = 0;

  final List<ChildData> daftarAnak = [
    ChildData(name: "Fatimah Azzahra", birthDate: "21 Juli 2022", age: "18 Bulan", weight: "10.4 Kg", height: "80 cm", gender: "Perempuan"),
    ChildData(name: "Ahmad Faiz", birthDate: "10 Jan 2024", age: "4 Bulan", weight: "6.2 Kg", height: "65 cm", gender: "Laki-laki"),
  ];

  @override
  Widget build(BuildContext context) {
    if (daftarAnak.isEmpty) {
      return _buildEmptyState();
    }

    final currentChild = daftarAnak[selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.lightPink,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(currentChild),
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildToggleButton("Berat Badan", isBeratBadan)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildToggleButton("Tinggi Badan", !isBeratBadan)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildFauxChartCard(),
                  const SizedBox(height: 15),
                  _buildStatusPertumbuhan(currentChild.name),
                  const SizedBox(height: 15),
                  _buildPrediksiGizi(currentChild),
                  const SizedBox(height: 30),
                  _buildRiwayatHeader(context),
                  const SizedBox(height: 15),
                  _buildRiwayatList(),
                  
                  // 👇 INI PERBAIKANNYA: Ganjalan agar tidak ketutup Navbar
                  const SizedBox(height: 120), 
                ],
              ),
            ),
          ],
        ),
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
            Icon(Icons.child_friendly_rounded, size: 100, color: navyBackground.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text("Belum Ada Data Anak", style: TextStyle(color: navyBackground, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Yuk, tambahkan data si kecil untuk mulai memantau tumbuh kembangnya.", textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: oceanBlue, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: const Text("Tambah Data Anak", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ChildData child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
      decoration: BoxDecoration(
        color: navyBackground,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kesehatan Anak", style: TextStyle(color: offWhitePink, fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("Pantau tumbuh kembang si kecil secara berkala", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          if (daftarAnak.length > 1) ...[
            const SizedBox(height: 20),
            _buildChildSelector(),
          ],
          const SizedBox(height: 25),
          _buildMainCard(child),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daftarAnak.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? oceanBlue : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Text(
                daftarAnak[index].name, 
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                )
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainCard(ChildData child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: softPinkCard, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: AppColors.lightPink, shape: BoxShape.circle), child: Icon(Icons.child_care, color: navyBackground, size: 30)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: TextStyle(color: navyBackground, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${child.gender}, ${child.birthDate}", style: TextStyle(color: navyBackground, fontSize: 13)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditDataAnakScreen())),
                child: Icon(Icons.edit_square, color: navyBackground.withOpacity(0.5)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Divider(color: navyBackground.withOpacity(0.2)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProfileStat("Usia", child.age),
              _buildProfileStat("Berat", child.weight),
              _buildProfileStat("Tinggi", child.height),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrediksiGizi(ChildData child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: offWhitePink, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_outlined, color: Color(0xFFB88E9B), size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Prediksi Status Gizi", style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Berdasarkan data terbaru", style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProfileStat("Usia Anak", child.age),
                    _buildProfileStat("BMI (IMT)", "15.6"),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 15),
                const Text("Status Gizi", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(color: oceanBlue, borderRadius: BorderRadius.circular(10)),
                  child: const Text("Normal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: oceanBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.balance, color: navyBackground, size: 18),
                    const SizedBox(width: 8),
                    const Text("Rekomendasi", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Pertumbuhan anak sangat baik! Terus berikan nutrisi seimbang dan pantau perkembangannya secara rutin.",
                  style: TextStyle(color: navyBackground, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: navyBackground.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: navyBackground, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildToggleButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => isBeratBadan = (title == "Berat Badan")),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? oceanBlue : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: oceanBlue.withOpacity(0.2))
        ),
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(color: isActive ? Colors.white : oceanBlue, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFauxChartCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: offWhitePink, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isBeratBadan ? "Grafik Berat Badan" : "Grafik Tinggi Badan", style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Container(
            height: 150,
            decoration: BoxDecoration(border: Border(left: BorderSide(color: navyBackground.withOpacity(0.2)), bottom: BorderSide(color: navyBackground.withOpacity(0.2)))),
            child: Center(child: Icon(isBeratBadan ? Icons.show_chart : Icons.bar_chart, color: oceanBlue, size: 80)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPertumbuhan(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: oceanBlue, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.check_circle_outline, color: offWhitePink), const SizedBox(width: 10), const Text("Status Pertumbuhan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
          const SizedBox(height: 10),
          Text("Pertumbuhan $name normal dan sesuai kurva WHO.", style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRiwayatHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Riwayat Pengukuran", style: TextStyle(color: navyBackground, fontSize: 18, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CatatPertumbuhanScreen())),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: const Text("Catat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: oceanBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatList() {
    return Column(
      children: [
        _buildRiwayatCard("5 Februari 2026", "10.4 kg", "80 cm"),
        const SizedBox(height: 10),
        _buildRiwayatCard("5 Jan 2026", "10.0 kg", "78 cm"),
      ],
    );
  }

  Widget _buildRiwayatCard(String date, String bb, String tb) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 5),
              Row(children: [
                Text("BB: $bb", style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15),
                Text("TB: $tb", style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold)),
              ])
            ]
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey.withOpacity(0.5), size: 14),
        ],
      ),
    );
  }
}