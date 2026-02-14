import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class FinancialCalendarScreen extends StatefulWidget {
  const FinancialCalendarScreen({super.key});

  @override
  State<FinancialCalendarScreen> createState() => _FinancialCalendarScreenState();
}

class _FinancialCalendarScreenState extends State<FinancialCalendarScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'RUPS', 'Dividen', 'FOMC', 'Fed', 'Lainnya'];

  // Sample calendar events - in production, this would come from an API
  final List<Map<String, dynamic>> _calendarEvents = [
    // RUPS Events
    {
      'title': 'RUPS Tahunan - BBCA',
      'date': DateTime(2025, 3, 15),
      'category': 'RUPS',
      'description': 'Rapat Umum Pemegang Saham Tahunan Bank Central Asia',
      'type': 'RUPS',
      'importance': 'High',
    },
    {
      'title': 'RUPS Luar Biasa - GOTO',
      'date': DateTime(2025, 3, 22),
      'category': 'RUPS',
      'description': 'RUPS Luar Biasa untuk persetujuan aksi korporasi',
      'type': 'RUPS',
      'importance': 'Medium',
    },
    {
      'title': 'RUPS Tahunan - BBRI',
      'date': DateTime(2025, 4, 10),
      'category': 'RUPS',
      'description': 'Rapat Umum Pemegang Saham Tahunan Bank Rakyat Indonesia',
      'type': 'RUPS',
      'importance': 'High',
    },
    // Dividend Events
    {
      'title': 'Cum Date Dividen - BBCA',
      'date': DateTime(2025, 3, 20),
      'category': 'Dividen',
      'description': 'Cum Date untuk dividen interim Q1 2025',
      'type': 'Dividen',
      'importance': 'High',
    },
    {
      'title': 'Ex Date Dividen - BMRI',
      'date': DateTime(2025, 3, 25),
      'category': 'Dividen',
      'description': 'Ex Date untuk dividen tunai',
      'type': 'Dividen',
      'importance': 'High',
    },
    {
      'title': 'Pembayaran Dividen - ASII',
      'date': DateTime(2025, 4, 5),
      'category': 'Dividen',
      'description': 'Pembayaran dividen tahunan 2024',
      'type': 'Dividen',
      'importance': 'Medium',
    },
    // FOMC Events
    {
      'title': 'FOMC Meeting',
      'date': DateTime(2025, 3, 19),
      'category': 'FOMC',
      'description': 'Federal Open Market Committee Meeting - Pengumuman suku bunga',
      'type': 'FOMC',
      'importance': 'High',
    },
    {
      'title': 'FOMC Meeting',
      'date': DateTime(2025, 5, 1),
      'category': 'FOMC',
      'description': 'Federal Open Market Committee Meeting',
      'type': 'FOMC',
      'importance': 'High',
    },
    {
      'title': 'FOMC Meeting',
      'date': DateTime(2025, 6, 18),
      'category': 'FOMC',
      'description': 'Federal Open Market Committee Meeting',
      'type': 'FOMC',
      'importance': 'High',
    },
    // Fed Announcements
    {
      'title': 'Fed Chair Speech',
      'date': DateTime(2025, 3, 28),
      'category': 'Fed',
      'description': 'Pidato Ketua Federal Reserve tentang kebijakan moneter',
      'type': 'Fed',
      'importance': 'High',
    },
    {
      'title': 'Fed Minutes Release',
      'date': DateTime(2025, 4, 10),
      'category': 'Fed',
      'description': 'Rilis notulen rapat FOMC sebelumnya',
      'type': 'Fed',
      'importance': 'Medium',
    },
    {
      'title': 'Fed Economic Projections',
      'date': DateTime(2025, 6, 18),
      'category': 'Fed',
      'description': 'Proyeksi ekonomi dan suku bunga jangka panjang',
      'type': 'Fed',
      'importance': 'High',
    },
    // Other Events
    {
      'title': 'Laporan Keuangan Q1 2025',
      'date': DateTime(2025, 4, 30),
      'category': 'Lainnya',
      'description': 'Batas waktu pengumuman laporan keuangan Q1 2025',
      'type': 'Lainnya',
      'importance': 'High',
    },
    {
      'title': 'IDX Trading Holiday',
      'date': DateTime(2025, 4, 21),
      'category': 'Lainnya',
      'description': 'Hari libur perdagangan - Hari Raya Idul Fitri',
      'type': 'Lainnya',
      'importance': 'Medium',
    },
    {
      'title': 'IPO - Saham Baru',
      'date': DateTime(2025, 5, 15),
      'category': 'Lainnya',
      'description': 'Penawaran Umum Perdana saham baru',
      'type': 'Lainnya',
      'importance': 'Medium',
    },
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedCategory == 'All') {
      return _calendarEvents;
    }
    return _calendarEvents.where((event) => event['category'] == _selectedCategory).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedEvents {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var event in _filteredEvents) {
      final monthKey = DateFormat('MMMM yyyy').format(event['date']);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(event);
    }
    // Sort events within each month
    grouped.forEach((key, value) {
      value.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    });
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Kalender Finance',
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
              _buildCategoryFilter(),
              Expanded(
                child: _filteredEvents.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: _buildEventList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC800FF).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFC800FF)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFFC800FF)
                        : Colors.white70,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildEventList() {
    final grouped = _groupedEvents;
    final sortedMonths = grouped.keys.toList()..sort((a, b) {
      final dateA = DateFormat('MMMM yyyy').parse(a);
      final dateB = DateFormat('MMMM yyyy').parse(b);
      return dateA.compareTo(dateB);
    });

    return sortedMonths.map((month) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Text(
              month.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC800FF),
                letterSpacing: 1.5,
              ),
            ),
          ),
          ...grouped[month]!.map((event) => _buildEventCard(event)),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final date = event['date'] as DateTime;
    final isPast = date.isBefore(DateTime.now());
    final categoryColor = _getCategoryColor(event['category']);
    final importance = event['importance'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPast
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast
              ? Colors.white.withValues(alpha: 0.05)
              : categoryColor.withValues(alpha: 0.3),
          width: isPast ? 1 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Column
          Container(
            width: 60,
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(date),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPast ? Colors.white38 : categoryColor,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date).toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEE').format(date).toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event['category'],
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    if (importance == 'High') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HIGH',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                    if (isPast) ...[
                      const Spacer(),
                      Text(
                        'SELESAI',
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          color: Colors.white24,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event['title'],
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isPast ? Colors.white54 : Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event['description'],
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white60,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            _getCategoryIcon(event['category']),
            color: categoryColor.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'RUPS':
        return Colors.cyanAccent;
      case 'Dividen':
        return const Color(0xFF39FF14);
      case 'FOMC':
        return Colors.orangeAccent;
      case 'Fed':
        return Colors.redAccent;
      case 'Lainnya':
        return const Color(0xFFC800FF);
      default:
        return Colors.white;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'RUPS':
        return Icons.groups_rounded;
      case 'Dividen':
        return Icons.account_balance_wallet_rounded;
      case 'FOMC':
        return Icons.trending_up_rounded;
      case 'Fed':
        return Icons.account_balance_rounded;
      case 'Lainnya':
        return Icons.event_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada event untuk kategori ini',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
