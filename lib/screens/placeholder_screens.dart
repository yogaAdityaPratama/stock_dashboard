import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text(
          'Community Feed Coming Soon',
          style: GoogleFonts.outfit(color: Colors.white54),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _portfolioController = TextEditingController(
    text: '1250500000',
  );
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    // Format currency for display
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0A2E), Color(0xFF0A0214)],
          ),
        ),
        child: Column(
          children: [
            // User Avatar & Info
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFC800FF),
              child: Icon(Icons.person_rounded, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Investor Class A',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Premium Member',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.yellowAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),

            // Portfolio Value Input Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Portfolio Value',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        icon: Icon(
                          _isEditing
                              ? Icons.check_circle_rounded
                              : Icons.edit_rounded,
                          color: _isEditing
                              ? Colors.greenAccent
                              : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isEditing)
                    TextField(
                      controller: _portfolioController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                    )
                  else
                    Text(
                      currencyFormatter.format(
                        double.tryParse(_portfolioController.text) ?? 0,
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Digunakan untuk kalkulasi Money Management',
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // Add more profile settings here...
          ],
        ),
      ),
    );
  }
}
