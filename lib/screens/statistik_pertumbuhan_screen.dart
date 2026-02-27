import 'package:flutter/material.dart';
import 'package:kawantumbuh/utils/app_colors.dart';

class StatistikPertumbuhanScreen extends StatelessWidget {
  const StatistikPertumbuhanScreen({super.key});

  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color oceanBlue = const Color(0xFF1E88B3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      appBar: AppBar(
        title: const Text("Statistik Pertumbuhan", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: navyBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildChartPlaceholder("Grafik Berat Badan (Kg)"),
            const SizedBox(height: 20),
            _buildChartPlaceholder("Grafik Tinggi Badan (Cm)"),
            const SizedBox(height: 30),
            _buildSummaryBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: oceanBlue),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Grafik di bawah menunjukkan tren pertumbuhan Fatimah dalam 6 bulan terakhir.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: navyBackground)),
          const SizedBox(height: 20),
          // Nanti di sini tempat menaruh library grafik seperti fl_chart
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: oceanBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.stacked_line_chart, size: 50, color: oceanBlue.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: oceanBlue, borderRadius: BorderRadius.circular(20)),
      child: const Column(
        children: [
          Text("Kesimpulan Bulan Ini", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
            "Kenaikan berat badan Fatimah stabil dan berada pada jalur hijau kurva pertumbuhan WHO.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}