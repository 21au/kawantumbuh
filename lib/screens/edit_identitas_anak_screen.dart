import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditDataAnakScreen extends StatefulWidget {
  const EditDataAnakScreen({super.key});

  @override
  State<EditDataAnakScreen> createState() => _EditDataAnakScreenState();
}

class _EditDataAnakScreenState extends State<EditDataAnakScreen> {
  // --- WARNA ---
  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color oceanBlue = const Color(0xFF1E88B3);
  final Color offWhitePink = const Color(0xFFFFF0F1); 
  final Color lightPinkBg = const Color(0xFFFFC0CB); 
  final Color borderPink = const Color(0xFFF8BBD0);
  final Color iconBgPink = const Color(0xFFF4C2C2);

  // --- STATE ---
  String selectedGender = 'Perempuan';
  String? selectedGolDarah; // Bisa null/kosong
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
              primary: navyBackground, 
              onPrimary: offWhitePink,
              onSurface: navyBackground,
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
      backgroundColor: lightPinkBg,
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
              color: navyBackground,
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
                      Icon(Icons.arrow_back, color: offWhitePink, size: 20),
                      const SizedBox(width: 5),
                      Text("Kembali", style: TextStyle(color: offWhitePink, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text("Data Anak", style: TextStyle(color: offWhitePink, fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Lengkapi identitas si kecil", style: TextStyle(color: offWhitePink.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),

          // --- BODY (FORM) ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navyBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("Simpan Data", style: TextStyle(color: offWhitePink, fontSize: 16, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(color: offWhitePink, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: iconBgPink, shape: BoxShape.circle),
                  child: Icon(icon, color: navyBackground, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Text(title, style: TextStyle(color: navyBackground, fontSize: 16, fontWeight: FontWeight.bold)),
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
          style: TextStyle(color: navyBackground, fontSize: 13, fontWeight: FontWeight.bold),
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
      style: TextStyle(color: navyBackground, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
        filled: true,
        fillColor: offWhitePink,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderPink)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: oceanBlue)),
      ),
    );
  }

  Widget _buildDropdownGolDarah() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: offWhitePink,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderPink),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGolDarah,
          hint: const Text("Pilih Golongan Darah", style: TextStyle(fontSize: 14)),
          isExpanded: true,
          items: golDarahList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: navyBackground)),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? iconBgPink : offWhitePink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? oceanBlue : borderPink),
        ),
        child: Center(child: Text("$emoji $gender", style: TextStyle(color: navyBackground, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
      ),
    );
  }
}