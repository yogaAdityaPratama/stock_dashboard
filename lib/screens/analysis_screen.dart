import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/trading_view_chart.dart';
import '../services/api_service.dart';
import 'package:stockid/widgets/quant_warning_blackrock.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================================
/// ANALYSIS SCREEN - CORE MODULE
/// ============================================================================
///
/// Deskripsi:
/// Halaman analisis saham yang menampilkan data real-time, deteksi arus bandar,
/// chart teknikal, dan rekomendasi AI yang komprehensif.
///
/// Fitur Utama:
/// - Real-time price tracking
/// - Deteksi Smart Money Flow dengan rekomendasi Bullish/Bearish
/// - TradingView Chart integration
/// - AI-powered analysis tasks
/// - Breaking news with impact analysis
///
/// Arsitektur:
/// - Pattern: OOP dengan separation of concerns
/// - State Management: StatefulWidget dengan efficient state updates
/// - UI Pattern: Component-based dengan glassmorphism design
///
/// Performance Optimizations:
/// - Lazy loading untuk image assets
/// - Efficient widget rebuilding dengan const constructors
/// - Async data fetching dengan proper error handling
///
/// Author: Senior Fullstack Developer & Quant Analyst
/// Version: 2.0.0
/// Last Updated: 2026-02-15
/// ============================================================================

class AnalysisScreen extends StatefulWidget {
  /// Data saham yang dipassing dari parent screen
  final Map<String, dynamic> stockData;

  const AnalysisScreen({super.key, required this.stockData});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // ========== Services & Controllers ==========
  /// API Service instance for handling network requests.
  final ApiService _apiService = ApiService();

  // ========== State Variables ==========

  /// Holds the current real-time price of the stock.
  double? _livePrice;

  /// Holds the nominal change in price (e.g., +125.0).
  double? _liveChange;

  /// Holds the percentage change in price (e.g., +1.2%).
  double? _liveChangePercent;

  /// Loading state for the real-time price section.
  bool _isLiveLoading = false;

  /// Stores the comprehensive AI analysis data (Smart Money, Sentiment, etc.).
  Map<String, dynamic>? _dynamicAnalysis;

  /// Loading state for the analysis section.
  bool _isAnalysisLoading = false;

  /// Stores the latest news items related to the stock.
  Map<String, dynamic>? _dynamicNews;

  /// Loading state for the news section.
  bool _isNewsLoading = false;

  /// Stores fundamental financial data (ratios, scores, etc.).
  Map<String, dynamic>? _fundamentalData;

  /// Loading state for fundamental data.
  bool _isFundamentalLoading = false;

  /// Stores Forecast Result (Prediction 30 days)
  Map<String, dynamic>? _forecastData;
  final ValueNotifier<Map<String, dynamic>?> _forecastNotifier = ValueNotifier(
    null,
  );

  /// Loading state for Advanced Forecast (LSTM)
  bool _isForecastLoading = false;

  // ========== Lifecycle Methods ==========

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Master initialization method.
  ///
  /// Triggers asynchronous operations to populate the screen:
  /// 1. Real-time Price
  /// 2. AI Analysis
  /// 3. News Feed
  /// 4. Fundamental Data
  /// 5. Advanced Forecast (Background Trigger)
  void _initializeData() {
    _loadRealTimePrice();
    _fetchDynamicAnalysis();
    _fetchDynamicNews();
    _fetchFundamentalData();
    _fetchAdvancedForecast();
  }

  // ========== Data Fetching Methods ==========

  Future<void> _fetchAdvancedForecast() async {
    if (!mounted) return;
    setState(() => _isForecastLoading = true);

    try {
      final result = await _apiService.getAdvancedForecast(
        widget.stockData['code'],
      );

      if (mounted && result.isNotEmpty) {
        setState(() {
          _forecastData = result;
          _isForecastLoading = false;
          _forecastNotifier.value = result; // Update notifier
        });
        debugPrint("✅ Forecast Data Received: ${result['quant_warning']}");
      }
    } catch (e) {
      debugPrint("⚠️ Forecast Fetch Error: $e");
      if (mounted) setState(() => _isForecastLoading = false);
    }
  }

