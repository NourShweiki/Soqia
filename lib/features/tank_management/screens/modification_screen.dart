import 'package:flutter/material.dart';
import '../services/tuya_service.dart'; // 💡 Fixed path to go into services folder
import '../models/sensor_model.dart';   // 💡 Fixed path to go into models folder

class ModificationPage extends StatefulWidget {
  const ModificationPage({super.key});

  @override
  State<ModificationPage> createState() => _ModificationPageState();
}

class _ModificationPageState extends State<ModificationPage> {
  final TuyaService _tuya = TuyaService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _isRenaming = false;
  bool _isSettingHeight = false;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // Corresponds to the PUT /v1.0/devices/{id} logic
  Future<void> _handleRename() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isRenaming = true);
    
    try {
      final success = await _tuya.renameDevice(newName); 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? "Device renamed successfully" : "Failed to rename")),
        );
      }
    } finally {
      if (mounted) setState(() => _isRenaming = false);
    }
  }

  // Corresponds to the POST /v1.0/devices/{id}/commands logic
  Future<void> _handleSetHeight() async {
    final height = int.tryParse(_heightController.text);
    if (height == null || height < 100 || height > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a value between 100 and 10000 mm")),
      );
      return;
    }

    setState(() => _isSettingHeight = true);

    try {
      final success = await _tuya.sendDeviceCommand("installation_height", height);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? "Height updated to ${height}mm" : "Failed to update height")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSettingHeight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Matching theme background gradient
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F5FF),
              Color(0xFFF1F9FF),
              Color(0xFFE5F6FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom styled transparent AppBar to preserve gradient canvas look
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2B70D6), size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  "Device Settings",
                  style: TextStyle(
                    color: Color(0xFF2B70D6),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                centerTitle: false,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // White Floating Dashboard Configuration Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Headline Accent
                            Row(
                              children: const [
                                Icon(Icons.tune_rounded, color: Color(0xFF3883FF), size: 22),
                                SizedBox(width: 8),
                                Text(
                                  "Device Management",
                                  style: TextStyle(
                                    color: Color(0xFF2B70D6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFFEDF2F7), thickness: 1.5, height: 24),
                            const SizedBox(height: 12),

                            // Rename Action Input Row Group
                            _buildInputGroup(
                              label: "Change Device Name",
                              controller: _nameController,
                              hint: "New name",
                              buttonLabel: "RENAME",
                              isLoading: _isRenaming,
                              onPressed: _handleRename,
                            ),

                            const SizedBox(height: 32),

                            // Height Settings Input Row Group
                            _buildInputGroup(
                              label: "Installation Height (mm)",
                              controller: _heightController,
                              hint: "e.g., 3000",
                              buttonLabel: "SET HEIGHT",
                              isLoading: _isSettingHeight,
                              onPressed: _handleSetHeight,
                              isNumeric: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String buttonLabel,
    required bool isLoading,
    required VoidCallback onPressed,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Keeps validation errors from misaligning the button layout
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFF00B4DB), width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isLoading ? null : onPressed,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: isLoading 
                        ? [Colors.grey.shade400, Colors.grey.shade400]
                        : [const Color(0xFF3883FF), const Color(0xFF00B4DB)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: isLoading 
                      ? null 
                      : [
                          BoxShadow(
                            color: Color(0xFF00B4DB).withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}