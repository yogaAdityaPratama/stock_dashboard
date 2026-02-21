import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/timeframe_selector.dart';
import '../widgets/parameter_bottom_sheet.dart';
import 'analysis_screen.dart';

class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({super.key});

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _chatController = TextEditingController();

  String _selectedTactical = 'Deep Value';
  bool _isAutoMode = true;
  String _selectedTimeframe = 'Monthly';
  late ScreeningParameters _screeningParams;
  String _aiResponse = '';
  bool _isAiLoading = false;

  List<String> _tacticals = [];

  List<dynamic> _allResults = []; // Store original fetch
  List<dynamic> _results = []; // Store filtered
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _screeningParams = ScreeningParameters();
    _fetchTacticals();
    _runScreening();
  }

  Future<void> _fetchTacticals() async {
    try {
      final data = await _apiService.getStrategies();
      final strategies = data['strategies'] as List;
      setState(() {
        _tacticals = strategies.map((s) => s['name'].toString()).toList();
        if (_tacticals.isNotEmpty && !_tacticals.contains(_selectedTactical)) {
          _selectedTactical = _tacticals.first;
          _setTacticalDefaults(_selectedTactical);
        } else if (_tacticals.isNotEmpty &&
            _tacticals.contains(_selectedTactical)) {
          _setTacticalDefaults(_selectedTactical);
        } else if (_tacticals.isEmpty) {
          _selectedTactical = 'Deep Value';
          _setTacticalDefaults(_selectedTactical);
        }
      });
    } catch (e) {
      debugPrint('Error fetching tacticals: $e');
      setState(() {
        _tacticals = [
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
        if (!_tacticals.contains(_selectedTactical)) {
          _selectedTactical = _tacticals.first;
          _setTacticalDefaults(_selectedTactical);
        }
      });
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _setTacticalDefaults(String tactical) {
    setState(() {
      _selectedTactical = tactical;
      switch (tactical) {
        case 'Deep Value':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(50, 5000),
            aiScoreRange: const RangeValues(80, 99),
            freeFloatValue: 15,
            perFilter: true,
            roeFilter: true,
          );
          break;
        case 'Hyper Growth':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(100, 50000),
            aiScoreRange: const RangeValues(85, 99),
            freeFloatValue: 10,
            perFilter: false,
            roeFilter: true,
          );
          break;
        case 'Dividend King':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(500, 100000),
            aiScoreRange: const RangeValues(75, 99),
            freeFloatValue: 20,
            dividendFilter: true,
          );
          break;
        case 'Blue Chip':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(2000, 1000000),
            aiScoreRange: const RangeValues(70, 99),
            freeFloatValue: 10,
            marketCapValue: 100,
          );
          break;
        case 'Penny Gems':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(50, 500),
            aiScoreRange: const RangeValues(75, 99),
            freeFloatValue: 30,
          );
          break;
        case 'Momentum':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(100, 20000),
            aiScoreRange: const RangeValues(80, 99),
            freeFloatValue: 15,
            volumeFilter: true,
          );
          break;
        case 'Bottom Fish':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(50, 2000),
            aiScoreRange: const RangeValues(60, 85),
            freeFloatValue: 20,
          );
          break;
        case 'Institutional':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(1000, 100000),
            aiScoreRange: const RangeValues(85, 99),
            freeFloatValue: 10,
          );
          break;
        case 'Smart Money':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(100, 50000),
            aiScoreRange: const RangeValues(90, 99),
            freeFloatValue: 10,
          );
          break;
        case 'Scalper':
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(50, 1000),
            aiScoreRange: const RangeValues(70, 99),
            freeFloatValue: 40,
          );
          break;
        default:
          _screeningParams = _screeningParams.copyWith(
            priceRange: const RangeValues(50, 1000000),
            aiScoreRange: const RangeValues(0, 99),
            freeFloatValue: 10,
          );
          break;
      }
      _applyFiltersFromParams();
    });
  }

  Future<void> _runScreening() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> data;
      if (_isAutoMode) {
        data = await _apiService.screenStocksV2(
          mode: 'auto',
          tacticalStrategy: _selectedTactical,
          timeframe: 'Monthly',
          filters: _screeningParams.toJson(),
        );
      } else {
        data = await _apiService.screenStocksV2(
          mode: 'manual',
          timeframe: _selectedTimeframe,
          filters: _screeningParams.toJson(),
        );
      }
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
        final price = (stock['current_price'] ?? stock['price'] ?? 0) as num;
        final aiScore =
            (stock['analyst_score'] ?? stock['ml_accuracy'] ?? 0) as num;

        return price >= _screeningParams.priceRange.start &&
            price <= _screeningParams.priceRange.end &&
            aiScore >= _screeningParams.aiScoreRange.start &&
            aiScore <= _screeningParams.aiScoreRange.end;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Market Screener',
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
              Colors.black.withOpacity(0.7),
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
              _buildHeaderRow(),
              if (_isAutoMode) _buildTacticalTrigger(),
              if (!_isAutoMode) ...[
                TimeframeSelector(
                  selectedTimeframe: _selectedTimeframe,
                  onChanged: (tf) => setState(() => _selectedTimeframe = tf),
                ),
                const SizedBox(height: 10),
              ],
              _buildParameterTrigger(),
              const SizedBox(height: 10),
              if (!_isAutoMode) _buildChatInput(),
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
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'AI Engine Offline\nCheck backend connectivity',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.redAccent.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
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
                            ? const Color(0xFFC800FF).withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC800FF)
                              : Colors.white.withOpacity(0.1),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFC800FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC800FF).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC800FF).withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC800FF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFFC800FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVE AI STRATEGY',
                      style: TextStyle(
                        color: Color(0xFFC800FF),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedTactical,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
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

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ModeToggle(
              isAutoMode: _isAutoMode,
              onChanged: (isAuto) {
                setState(() {
                  _isAutoMode = isAuto;
                  if (isAuto) {
                    _setTacticalDefaults(_selectedTactical);
                  }
                });
                _runScreening();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterTrigger() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _showParameterSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF48CAE4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF48CAE4).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                color: const Color(0xFF48CAE4),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Edit Parameters',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF48CAE4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF48CAE4),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showParameterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ParameterBottomSheet(
        initialParams: _screeningParams,
        onParamsChanged: (params) {
          setState(() {
            _screeningParams = params;
          });
          _applyFiltersFromParams();
          _runScreening();
        },
      ),
    );
  }

  void _applyFiltersFromParams() {
    _applyFilters();
  }

  Widget _buildChatInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC800FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tanyakan kepada AI...',
                hintStyle: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => _sendChat(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isAiLoading ? null : _sendChat,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC800FF), Color(0xFF6C5CE7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isAiLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChat() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAiLoading = true;
    });

    try {
      final response = await _apiService.aiChat(
        prompt: text,
        screeningResults: _results.isNotEmpty
            ? _results
                  .map(
                    (s) => {
                      'code': s['code'],
                      'ml_accuracy': s['ml_accuracy'],
                      'entry_signal': s['entry_signal'],
                    },
                  )
                  .toList()
            : null,
        timeframe: _selectedTimeframe,
      );

      setState(() {
        _aiResponse =
            response['response'] ??
            'Maaf, saya tidak dapat memproses permintaan Anda.';
        _isAiLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_aiResponse, style: GoogleFonts.outfit(fontSize: 12)),
            backgroundColor: const Color(0xFF1A0A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'Terjadi kesalahan. Silakan coba lagi.';
        _isAiLoading = false;
      });
    }

    _chatController.clear();
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Code',
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Price',
              textAlign: TextAlign.right,
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'AI Score',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.cyanAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'ML Acc %',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 10),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rev. M',
              textAlign: TextAlign.right,
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 10),
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
      itemCount: _results.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final stock = _results[index];
        final accuracy =
            (stock['ml_accuracy'] ?? stock['analyst_score'] ?? 0) as num;
        final isReverseMerger = (stock['is_reverse_merger'] ?? false) as bool;
        final score =
            (stock['analyst_score'] ?? stock['ml_accuracy'] ?? 0) as int;
        final price = stock['current_price'] ?? stock['price'] ?? 0;

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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              gradient: isHighTier
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF4B0082).withOpacity(0.6),
                        const Color(0xFF8A2BE2).withOpacity(0.3),
                      ],
                    )
                  : null,
              color: isHighTier ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: isHighTier
                  ? Border.all(color: Colors.cyanAccent.withOpacity(0.5))
                  : Border.all(color: Colors.white10),
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
                          color: Colors.cyanAccent.withOpacity(0.8),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF1A0A2E).withOpacity(0.9),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: _runScreening,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A00F4), Color(0xFFC800FF)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC800FF).withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Run Screening',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.rocket_launch_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreeningDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Text(
        'DISCLAIMER: Sistem AI Screening menggunakan algoritma pembelajaran mesin untuk analisis saham. Hasil screening bersifat informatif dan tidak menjamin keuntungan investasi. Score dan rekomendasi yang diberikan AI adalah prediksi berdasarkan data historis dan pola pasar, bukan saran investasi profesional. Selalu lakukan analisis fundamental dan teknikal mandiri (DYOR) sebelum berinvestasi. Keputusan dan risiko investasi sepenuhnya tanggung jawab Anda.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 8),
      ),
    );
  }
}
