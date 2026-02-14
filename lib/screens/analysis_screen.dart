import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/trading_view_chart.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================================
/// ANALYSIS SCREEN - CORE MODULE
/// ============================================================================
///
/// Deskripsi:
/// Halaman ini bertanggung jawab untuk menampilkan analisis mendalam terhadap
/// saham spesifik. Mengintegrasikan data realtime dari TradingView dan
/// intelegensi buatan (AI) untuk mendeteksi flow broker dan corporate action.
///
/// Arsitektur:
/// - State Management: StatefulWidget (Local State)
/// - UI Pattern: Component-Based with Glassmorphism
/// - Integration: TradingView Widget (WebView)
///
/// Author: Senior Stock Programmer
/// ============================================================================

class AnalysisScreen extends StatefulWidget {
  /// Data saham yang dipassing dari parent screen
  final Map<String, dynamic> stockData;

  const AnalysisScreen({super.key, required this.stockData});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ApiService _apiService = ApiService();
  double? _livePrice;
  double? _liveChange;
  double? _liveChangePercent;
  bool _isLiveLoading = false;
  Map<String, dynamic>? _dynamicAnalysis;
  bool _isAnalysisLoading = false;
  Map<String, dynamic>? _dynamicNews;
  bool _isNewsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRealTimePrice();
    _fetchDynamicAnalysis();
    _fetchDynamicNews();
  }

  Future<void> _fetchDynamicNews() async {
    if (!mounted) return;
    setState(() => _isNewsLoading = true);
    try {
      final data = await _apiService.getStockNews(widget.stockData['code']);
      if (mounted) {
        setState(() {
          if (data.isNotEmpty) {
            _dynamicNews = data;
          }
          _isNewsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dynamic news: $e');
      if (mounted) setState(() => _isNewsLoading = false);
    }
  }

  Future<void> _fetchDynamicAnalysis() async {
    if (!mounted) return;
    setState(() => _isAnalysisLoading = true);
    try {
      final data = await _apiService.getFullAnalysis(widget.stockData['code']);
      if (mounted) {
        setState(() {
          if (data.isNotEmpty) {
            _dynamicAnalysis = data;
          }
          _isAnalysisLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dynamic analysis: $e');
      if (mounted) setState(() => _isAnalysisLoading = false);
    }
  }

  Future<void> _loadRealTimePrice() async {
    if (!mounted) return;
    setState(() => _isLiveLoading = true);
    try {
      final data = await _apiService.getStockPrice(widget.stockData['code']);
      if (mounted && data.isNotEmpty) {
        setState(() {
          _livePrice = data['price'];
          _liveChange = data['change'];
          _liveChangePercent = data['changePercent'];
          _isLiveLoading = false;
        });
      } else {
        setState(() => _isLiveLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLiveLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgGradientStart = Color(0xFF1A0A2E);
    const bgGradientEnd = Color(0xFF0A0214);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: ClipOval(
                  child: ClipOval(
                    child: Image.asset(
                      'asset/logos/${widget.stockData['code']}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, assetError, assetStack) {
                        return CachedNetworkImage(
                          imageUrl:
                              'https://assets.stockbit.com/logos/companies/${widget.stockData['code']}.png',
                          fit: BoxFit.cover,
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
                          errorWidget: (context, url, error) {
                            return Center(
                              child: Text(
                                widget.stockData['code']
                                    .toString()
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: GoogleFonts.robotoMono(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.stockData['code'],
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.stockData['name'],
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderPrice(),
                const SizedBox(height: 16),
                _buildChartSection(),
                const SizedBox(height: 20),
                _buildBrokerageFlowSection(),
                const SizedBox(height: 20),
                _buildAiTasksSection(),
                const SizedBox(height: 20),
                _buildBigNewsSection(),
                const SizedBox(height: 20),
                _buildDisclaimer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPrice() {
    final price =
        _livePrice ?? (widget.stockData['current_price'] as num).toDouble();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Live data or fallbacks
    final bool hasLive = _liveChangePercent != null;
    final changePct = hasLive ? _liveChangePercent!.toStringAsFixed(2) : "--";
    final isPositive = (_liveChange ?? 0) >= 0;
    final color = hasLive
        ? (isPositive ? const Color(0xFF39FF14) : Colors.redAccent)
        : Colors.white38;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isLiveLoading && _livePrice == null)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.cyanAccent,
                ),
              )
            else
              Text(
                currencyFormat.format(price).replaceAll(',', '.'),
                style: GoogleFonts.robotoMono(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    color: color,
                    size: 20,
                  ),
                  Text(
                    '${isPositive ? '+' : ''}$changePct%',
                    style: GoogleFonts.robotoMono(
                      fontSize: 16,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          'Last Price (Delayed 15m)',
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBrokerageFlowSection() {
    if (_isAnalysisLoading && _dynamicAnalysis == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    final flow = _dynamicAnalysis?['brokerage_flow'] ?? {};
    final groups =
        flow['groups'] ?? {'status': 'NEUTRAL', 'desc': 'Scanning market...'};
    final whale =
        flow['whale'] ??
        {'status': 'SIDEWAYS', 'desc': 'Monitoring whale movements...'};
    final retail =
        flow['retail'] ??
        {'status': 'NORMAL', 'desc': 'Tracking retail sentiment...'};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.cyanAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'DETEKSI ARUS BANDAR', // Translated
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFlowRow(
            'Arus Smart Money', // Translated
            groups['status'],
            groups['status'] == 'DETECTED'
                ? Colors.greenAccent
                : Colors.orangeAccent,
            groups['desc'],
            Icons.psychology,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildFlowRow(
            'Market Maker / Megalodon', // Quant Term
            whale['status'],
            whale['status'].contains('BUY')
                ? Colors.cyanAccent
                : Colors.redAccent,
            whale['desc'],
            Icons.waves,
            avgPrice: (widget.stockData['price'] * 0.96)
                .round(), // Simulated AVG Price
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildFlowRow(
            'Ritel / Kerumunan', // Translated
            retail['status'],
            retail['status'].contains('PANIC')
                ? Colors.grey
                : Colors.yellowAccent,
            retail['desc'],
            Icons.groups,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowRow(
    String label,
    String status,
    Color color,
    String desc,
    IconData icon, {
    int? avgPrice,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color.withValues(alpha: 0.7), size: 16),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    if (avgPrice != null)
                      Text(
                        'AVG: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(avgPrice)}',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grafik Teknikal ${widget.stockData['code']}', // Translated & Simplified
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.show_chart, color: Colors.cyanAccent, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          // Clean Code: Menggunakan widget TradingViewChart yang dipisahkan secara OOP
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TradingViewChart(
              symbol: widget.stockData['code'],
              height: 350,
              interval: 'D', // Set to Daily as default
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartLegend('Teknikal', Colors.cyanAccent),
              _buildChartLegend('Real-time', Colors.greenAccent),
              _buildChartLegend('Analisis AI', Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildAiTasksSection() {
    final dynamicTasks = _dynamicAnalysis?['ai_tasks'] ?? {};

    final tasks = [
      {
        'id': '1',
        'name': '1. Supply Demand',
        'status': dynamicTasks['supply_demand'] ?? 'Normal',
        'color': _getColorForStatus(dynamicTasks['supply_demand']),
      },
      {
        'id': '2',
        'name': '2. Foreign Flow',
        'status': dynamicTasks['foreign_flow'] ?? 'Neutral',
        'color': _getColorForStatus(dynamicTasks['foreign_flow']),
      },
      {
        'id': '3',
        'name': '3. Technical Trend',
        'status': dynamicTasks['technical_trend'] ?? 'Neutral',
        'color': _getColorForStatus(dynamicTasks['technical_trend']),
      },
      {
        'id': '4',
        'name': '4. Momentum',
        'status': dynamicTasks['momentum'] ?? 'Normal',
        'color': _getColorForStatus(dynamicTasks['momentum']),
      },
      {
        'id': '5',
        'name': '5. Valuation',
        'status': dynamicTasks['valuation'] ?? 'Fair Value',
        'color': _getColorForStatus(dynamicTasks['valuation']),
      },
      {
        'id': '6',
        'name': '6. Sentiment Analysis',
        'status': dynamicTasks['sentiment'] ?? 'Neutral',
        'color': _getColorForStatus(dynamicTasks['sentiment']),
      },
      {
        'id': '7',
        'name': '7. Risk Assessment',
        'status': dynamicTasks['risk'] ?? 'Moderate',
        'color': _getColorForStatus(dynamicTasks['risk']),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI ANALYSIS TASKS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          if (_isAnalysisLoading && _dynamicAnalysis == null)
            const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.5,
              ),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskItem(task);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForTask(task['id'] as String),
            size: 14,
            color: task['color'] as Color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['name'] as String,
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  task['status'] as String,
                  style: TextStyle(
                    color: task['color'] as Color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForStatus(String? status) {
    if (status == null) return Colors.white54;
    final s = status.toLowerCase();
    if (s.contains('strong') ||
        s.contains('buy') ||
        s.contains('bullish') ||
        s.contains('optimistic') ||
        s.contains('low') ||
        s.contains('undervalued') ||
        s.contains('positive')) {
      return Colors.greenAccent;
    }
    if (s.contains('weak') ||
        s.contains('sell') ||
        s.contains('bearish') ||
        s.contains('pessimistic') ||
        s.contains('high') ||
        s.contains('overvalued') ||
        s.contains('negative')) {
      return Colors.redAccent;
    }
    return Colors.yellowAccent;
  }

  IconData _getIconForTask(String id) {
    switch (id) {
      case '1':
        return Icons.show_chart;
      case '2':
        return Icons.public;
      case '3':
        return Icons.trending_up;
      case '4':
        return Icons.speed;
      case '5':
        return Icons.scale;
      case '6':
        return Icons.mood;
      case '7':
        return Icons.security;
      default:
        return Icons.circle;
    }
  }

  Widget _buildBigNewsSection() {
    final newsText =
        _dynamicNews?['news'] ?? 'Loading latest market updates...';
    final newsTime =
        _dynamicNews?['time'] ??
        DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.now());
    final newsImpact =
        _dynamicNews?['impact_detail'] ?? 'Analyzing potential price impact...';
    final newsImage = _dynamicNews?['image'];
    final newsUrl = _dynamicNews?['url'];

    return GestureDetector(
      onTap: () async {
        if (newsUrl != null) {
          final uri = Uri.parse(newsUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A1B3D).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'BIG NEWS 🚨',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_isNewsLoading && _dynamicNews == null)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            newsText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'BREAKING: $newsTime',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, height: 1.4),
                              children: [
                                const TextSpan(
                                  text: 'Impact: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: newsImpact,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (newsImage != null) ...[
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          newsImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 12),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Source: Google News',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.open_in_new, color: Colors.white38, size: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'DISCLAIMER & DYOR',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Seluruh data, grafik, dan prediksi AI adalah simulasi hipotesis berdasarkan data historis. Performa masa lalu tidak menjamin hasil di masa depan. Berinvestasilah dengan bijak dan lakukan riset mandiri (Do Your Own Research).',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
