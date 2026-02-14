import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // For ImageFilter
import '../services/api_service.dart';
import 'analysis_screen.dart';

class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({super.key});

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  final ApiService _apiService = ApiService();

  String _selectedTactical = 'Deep Value';

  final List<String> _tacticals = [
    'Deep Value',
    'Hyper Growth',
    'Dividend King',
    'Blue Chip',
    'Penny Gems',
    'Momentum',
    'Bottom Fish',
    'Institutional',
    'Smart Money',
    'Scalper',
  ];

  // UI State for filters
  double _marketCapValue = 50; // Billion
  double _freeFloatValue = 15; // Percent
  RangeValues _priceRange = const RangeValues(50, 1000000);
  RangeValues _aiScoreRange = const RangeValues(70, 99);
  bool _perFilter = true;
  bool _roeFilter = true;

  List<dynamic> _allResults = []; // Store original fetch
  List<dynamic> _results = []; // Store filtered
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setTacticalDefaults(_selectedTactical);
    _runScreening();
  }

  void _setTacticalDefaults(String tactical) {
    setState(() {
      _selectedTactical = tactical;
      switch (tactical) {
        case 'Deep Value':
          _priceRange = const RangeValues(50, 5000);
          _aiScoreRange = const RangeValues(80, 99);
          _freeFloatValue = 15;
          break;
        case 'Hyper Growth':
          _priceRange = const RangeValues(100, 50000);
          _aiScoreRange = const RangeValues(85, 99);
          _freeFloatValue = 10;
          break;
        case 'Dividend King':
          _priceRange = const RangeValues(500, 100000);
          _aiScoreRange = const RangeValues(75, 99);
          _freeFloatValue = 20;
          break;
        case 'Blue Chip':
          _priceRange = const RangeValues(2000, 1000000);
          _aiScoreRange = const RangeValues(70, 99);
          _freeFloatValue = 10;
          break;
        case 'Penny Gems':
          _priceRange = const RangeValues(50, 500);
          _aiScoreRange = const RangeValues(75, 99);
          _freeFloatValue = 30;
          break;
        case 'Momentum':
          _priceRange = const RangeValues(100, 20000);
          _aiScoreRange = const RangeValues(80, 99);
          _freeFloatValue = 15;
          break;
        case 'Bottom Fish':
          _priceRange = const RangeValues(50, 2000);
          _aiScoreRange = const RangeValues(60, 85);
          _freeFloatValue = 20;
          break;
        case 'Institutional':
          _priceRange = const RangeValues(1000, 100000);
          _aiScoreRange = const RangeValues(85, 99);
          _freeFloatValue = 10;
          break;
        case 'Smart Money':
          _priceRange = const RangeValues(100, 50000);
          _aiScoreRange = const RangeValues(90, 99);
          _freeFloatValue = 10;
          break;
        case 'Scalper':
          _priceRange = const RangeValues(50, 1000);
          _aiScoreRange = const RangeValues(70, 99);
          _freeFloatValue = 40;
          break;
      }
    });
  }

  Future<void> _runScreening() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final style = _selectedTactical;
      final data = await _apiService.screenStocks(style);
      setState(() {
        _allResults = data['results'] ?? [];
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _results = _allResults.where((stock) {
        final price = stock['current_price'] as num;
        final aiScore = stock['analyst_score'] as num? ?? 0;
        final freeFloat =
            stock['free_float'] as num? ??
            100; // Default to pass if data missing

        return price >= _priceRange.start &&
            price <= _priceRange.end &&
            aiScore >= _aiScoreRange.start &&
            aiScore <= _aiScoreRange.end &&
            freeFloat >= _freeFloatValue;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'AI Market Screener',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('asset/bg.jpg'),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7),
              BlendMode.darken,
            ),
          ),
          gradient: const LinearGradient(
            begin: Alignment(0, 0.5),
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xFF0A0214)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTacticalTrigger(),
              _buildControlPanel(),
              const SizedBox(height: 10),
              _buildTableHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.cyanAccent,
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _buildStockList(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildScreeningDisclaimer(),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _showTacticalSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1A0A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFC800FF),
              blurRadius: 20,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'PILIH TACTICAL STRATEGY',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI akan otomatis menyesuaikan parameter filter',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemCount: _tacticals.length,
                itemBuilder: (context, index) {
                  final tactical = _tacticals[index];
                  final isSelected = tactical == _selectedTactical;
                  return InkWell(
                    onTap: () {
                      _setTacticalDefaults(tactical);
                      _runScreening();
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFC800FF).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC800FF)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tactical,
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTacticalTrigger() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _showTacticalSelector,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFC800FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFC800FF).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC800FF).withValues(alpha: 0.05),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFC800FF).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFFC800FF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVE AI STRATEGY',
                      style: TextStyle(
                        color: Color(0xFFC800FF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedTactical,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      name: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8A2BE2).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          const SizedBox(height: 12),

          // Price Range Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price Range',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '${currencyFormat.format(_priceRange.start)} - ${currencyFormat.format(_priceRange.end)}',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFBB86FC),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.cyanAccent,
                  overlayColor: const Color(0xFFBB86FC).withValues(alpha: 0.2),
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: RangeSlider(
                  values: _priceRange,
                  min: 50,
                  max: 1000000,
                  divisions: 100,
                  labels: RangeLabels(
                    currencyFormat.format(_priceRange.start),
                    currencyFormat.format(_priceRange.end),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _priceRange = values;
                      _applyFilters();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // AI Score Range Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Score Filter',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '${_aiScoreRange.start.toInt()}% - ${_aiScoreRange.end.toInt()}%',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFBB86FC),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.cyanAccent,
                  overlayColor: const Color(0xFFBB86FC).withValues(alpha: 0.2),
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: RangeSlider(
                  values: _aiScoreRange,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  labels: RangeLabels(
                    '${_aiScoreRange.start.toInt()}%',
                    '${_aiScoreRange.end.toInt()}%',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _aiScoreRange = values;
                      _applyFilters();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Filter Rows
          // Market Cap Slider
          _buildFilterRow(
            label: 'Market Cap',
            child: Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: const Color(0xFFBB86FC),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        trackHeight: 2,
                      ),
                      child: Slider(
                        value: _marketCapValue,
                        min: 0,
                        max: 100,
                        onChanged: (v) {
                          setState(() => _marketCapValue = v);
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '>\$${_marketCapValue.toInt()}B',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Free Float Slider
          _buildFilterRow(
            label: 'Free Float',
            child: Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.cyanAccent,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        trackHeight: 2,
                      ),
                      child: Slider(
                        value: _freeFloatValue,
                        min: 0,
                        max: 100,
                        onChanged: (v) {
                          setState(() => _freeFloatValue = v);
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '>${_freeFloatValue.toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // PER Toggle
          _buildFilterRow(
            label: 'PER < 15',
            child: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _perFilter,
                activeColor: const Color(0xFFBB86FC),
                activeTrackColor: const Color(
                  0xFFBB86FC,
                ).withValues(alpha: 0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.black,
                onChanged: (v) => setState(() => _perFilter = v),
              ),
            ),
            trailingText: '< 15',
          ),
          const SizedBox(height: 4),
          // ROE Toggle
          _buildFilterRow(
            label: 'ROE > 15%',
            child: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _roeFilter,
                activeColor: const Color(0xFFBB86FC),
                activeTrackColor: const Color(
                  0xFFBB86FC,
                ).withValues(alpha: 0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.black,
                onChanged: (v) => setState(() => _roeFilter = v),
              ),
            ),
            trailingText: '15%',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow({
    required String label,
    required Widget child,
    String? trailingText,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        // Optional: Add subtle borders to rows if needed like the image
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          child,
          if (trailingText != null) ...[
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFBB86FC).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFFBB86FC).withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                trailingText,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Code',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Price',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'AI Score',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'ML Acc %',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rev. M',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList() {
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'No stocks found.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length + 1, // +1 for Disclaimer
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        if (index == _results.length) {
          return _buildDisclaimer();
        }

        final stock = _results[index];
        final accuracy = stock['ml_accuracy'] as num;
        final isReverseMerger = stock['is_reverse_merger'] as bool;
        final score = stock['analyst_score'] as int;
        final price = stock['current_price'];

        // Highlight row effect for top stocks
        final bool isHighTier = accuracy > 90 && score > 80;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalysisScreen(stockData: stock),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: isHighTier
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF4B0082).withValues(alpha: 0.6),
                        const Color(0xFF8A2BE2).withValues(alpha: 0.3),
                      ],
                    )
                  : null,
              color: isHighTier ? null : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: isHighTier
                  ? Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5))
                  : Border.all(color: Colors.white10),
              boxShadow: isHighTier
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    stock['code'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    NumberFormat.simpleCurrency(
                      locale: 'id_ID',
                      name: 'Rp ',
                      decimalDigits: 0,
                    ).format(price),
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '$score',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${accuracy.toInt()}%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accuracy >= 80
                          ? Colors.greenAccent
                          : Colors.white70,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    isReverseMerger ? 'YES' : 'No',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isReverseMerger
                          ? Colors.redAccent
                          : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF1A0A2E).withValues(alpha: 0.9),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: _runScreening,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A00F4), Color(0xFFC800FF)],
            ), // Neon Purple Gradient
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC800FF).withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Run AI Screening',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.smart_toy_outlined, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 40),
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
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Aplikasi ini menggunakan kecerdasan buatan (AI) hanya sebagai alat bantu analisis dan referensi. INI BUKAN SARAN INVESTASI ATAU KEUANGAN. \n\nSelalu lakukan riset mandiri (Do Your Own Research) secara mendalam sebelum mengambil keputusan. Segala keuntungan dan kerugian investasi adalah tanggung jawab penuh Anda masing-masing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Text(
        'DISCLAIMER: Sistem AI Screening menggunakan algoritma pembelajaran mesin untuk analisis saham. Hasil screening bersifat informatif dan tidak menjamin keuntungan investasi. Score dan rekomendasi yang diberikan AI adalah prediksi berdasarkan data historis dan pola pasar, bukan saran investasi profesional. Selalu lakukan analisis fundamental dan teknikal mandiri (DYOR) sebelum berinvestasi. Keputusan dan risiko investasi sepenuhnya tanggung jawab Anda.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 10),
      ),
    );
  }
}
