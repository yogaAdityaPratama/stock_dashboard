import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart'; // Ensure fl_chart is added for mini charts

import 'screens/screening_screen.dart';
import 'screens/placeholder_screens.dart';
import 'screens/calculator_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/news_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/trading_plan_screen.dart';
import 'screens/knowledge_screen.dart';

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
          ).withOpacity(0.8), // Translucent dark purple
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
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

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

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
              Colors.black.withOpacity(0.6),
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
                  color: const Color(0xFF8A2BE2).withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A2BE2).withOpacity(0.3),
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
                  color: Colors.cyanAccent.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.15),
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
                    _buildPortfolioSummary(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    Text(
                      'Trending Multibaggers',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTrendingList(context),
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

  Widget _buildPortfolioSummary(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: 180,
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Chart Wave (Abstract)
              Positioned(
                bottom: -20,
                left: 0,
                right: 0,
                height: 80,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 3),
                          const FlSpot(1, 4),
                          const FlSpot(2, 3.5),
                          const FlSpot(3, 5),
                          const FlSpot(4, 4.8),
                          const FlSpot(5, 6),
                          const FlSpot(6, 5.5),
                          const FlSpot(7, 7),
                        ],
                        isCurved: true,
                        color: Colors.white.withOpacity(0.1),
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Portfolio Value',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 1,250,500,000',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_circle_up_rounded,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+5.4%',
                          style: GoogleFonts.outfit(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Today\'s Gain',
                          style: GoogleFonts.outfit(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
              Icons.newspaper_rounded,
              'News',
              'Market Updates',
              const Color(0xFF00E5FF),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsScreen()),
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
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.01),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
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

  Widget _buildTrendingList(BuildContext context) {
    final stocks = [
      {
        'code': 'BBCA',
        'name': 'Bank Central Asia',
        'price': 'Rp 9,850',
        'change': '+2.3%',
        'color': Colors.greenAccent,
      },
      {
        'code': 'ADRO',
        'name': 'Adaro Energy',
        'price': 'Rp 2,450',
        'change': '+4.1%',
        'color': Colors.greenAccent,
      },
      {
        'code': 'GOTO',
        'name': 'GoTo Gojek Tokopedia',
        'price': 'Rp 82',
        'change': '+7.8%',
        'color': Colors.greenAccent,
      },
      {
        'code': 'TLKM',
        'name': 'Telkom Indonesia',
        'price': 'Rp 3,980',
        'change': '-0.5%',
        'color': Colors.redAccent,
      },
    ];

    return Column(
      children: stocks.map<Widget>((stock) => _buildStockCard(stock)).toList(),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock) {
    final isPositive = stock['change'].toString().startsWith('+');
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;
    // Mock data for mini chart
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
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.01),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stock['price'],
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
                        color: color.withOpacity(0.8),
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.2),
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
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        'DISCLAIMER: Nilai portofolio dan kinerja saham yang ditampilkan hanya untuk tujuan informasi. Kinerja masa lalu tidak menjamin hasil di masa depan. Selalu lakukan riset menyeluruh sebelum mengambil keputusan investasi.',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          color: Colors.grey.withOpacity(0.6),
          fontSize: 10,
        ),
      ),
    );
  }
}
