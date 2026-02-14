import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class MSCIRebalancingScreen extends StatefulWidget {
  const MSCIRebalancingScreen({super.key});

  @override
  State<MSCIRebalancingScreen> createState() => _MSCIRebalancingScreenState();
}

class _MSCIRebalancingScreenState extends State<MSCIRebalancingScreen> {
  int _selectedYear = DateTime.now().year;

  // MSCI Rebalancing Data
  final Map<int, Map<String, Map<String, String>>> _rebalancingData = {
    2025: {
      'May': {
        'announcement': 'Mid-May 2025 (approx. May 12)',
        'effective': 'June 1, 2025',
        'cutoff': 'Late April 2025',
        'status': 'Upcoming',
      },
      'November': {
        'announcement': 'Early November 2025 (approx. Nov 10)',
        'effective': 'December 1, 2025',
        'cutoff': 'Late October 2025',
        'status': 'Upcoming',
      },
    },
    2026: {
      'May': {
        'announcement': 'Mid-May 2026 (approx. May 12)',
        'effective': 'June 1, 2026',
        'cutoff': 'Late April 2026',
        'status': 'Projected',
      },
      'November': {
        'announcement': 'Early November 2026 (approx. Nov 10)',
        'effective': 'December 1, 2026',
        'cutoff': 'Late October 2026',
        'status': 'Projected',
      },
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'MSCI Rebalancing Schedule',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0A2E), Color(0xFF0A0214)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Year Selector
              _buildYearSelector(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildKeyDefinitions(),
                    const SizedBox(height: 20),
                    if (_rebalancingData.containsKey(_selectedYear)) ...[
                      _buildReviewCard('May', _rebalancingData[_selectedYear]!['May']!),
                      const SizedBox(height: 16),
                      _buildReviewCard('November', _rebalancingData[_selectedYear]!['November']!),
                    ],
                    const SizedBox(height: 20),
                    _buildContextCard(),
                    const SizedBox(height: 20),
                    _buildStrategyTips(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    final availableYears = [currentYear, currentYear + 1];
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: availableYears.map((year) {
          final isSelected = _selectedYear == year;
          return GestureDetector(
            onTap: () => setState(() => _selectedYear = year),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC800FF).withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFC800FF)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                year.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFFC800FF)
                      : Colors.white70,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFC800FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC800FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFC800FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFC800FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MSCI Index Rebalancing',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'MSCI melakukan rebalancing indeks dua kali setahun pada bulan Mei dan November. '
            'Perubahan ini mempengaruhi alokasi dana asing yang sangat besar ke saham-saham Indonesia.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyDefinitions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEFINISI PENTING',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC800FF),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildDefinitionItem(
            'Announcement Date',
            'Tanggal ketika MSCI secara publik merilis daftar penambahan, penghapusan, dan perubahan bobot saham dalam indeks.',
            Icons.campaign_rounded,
          ),
          const SizedBox(height: 12),
          _buildDefinitionItem(
            'Effective Date (Implementation)',
            'Tanggal ketika perubahan benar-benar berlaku dalam indeks. Rebalancing biasanya terjadi pada penutupan hari kerja terakhir bulan sebelum effective date.',
            Icons.event_available_rounded,
          ),
          const SizedBox(height: 12),
          _buildDefinitionItem(
            'Cut-off Date',
            'Biasanya terjadi dalam 10 hari kerja terakhir bulan sebelum pengumuman (misalnya akhir April untuk review Mei).',
            Icons.calendar_today_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.cyanAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String month, Map<String, String> data) {
    final isUpcoming = data['status'] == 'Upcoming';
    final statusColor = isUpcoming ? Colors.orangeAccent : Colors.cyanAccent;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$month ${_selectedYear} Semi-Annual Index Review',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data['status']!.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDateRow('📢 Announcement Date', data['announcement']!, Colors.cyanAccent),
          const SizedBox(height: 12),
          _buildDateRow('✅ Effective Date', data['effective']!, const Color(0xFF39FF14)),
          const SizedBox(height: 12),
          _buildDateRow('📅 Cut-off Date', data['cutoff']!, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String date, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            date,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContextCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF39FF14),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'KONTEKS MSCI INDONESIA',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF39FF14),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pada review November 2024, terjadi pergeseran signifikan dalam MSCI Indonesia Index, '
            'termasuk penambahan/penghapusan saham large-cap tertentu (misalnya perubahan yang melibatkan TPIA, BRPT, dll, '
            'tergantung periode review spesifik).',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Investor biasanya memantau review Mei dan November lebih ketat karena melibatkan rebalancing '
            'yang lebih luas di seluruh Global Standard Indices.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC800FF).withValues(alpha: 0.1),
            Colors.cyanAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC800FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFC800FF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'TIPS & STRATEGI',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC800FF),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('1. Pantau pengumuman rebalancing dengan ketat'),
          _buildTipItem('2. Masuk sebelum dana asing melakukan eksekusi beli di penutupan pasar'),
          _buildTipItem('3. Saham yang masuk MSCI akan dibeli masif oleh dana asing'),
          _buildTipItem('4. Perhatikan cut-off date untuk mempersiapkan posisi'),
          _buildTipItem('5. Verifikasi tanggal tepat di halaman MSCI Index Review setelah koneksi teknis pulih'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFC800FF),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
