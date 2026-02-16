import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'analysis_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with AutomaticKeepAliveClientMixin {
  // Portfolio data
  List<Map<String, dynamic>> _holdings = [];
  double _totalValue = 0;
  double _totalGainLoss = 0;
  double _totalGainLossPercent = 0;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);

    try {
      // Simulated portfolio data - in production, this would come from user's saved portfolio
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock portfolio holdings
      final mockHoldings = [
        {
          'code': 'BBCA',
          'name': 'Bank Central Asia',
          'shares': 500,
          'avgPrice': 9500,
          'currentPrice': 9850,
          'sector': 'Finance',
        },
        {
          'code': 'BBRI',
          'name': 'Bank Rakyat Indonesia',
          'shares': 1000,
          'avgPrice': 6000,
          'currentPrice': 6125,
          'sector': 'Finance',
        },
        {
          'code': 'GOTO',
          'name': 'GoTo Tech',
          'shares': 5000,
          'avgPrice': 90,
          'currentPrice': 85,
          'sector': 'Technology',
        },
        {
          'code': 'ADRO',
          'name': 'Adaro Energy',
          'shares': 2000,
          'avgPrice': 2600,
          'currentPrice': 2700,
          'sector': 'Energy',
        },
      ];

      // Calculate portfolio metrics
      double totalValue = 0;
      double totalCost = 0;

      for (var holding in mockHoldings) {
        final shares = (holding['shares'] as num).toDouble();
        final currentPrice = (holding['currentPrice'] as num).toDouble();
        final avgPrice = (holding['avgPrice'] as num).toDouble();

        final currentValue = shares * currentPrice;
        final costBasis = shares * avgPrice;
        holding['currentValue'] = currentValue;
        holding['costBasis'] = costBasis;
        holding['gainLoss'] = currentValue - costBasis;
        holding['gainLossPercent'] =
            ((currentValue - costBasis) / costBasis) * 100;

        totalValue += currentValue;
        totalCost += costBasis;
      }

      if (mounted) {
        setState(() {
          _holdings = mockHoldings;
          _totalValue = totalValue;
          _totalGainLoss = totalValue - totalCost;
          _totalGainLossPercent = ((totalValue - totalCost) / totalCost) * 100;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading portfolio: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refresh() async {
    await _loadPortfolio();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Portfolio',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black26),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // TODO: Add stock to portfolio
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add stock feature coming soon'),
                  backgroundColor: Color(0xFF8A2BE2),
                ),
              );
            },
          ),
        ],
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.cyanAccent),
                )
              : RefreshIndicator(
                  color: Colors.cyanAccent,
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildPortfolioSummary(),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Holdings'),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: _buildHoldingsList(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80), // Space for bottom nav
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    final isPositive = _totalGainLoss >= 0;
    final color = isPositive ? const Color(0xFF39FF14) : Colors.redAccent;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Portfolio Value',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(_totalValue).replaceAll(',', '.'),
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Gain/Loss',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: color,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currencyFormat
                                  .format(_totalGainLoss.abs())
                                  .replaceAll(',', '.'),
                              style: GoogleFonts.robotoMono(
                                color: color,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${_totalGainLossPercent.toStringAsFixed(2)}%',
                        style: GoogleFonts.robotoMono(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '${_holdings.length} stocks',
          style: GoogleFonts.outfit(fontSize: 14, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildHoldingsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final holding = _holdings[index];
        return _buildHoldingCard(holding);
      }, childCount: _holdings.length),
    );
  }

  Widget _buildHoldingCard(Map<String, dynamic> holding) {
    final double gainLoss = holding['gainLoss'] ?? 0.0;
    final double gainLossPercent = holding['gainLossPercent'] ?? 0.0;
    final bool isPositive = gainLoss >= 0;
    final Color trendColor = isPositive
        ? const Color(0xFF39FF14)
        : Colors.redAccent;

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              stockData: {
                'code': holding['code'],
                'name': holding['name'],
                'price': holding['currentPrice'],
                'current_price': holding['currentPrice'],
                'change': gainLossPercent,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Logo
                Container(
                  width: 48,
                  height: 48,
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
                      'asset/logos/${holding['code']}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return CachedNetworkImage(
                          imageUrl:
                              'https://assets.stockbit.com/logos/companies/${holding['code']}.png',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                          ),
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
                                  holding['code']
                                      .toString()
                                      .substring(0, 2)
                                      .toUpperCase(),
                                  style: GoogleFonts.robotoMono(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
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
                const SizedBox(width: 12),

                // Stock info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding['code'],
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${holding['shares']} shares',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Current value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat
                          .format(holding['currentValue'])
                          .replaceAll(',', '.'),
                      style: GoogleFonts.robotoMono(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: trendColor,
                          size: 18,
                        ),
                        Text(
                          '${isPositive ? '+' : ''}${gainLossPercent.toStringAsFixed(2)}%',
                          style: GoogleFonts.robotoMono(
                            color: trendColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 12),

            // Additional details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  'Avg Price',
                  currencyFormat
                      .format(holding['avgPrice'])
                      .replaceAll(',', '.'),
                ),
                _buildDetailItem(
                  'Current',
                  currencyFormat
                      .format(holding['currentPrice'])
                      .replaceAll(',', '.'),
                ),
                _buildDetailItem(
                  'P/L',
                  '${isPositive ? '+' : ''}${currencyFormat.format(gainLoss.abs()).replaceAll(',', '.')}',
                  color: trendColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            color: color ?? Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
