import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async'; // Added for News Slider Timer
import 'package:fl_chart/fl_chart.dart'; // Ensure fl_chart is added for mini charts

import 'screens/screening_screen.dart';
import 'screens/placeholder_screens.dart';
import 'screens/calculator_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/stocks_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/trading_plan_screen.dart';
import 'screens/knowledge_screen.dart';
import 'screens/analysis_screen.dart';
import 'services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const StockIDApp());
}

class StockIDApp extends StatelessWidget {
  const StockIDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockID - Professional AI Screening',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4B0082),
        scaffoldBackgroundColor: const Color(0xFF0A0214),
        textTheme: GoogleFonts.outfitTextTheme(
          // Switched to Outfit for modern look
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4B0082),
          secondary: Color(0xFF301934),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          tertiary: Color(0xFF8A2BE2),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const MainContainer(),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const ScreeningScreen(),

      const CommunityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true, // Make body extend behind translucent nav bar
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(
            0xFF1A0A2E,
          ).withValues(alpha: 0.8), // Translucent dark purple
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              selectedItemColor: const Color(0xFFC800FF), // Neon Purple
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.psychology_rounded),
                  label: 'AI Screen',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.forum_rounded),
                  label: 'Community',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  Map<String, List<Map<String, dynamic>>> _categoryStocks = {
    'Gainer': [],
    'Hype': [],
    'MSCI': [],
    'FTSE': [],
    'Loser': [],
  };
  bool _isLoadingCategories = true;

  // News Slider State
  late PageController _newsController;
  int _currentNewsIndex = 0;
  Timer? _newsTimer;
  Timer? _updateTimer;
  List<dynamic> _newsList = [
    // Default fallback news
    {
      'title': 'IHSG Stabil di Level 7.200',
      'time': '1 jam lalu',
      'source': 'CNBC',
    },
    {
      'title': 'Saham Bank Big Caps Menguat',
      'time': '2 jam lalu',
      'source': 'Kontan',
    },
    {
      'title': 'Sektor Teknologi Mulai Rebound',
      'time': '3 jam lalu',
      'source': 'Bisnis',
    },
    {
      'title': 'The Fed Tahan Suku Bunga',
      'time': '5 jam lalu',
      'source': 'Bloomberg',
    },
    {
      'title': 'Harga Komoditas Emas Naik Tipis',
      'time': '6 jam lalu',
      'source': 'Investing',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _newsController = PageController();
    _fetchLivePrices();
    _fetchNews(); // Initial fetch
    _startNewsSlider();
    _startUpdateTimer();
  }

  void _fetchNews() async {
    try {
      final data = await _apiService.fetchMarketNews();
      if (mounted &&
          data['news'] != null &&
          (data['news'] as List).isNotEmpty) {
        setState(() {
          _newsList = data['news'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
    }
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Launch Error: $e');
    }
  }

  void _startNewsSlider() {
    _newsTimer?.cancel();
    _newsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _newsController.hasClients) {
        int nextPage = _currentNewsIndex + 1;
        if (nextPage >= _newsList.length) {
          nextPage = 0;
        }
        _newsController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentNewsIndex = nextPage;
        });
      }
    });
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _fetchNews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newsController.dispose();
    _newsTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLivePrices() async {
    if (!mounted) return;

    setState(() => _isLoadingCategories = true);

    try {
      final categories = await _apiService.fetchMarketCategories();
      if (mounted) {
        setState(() {
          // Robust key checking and data merging
          if (categories.isNotEmpty) {
            _categoryStocks = categories;
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching market dynamics: $e');
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 100,
        title: Image.asset('asset/logo.png', height: 80),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('asset/bg.jpg'),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.darken,
            ),
          ),
          gradient: const LinearGradient(
            begin: Alignment(0, 0.5),
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xFF0A0214)],
          ),
        ),
        child: Stack(
          children: [
            // Ambient background glows
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.3),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.15),
                      blurRadius: 80,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNewsSlider(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildCategoryTabs(),
                    const SizedBox(height: 20),
                    _buildCategoryList(),
                    const SizedBox(height: 32),
                    _buildDisclaimer(),
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSlider(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: PageView.builder(
            controller: _newsController,
            itemCount: _newsList.length,
            onPageChanged: (index) {
              setState(() {
                _currentNewsIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final news = _newsList[index];
              return GestureDetector(
                onTap: () => _launchURL(news['url']),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    CachedNetworkImage(
                      imageUrl:
                          (news['imageUrl'] != null &&
                              news['imageUrl'].toString().trim().isNotEmpty)
                          ? news['imageUrl'].toString().trim()
                          : 'https://images.unsplash.com/photo-1611974717482-aa002b6624f1?w=800&auto=format',
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.5),
                      colorBlendMode: BlendMode.darken,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFF13081E),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFFC800FF),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF4B0082), Color(0xFF0A0214)],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white.withValues(alpha: 0.1),
                            size: 40,
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFC800FF,
                              ).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              news['source'] ?? 'BREAKING NEWS',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            news['title'] ?? 'Market Updates',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            news['time'] ?? 'Just/Now',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Insights',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _actionCard(
              context,
              Icons.list_alt_rounded,
              'Stocks',
              '800+ Listed',
              const Color(0xFF00E5FF),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StocksScreen()),
              ),
            ),
            _actionCard(
              context,
              Icons.auto_graph_rounded,
              'Forecast',
              'AI Predictions',
              const Color(0xFFFF00E5),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForecastScreen()),
              ),
            ),
            _actionCard(
              context,
              Icons.star_rounded,
              'Watchlist',
              'Your Stocks',
              const Color(0xFFFFD600),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WatchlistScreen(),
                ),
              ),
            ),
            _actionCard(
              context,
              Icons.calculate_rounded,
              'Calculator',
              'Risk Tool',
              const Color(0xFF00FF94),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalculatorScreen(),
                ),
              ),
            ),
            _actionCard(
              context,
              Icons.assignment_rounded,
              'Plan',
              'Strategy',
              const Color(0xFFC800FF),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TradingPlanScreen(),
                ),
              ),
            ),
            _actionCard(
              context,
              Icons.menu_book_rounded,
              'Knowledge',
              'Learning',
              const Color(0xFF8A2BE2),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BasicKnowledgeScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.01),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Center(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF8A2BE2), Color(0xFFC800FF)],
            ),
          ),
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Gainer'),
            Tab(text: 'Hype'),
            Tab(text: 'MSCI'),
            Tab(text: 'FTSE'),
            Tab(text: 'Loser'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        if (_isLoadingCategories) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Color(0xFFC800FF)),
            ),
          );
        }

        if (_categoryStocks.isEmpty) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        const categoryKeys = ['Gainer', 'Hype', 'MSCI', 'FTSE', 'Loser'];
        final String categoryName = categoryKeys[_tabController.index];

        // Final fallback: Ensure list exists even if key mapping fails temporarily
        final List<Map<String, dynamic>> stocks =
            _categoryStocks[categoryName] ?? [];

        return SizedBox(
          height: 400, // Fixed height to show approx 4 cards
          child: ListView.builder(
            itemCount: stocks.take(10).length,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnalysisScreen(
                        stockData: {
                          ...stock,
                          'current_price': stock['price'],
                          'analyst_score': 85,
                        },
                      ),
                    ),
                  );
                },
                child: _buildStockCard(stock),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock) {
    final double changePercent = stock['changeNum'] ?? 0.0;
    final isPositive = changePercent >= 0;
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;

    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Mock data for mini chart remains for aesthetics
    final spots = isPositive
        ? [
            const FlSpot(0, 1),
            const FlSpot(1, 1.5),
            const FlSpot(2, 1.4),
            const FlSpot(3, 2),
            const FlSpot(4, 1.8),
            const FlSpot(5, 2.5),
          ]
        : [
            const FlSpot(0, 2.5),
            const FlSpot(1, 2),
            const FlSpot(2, 2.2),
            const FlSpot(3, 1.5),
            const FlSpot(4, 1.8),
            const FlSpot(5, 1),
          ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.01),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock['code'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      stock['name'],
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(stock['price']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.north_east : Icons.south_east,
                          color: color,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          stock['change'],
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 60,
                height: 30,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: color.withValues(alpha: 0.8),
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withValues(alpha: 0.2),
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

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(
        'DISCLAIMER: Nilai portofolio dan kinerja saham yang ditampilkan hanya untuk tujuan informasi. Kinerja masa lalu tidak menjamin hasil di masa depan. Selalu lakukan riset menyeluruh sebelum mengambil keputusan investasi.',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          color: Colors.grey.withValues(alpha: 0.6),
          fontSize: 10,
        ),
      ),
    );
  }
}
