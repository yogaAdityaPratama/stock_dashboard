// ============================================================================
// WatchlistScreen - Halaman untuk mengelola daftar watchlist saham
// ============================================================================
//
// Fitur utama:
// - Multi-watchlist management (create, rename, delete)
// - Add/remove stocks dari watchlist
// - Navigasi ke analysis screen untuk detail saham
// - Persistent storage menggunakan SharedPreferences
//
// Prinsip yang digunakan:
// - OOP: Separation of concerns dengan WatchlistManager class
// - Clean Code: Single Responsibility, DRY principle
// - Best Practice: Proper resource management, error handling
//
// Author: Senior Flutter Developer & Clean Code Advocate
// Version: 2.0.0 (Refactored)
// Last Updated: 2026-02-17
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analysis_screen.dart';
import 'stocks_screen.dart';
import '../widgets/stock_card.dart';

// ============================================================================
// SECTION 1: CONSTANTS & CONFIGURATION
// ============================================================================

/// Konfigurasi tema untuk Watchlist Screen
class _WatchlistTheme {
  static const Color bgGradientStart = Color(0xFF1A0A2E);
  static const Color bgGradientEnd = Color(0xFF0A0214);
  static const Color primaryPurple = Color(0xFFC800FF);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white54;
  static const Color textHint = Colors.white30;
  static const Color borderColor = Colors.white24;
  static const Color errorColor = Colors.redAccent;
}

/// Storage keys untuk SharedPreferences
class _StorageKeys {
  static const String watchlistsData = 'watchlists_data';
  static const String selectedWatchlist = 'selected_watchlist';
}

// ============================================================================
// SECTION 2: WATCHLIST DATA MANAGER (OOP Pattern)
// ============================================================================

/// Manager class untuk handle semua operasi watchlist
/// Mengikuti Single Responsibility Principle
class WatchlistManager {
  final Map<String, List<Map<String, dynamic>>> _watchlists = {};
  String _selectedWatchlist = 'My Watchlist';

  /// Getter untuk watchlists (immutable)
  Map<String, List<Map<String, dynamic>>> get watchlists =>
      Map.unmodifiable(_watchlists);

  /// Getter untuk selected watchlist
  String get selectedWatchlist => _selectedWatchlist;

  /// Getter untuk watchlist names
  List<String> get watchlistNames => _watchlists.keys.toList();

  /// Getter untuk current watchlist stocks
  List<Map<String, dynamic>> get currentStocks =>
      _watchlists[_selectedWatchlist] ?? [];

  /// Constructor dengan default watchlist
  WatchlistManager() {
    _watchlists['My Watchlist'] = [];
  }

  /// Load data dari SharedPreferences
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString(_StorageKeys.watchlistsData);

      if (savedData != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedData);
        _watchlists.clear();

        decoded.forEach((key, value) {
          _watchlists[key] = List<Map<String, dynamic>>.from(
            (value as List).map((item) => Map<String, dynamic>.from(item)),
          );
        });
      }

      // Load selected watchlist
      _selectedWatchlist =
          prefs.getString(_StorageKeys.selectedWatchlist) ?? 'My Watchlist';

      // Validasi jika selected watchlist tidak ada lagi
      if (!_watchlists.containsKey(_selectedWatchlist)) {
        _selectedWatchlist = _watchlists.keys.first;
      }
    } catch (e) {
      debugPrint('⚠️ Error loading watchlists: $e');
      // Fallback ke default jika error
      _watchlists.clear();
      _watchlists['My Watchlist'] = [];
      _selectedWatchlist = 'My Watchlist';
    }
  }

  /// Save data ke SharedPreferences
  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_watchlists);
      await prefs.setString(_StorageKeys.watchlistsData, encoded);
      await prefs.setString(_StorageKeys.selectedWatchlist, _selectedWatchlist);
    } catch (e) {
      debugPrint('⚠️ Error saving watchlists: $e');
    }
  }

  /// Create watchlist baru
  /// Returns: true jika berhasil, false jika nama sudah ada
  bool createWatchlist(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || _watchlists.containsKey(trimmedName)) {
      return false;
    }
    _watchlists[trimmedName] = [];
    _selectedWatchlist = trimmedName;
    saveToStorage(); // Auto-save
    return true;
  }

  /// Rename watchlist
  /// Returns: true jika berhasil, false jika nama baru sudah ada
  bool renameWatchlist(String oldName, String newName) {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty ||
        !_watchlists.containsKey(oldName) ||
        _watchlists.containsKey(trimmedName)) {
      return false;
    }

    final stocks = _watchlists[oldName]!;
    _watchlists.remove(oldName);
    _watchlists[trimmedName] = stocks;

    if (_selectedWatchlist == oldName) {
      _selectedWatchlist = trimmedName;
    }

    saveToStorage(); // Auto-save
    return true;
  }

  /// Delete watchlist
  void deleteWatchlist(String name) {
    _watchlists.remove(name);

    // Pastikan selalu ada minimal 1 watchlist
    if (_watchlists.isEmpty) {
      _watchlists['My Watchlist'] = [];
    }

    // Update selected jika yang didelete adalah yang aktif
    if (_selectedWatchlist == name) {
      _selectedWatchlist = _watchlists.keys.first;
    }

    saveToStorage(); // Auto-save
  }

  /// Change selected watchlist
  void selectWatchlist(String name) {
    if (_watchlists.containsKey(name)) {
      _selectedWatchlist = name;
      saveToStorage(); // Auto-save
    }
  }

  /// Add stock ke watchlist
  /// Returns: true jika berhasil, false jika sudah ada
  bool addStock(String watchlistName, Map<String, dynamic> stock) {
    if (!_watchlists.containsKey(watchlistName)) return false;

    // Check duplikasi berdasarkan stock code
    final stocks = _watchlists[watchlistName]!;
    final isDuplicate = stocks.any((s) => s['code'] == stock['code']);

    if (isDuplicate) return false;

    stocks.add(stock);
    saveToStorage(); // Auto-save
    return true;
  }

  /// Remove stock dari watchlist
  void removeStock(String watchlistName, Map<String, dynamic> stock) {
    _watchlists[watchlistName]?.remove(stock);
    saveToStorage(); // Auto-save
  }
}

