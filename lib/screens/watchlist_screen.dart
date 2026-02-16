import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'analysis_screen.dart'; // To navigate to details
import 'stocks_screen.dart'; // To browse and add stocks
import '../widgets/stock_card.dart'; // Widget Custom untuk Kartu Saham

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  // Data Structure: Map<WatchlistName, List<StockData>>
  // Initialized with one empty default watchlist
  final Map<String, List<Map<String, dynamic>>> _watchlists = {
    'My Watchlist': [],
  };

  late String _selectedWatchlist;

  @override
  void initState() {
    super.initState();
    _selectedWatchlist = _watchlists.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    const bgGradientStart = Color(0xFF1A0A2E);
    const bgGradientEnd = Color(0xFF0A0214);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _buildWatchlistDropdown(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create New Watchlist',
            onPressed: _showCreateCategoryDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteWatchlistDialog();
              } else if (value == 'rename') {
                _showRenameWatchlistDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'rename',
                child: Text('Rename Watchlist'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text(
                  'Delete Watchlist',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToStocksScreen,
        backgroundColor: const Color(0xFFC800FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Stock',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderStats(), // Optional: Summary stats like Stockbit
              Expanded(child: _buildWatchlistContent(_selectedWatchlist)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xFF1E1E1E), // Dropdown background
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _watchlists.containsKey(_selectedWatchlist)
              ? _selectedWatchlist
              : null,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
          isExpanded: false,
          items: _watchlists.keys.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedWatchlist = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Symbol',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
          ),
          Text(
            'Last Price / Change',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistContent(String category) {
    final stocks = _watchlists[category] ?? [];

    if (stocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_list_bulleted,
              size: 64,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Watchlist is empty',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return _buildStockItem(stock);
      },
    );
  }

  void _navigateToStocksScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StocksScreen()),
    );
  }

  Widget _buildStockItem(Map<String, dynamic> stock) {
    // Menggunakan Widget StockCard yang Reusable (OOP & Clean Code)
    return StockCard.fromMap(
      stock,
      onTap: () {
        // Navigasi ke detail (menggunakan AnalysisScreen dengan data minimal)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              stockData: {
                ...stock,
                'current_price': (stock['price'] as num?)?.toDouble() ?? 0.0,
                'analyst_score': 85, // Mock data
                'news_multibagger': 'Trending Up', // Mock data
              },
            ),
          ),
        );
      },
      onLongPress: () {
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
            hintText: 'Watchlist Name',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFC800FF)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                if (_watchlists.containsKey(newName)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Watchlist name already exists'),
                    ),
                  );
                } else {
                  setState(() {
                    _watchlists[newName] = [];
                    _selectedWatchlist = newName;
                  });
                  Navigator.pop(context);
                }
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

  void _showRenameWatchlistDialog() {
    final controller = TextEditingController(text: _selectedWatchlist);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Rename Watchlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'New Name',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFC800FF)),
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
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != _selectedWatchlist) {
                if (_watchlists.containsKey(newName)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Watchlist name already exists'),
                    ),
                  );
                } else {
                  setState(() {
                    var stocks = _watchlists[_selectedWatchlist]!;
                    _watchlists.remove(_selectedWatchlist);
                    _watchlists[newName] = stocks;
                    _selectedWatchlist = newName;
                  });
                  Navigator.pop(context);
                }
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFC800FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteWatchlistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Watchlist',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "$_selectedWatchlist"?',
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
                _watchlists.remove(_selectedWatchlist);
                if (_watchlists.isEmpty) {
                  _watchlists['My Watchlist'] = [];
                }
                _selectedWatchlist = _watchlists.keys.first;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
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
          'Remove ${stock['code']} from $_selectedWatchlist?',
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
                _watchlists[_selectedWatchlist]?.remove(stock);
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
