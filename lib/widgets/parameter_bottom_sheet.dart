import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScreeningParameters {
  double marketCapValue;
  double freeFloatValue;
  RangeValues priceRange;
  RangeValues aiScoreRange;
  RangeValues peRange;
  RangeValues roeRange;
  RangeValues pbvRange;
  bool perFilter;
  bool roeFilter;
  bool pbvFilter;
  bool dividendFilter;
  bool volumeFilter;
  double minVolume;

  ScreeningParameters({
    this.marketCapValue = 50,
    this.freeFloatValue = 15,
    this.priceRange = const RangeValues(50, 1000000),
    this.aiScoreRange = const RangeValues(70, 99),
    this.peRange = const RangeValues(0, 30),
    this.roeRange = const RangeValues(0, 50),
    this.pbvRange = const RangeValues(0, 10),
    this.perFilter = true,
    this.roeFilter = true,
    this.pbvFilter = false,
    this.dividendFilter = false,
    this.volumeFilter = false,
    this.minVolume = 1000000,
  });

  Map<String, dynamic> toJson() => {
    'market_cap_min': marketCapValue,
    'free_float_min': freeFloatValue,
    'price_min': priceRange.start,
    'price_max': priceRange.end,
    'ai_score_min': aiScoreRange.start,
    'ai_score_max': aiScoreRange.end,
    'pe_max': peRange.end,
    'roe_min': roeRange.start,
    'pbv_max': pbvRange.end,
    'has_dividend': dividendFilter,
    'min_volume': minVolume,
  };

  ScreeningParameters copyWith({
    double? marketCapValue,
    double? freeFloatValue,
    RangeValues? priceRange,
    RangeValues? aiScoreRange,
    RangeValues? peRange,
    RangeValues? roeRange,
    RangeValues? pbvRange,
    bool? perFilter,
    bool? roeFilter,
    bool? pbvFilter,
    bool? dividendFilter,
    bool? volumeFilter,
    double? minVolume,
  }) {
    return ScreeningParameters(
      marketCapValue: marketCapValue ?? this.marketCapValue,
      freeFloatValue: freeFloatValue ?? this.freeFloatValue,
      priceRange: priceRange ?? this.priceRange,
      aiScoreRange: aiScoreRange ?? this.aiScoreRange,
      peRange: peRange ?? this.peRange,
      roeRange: roeRange ?? this.roeRange,
      pbvRange: pbvRange ?? this.pbvRange,
      perFilter: perFilter ?? this.perFilter,
      roeFilter: roeFilter ?? this.roeFilter,
      pbvFilter: pbvFilter ?? this.pbvFilter,
      dividendFilter: dividendFilter ?? this.dividendFilter,
      volumeFilter: volumeFilter ?? this.volumeFilter,
      minVolume: minVolume ?? this.minVolume,
    );
  }
}

class ParameterBottomSheet extends StatefulWidget {
  final ScreeningParameters initialParams;
  final ValueChanged<ScreeningParameters> onParamsChanged;

  const ParameterBottomSheet({
    super.key,
    required this.initialParams,
    required this.onParamsChanged,
  });

  @override
  State<ParameterBottomSheet> createState() => _ParameterBottomSheetState();
}

class _ParameterBottomSheetState extends State<ParameterBottomSheet> {
  late ScreeningParameters _params;
  final Set<int> _expandedSections = {0};

