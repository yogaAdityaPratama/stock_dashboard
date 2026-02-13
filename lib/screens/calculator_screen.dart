import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'dart:ui';

class InvestmentCalculator {
  static double calculateFutureValue({
    required double initialInvestment,
    required double monthlyContribution,
    required double annualReturnRate,
    required int years,
    required double inflationRate,
    required double taxRate,
  }) {
    // Convert annual rates to monthly
    double monthlyRate = annualReturnRate / 100 / 12;
    int months = years * 12;

    // Future Value of Initial Investment
    double fvInitial = initialInvestment * pow(1 + monthlyRate, months);

    // Future Value of Annuity (Monthly Contributions)
    double fvContributions = 0;
    if (monthlyRate > 0) {
      fvContributions =
          monthlyContribution *
          (pow(1 + monthlyRate, months) - 1) /
          monthlyRate;
    } else {
      fvContributions = monthlyContribution * months;
    }

    double totalFV = fvInitial + fvContributions;

    // Apply Tax on Gains
    double totalInvested = initialInvestment + (monthlyContribution * months);
    double gains = totalFV - totalInvested;
    double taxAmount = gains > 0 ? gains * (taxRate / 100) : 0;
    double netAfterTax = totalFV - taxAmount;

    // Apply Inflation Adjustment (Real Return)
    // Formula: Real Value = Nominal Value / ((1 + inflation_rate)^years)
    double realValue = netAfterTax / pow(1 + (inflationRate / 100), years);

    return realValue;
  }

  static double calculateMonthlyTarget({
    required double targetAmount,
    required double initialInvestment,
    required double annualReturnRate,
    required int years,
  }) {
    double monthlyRate = annualReturnRate / 100 / 12;
    int months = years * 12;

    // FV = PV * (1+r)^n + PMT * [((1+r)^n - 1) / r]
    // PMT = (FV - PV * (1+r)^n) / [((1+r)^n - 1) / r]

    double fvInitial = initialInvestment * pow(1 + monthlyRate, months);
    double remainingTarget = targetAmount - fvInitial;

    if (remainingTarget <= 0) return 0;

    if (monthlyRate > 0) {
      return remainingTarget * monthlyRate / (pow(1 + monthlyRate, months) - 1);
    } else {
      return remainingTarget / months;
    }
  }

