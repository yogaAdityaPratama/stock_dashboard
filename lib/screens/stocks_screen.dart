import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import 'analysis_screen.dart';
import 'dart:ui';
import 'dart:async';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  Map<String, List<dynamic>> _sectors = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSector = 'All Sectors';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAllStocks();
  }

  @override
  void didUpdateWidget(StocksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure data reloads when widget updates
    if (_sectors.isEmpty && !_isLoading) {
      _loadAllStocks();
    }
  }

  Future<void> _loadAllStocks({bool forceLive = false}) async {
    // Try to fetch live sectors but fail fast (client-side timeout) to avoid long spinner.
    setState(() => _isLoading = true);

    try {
      // Short timeout for immediate UI responsiveness
      final data = await _apiService.fetchSectors().timeout(
        const Duration(seconds: 5),
      );

      if (mounted && data['sectors'] != null) {
        setState(() {
          _sectors = Map<String, List<dynamic>>.from(data['sectors']);
          _isLoading = false;
        });
        return;
      }
    } on TimeoutException {
      // Use local fallback immediately, then continue fetching live in background
      if (mounted) {
        setState(() {
          _sectors =
              _localSectorFallback()['sectors'] as Map<String, List<dynamic>>;
          _isLoading = false;
        });
      }

      // Background fetch (no timeout) to update UI when ready
      _apiService
          .fetchSectors()
          .then((data) {
            if (mounted && data['sectors'] != null) {
              setState(() {
                _sectors = Map<String, List<dynamic>>.from(data['sectors']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live market data loaded')),
              );
            }
          })
          .catchError((e) {
            debugPrint('Background sector fetch failed: $e');
          });

      return;
    } catch (e) {
      // Other errors: show local fallback
      if (mounted) {
        setState(() {
          _sectors =
              _localSectorFallback()['sectors'] as Map<String, List<dynamic>>;
          _isLoading = false;
        });
      }
      return;
    }

    // If we reach here and didn't return, try to parse any response
    try {
      final data = await _apiService.fetchSectors();
      if (mounted && data['sectors'] != null) {
        setState(() {
          _sectors = Map<String, List<dynamic>>.from(data['sectors']);
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _sectors =
              _localSectorFallback()['sectors'] as Map<String, List<dynamic>>;
        });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await _loadAllStocks(forceLive: true);
  }

  Map<String, dynamic> _localSectorFallback() {
    return {
      'sectors': {
        'Finance': [
          {
            'code': 'BBCA',
            'name': 'Bank Central Asia',
            'price': 9850,
            'change': 1.2,
          },
          {
            'code': 'BBRI',
            'name': 'Bank Rakyat Indonesia',
            'price': 6125,
            'change': 0.8,
          },
          {
            'code': 'BMRI',
            'name': 'Bank Mandiri',
            'price': 7200,
            'change': -0.5,
          },
          {
            'code': 'BBNI',
            'name': 'Bank Negara Indonesia',
            'price': 5450,
            'change': 0.3,
          },
        ],
        'Technology': [
          {'code': 'GOTO', 'name': 'GoTo Tech', 'price': 85, 'change': -1.4},
          {'code': 'BUKA', 'name': 'Bukalapak', 'price': 92, 'change': 2.1},
        ],
        'Energy': [
          {
            'code': 'ADRO',
            'name': 'Adaro Energy',
            'price': 2700,
            'change': 3.5,
          },
          {
            'code': 'PGAS',
            'name': 'Perusahaan Gas Negara',
            'price': 1580,
            'change': 1.2,
          },
        ],
      },
      'total_count': 9,
      'sector_count': 3,
      'status': 'fallback',
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Calculate total stock count
    int totalStocks = 0;
    _sectors.forEach((_, stocks) => totalStocks += stocks.length);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Indonesian Stocks',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${NumberFormat('#,###', 'id_ID').format(totalStocks).replaceAll(',', '.')}+',
                style: GoogleFonts.robotoMono(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black26),
          ),
        ),
      ),
      body: Container(
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
              _buildFilterBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.cyanAccent,
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.cyanAccent,
                        onRefresh: _refresh,
                        child: _buildSectorList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search stocks...',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white54,
                  size: 18,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Sector Dropdown
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSector,
                  dropdownColor: const Color(0xFF1A0A2E),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.cyanAccent,
                    size: 20,
                  ),
                  isExpanded: true,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                  items: ['All Sectors', ..._sectors.keys].map((String sector) {
                    return DropdownMenuItem<String>(
                      value: sector,
                      child: Text(sector, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedSector = newValue);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorList() {
    final filteredSectors = <String, List<dynamic>>{};
    _sectors.forEach((sector, stocks) {
      // Apply Sector Filter
      if (_selectedSector != 'All Sectors' && sector != _selectedSector) return;

      final filteredStocks = stocks.where((stock) {
        final code = stock['code'].toString().toLowerCase();
        final name = stock['name'].toString().toLowerCase();
        return code.contains(_searchQuery.toLowerCase()) ||
            name.contains(_searchQuery.toLowerCase());
      }).toList();
      if (filteredStocks.isNotEmpty) {
        filteredSectors[sector] = filteredStocks;
      }
    });

    if (filteredSectors.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(
        child: Text('No stocks found', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredSectors.keys.length,
      itemBuilder: (context, index) {
        final sectorName = filteredSectors.keys.elementAt(index);
        final stocks = filteredSectors[sectorName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyanAccent.withValues(alpha: 0.08),
                    Colors.cyanAccent.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.cyanAccent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sectorName.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${stocks.length}',
                      style: GoogleFonts.robotoMono(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...stocks.map((stock) => _buildStockTile(stock)).toList(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildStockTile(dynamic stock) {
    final double change = (stock['change'] as num?)?.toDouble() ?? 0.0;
    final bool isPositive = change >= 0;
    final Color trendColor = isPositive
        ? const Color(0xFF39FF14)
        : Colors.redAccent;

    // Format price with thousand separator WITHOUT decimal (Indonesian style: 4.650)
    final NumberFormat priceFormatter = NumberFormat('#,##0', 'id_ID');
    final double price = (stock['price'] as num?)?.toDouble() ?? 0.0;
    final String formattedPrice = priceFormatter
        .format(price)
        .replaceAll(',', '.');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              stockData: {
                'code': stock['code'],
                'name': stock['name'],
                'price': stock['price'],
                'current_price': stock['price'] ?? 0,
                'change': stock['change'],
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.06),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Side: Ticker and Name
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock['code'],
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stock['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Center-Right: Price and Change
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp $formattedPrice',
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        color: trendColor,
                        size: 18,
                      ),
                      Text(
                        '${change.toStringAsFixed(2)}%',
                        style: GoogleFonts.robotoMono(
                          color: trendColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Far Right: Company Logo
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'asset/logos/${stock['code']}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, assetError, assetStack) {
                    return CachedNetworkImage(
                      imageUrl:
                          'https://assets.stockbit.com/logos/companies/${stock['code']}.png',
                      fit: BoxFit.cover,
                      // Placeholder for loading state (small spinner)
                      placeholder: (context, url) => Container(
                        color: Colors.white.withValues(alpha: 0.05),
                        child: const Center(
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                      ),
                      // Fallback to text if network image fails
                      errorWidget: (context, url, error) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                trendColor.withValues(alpha: 0.2),
                                trendColor.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              stock['code']
                                  .toString()
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style: GoogleFonts.robotoMono(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
