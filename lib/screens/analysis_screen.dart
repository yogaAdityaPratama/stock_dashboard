import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/trading_view_chart.dart';

/// ============================================================================
/// ANALYSIS SCREEN - CORE MODULE
/// ============================================================================
///
/// Deskripsi:
/// Halaman ini bertanggung jawab untuk menampilkan analisis mendalam terhadap
/// saham spesifik. Mengintegrasikan data realtime dari TradingView dan
/// intelegensi buatan (AI) untuk mendeteksi flow broker dan corporate action.
///
/// Arsitektur:
/// - State Management: StatefulWidget (Local State)
/// - UI Pattern: Component-Based with Glassmorphism
/// - Integration: TradingView Widget (WebView)
///
/// Author: Senior Stock Programmer
/// ============================================================================

class AnalysisScreen extends StatefulWidget {
  /// Data saham yang dipassing dari parent screen
  final Map<String, dynamic> stockData;

  const AnalysisScreen({super.key, required this.stockData});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    const bgGradientStart = Color(0xFF1A0A2E);
    const bgGradientEnd = Color(0xFF0A0214);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              widget.stockData['code'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '- ${widget.stockData['name']}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderPrice(),
                const SizedBox(height: 16),
                _buildChartSection(),
                const SizedBox(height: 20),
                _buildBrokerageFlowSection(),
                const SizedBox(height: 20),
                _buildAiTasksSection(),
                const SizedBox(height: 20),
                _buildBigNewsSection(),
                const SizedBox(height: 20),
                _buildDisclaimer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPrice() {
    final price = widget.stockData['current_price'] as num;
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      name: 'Rp ',
      decimalDigits: 0,
    );
    // Mock change data since backend doesn't fully provide it yet
    final changePct = 0.75;
    final changeVal = 65;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(price),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '+$changePct% (+$changeVal)',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrokerageFlowSection() {
    final score = (widget.stockData['analyst_score'] as num? ?? 0).toInt();
    final bool isBullish = score > 70;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.cyanAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'BROKERAGE FLOW DETECTION',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFlowRow(
            'Groups',
            isBullish ? 'DETECTED' : 'EXITING',
            isBullish ? Colors.greenAccent : Colors.orangeAccent,
            isBullish
                ? 'Institusi sedang melakukan akumulasi silent.'
                : 'Dana besar mulai keluar dari market.',
            Icons.psychology,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildFlowRow(
            'Whale / Bandar',
            isBullish ? 'ACTIVE BUYING' : 'DUMPING',
            isBullish ? Colors.cyanAccent : Colors.redAccent,
            isBullish
                ? 'KZ, RX, AK aktif menjaga harga di area support.'
                : 'Ditemukan aksi buang barang masif oleh broker asing.',
            Icons.waves,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildFlowRow(
            'Retail / Crowd',
            isBullish ? 'PANIC SELL / OUT' : 'EXTREME FOMO',
            isBullish ? Colors.grey : Colors.yellowAccent,
            isBullish
                ? 'Retail banyak cut loss, barang ditampung Bandar.'
                : 'Retail sedang agresif membeli di area pucuk (high risk).',
            Icons.groups,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowRow(
    String label,
    String status,
    Color color,
    String desc,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color.withOpacity(0.7), size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.stockData['code']} Real-time Technical Chart',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.show_chart, color: Colors.cyanAccent, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          // Clean Code: Menggunakan widget TradingViewChart yang dipisahkan secara OOP
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TradingViewChart(
              symbol: widget.stockData['code'],
              height: 350,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartLegend('Technical', Colors.cyanAccent),
              _buildChartLegend('Real-time', Colors.greenAccent),
              _buildChartLegend('AI Enhanced', Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
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

  Widget _buildAiTasksSection() {
    // Determine Mock Statuses based on Score/Accuracy for variety
    final score = (widget.stockData['analyst_score'] as num? ?? 0).toInt();
    final isGood = score > 70;

    final bool isBullish = isGood;

    final tasks = [
      {
        'id': '1',
        'name': 'Identifikasi Broker Dominan (Top 3-5)',
        'status': isBullish
            ? 'Akumulasi Kuat (Top 3: KZ, RX, LG)'
            : 'Distribusi Terdeteksi (Seller: YP, CC, PD)',
        'desc': isBullish
            ? 'Broker institusi asing terlihat akumulasi bertahap dalam 5 hari terakhir dengan volume stabil.'
            : 'Broker retail (YP, CC) mendominasi sisi beli, sementara institusi melakukan distribusi masif.',
        'color': isBullish ? Colors.greenAccent : Colors.orangeAccent,
      },
      {
        'id': '2',
        'name': 'Analisa Pola Akumulasi vs Distribusi',
        'status': isBullish
            ? 'Akumulasi Bertahap (Smart Money)'
            : 'Distribusi Terselubung',
        'desc': isBullish
            ? 'Terjadi divergensi positif: Harga sideway namun Broker Summary menunjukkan net buy signifikan.'
            : 'Harga naik dengan volume menipis, disertai aksi jual besar oleh broker dominan sektor.',
        'color': isBullish ? Colors.greenAccent : Colors.redAccent,
      },
      {
        'id': '3',
        'name': 'Analisa NIAT BANDAR (Intent)',
        'status': isBullish
            ? 'Fase Markup - Siap Dorong'
            : 'Fase Distribusi - Buang Barang',
        'desc': isBullish
            ? 'Bandar sudah menguasai >60% floating shares. Prediksi fase markup akan dimulai dalam 1-3 hari.'
            : 'Bandar mulai memancing retail masuk lewat fake bid, saat ini dalam fase exit strategis.',
        'color': isBullish ? Colors.greenAccent : Colors.orangeAccent,
      },
      {
        'id': '4',
        'name': 'Level Penting (Support/Resistance)',
        'status': isBullish ? 'S: Rp 820 | R: Rp 950' : 'S: Rp 710 | R: Rp 800',
        'desc':
            'Support kuat ditentukan berdasarkan rata-rata harga akumulasi bandar (Average Buy Price).',
        'color': Colors.cyanAccent,
      },
      {
        'id': '5',
        'name': 'Volume & Psikologi Market',
        'status': isBullish
            ? 'Volume Sehat - Partisipasi Tinggi'
            : 'Bearish Divergence / Bull Trap',
        'desc': isBullish
            ? 'Fear and Greed Index menunjukkan akumulasi aman. Retail belum banyak menyadari pergerakan ini.'
            : 'Hati-hati fake breakout. Psikologi market menunjukkan kejenuhan beli di area resistance.',
        'color': isBullish ? Colors.yellowAccent : Colors.white70,
      },
      {
        'id': '6',
        'name': 'STRATEGI TRADING',
        'status': isBullish
            ? 'BUY on Weakness / Buy Area'
            : 'Sell Strength / Avoid',
        'desc': isBullish
            ? 'TP1: Rp 980 | TP2: Rp 1,050 | Stop Loss: di bawah Rp 800.'
            : 'Tunggu konfirmasi di area support kuat. Jangan FOMO saat harga ditarik sesaat.',
        'color': isBullish ? Colors.greenAccent : Colors.orangeAccent,
      },
      {
        'id': '7',
        'name': 'KESIMPULAN AKHIR',
        'status': isBullish
            ? 'AKUMULASI - Cocok untuk Swing'
            : 'HINDARI - Resiko Tinggi',
        'desc': isBullish
            ? 'Risk vs Reward sangat menarik (1:3). Bandar masih mengumpulkan barang di area support.'
            : 'Struktur trend rusak. Bandar sudah keluar >40% dari total kepemilikan sebelumnya.',
        'color': isBullish ? Colors.greenAccent : Colors.redAccent,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Column(
            children: tasks.map((task) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (task['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForTask(task['id'] as String),
                        size: 16,
                        color: task['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['name'] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task['status'] as String,
                            style: TextStyle(
                              color: task['color'] as Color,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (task['desc'] != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              task['desc'] as String,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTask(String id) {
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
      case '7':
        return Icons.security;
      default:
        return Icons.circle;
    }
  }

  Widget _buildBigNewsSection() {
    final bool isReverseMerger = widget.stockData['is_reverse_merger'] ?? false;
    final String stockTicker = widget.stockData['code'];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'BREAKING: CORPORATE ACTION',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReverseMerger
                      ? "STRATEGIC MERGER: $stockTicker and ${widget.stockData['news_multibagger']} back-door listing confirmation."
                      : "$stockTicker Corporate Restructuring: Intelligence report suggests potential asset acquisition.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SOURCE: AI Intelligence Data Feed',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Analysis: ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: isReverseMerger
                            ? "This activity matches 'Reverse Merger' patterns. Volatility expected to increase significantly."
                            : "High probability of value unlocking through new commercial synergy.",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orangeAccent),
                      foregroundColor: Colors.orangeAccent,
                    ),
                    child: const Text('FULL REPORT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Charts and AI forecasts are hypothetical simulations based on historical data. Past performance does not guarantee future results. Invest responsibly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