  static List<FlSpot> generateGrowthPoints({
    required double initialInvestment,
    required double monthlyContribution,
    required double annualReturnRate,
    required int years,
  }) {
    List<FlSpot> spots = [];
    double monthlyRate = annualReturnRate / 100 / 12;
    double currentBalance = initialInvestment;

    for (int i = 0; i <= years; i++) {
      spots.add(FlSpot(i.toDouble(), currentBalance));
      // Approximate growth for next year (loop 12 months)
      for (int m = 0; m < 12; m++) {
        currentBalance =
            (currentBalance + monthlyContribution) * (1 + monthlyRate);
      }
    }
    return spots;
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Investment Growth Inputs
  double _initialInvestment = 10000000; // 10 Juta
  double _monthlyContribution = 1000000; // 1 Juta
  double _annualReturn = 12.0; // Moderate
  int _years = 10;
  double _inflationRate = 3.0; // Avg Inflation
  double _taxRate = 0.0; // Start with 0

  // Goal Planning Inputs
  double _targetAmount = 1000000000; // 1 Milyar
  double _goalInitialInvestment = 5000000;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateProfile(String profile) {
    setState(() {
      if (profile == 'Conservative') {
        _annualReturn = 6.0;
      } else if (profile == 'Moderate') {
        _annualReturn = 12.0;
      } else if (profile == 'Aggressive') {
        _annualReturn = 18.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgGradientStart = Color(0xFF1A0A2E);
    const bgGradientEnd = Color(0xFF0A0214);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Financial Calculator',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
          tabs: const [
            Tab(text: 'Investment Growth'),
            Tab(text: 'Goal Planning'),
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
          child: TabBarView(
            controller: _tabController,
            children: [_buildGrowthTab(), _buildGoalTab()],
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthTab() {
    double futureValue = InvestmentCalculator.calculateFutureValue(
      initialInvestment: _initialInvestment,
      monthlyContribution: _monthlyContribution,
      annualReturnRate: _annualReturn,
      years: _years,
      inflationRate: _inflationRate,
      taxRate: _taxRate,
    );

    final currencyFmt = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      name: 'Rp ',
      decimalDigits: 0,
    );
    List<FlSpot> chartData = InvestmentCalculator.generateGrowthPoints(
      initialInvestment: _initialInvestment,
      monthlyContribution: _monthlyContribution,
      annualReturnRate: _annualReturn,
      years: _years,
    );

    // Scale chart data to not be too huge numbers for Y axis if needed,
    // but FlChart handles scaling. We just need to format axis titles.

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultCard(
            'Projected Wealth',
            currencyFmt.format(futureValue),
            subtitle: 'Net of Tax & Inflation (${_years} years)',
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            padding: const EdgeInsets.only(right: 16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: false,
                ), // Simplified for aesthetics
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: const Color(0xFFC800FF),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFC800FF).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSliderInput(
            'Initial Investment',
            _initialInvestment,
            0,
            1000000000,
            (val) => setState(() => _initialInvestment = val),
            currencyFmt,
          ),
          _buildSliderInput(
            'Monthly Contribution',
            _monthlyContribution,
            0,
            50000000,
            (val) => setState(() => _monthlyContribution = val),
            currencyFmt,
          ),
          _buildSliderInput(
            'Duration (Years)',
            _years.toDouble(),
            1,
            50,
            (val) => setState(() => _years = val.toInt()),
            null,
            0,
          ),

          const SizedBox(height: 16),
          Text(
            'Risk Profile & Return',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRiskButton('Conservative', Colors.greenAccent),
              _buildRiskButton('Moderate', Colors.amberAccent),
              _buildRiskButton('Aggressive', Colors.redAccent),
            ],
          ),
          const SizedBox(height: 16),
          _buildSliderInput(
            'Est. Annual Return (%)',
            _annualReturn,
            1,
            30,
            (val) => setState(() => _annualReturn = val),
            null,
            1,
          ),
          _buildAdvancedOptions(),
          const SizedBox(height: 24),
          _buildCalculatorDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildGoalTab() {
    // Goal Planning Calculation
    double monthlyNeeded = InvestmentCalculator.calculateMonthlyTarget(
      targetAmount: _targetAmount,
      initialInvestment: _goalInitialInvestment,
      annualReturnRate: _annualReturn,
      years: _years,
    );

    final currencyFmt = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      name: 'Rp ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultCard(
            'Required Monthly Saving',
            currencyFmt.format(monthlyNeeded),
            subtitle: 'To reach goal in $_years years',
          ),
          const SizedBox(height: 30),
          _buildSliderInput(
            'Target Amount',
            _targetAmount,
            10000000,
            10000000000,
            (val) => setState(() => _targetAmount = val),
            currencyFmt,
          ),
          _buildSliderInput(
            'Starting Balance',
            _goalInitialInvestment,
            0,
            1000000000,
            (val) => setState(() => _goalInitialInvestment = val),
            currencyFmt,
          ),
          _buildSliderInput(
            'Time Horizon (Years)',
            _years.toDouble(),
            1,
            50,
            (val) => setState(() => _years = val.toInt()),
            null,
            0,
          ),
          _buildSliderInput(
            'Est. Annual Return (%)',
            _annualReturn,
            1,
            30,
            (val) => setState(() => _annualReturn = val),
            null,
            1,
          ),
          const SizedBox(height: 24),
          _buildCalculatorDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, {String? subtitle}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4B0082).withOpacity(0.5),
                const Color(0xFF301934).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderInput(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    NumberFormat? fmt, [
    int decimals = 2,
  ]) {
    String displayValue = fmt != null
        ? fmt.format(value)
        : value.toStringAsFixed(0); // Default to int for years, or 1 decimal

    if (fmt == null && decimals > 0)
      displayValue = value.toStringAsFixed(decimals) + '%';
    if (label.contains('Years')) displayValue = '${value.toInt()} Years';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              displayValue,
              style: const TextStyle(
                color: Color(0xFFC800FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFC800FF),
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            overlayColor: const Color(0xFFC800FF).withOpacity(0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildRiskButton(String label, Color color) {
    bool isSelected = false;
    if (label == 'Conservative' && _annualReturn == 6.0) isSelected = true;
    if (label == 'Moderate' && _annualReturn == 12.0) isSelected = true;
    if (label == 'Aggressive' && _annualReturn == 18.0) isSelected = true;

    return GestureDetector(
      onTap: () => _updateProfile(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.white24),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? color : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return ExpansionTile(
      title: Text(
        'Advanced Options (Inflation & Tax)',
        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
      ),
      collapsedIconColor: Colors.white54,
      iconColor: Colors.white,
      children: [
        _buildSliderInput(
          'Inflation Rate (%)',
          _inflationRate,
          0,
          10,
          (val) => setState(() => _inflationRate = val),
          null,
          1,
        ),
        _buildSliderInput(
          'Tax Rate (%)',
          _taxRate,
          0,
          30,
          (val) => setState(() => _taxRate = val),
          null,
          1,
        ),
      ],
    );
  }

  Widget _buildCalculatorDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        'DISCLAIMER: Semua proyeksi dan perhitungan adalah estimasi berdasarkan asumsi tingkat pengembalian, inflasi, dan skenario pajak. Kinerja investasi aktual dapat berbeda secara signifikan. Kondisi pasar, faktor ekonomi, dan keadaan individu dapat mempengaruhi hasil. Alat ini hanya untuk tujuan edukasi dan bukan merupakan nasihat keuangan. Konsultasikan dengan penasihat keuangan yang berkualifikasi sebelum mengambil keputusan investasi.',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          color: Colors.grey.withOpacity(0.6),
          fontSize: 10,
        ),
      ),
    );
  }
}
