import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'analysis_screen.dart'; // To navigate to details

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data Structure
  // Map<CategoryName, List<StockData>>
  final Map<String, List<Map<String, dynamic>>> _watchlists = {
    'My Favorites': [
      {
        'code': 'BBCA',
        'name': 'Bank Central Asia',
        'price': 9850,
        'change': 2.3,
        'is_reverse_merger': false,
      },
      {
        'code': 'BBRI',
        'name': 'Bank Rakyat Indonesia',
        'price': 5400,
        'change': -1.2,
        'is_reverse_merger': false,
      },
    ],
    'Tech Growth': [
      {
        'code': 'GOTO',
        'name': 'GoTo Gojek Tokopedia',
        'price': 82,
        'change': 7.8,
        'is_reverse_merger': false,
      },
      {
        'code': 'BUKA',
        'name': 'Bukalapak',
        'price': 120,
        'change': 0.5,
        'is_reverse_merger': false,
      },
    ],
    'Dividend': [
      {
        'code': 'ITMG',
        'name': 'Indo Tambangraya',
        'price': 25000,
        'change': 1.5,
        'is_reverse_merger': false,
      },
      {
        'code': 'ADRO',
        'name': 'Adaro Energy',
        'price': 2450,
        'change': 4.1,
        'is_reverse_merger': false,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _watchlists.keys.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgGradientStart = Color(0xFF1A0A2E);
    const bgGradientEnd = Color(0xFF0A0214);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Watchlist',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search to add stock
              _showAddStockDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Watchlist',
            onPressed: _showCreateCategoryDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorColor: const Color(0xFFC800FF),
          indicatorSize: TabBarIndicatorSize.label,
          labelPadding: EdgeInsets.zero,
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
          tabs: _watchlists.keys.map((cat) => Tab(text: cat)).toList(),
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
          child: TabBarView(
            controller: _tabController,
            children: _watchlists.keys.map((cat) {
              return _buildWatchlistContent(cat);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistContent(String category) {
    final stocks = _watchlists[category] ?? [];

    if (stocks.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.list_alt,
                size: 64,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'This watchlist is empty',
                style: GoogleFonts.outfit(color: Colors.white54),
              ),
              TextButton(
                onPressed: _showAddStockDialog,
                child: const Text('Add Stock'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          return _buildStockItem(stock);
        },
      ),
    );
  }

  Widget _buildStockItem(Map<String, dynamic> stock) {
    final price = stock['price'] as num;
    final change = stock['change'] as num;
    final isPositive = change >= 0;
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;
    final currencyFmt = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      name: 'Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: () {
        // Navigate to details (reusing AnalysisScreen with minimal data)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              stockData: {
                ...stock,
                'current_price': price,
                'is_reverse_merger': false, // Mock
                'analyst_score': 85, // Mock
                'news_multibagger': 'Trending Up',
                'name': stock['name'],
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock['code'],
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  stock['name'],
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFmt.format(price),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}$change%',
                    style: GoogleFonts.outfit(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onLongPress: () {
        // Option to delete
        _showRemoveStockDialog(stock);
      },
    );
  }

  void _showCreateCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'New Watchlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g., gorengan',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _watchlists[controller.text] = [];
                  // Re-initialize tab controller with new length
                  final oldIndex = _tabController.index;
                  _tabController = TabController(
                    length: _watchlists.keys.length,
                    vsync: this,
                  );
                  _tabController.index = oldIndex;
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: Color(0xFFC800FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog() {
    // Mock stock search
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Add to ${_watchlists.keys.elementAt(_tabController.index)}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Stock Code (e.g. TLKM)',
                hintStyle: TextStyle(color: Colors.white30),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Mock adding stock
                setState(() {
                  final cat = _watchlists.keys.elementAt(_tabController.index);
                  _watchlists[cat]?.add({
                    'code': controller.text.toUpperCase(),
                    'name': 'Unknown Company', // Mock
                    'price': 1000, // Mock
                    'change': 0.0,
                    'is_reverse_merger': false,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Color(0xFFC800FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveStockDialog(Map<String, dynamic> stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Remove Stock?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove ${stock['code']} from ${_watchlists.keys.elementAt(_tabController.index)}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final cat = _watchlists.keys.elementAt(_tabController.index);
                _watchlists[cat]?.remove(stock);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
