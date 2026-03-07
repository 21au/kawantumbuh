import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditDataAnakScreen extends StatefulWidget {
  const EditDataAnakScreen({super.key});

  @override
  State<EditDataAnakScreen> createState() => _EditDataAnakScreenState();
}

class _EditDataAnakScreenState extends State<EditDataAnakScreen> {
  // --- PALET WARNA BARU SESUAI TEMA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA); 
  final Color highlightPink = const Color(0xFFD6B5B5); // Dusty pink untuk aksen
  final Color whiteCard = Colors.white; // Biar formnya bersih dan menonjol

  // --- STATE ---
  String selectedGender = 'Perempuan';
  String? selectedGolDarah; 
  final TextEditingController _dateController = TextEditingController();
  
  final List<String> golDarahList = ['A', 'B', 'AB', 'O', 'Belum Tahu'];

  // Fungsi Kalender
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyDark, // Warna header kalender
              onPrimary: Colors.white, // Warna teks di header
              onSurface: navyDark, // Warna teks tanggal
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink, // Background utama soft pink
      body: Column(
        children: [
          // --- HEADER ANTI OVERFLOW ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, 
              left: 20, right: 20, bottom: 25
            ),
            decoration: BoxDecoration(
              color: navyDark,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      const SizedBox(width: 5),
                      const Text("Kembali", style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Text("Data Anak", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Lengkapi identitas si kecil", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),

          // --- BODY (FORM) ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // CARD 1: IDENTITAS ANAK
                  _buildSectionCard(
                    icon: Icons.child_care,
                    title: "Identitas Anak",
                    children: [
                      _buildLabel("Nama Lengkap Anak", isRequired: true),
                      _buildTextField(hint: "Contoh: Aisyah Putri"),
                      const SizedBox(height: 15),
                      
                      _buildLabel("Jenis Kelamin", isRequired: true),
                      _buildGenderSelector(),
                      const SizedBox(height: 15),
                      
                      _buildLabel("Tanggal Lahir", isRequired: true),
                      _buildTextField(
                        hint: "Pilih Tanggal", 
                        icon: Icons.calendar_today, 
                        readOnly: true,
                        controller: _dateController,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 15),
                      
                      _buildLabel("Tempat Lahir"),
                      _buildTextField(hint: "Contoh: Jakarta", icon: Icons.location_on_outlined),
                      const SizedBox(height: 15),
                      
                      _buildLabel("Golongan Darah (Opsional)"),
                      _buildDropdownGolDarah(),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // CARD 2: DATA ORANG TUA
                  _buildSectionCard(
                    icon: Icons.favorite_border,
                    title: "Data Orang Tua",
                    children: [
                      _buildLabel("Nama Ibu", isRequired: true),
                      _buildTextField(hint: "Nama lengkap ibu", icon: Icons.person_outline),
                      const SizedBox(height: 15),
                      _buildLabel("Nama Ayah"),
                      _buildTextField(hint: "Nama lengkap ayah", icon: Icons.person_outline),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // CARD 3: KONTAK
                  _buildSectionCard(
                    icon: Icons.call_outlined,
                    title: "Kontak",
                    children: [
                      _buildLabel("Alamat Lengkap"),
                      _buildTextField(hint: "Jalan, RT/RW, Kecamatan", maxLines: 2),
                      const SizedBox(height: 15),
                      _buildLabel("Nomor Telepon"),
                      _buildTextField(hint: "08xx xxxx xxxx", icon: Icons.call_outlined, keyboardType: TextInputType.phone),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // TOMBOL SIMPAN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navyDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: navyDark.withOpacity(0.3),
                      ),
                      child: const Text("Simpan Data", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionCard({IconData? icon, required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteCard, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: navyDark.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: softPink, shape: BoxShape.circle),
                  child: Icon(icon, color: navyDark, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Text(title, style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(color: navyDark, fontSize: 13, fontWeight: FontWeight.bold),
          children: [if (isRequired) const TextSpan(text: " *", style: TextStyle(color: Colors.redAccent))],
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, IconData? icon, bool readOnly = false, int maxLines = 1, TextInputType keyboardType = TextInputType.text, TextEditingController? controller, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: navyDark, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: navyDark.withOpacity(0.4)),
        prefixIcon: icon != null ? Icon(icon, color: navyDark.withOpacity(0.5), size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: highlightPink.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: navyDark, width: 1.5)),
      ),
    );
  }

  Widget _buildDropdownGolDarah() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlightPink.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGolDarah,
          hint: Text("Pilih Golongan Darah", style: TextStyle(fontSize: 14, color: navyDark.withOpacity(0.4))),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: navyDark),
          items: golDarahList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: navyDark)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedGolDarah = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(child: _buildGenderBtn("Perempuan", "👧")),
        const SizedBox(width: 15),
        Expanded(child: _buildGenderBtn("Laki-laki", "👦")),
      ],
    );
  }

  Widget _buildGenderBtn(String gender, String emoji) {
    bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? highlightPink : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? navyDark : highlightPink.withOpacity(0.5), width: isSelected ? 1.5 : 1),
        ),
        child: Center(
          child: Text(
            "$emoji $gender", 
            style: TextStyle(
              color: navyDark, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            )
          )
        ),
      ),
    );
  }
}