// ============================================================================
// SECTION 3: MAIN SCREEN WIDGET
// ============================================================================

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late final WatchlistManager _manager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _manager = WatchlistManager();
    _loadData();
  }

  /// Load data dari storage dengan error handling
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await _manager.loadFromStorage();
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load watchlists');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _buildBody(),
    );
  }

  // ========== UI BUILDERS ==========

  /// Build AppBar dengan dropdown dan action buttons
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _buildWatchlistDropdown(),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Create New Watchlist',
          onPressed: _showCreateWatchlistDialog,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handlePopupMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Text('Rename Watchlist'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete Watchlist',
                style: TextStyle(color: _WatchlistTheme.errorColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build watchlist dropdown selector
  Widget _buildWatchlistDropdown() {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(canvasColor: _WatchlistTheme.cardBackground),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _manager.watchlistNames.contains(_manager.selectedWatchlist)
              ? _manager.selectedWatchlist
              : null,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: _WatchlistTheme.textPrimary,
          ),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _WatchlistTheme.textPrimary,
          ),
          items: _manager.watchlistNames.map((name) {
            return DropdownMenuItem(value: name, child: Text(name));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() => _manager.selectWatchlist(newValue));
            }
          },
        ),
      ),
    );
  }

  /// Build body dengan gradient background
  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _WatchlistTheme.bgGradientStart,
            _WatchlistTheme.bgGradientEnd,
          ],
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : Column(
                children: [
                  _buildHeaderStats(),
                  Expanded(child: _buildWatchlistContent()),
                ],
              ),
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: _WatchlistTheme.primaryPurple),
    );
  }

  /// Build header dengan column labels
  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _WatchlistTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Symbol',
            style: GoogleFonts.outfit(
              color: _WatchlistTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            'Last Price / Change',
            style: GoogleFonts.outfit(
              color: _WatchlistTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build watchlist content (list atau empty state)
  Widget _buildWatchlistContent() {
    final stocks = _manager.currentStocks;

    if (stocks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
      itemCount: stocks.length,
      itemBuilder: (context, index) => _buildStockItem(stocks[index]),
    );
  }

  /// Build empty state UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_list_bulleted,
            size: 64,
            color: _WatchlistTheme.textPrimary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Watchlist is empty',
            style: GoogleFonts.outfit(color: _WatchlistTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add stocks',
            style: GoogleFonts.outfit(
              color: _WatchlistTheme.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stock card
  Widget _buildStockItem(Map<String, dynamic> stock) {
    return StockCard.fromMap(
      stock,
      onTap: () => _navigateToAnalysis(stock),
      onLongPress: () => _showRemoveStockDialog(stock),
    );
  }

  /// Build Floating Action Button
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToStocksScreen,
      backgroundColor: _WatchlistTheme.primaryPurple,
      icon: const Icon(Icons.add, color: _WatchlistTheme.textPrimary),
      label: Text(
        'Add Stock',
        style: GoogleFonts.outfit(
          color: _WatchlistTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ========== NAVIGATION HANDLERS ==========

  /// Navigasi ke StocksScreen untuk menambah saham
  Future<void> _navigateToStocksScreen() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StocksScreen()),
      );
      // Refresh data setelah kembali
      setState(() {});
    } catch (e) {
      _showErrorSnackbar('Navigation failed');
    }
  }

  /// Navigasi ke AnalysisScreen untuk melihat detail
  Future<void> _navigateToAnalysis(Map<String, dynamic> stock) async {
    try {
      await Navigator.push(
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
    } catch (e) {
      _showErrorSnackbar('Failed to open stock details');
    }
  }

  // ========== ACTION HANDLERS ==========

  /// Handle popup menu action
  void _handlePopupMenuAction(String value) {
    switch (value) {
      case 'delete':
        _showDeleteWatchlistDialog();
        break;
      case 'rename':
        _showRenameWatchlistDialog();
        break;
    }
  }

  // ========== DIALOG HELPERS ==========

  /// Show dialog untuk create watchlist baru
  void _showCreateWatchlistDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _buildInputDialog(
        title: 'New Watchlist',
        hintText: 'Watchlist Name',
        controller: controller,
        confirmText: 'Create',
        onConfirm: () {
          final name = controller.text.trim();
          if (name.isEmpty) {
            _showErrorSnackbar('Please enter a watchlist name');
            return;
          }

          if (_manager.createWatchlist(name)) {
            setState(() {});
            Navigator.pop(context);
            _showSuccessSnackbar('Watchlist "$name" created');
          } else {
            _showErrorSnackbar('Watchlist name already exists');
          }
        },
      ),
    ).then((_) => controller.dispose());
  }

  /// Show dialog untuk rename watchlist
  void _showRenameWatchlistDialog() {
    final controller = TextEditingController(text: _manager.selectedWatchlist);

    showDialog(
      context: context,
      builder: (context) => _buildInputDialog(
        title: 'Rename Watchlist',
        hintText: 'New Name',
        controller: controller,
        confirmText: 'Save',
        onConfirm: () {
          final newName = controller.text.trim();
          if (newName.isEmpty) {
            _showErrorSnackbar('Please enter a watchlist name');
            return;
          }

          if (_manager.renameWatchlist(_manager.selectedWatchlist, newName)) {
            setState(() {});
            Navigator.pop(context);
            _showSuccessSnackbar('Watchlist renamed to "$newName"');
          } else {
            _showErrorSnackbar('Watchlist name already exists');
          }
        },
      ),
    ).then((_) => controller.dispose());
  }

  /// Show dialog untuk delete watchlist
  void _showDeleteWatchlistDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildConfirmDialog(
        title: 'Delete Watchlist',
        content:
            'Are you sure you want to delete "${_manager.selectedWatchlist}"?',
        confirmText: 'Delete',
        isDangerous: true,
        onConfirm: () {
          final deletedName = _manager.selectedWatchlist;
          _manager.deleteWatchlist(deletedName);
          setState(() {});
          Navigator.pop(context);
          _showSuccessSnackbar('Watchlist "$deletedName" deleted');
        },
      ),
    );
  }

  /// Show dialog untuk remove stock
  void _showRemoveStockDialog(Map<String, dynamic> stock) {
    showDialog(
      context: context,
      builder: (context) => _buildConfirmDialog(
        title: 'Remove Stock?',
        content: 'Remove ${stock['code']} from ${_manager.selectedWatchlist}?',
        confirmText: 'Remove',
        isDangerous: true,
        onConfirm: () {
          _manager.removeStock(_manager.selectedWatchlist, stock);
          setState(() {});
          Navigator.pop(context);
          _showSuccessSnackbar('${stock['code']} removed');
        },
      ),
    );
  }

  // ========== REUSABLE DIALOG BUILDERS (DRY PRINCIPLE) ==========

  /// Build input dialog (untuk create/rename)
  Widget _buildInputDialog({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    return AlertDialog(
      backgroundColor: _WatchlistTheme.cardBackground,
      title: Text(
        title,
        style: const TextStyle(color: _WatchlistTheme.textPrimary),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: _WatchlistTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: _WatchlistTheme.textHint),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _WatchlistTheme.borderColor),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _WatchlistTheme.primaryPurple),
          ),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: const TextStyle(color: _WatchlistTheme.primaryPurple),
          ),
        ),
      ],
    );
  }

  /// Build confirmation dialog (untuk delete/remove)
  Widget _buildConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    bool isDangerous = false,
  }) {
    return AlertDialog(
      backgroundColor: _WatchlistTheme.cardBackground,
      title: Text(
        title,
        style: const TextStyle(color: _WatchlistTheme.textPrimary),
      ),
      content: Text(
        content,
        style: const TextStyle(color: _WatchlistTheme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: TextStyle(
              color: isDangerous
                  ? _WatchlistTheme.errorColor
                  : _WatchlistTheme.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  // ========== SNACKBAR HELPERS ==========

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _WatchlistTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