  @override
  void initState() {
    super.initState();
    _params = widget.initialParams;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1A0A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(0, 'Price & Market', Icons.attach_money_rounded, _buildPriceSection()),
                _buildSection(1, 'Fundamental', Icons.analytics_rounded, _buildFundamentalSection()),
                _buildSection(2, 'Technical', Icons.candlestick_chart_rounded, _buildTechnicalSection()),
                _buildSection(3, 'Advanced', Icons.tune_rounded, _buildAdvancedSection()),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC800FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFFC800FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Parameters',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customize your screening filters',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(int index, String title, IconData icon, Widget content) {
    final isExpanded = _expandedSections.contains(index);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFFC800FF).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSections.remove(index);
                } else {
                  _expandedSections.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC800FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFFC800FF), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSliderWithLabel(
          'Price Range',
          '${currencyFormat.format(_params.priceRange.start)} - ${currencyFormat.format(_params.priceRange.end)}',
          RangeSlider(
            values: _params.priceRange,
            min: 50,
            max: 1000000,
            divisions: 100,
            activeColor: const Color(0xFFC800FF),
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _params.priceRange = v),
          ),
        ),
        const SizedBox(height: 16),
        _buildSliderWithLabel(
          'Market Cap',
          '>\$${_params.marketCapValue.toInt()}B',
          Slider(
            value: _params.marketCapValue,
            min: 0,
            max: 500,
            divisions: 50,
            activeColor: const Color(0xFF48CAE4),
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _params.marketCapValue = v),
          ),
        ),
        const SizedBox(height: 16),
        _buildSliderWithLabel(
          'Free Float',
          '>${_params.freeFloatValue.toInt()}%',
          Slider(
            value: _params.freeFloatValue,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: const Color(0xFF48CAE4),
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _params.freeFloatValue = v),
          ),
        ),
      ],
    );
  }

  Widget _buildFundamentalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSliderWithLabel(
          'AI Score',
          '${_params.aiScoreRange.start.toInt()}% - ${_params.aiScoreRange.end.toInt()}%',
          RangeSlider(
            values: _params.aiScoreRange,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: const Color(0xFFC800FF),
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _params.aiScoreRange = v),
          ),
        ),
        const SizedBox(height: 16),
        _buildSliderWithLabel(
          'PER Range',
          '${_params.peRange.start.toInt()} - ${_params.peRange.end.toInt()}x',
          RangeSlider(
            values: _params.peRange,
            min: 0,
            max: 50,
            divisions: 50,
            activeColor: const Color(0xFFC800FF),
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _params.peRange = v),
          ),
        ),
        const SizedBox(height: 16),
        _buildSliderWithLabel(
          'ROE Range',
          '${_params.roeRange.start.toInt()}% - ${_params.roeRange.end.toInt()}%',
          RangeSlider(
            values: _params.roeRange,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: const Color(0xFFC800FF),
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _params.roeRange = v),
          ),
        ),
        const SizedBox(height: 16),
        _buildSliderWithLabel(
          'PBV Max',
          '<${_params.pbvRange.end.toInt()}x',
          RangeSlider(
            values: _params.pbvRange,
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: const Color(0xFFC800FF),
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _params.pbvRange = v),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickChip('PER < 15', _params.perFilter, (v) => setState(() => _params.perFilter = v)),
            _buildQuickChip('ROE > 15%', _params.roeFilter, (v) => setState(() => _params.roeFilter = v)),
            _buildQuickChip('PBV < 2', _params.pbvFilter, (v) => setState(() => _params.pbvFilter = v)),
            _buildQuickChip('Dividend', _params.dividendFilter, (v) => setState(() => _params.dividendFilter = v)),
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical filters will use ML-based analysis based on timeframe selection',
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickChip('Volume Spike', _params.volumeFilter, (v) => setState(() => _params.volumeFilter = v)),
          ],
        ),
        if (_params.volumeFilter) ...[
          const SizedBox(height: 16),
          _buildSliderWithLabel(
            'Min Volume',
            NumberFormat.compact().format(_params.minVolume),
            Slider(
              value: _params.minVolume,
              min: 100000,
              max: 100000000,
              divisions: 100,
              activeColor: const Color(0xFF4ECDC4),
              inactiveColor: Colors.white24,
              onChanged: (v) => setState(() => _params.minVolume = v),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced filters for experienced investors',
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickChip('Smart Money', false, (_) {}),
            _buildQuickChip('Institutional', false, (_) {}),
            _buildQuickChip('Reverse Merger', false, (_) {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSliderWithLabel(String label, String value, Widget slider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text(value, style: const TextStyle(color: Color(0xFF48CAE4), fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        slider,
      ],
    );
  }

  Widget _buildQuickChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label, style: TextStyle(color: value ? Colors.white : Colors.white54, fontSize: 12)),
      selected: value,
      selectedColor: const Color(0xFFC800FF).withValues(alpha: 0.3),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      checkmarkColor: const Color(0xFFC800FF),
      side: BorderSide(color: value ? const Color(0xFFC800FF) : Colors.white.withValues(alpha: 0.1)),
      onSelected: onChanged,
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0221),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _resetToDefaults,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white54,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyParams,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC800FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _params = ScreeningParameters();
    });
  }

  void _applyParams() {
    widget.onParamsChanged(_params);
    Navigator.pop(context);
  }
}