  /// Fetches the latest price snapshot from the API.
  ///
  /// Updates `_livePrice`, `_liveChange`, and `_liveChangePercent`.
  /// Handles loading state and gracefully fails silently if mounted check fails.
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
      debugPrint('Error loading real-time price: $e');
      if (mounted) setState(() => _isLiveLoading = false);
    }
  }

  /// Fetches detailed AI-driven analysis including Brokerage Flow and Sentiment.
  ///
  /// Populates `_dynamicAnalysis` which drives the Logic and Recommendation UI widgets.
  Future<void> _fetchDynamicAnalysis() async {
    if (!mounted) return;

    setState(() => _isAnalysisLoading = true);

    try {
      final data = await _apiService.getFullAnalysis(widget.stockData['code']);

      if (mounted && data.isNotEmpty) {
        setState(() {
          _dynamicAnalysis = data;
          _isAnalysisLoading = false;
        });
      } else {
        setState(() => _isAnalysisLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching dynamic analysis: $e');
      if (mounted) setState(() => _isAnalysisLoading = false);
    }
  }

  /// Fetches recent news and market sentiment data.
  ///
  /// Populates `_dynamicNews` for the news feed section.
  Future<void> _fetchDynamicNews() async {
    if (!mounted) return;

    setState(() => _isNewsLoading = true);

    try {
      final data = await _apiService.getStockNews(widget.stockData['code']);

      if (mounted && data.isNotEmpty) {
        setState(() {
          _dynamicNews = data;
          _isNewsLoading = false;
        });
      } else {
        setState(() => _isNewsLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching dynamic news: $e');
      if (mounted) setState(() => _isNewsLoading = false);
    }
  }

  /// Fetches fundamental data such as PER, PBV, ROE, etc.
  ///
  /// If the API call fails or returns empty, it triggers `_setFallbackFundamentalData`
  /// to ensure the UI remains populated with mock/educational data.
  Future<void> _fetchFundamentalData() async {
    if (!mounted) return;

    setState(() => _isFundamentalLoading = true);

    try {
      final data = await _apiService.getFundamentalData(
        widget.stockData['code'],
      );

      debugPrint('🔍 Fundamental Data Response: $data');

      if (mounted && data.isNotEmpty) {
        setState(() {
          _fundamentalData = data;
          _isFundamentalLoading = false;
        });
        debugPrint('✅ Fundamental data loaded successfully: ${data['code']}');
      } else {
        debugPrint('⚠️ Fundamental data is empty, setting fallback');
        // Provide fallback data based on mock logic for seamless UX
        _setFallbackFundamentalData();
        setState(() => _isFundamentalLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error fetching fundamental data: $e');
      _setFallbackFundamentalData();
      if (mounted) setState(() => _isFundamentalLoading = false);
    }
  }

  /// Set fallback fundamental data dari mock
  void _setFallbackFundamentalData() {
    final code = widget.stockData['code'] ?? 'UNKNOWN';
    final mockData = {
      'code': code,
      'name': widget.stockData['name'] ?? 'N/A',
      'sector': 'Finance',
      'price': widget.stockData['price'] ?? 0,
      'market_cap_b': 500,
      'metrics': {
        'roe': 18.5,
        'roic': 16.2,
        'per': 12.5,
        'pbv': 1.8,
        'der': 0.3,
        'dividend_yield': 3.5,
        'net_profit_growth': 15,
        'fcf_to_net_income': 0.18,
        'esg_score': 85,
      },
      'per_share_metrics': {'eps': 1850, 'bvps': 5444, 'dps': 343},
      'classification': {
        'type': 'VALUE INVEST - Undervalue & High ROE',
        'color': 'green',
      },
      'valuation_indicators': {
        'is_undervalue': true,
        'is_overvalue': false,
        'has_strong_roe': true,
        'has_low_debt': true,
        'has_good_fcf': true,
      },
      'quality_assessment': {
        'financial_health': 'Strong',
        'profitability': 'Excellent',
        'valuation': 'Cheap',
        'sustainability': 'High',
      },
      'status': 'fallback',
    };

    if (mounted) {
      setState(() {
        _fundamentalData = mockData;
      });
    }
  }

  /// Membuka halaman website perusahaan dengan smart fallback
  Future<void> _openCompanyAnalysisPage(String stockCode) async {
    try {
      // Mapping untuk perusahaan-perusahaan utama (Top 100 Most Liquid)
      final companyUrls = {
        // Blue Chip Banks
        'BBCA': 'https://www.bca.co.id',
        'BMRI': 'https://www.bri.co.id',
        'BBNI': 'https://www.bni.co.id',
        'BBTN': 'https://www.btn.co.id',
        'BJBR': 'https://www.bjb.co.id',
        'BSDE': 'https://www.banksde.co.id',
        'BSIM': 'https://www.banksinarmas.com',

        // Insurance & Finance
        'ASII': 'https://www.astra.co.id',
        'PGAS': 'https://www.pgas.co.id',
        'INDF': 'https://www.indofood.co.id',
        'HMSP': 'https://www.hm-sampoerna.com',
        'TLKM': 'https://www.telkomsel.com',
        'UNVR': 'https://www.unilever.co.id',
        'GGRM': 'https://www.gudanggaramtbk.com',
        'JSMR': 'https://www.jasa-marga.co.id',
        'ICBP': 'https://www.indofood.co.id',
        'MEDC': 'https://www.medco.co.id',
        'MNCN': 'https://www.mnc.co.id',
        'TOWR': 'https://www.towr.co.id',
        'KAEF': 'https://www.kaef.co.id',
        'CENT': 'https://www.centralasia.com',
        'ANTM': 'https://www.antam.com',
        'GOLD': 'https://www.antam.com',
        'ADRO': 'https://www.adaro.com',
      };

      // Cek di mapping terlebih dahulu
      String? url = companyUrls[stockCode];

      if (url != null && url.isNotEmpty) {
        // Gunakan mapping yang sudah ada
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          return;
        }
      }

      // FALLBACK: Gunakan Google Search untuk perusahaan yang tidak ada di mapping
      // Format: "website resmi STOCKCODE pt (company name)"
      final googleSearchUrl =
          'https://www.google.com/search?q=website+resmi+$stockCode+pt+investor+relations';

      if (await canLaunchUrl(Uri.parse(googleSearchUrl))) {
        await launchUrl(
          Uri.parse(googleSearchUrl),
          mode: LaunchMode.externalApplication,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Membuka pencarian untuk website $stockCode'),
              backgroundColor: Colors.blueAccent.withValues(alpha: 0.8),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak bisa membuka website untuk $stockCode'),
              backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening company website: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat membuka halaman'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Menampilkan fundamental data dalam bottom sheet modal
  void _showFundamentalModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75, // 75% dari screen height
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2A1B3D).withValues(alpha: 0.95),
                const Color(0xFF1A0A2E).withValues(alpha: 0.98),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: _isFundamentalLoading && _fundamentalData == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(color: Color(0xFFFF6B35)),
                            SizedBox(height: 16),
                            Text(
                              'Memuat data fundamental...',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _fundamentalData == null
                    ? Center(
                        child: Text(
                          'Data fundamental tidak tersedia',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      )
                    : SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: _buildComprehensiveFundamentalContent(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build comprehensive fundamental content untuk modal
  Widget _buildComprehensiveFundamentalContent() {
    if (_fundamentalData == null) {
      return const SizedBox.shrink();
    }

    final metrics = _fundamentalData!['metrics'] ?? {};
    final perShare = _fundamentalData!['per_share_metrics'] ?? {};
    final classification = _fundamentalData!['classification'] ?? {};
    final valuation = _fundamentalData!['valuation_indicators'] ?? {};
    final quality = _fundamentalData!['quality_assessment'] ?? {};
    final code = _fundamentalData!['code'] ?? 'N/A';
    final name = _fundamentalData!['name'] ?? 'N/A';
    final sector = _fundamentalData!['sector'] ?? 'N/A';
    final price = _fundamentalData!['price'] ?? 0;
    final marketCap = _fundamentalData!['market_cap_b'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        _buildModalHeader(code, name, sector, price, marketCap),
        const SizedBox(height: 20),

        // Classification Section
        _buildClassificationBadge(classification),
        const SizedBox(height: 20),

        // Core Metrics Section
        _buildSectionTitle('Core Metrics'),
        const SizedBox(height: 12),
        _buildCoreMetricsGrid(metrics),
        const SizedBox(height: 20),

        // Per Share Metrics Section
        _buildSectionTitle('Per Share Metrics'),
        const SizedBox(height: 12),
        _buildPerShareMetricsGrid(perShare),
        const SizedBox(height: 20),

        // Valuation Indicators
        _buildSectionTitle('Indikator Valuasi'),
        const SizedBox(height: 12),
        _buildValuationGrid(valuation),
        const SizedBox(height: 20),

        // Quality Assessment
        _buildSectionTitle('Penilaian Kualitas'),
        const SizedBox(height: 12),
        _buildQualityDetailSection(quality),
        const SizedBox(height: 20),

        // Educational Information
        _buildEducationalInfo(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildModalHeader(
    String code,
    String name,
    String sector,
    dynamic price,
    dynamic marketCap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: GoogleFonts.robotoMono(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF6B35),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FBCA3).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF1FBCA3).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    sector,
                    style: const TextStyle(
                      color: Color(0xFF1FBCA3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatThousands((price as num)),
                      style: GoogleFonts.robotoMono(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _openCompanyAnalysisPage(code),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.open_in_new,
                          color: Color(0xFF10B981),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.language, color: Colors.white38, size: 12),
            const SizedBox(width: 4),
            Text(
              'Market Cap: ${(marketCap as num).toStringAsFixed(1)}B',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassificationBadge(Map<String, dynamic> classification) {
    final type = classification['type'] ?? 'N/A';
    final color = _getColorFromName(classification['color'] ?? 'yellow');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rate, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              type,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCoreMetricsGrid(Map<String, dynamic> metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLargeMetricCard(
                'ROE',
                '${metrics['roe'] ?? 0}%',
                const Color(0xFF1FBCA3),
                'Return on Equity',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildLargeMetricCard(
                'ROIC',
                '${metrics['roic'] ?? 0}%',
                const Color(0xFF6B7FF1),
                'Return on Invested Capital',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildLargeMetricCard(
                'PER',
                '${metrics['per'] ?? 0}x',
                const Color(0xFF10B981),
                'Price-to-Earnings',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildLargeMetricCard(
                'PBV',
                '${metrics['pbv'] ?? 0}x',
                const Color(0xFF8B5CF6),
                'Price-to-Book Value',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildLargeMetricCard(
                'DER',
                '${metrics['der'] ?? 0}x',
                const Color(0xFFC2410C),
                'Debt-to-Equity',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildLargeMetricCard(
                'Dividend',
                '${metrics['dividend_yield'] ?? 0}%',
                const Color(0xFFC2410C),
                'Dividend Yield',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildLargeMetricCard(
                'Growth',
                '${metrics['net_profit_growth'] ?? 0}%',
                const Color(0xFFF59E0B),
                'Net Profit Growth',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildLargeMetricCard(
                'ESG',
                '${metrics['esg_score'] ?? 0}',
                const Color(0xFF6CC24A),
                'ESG Score (0-100)',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerShareMetricsGrid(Map<String, dynamic> perShare) {
    return Row(
      children: [
        Expanded(
          child: _buildLargeMetricCard(
            'EPS',
            _formatThousands((perShare['eps'] ?? 0)),
            const Color(0xFFF59E0B),
            'Earnings Per Share',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildLargeMetricCard(
            'BVPS',
            _formatThousands((perShare['bvps'] ?? 0)),
            const Color(0xFF6B7FF1),
            'Book Value Per Share',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildLargeMetricCard(
            'DPS',
            _formatThousands((perShare['dps'] ?? 0)),
            const Color(0xFFF43F5E),
            'Dividend Per Share',
          ),
        ),
      ],
    );
  }

  Widget _buildValuationGrid(Map<String, dynamic> valuation) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (valuation['is_undervalue'] ?? false)
          _buildDetailBadge('Undervalue', const Color(0xFF10B981)),
        if (valuation['is_overvalue'] ?? false)
          _buildDetailBadge('Overvalue', const Color(0xFFFCA5A5)),
        if (valuation['has_strong_roe'] ?? false)
          _buildDetailBadge('Strong ROE', const Color(0xFF1FBCA3)),
        if (valuation['has_low_debt'] ?? false)
          _buildDetailBadge('Low Debt', const Color(0xFF6B7FF1)),
        if (valuation['has_good_fcf'] ?? false)
          _buildDetailBadge('Good FCF', const Color(0xFF6CC24A)),
        if (!(valuation['is_undervalue'] ?? false) &&
            !(valuation['is_overvalue'] ?? false) &&
            !(valuation['has_strong_roe'] ?? false) &&
            !(valuation['has_low_debt'] ?? false))
          _buildDetailBadge('Fair Value', Colors.grey),
      ],
    );
  }

  Widget _buildQualityDetailSection(Map<String, dynamic> quality) {
    return Column(
      children: [
        _buildQualityRow(
          'Financial Health',
          quality['financial_health'] ?? 'N/A',
        ),
        const SizedBox(height: 10),
        _buildQualityRow('Profitability', quality['profitability'] ?? 'N/A'),
        const SizedBox(height: 10),
        _buildQualityRow('Valuation', quality['valuation'] ?? 'N/A'),
        const SizedBox(height: 10),
        _buildQualityRow('Sustainability', quality['sustainability'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildLargeMetricCard(
    String label,
    String value,
    Color color,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 8,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildQualityRow(String label, String value) {
    final color = _getQualityColor(value);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF140820),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Educational Information Section
  Widget _buildEducationalInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1FBCA3).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF1FBCA3).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Color(0xFF1FBCA3), size: 16),
              const SizedBox(width: 8),
              Text(
                'PANDUAN FUNDAMENTAL INVESTING',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1FBCA3),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEducationRow(
            '💎 Moat (Economic Moat)',
            'Keunggulan kompetitif yang sulit ditiru pesaing. Contoh: brand strength, network effect, switching cost tinggi.',
          ),
          const SizedBox(height: 8),
          _buildEducationRow(
            '🛡️ Margin of Safety (MoS)',
            'Selisih antara nilai intrinsik dengan harga pasar. "Bantalan keamanan" jika prediksi meleset.',
          ),
          const SizedBox(height: 8),
          _buildEducationRow(
            '📈 Consistent Growth',
            'Laba dan pendapatan naik stabil 5-10 tahun terakhir. Indikator bisnis yang healthy dan sustainable.',
          ),
          const SizedBox(height: 8),
          _buildEducationRow(
            '🎭 Creative Accounting',
            'Praktik mempercantik laporan keuangan. Perhatikan: unusual provisions, related party transactions.',
          ),
          const SizedBox(height: 8),
          _buildEducationRow(
            '🔗 Pledging',
            'Saham owner/pengendali digadaikan ke pihak lain. Risiko tinggi jika terjadi gagal bayar.',
          ),
        ],
      ),
    );
  }

  /// Build education row
  Widget _buildEducationRow(String term, String explanation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          term,
          style: const TextStyle(
            color: Color(0xFF1FBCA3),
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          explanation,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 9,
            letterSpacing: 0.2,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  /// Get color from string name
  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'green':
        return const Color(0xFF10B981);
      case 'red':
        return const Color(0xFFFCA5A5);
      case 'blue':
        return const Color(0xFF6B7FF1);
      case 'yellow':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  /// Get quality color based on value
  Color _getQualityColor(String value) {
    switch (value.toLowerCase()) {
      case 'strong':
      case 'excellent':
      case 'cheap':
      case 'high':
        return const Color(0xFF10B981);
      case 'weak':
      case 'poor':
      case 'expensive':
      case 'low':
        return const Color(0xFFFCA5A5);
      case 'moderate':
      case 'fair':
        return const Color(0xFFF59E0B);
      case 'good':
        return const Color(0xFF1FBCA3);
      default:
        return Colors.white38;
    }
  }

  /// Format number with thousand separator (dot)
  String _formatThousands(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  // ========== Build Methods ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Membuat AppBar dengan logo dan informasi saham
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: _StockHeaderInfo(stockData: widget.stockData),
    );
  }

  /// Membuat body utama dengan gradient background
  Widget _buildBody() {
    const bgGradientStart = Color(0xFF1A0A2E);
    const bgGradientEnd = Color(0xFF0A0214);

    return Container(
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
              _PriceHeader(
                livePrice: _livePrice,
                liveChange: _liveChange,
                liveChangePercent: _liveChangePercent,
                isLoading: _isLiveLoading,
                fallbackPrice: (widget.stockData['current_price'] as num)
                    .toDouble(),
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 12),
              _ChartSection(stockCode: widget.stockData['code']),
              const SizedBox(height: 12),
              _SmartMoneyFlowSection(
                dynamicAnalysis: _dynamicAnalysis,
                isLoading: _isAnalysisLoading,
                stockPrice: widget.stockData['price'],
                onToggleFundamental: () {
                  _showFundamentalModal();
                },
                forecastNotifier: _forecastNotifier, // Changed
              ),
              const SizedBox(height: 12),
              _AITasksSection(
                dynamicAnalysis: _dynamicAnalysis,
                isLoading: _isAnalysisLoading,
              ),
              const SizedBox(height: 12),
              _BigNewsSection(
                dynamicNews: _dynamicNews,
                isLoading: _isNewsLoading,
              ),
              const SizedBox(height: 16),
              const _DisclaimerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET COMPONENTS - Mengikuti prinsip OOP dan Component-based Architecture
// ============================================================================

/// Widget untuk menampilkan informasi header saham di AppBar
///
/// Menggunakan proper layout constraints untuk menghindari overflow
/// Mengikuti Flutter best practices:
/// - Row dengan Expanded untuk flexible width allocation
/// - Text dengan maxLines dan overflow untuk graceful truncation
/// - Responsive spacing yang adaptif terhadap screen size
class _StockHeaderInfo extends StatelessWidget {
  final Map<String, dynamic> stockData;

  const _StockHeaderInfo({required this.stockData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo perusahaan (fixed width)
        _buildStockLogo(),
        const SizedBox(width: 10),

        // Info saham (flexible width dengan overflow handling)
        Expanded(child: _buildStockInfo()),

        const SizedBox(width: 8),

        // Button website (fixed width)
        GestureDetector(
          onTap: () => _openCompanyWebsite(
            context,
            stockData['code']?.toString(),
            stockData['name']?.toString(),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.open_in_new,
              color: Color(0xFF10B981),
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Membuka website perusahaan (prefer company name for searches)
  void _openCompanyWebsite(
    BuildContext context,
    String? stockCode,
    String? companyName,
  ) async {
    try {
      // Mapping untuk perusahaan-perusahaan utama
      final companyUrls = {
        'BBCA': 'https://www.bca.co.id',
        'BMRI': 'https://www.bri.co.id',
        'BBNI': 'https://www.bni.co.id',
        'BBTN': 'https://www.btn.co.id',
        'BJBR': 'https://www.bjb.co.id',
        'BSDE': 'https://www.banksde.co.id',
        'BSIM': 'https://www.banksinarmas.com',
        'ASII': 'https://www.astra.co.id',
        'PGAS': 'https://www.pgas.co.id',
        'INDF': 'https://www.indofood.co.id',
        'HMSP': 'https://www.hm-sampoerna.com',
        'TLKM': 'https://www.telkomsel.com',
        'UNVR': 'https://www.unilever.co.id',
        'GGRM': 'https://www.gudanggaramtbk.com',
        'JSMR': 'https://www.jasa-marga.co.id',
        'ICBP': 'https://www.indofood.co.id',
        'MEDC': 'https://www.medco.co.id',
        'MNCN': 'https://www.mnc.co.id',
        'TOWR': 'https://www.towr.co.id',
        'KAEF': 'https://www.kaef.co.id',
        'CENT': 'https://www.centralasia.com',
        'ANTM': 'https://www.antam.com',
        'GOLD': 'https://www.antam.com',
        'ADRO': 'https://www.adaro.com',
      };

      String? url;
      if (stockCode != null) {
        url = companyUrls[stockCode.toUpperCase()];
      }

      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // FALLBACK: use company name for search if available, otherwise use code
      final queryTarget = (companyName?.trim().isNotEmpty == true)
          ? companyName!.trim()
          : (stockCode ?? 'company');

      final query = Uri.encodeComponent(
        'website resmi $queryTarget investor relations',
      );
      final googleSearchUrl = 'https://www.google.com/search?q=$query';

      final googleUri = Uri.parse(googleSearchUrl);
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka pencarian untuk website $queryTarget'),
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening company website: $e');
    }
  }

  /// Build logo perusahaan dengan fallback ke initial huruf
  ///
  /// Prioritas:
  /// 1. Asset lokal (asset/logos/CODE.png)
  /// 2. Online dari Stockbit CDN
  /// 3. Fallback ke inisial 2 huruf pertama
  Widget _buildStockLogo() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'asset/logos/${stockData['code']}.png',
          fit: BoxFit.cover,
          errorBuilder: (context, assetError, assetStack) {
            return CachedNetworkImage(
              imageUrl:
                  'https://assets.stockbit.com/logos/companies/${stockData['code']}.png',
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
                    stockData['code'].toString().substring(0, 2).toUpperCase(),
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
    );
  }

  /// Build informasi saham (kode dan nama)
  ///
  /// PENTING: Menggunakan Column dengan constraint yang proper
  /// untuk menghindari overflow pada nama perusahaan yang panjang
  Widget _buildStockInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stock code (selalu singkat, tidak perlu overflow handling)
        Text(
          stockData['code'] ?? 'N/A',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),

        // Company name (bisa sangat panjang, butuh overflow handling)
        Text(
          stockData['name'] ?? 'Unknown Company',
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.w300,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Widget untuk menampilkan harga saham dengan perubahan
class _PriceHeader extends StatelessWidget {
  final double? livePrice;
  final double? liveChange;
  final double? liveChangePercent;
  final bool isLoading;
  final double fallbackPrice;

  const _PriceHeader({
    required this.livePrice,
    required this.liveChange,
    required this.liveChangePercent,
    required this.isLoading,
    required this.fallbackPrice,
  });

  @override
  Widget build(BuildContext context) {
    final price = livePrice ?? fallbackPrice;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final bool hasLive = liveChangePercent != null;
    final changePct = hasLive ? liveChangePercent!.toStringAsFixed(2) : "--";
    final isPositive = (liveChange ?? 0) >= 0;
    final color = hasLive
        ? (isPositive ? const Color(0xFF39FF14) : Colors.redAccent)
        : Colors.white38;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isLoading && livePrice == null)
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    size: 18,
                  ),
                  Text(
                    '${isPositive ? '+' : ''}$changePct%',
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Last Price (Delayed 15m)',
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Widget untuk menampilkan chart TradingView
class _ChartSection extends StatelessWidget {
  final String stockCode;

  const _ChartSection({required this.stockCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                'Grafik Teknikal $stockCode',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.show_chart, color: Colors.cyanAccent, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TradingViewChart(
              symbol: stockCode,
              height: 280, // Reduced from 350
              interval: 'D',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ChartLegend(label: 'Teknikal', color: Colors.cyanAccent),
              _ChartLegend(label: 'Real-time', color: Colors.greenAccent),
              _ChartLegend(label: 'AI Analysis', color: Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget legend untuk chart
class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;

  const _ChartLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
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
}

/// Widget untuk deteksi arus Smart Money dengan rekomendasi Bullish/Bearish
class _SmartMoneyFlowSection extends StatelessWidget {
  final Map<String, dynamic>? dynamicAnalysis;
  final bool isLoading;
  final dynamic stockPrice;
  final VoidCallback? onToggleFundamental;
  final ValueNotifier<Map<String, dynamic>?>?
  forecastNotifier; // Changed for reactivity

  const _SmartMoneyFlowSection({
    required this.dynamicAnalysis,
    required this.isLoading,
    required this.stockPrice,
    this.onToggleFundamental,
    this.forecastNotifier, // Changed
  });

  /// Menghitung rekomendasi berdasarkan flow data
  _FlowRecommendation _calculateRecommendation() {
    if (dynamicAnalysis == null) {
      return _FlowRecommendation(
        isBullish: true,
        isNeutral: true,
        bullishPercentage: 50,
        bearishPercentage: 50,
        sentiment: 'NEUTRAL',
        explanation: 'Neutral market with balanced forces',
        factors: {},
      );
    }

    // ========== PRIORITY: USE BACKEND ML SENTIMENT ==========
    // Backend sudah menghitung dengan Quant Dominance v2.4 (ML + Flow Bonus)
    final sentimentDetail = dynamicAnalysis!['sentiment_detail'];

    if (sentimentDetail != null && sentimentDetail is Map) {
      final String backendSentiment =
          sentimentDetail['sentiment']?.toString().toUpperCase() ?? 'NEUTRAL';
      final double bullishPct =
          (sentimentDetail['bullish_percentage'] as num?)?.toDouble() ?? 50.0;
      final double bearishPct =
          (sentimentDetail['bearish_percentage'] as num?)?.toDouble() ?? 50.0;

      String displaySentiment;
      bool isNeutral = false;
      bool isBullish = false;

      if (backendSentiment.contains('BULLISH')) {
        if (bullishPct >= 70) {
          displaySentiment = 'STRONG BULLISH';
        } else {
          displaySentiment = 'BULLISH';
        }
        isBullish = true;
      } else if (backendSentiment.contains('BEARISH')) {
        if (bearishPct >= 70) {
          displaySentiment = 'STRONG BEARISH';
        } else {
          displaySentiment = 'BEARISH';
        }
        isBullish = false;
      } else {
        displaySentiment = 'NEUTRAL';
        isNeutral = true;
      }

      // Cap percentages at 100%
      final cappedBullishPct = bullishPct.clamp(0.0, 100.0).round();
      final cappedBearishPct = bearishPct.clamp(0.0, 100.0).round();

      // Parse quant warnings from backend (NEW)
      final List<Map<String, dynamic>> quantWarnings = [];
      if (dynamicAnalysis!['quant_warnings'] != null) {
        final rawWarnings = dynamicAnalysis!['quant_warnings'] as List<dynamic>;
        for (var warning in rawWarnings) {
          if (warning is Map<String, dynamic>) {
            quantWarnings.add(warning);
          }
        }
      }

      return _FlowRecommendation(
        isBullish: isBullish,
        isNeutral: isNeutral,
        bullishPercentage: cappedBullishPct,
        bearishPercentage: cappedBearishPct,
        sentiment: displaySentiment,
        explanation: sentimentDetail['explanation']?.toString() ?? '',
        factors: sentimentDetail['factors'] as Map<String, dynamic>? ?? {},
        quantWarnings: quantWarnings, // NEW
      );
    }

    // ========== FALLBACK: Local Calculation ==========
    final flow = dynamicAnalysis!['brokerage_flow'] ?? {};
    final groups = flow['groups'] ?? {};
    final whale = flow['whale'] ?? {};
    final retail = flow['retail'] ?? {};

    // Scoring logic untuk menentukan Bullish/Bearish
    int bullishScore = 0;
    int bearishScore = 0;

    // Analisis Smart Money
    final groupsStatus = groups['status']?.toString().toUpperCase() ?? '';
    if (groupsStatus.contains('DETECTED') || groupsStatus.contains('BUY')) {
      bullishScore += 40;
    } else if (groupsStatus.contains('SELL')) {
      bearishScore += 40;
    } else {
      bullishScore += 20;
      bearishScore += 20;
    }

    // Analisis Market Maker (Whale)
    final whaleStatus = whale['status']?.toString().toUpperCase() ?? '';
    if (whaleStatus.contains('BUY') || whaleStatus.contains('ACCUMULATION')) {
      bullishScore += 35;
    } else if (whaleStatus.contains('SELL') ||
        whaleStatus.contains('DISTRIBUTION')) {
      bearishScore += 35;
    } else {
      bullishScore += 15;
      bearishScore += 15;
    }

    // Analisis Retail
    final retailStatus = retail['status']?.toString().toUpperCase() ?? '';
    if (retailStatus.contains('PANIC') || retailStatus.contains('FEAR')) {
      // Contrarian indicator: retail panic = bullish for smart money
      bullishScore += 25;
    } else if (retailStatus.contains('FOMO') ||
        retailStatus.contains('EUPHORIA')) {
      bearishScore += 25;
    } else {
      bullishScore += 12;
      bearishScore += 12;
    }

    final total = bullishScore + bearishScore;
    final int bullishPct = total == 0
        ? 50
        : ((bullishScore / total) * 100).round();
    final int bearishPct = 100 - bullishPct;

    String sentiment;
    bool isNeutral = false;

    if (bullishPct == 50) {
      sentiment = 'NEUTRAL';
      isNeutral = true;
    } else if (bullishPct >= 70) {
      sentiment = 'STRONG BULLISH';
    } else if (bullishPct > 50) {
      sentiment = 'BULLISH';
    } else if (bullishPct <= 30) {
      sentiment = 'STRONG BEARISH';
    } else {
      sentiment = 'BEARISH';
    }

    return _FlowRecommendation(
      isBullish: bullishPct > 50,
      isNeutral: isNeutral,
      bullishPercentage: bullishPct,
      bearishPercentage: bearishPct,
      sentiment: sentiment,
      explanation: 'Based on local flow analysis',
      factors: {
        'Smart Money': groupsStatus,
        'Whale/Market Maker': whaleStatus,
        'Retail': retailStatus,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && dynamicAnalysis == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1B3D).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    final flow = dynamicAnalysis?['brokerage_flow'] ?? {};
    final groups =
        flow['groups'] ?? {'status': 'NEUTRAL', 'desc': 'Scanning market...'};
    final whale =
        flow['whale'] ??
        {'status': 'SIDEWAYS', 'desc': 'Monitoring whale movements...'};
    final retail =
        flow['retail'] ??
        {'status': 'NORMAL', 'desc': 'Tracking retail sentiment...'};

    final recommendation = _calculateRecommendation();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.analytics_outlined,
                    color: Colors.cyanAccent,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'DETEKSI ARUS BANDAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              _buildFundamentalButton(),
            ],
          ),
          const SizedBox(height: 12),

          // Rekomendasi Bullish/Bearish (seperti gambar 1)
          _buildRecommendationPanel(context, recommendation),

          const SizedBox(height: 12),

          // Flow indicators
          _FlowIndicator(
            label: 'Arus Smart Money',
            status: groups['status'],
            color: groups['status'] == 'DETECTED'
                ? Colors.greenAccent
                : Colors.orangeAccent,
            description: groups['desc'],
            icon: Icons.psychology,
          ),
          const Divider(color: Colors.white10, height: 16),
          _FlowIndicator(
            label: 'Market Maker',
            status: whale['status'],
            color: whale['status'].toString().contains('BUY')
                ? Colors.cyanAccent
                : Colors.redAccent,
            description: whale['desc'],
            icon: Icons.waves,
            avgPrice: stockPrice != null ? (stockPrice * 0.96).round() : null,
          ),
          const Divider(color: Colors.white10, height: 16),
          _FlowIndicator(
            label: 'Ritel',
            status: retail['status'],
            color: retail['status'].toString().contains('PANIC')
                ? Colors.grey
                : Colors.yellowAccent,
            description: retail['desc'],
            icon: Icons.groups,
          ),
        ],
      ),
    );
  }

  /// Panel rekomendasi profesional dengan visualisasi Bullish/Bearish
  Widget _buildRecommendationPanel(
    BuildContext context,
    _FlowRecommendation rec,
  ) {
    Color primaryColor;
    if (rec.isNeutral) {
      primaryColor = Colors.grey; // Atau Yellow
    } else {
      primaryColor = rec.isBullish ? Colors.greenAccent : Colors.redAccent;
    }

    return GestureDetector(
      onTap: () => _showSentimentExplanation(context, rec),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Sentiment & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'SENTIMENT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: 0.5 + (value * 0.5),
                          child: Icon(
                            Icons.auto_awesome,
                            color: primaryColor,
                            size: 14,
                          ),
                        );
                      },
                      onEnd: () {
                        // Animation completes without action
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      rec.isNeutral
                          ? Icons.remove_circle_outline
                          : (rec.isBullish
                                ? Icons.trending_up
                                : Icons.trending_down),
                      color: primaryColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${rec.sentiment} ${rec.isNeutral ? '' : (rec.isBullish ? '${rec.bullishPercentage}%' : '${rec.bearishPercentage}%')}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  // Bullish / Left Bar
                  Expanded(
                    flex: rec.bullishPercentage,
                    child: Container(
                      height: 8,
                      color: rec.isNeutral
                          ? Colors.grey.withValues(alpha: 0.5)
                          : Colors.greenAccent,
                    ),
                  ),
                  // Bearish / Right Bar
                  Expanded(
                    flex: rec.bearishPercentage,
                    child: Container(
                      height: 8,
                      color: rec.isNeutral
                          ? Colors.grey.withValues(alpha: 0.3)
                          : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 12, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  'Tap untuk lihat analisis lengkap',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show detailed sentiment explanation popup
  void _showSentimentExplanation(
    BuildContext context,
    _FlowRecommendation rec,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              rec.isNeutral
                  ? Icons.remove_circle_outline
                  : (rec.isBullish ? Icons.trending_up : Icons.trending_down),
              color: rec.isNeutral
                  ? Colors.grey
                  : (rec.isBullish ? Colors.greenAccent : Colors.redAccent),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Analisis ${rec.sentiment}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Percentage Display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            (rec.isBullish
                                    ? Colors.greenAccent
                                    : Colors.redAccent)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              (rec.isBullish
                                      ? Colors.greenAccent
                                      : Colors.redAccent)
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Optimis',
                                style: GoogleFonts.outfit(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${rec.bullishPercentage}%',
                                style: GoogleFonts.robotoMono(
                                  color: Colors.greenAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Pesimis',
                                style: GoogleFonts.outfit(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${rec.bearishPercentage}%',
                                style: GoogleFonts.robotoMono(
                                  color: Colors.redAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Explanation
                    if (rec.explanation.isNotEmpty) ...[
                      Text(
                        'Analisis',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rec.explanation,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Factors Breakdown
                    if (rec.factors.isNotEmpty) ...[
                      Text(
                        'Faktor Kunci',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...rec.factors.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC800FF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${entry.key}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(text: '${entry.value}'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Quant Warnings Section (NEW)
                    if (rec.quantWarnings.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              0xFFFF6B35,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFFF6B35),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'WARNING',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFF6B35),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...rec.quantWarnings.map((warning) {
                              Color warningColor;
                              switch (warning['type']) {
                                case 'DANGER':
                                  warningColor = Colors.redAccent;
                                  break;
                                case 'WARNING':
                                  warningColor = Colors.orangeAccent;
                                  break;
                                case 'SAFE':
                                  warningColor = Colors.greenAccent;
                                  break;
                                case 'OPPORTUNITY':
                                  warningColor = Colors.cyanAccent;
                                  break;
                                case 'MEGA_OPPORTUNITY':
                                  warningColor = const Color(
                                    0xFFFFD700,
                                  ); // Gold
                                  break;
                                case 'INFO':
                                  warningColor = Colors.blueAccent;
                                  break;
                                default:
                                  warningColor = Colors.white70;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: warningColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: warningColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          warning['icon'] ?? '⚠️',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            warning['message'] ?? '',
                                            style: GoogleFonts.outfit(
                                              color: warningColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (warning['detail'] != null &&
                                        warning['detail']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        warning['detail'],
                                        style: GoogleFonts.outfit(
                                          color: Colors.white60,
                                          fontSize: 10,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // NEW: BLACKROCK QUANT WARNING (Reactive)
                    if (forecastNotifier != null)
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: forecastNotifier!,
                        builder: (context, data, child) {
                          if (data != null) {
                            return Column(
                              children: [
                                const SizedBox(height: 16),
                                QuantWarningBlackRock(forecastData: data),
                              ],
                            );
                          } else {
                            // Loading State
                            return Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Analyzing Market Structure...",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Methodology Note with DYOR
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white38,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quant Architecture: Hybrid Bi-LSTM + Bi-GRU + Attention. Estimasi Akurasi: ~78% (Toleransi Error: ±12%). DYOR: Prediksi ini bukan saran finansial. Market sangat volatile. Selalu lakukan analisis mandiri.',
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.outfit(
                color: const Color(0xFFC800FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build tombol Fundamental dengan toggle state
  Widget _buildFundamentalButton() {
    return GestureDetector(
      onTap: onToggleFundamental,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF6B35), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              color: Color(0xFFFF6B35),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'FUNDAMENTAL',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFF6B35),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model untuk rekomendasi flow
class _FlowRecommendation {
  final bool isBullish;
  final bool isNeutral;
  final int bullishPercentage;
  final int bearishPercentage;
  final String sentiment;
  final String explanation;
  final Map<String, dynamic> factors;
  final List<Map<String, dynamic>> quantWarnings; // NEW

  _FlowRecommendation({
    required this.isBullish,
    this.isNeutral = false,
    required this.bullishPercentage,
    required this.bearishPercentage,
    required this.sentiment,
    this.explanation = '',
    this.factors = const {},
    this.quantWarnings = const [], // NEW
  });
}

/// Widget untuk menampilkan indikator flow individual
class _FlowIndicator extends StatelessWidget {
  final String label;
  final String status;
  final Color color;
  final String description;
  final IconData icon;
  final int? avgPrice;

  const _FlowIndicator({
    required this.label,
    required this.status,
    required this.color,
    required this.description,
    required this.icon,
    this.avgPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color.withValues(alpha: 0.7), size: 14),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    if (avgPrice != null)
                      Text(
                        'AVG: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(avgPrice)}',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}

/// Widget untuk menampilkan AI Analysis Tasks
class _AITasksSection extends StatelessWidget {
  final Map<String, dynamic>? dynamicAnalysis;
  final bool isLoading;

  const _AITasksSection({
    required this.dynamicAnalysis,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final dynamicTasks = dynamicAnalysis?['ai_tasks'] ?? {};

    final tasks = [
      _AITask(
        id: '1',
        name: 'Supply Demand',
        status: dynamicTasks['supply_demand'] ?? 'Normal',
      ),
      _AITask(
        id: '2',
        name: 'Foreign Flow',
        status: dynamicTasks['foreign_flow'] ?? 'Neutral',
      ),
      _AITask(
        id: '3',
        name: 'Technical Trend',
        status: dynamicTasks['technical_trend'] ?? 'Neutral',
      ),
      _AITask(
        id: '4',
        name: 'Momentum',
        status: dynamicTasks['momentum'] ?? 'Normal',
      ),
      _AITask(
        id: '5',
        name: 'Valuation',
        status: dynamicTasks['valuation'] ?? 'Fair',
      ),
      _AITask(
        id: '6',
        name: 'Sentiment',
        status: dynamicTasks['sentiment'] ?? 'Neutral',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
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
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading && dynamicAnalysis == null)
            const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3.8, // Reduced for compact view
              ),
              itemCount: tasks.length,
              itemBuilder: (context, index) => _AITaskItem(task: tasks[index]),
            ),
        ],
      ),
    );
  }
}

/// Model untuk AI Task
class _AITask {
  final String id;
  final String name;
  final String status;

  _AITask({required this.id, required this.name, required this.status});

  Color get color {
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

  IconData get icon {
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
      default:
        return Icons.circle;
    }
  }
}

/// Widget item untuk AI Task
class _AITaskItem extends StatelessWidget {
  final _AITask task;

  const _AITaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(task.icon, size: 12, color: task.color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  task.status,
                  style: TextStyle(
                    color: task.color,
                    fontSize: 9,
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
}

/// Widget untuk menampilkan Breaking News
class _BigNewsSection extends StatelessWidget {
  final Map<String, dynamic>? dynamicNews;
  final bool isLoading;

  const _BigNewsSection({required this.dynamicNews, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final newsText = dynamicNews?['news'] ?? 'Loading latest market updates...';
    final newsTime =
        dynamicNews?['time'] ??
        DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.now());
    final newsImpact =
        dynamicNews?['impact_detail'] ?? 'Analyzing potential price impact...';
    final newsImage = dynamicNews?['image'];
    final newsUrl = dynamicNews?['url'];

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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'BIG NEWS 🚨',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            if (isLoading && dynamicNews == null)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(12.0),
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
                              fontSize: 12,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'BREAKING: $newsTime',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 10, height: 1.3),
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
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          newsImage,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 8),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Source: Google News',
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.open_in_new, color: Colors.white38, size: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget disclaimer
class _DisclaimerWidget extends StatelessWidget {
  const _DisclaimerWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Text(
                'DISCLAIMER & DYOR',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Seluruh data, grafik, dan prediksi AI adalah simulasi hipotesis berdasarkan data historis. Performa masa lalu tidak menjamin hasil di masa depan. Berinvestasilah dengan bijak dan lakukan riset mandiri (Do Your Own Research).',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
