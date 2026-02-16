import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'msci_rebalancing_screen.dart';
import 'financial_calendar_screen.dart';

class BasicKnowledgeScreen extends StatefulWidget {
  const BasicKnowledgeScreen({super.key});

  @override
  State<BasicKnowledgeScreen> createState() => _BasicKnowledgeScreenState();
}

/// Screen: Fundamental Glossary
class FundamentalGlossaryScreen extends StatelessWidget {
  const FundamentalGlossaryScreen({super.key});

  final List<Map<String, String>> _terms = const [
    {
      'term': 'ROE',
      'desc':
          'Return on Equity: Laba bersih dibagi ekuitas pemegang saham (%). Mengukur profitabilitas modal.',
    },
    {
      'term': 'ROA',
      'desc':
          'Return on Assets: Laba bersih dibagi total aset. Efisiensi penggunaan aset.',
    },
    {'term': 'EPS', 'desc': 'Earnings Per Share: Laba bersih per saham.'},
    {
      'term': 'PER (P/E)',
      'desc':
          'Price-to-Earnings: Rasio harga saham terhadap laba per saham. Menilai valuasi relatif.',
    },
    {
      'term': 'PBV',
      'desc': 'Price-to-Book Value: Harga pasar dibagi nilai buku per saham.',
    },
    {
      'term': 'Market Cap',
      'desc': 'Kapitalisasi pasar: Harga saham x jumlah saham beredar.',
    },
    {
      'term': 'Dividend Yield',
      'desc': 'Dividen tahunan dibagi harga saham (%).',
    },
    {
      'term': 'Debt-to-Equity',
      'desc': 'Rasio utang terhadap ekuitas; ukuran leverage.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glosarium Fundamental'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0A2E), Color(0xFF0A0214)],
          ),
        ),
        child: ListView.separated(
          itemCount: _terms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final t = _terms[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['term']!,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t['desc']!,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Screen: Moody's Ratings Glossary
class MoodysRatingsScreen extends StatelessWidget {
  const MoodysRatingsScreen({super.key});

  final List<Map<String, String>> _ratings = const [
    {
      'rating': 'Aaa',
      'desc':
          "Tertinggi: Risiko kredit sangat rendah. Kualitas kredit sangat kuat.",
    },
    {
      'rating': 'Aa',
      'desc':
          "Sangat baik: Risiko kredit sangat rendah, sedikit lebih rentan terhadap kondisi ekonomi.",
    },
    {
      'rating': 'A',
      'desc':
          "Baik: Risiko kredit rendah; sensitivitas moderat terhadap perubahan ekonomi.",
    },
    {
      'rating': 'Baa',
      'desc':
          "Investment Grade rendah: Risiko moderat; mungkin rentan terhadap kondisi ekonomi.",
    },
    {
      'rating': 'Ba',
      'desc': "Speculative: Risiko kredit material; bukan investment grade.",
    },
    {
      'rating': 'B',
      'desc':
          "Lebih spekulatif: Risiko tinggi terhadap gagal bayar dalam kondisi buruk.",
    },
    {
      'rating': 'Caa',
      'desc':
          "Sangat spekulatif: Risiko sangat tinggi; kemungkinan gagal bayar signifikan.",
    },
    {
      'rating': 'Ca',
      'desc':
          "Terdekat pada gagal bayar: Sebagian besar obligasi ini sudah bermasalah.",
    },
    {
      'rating': 'C',
      'desc': "Dalam kondisi gagal bayar atau sudah gagal bayar.",
    },
    {
      'rating': "Notches / Modifiers",
      'desc':
          "Angka 1,2,3 (mis. Aa1,Aa2) menunjukkan peringkat relatif di dalam kategori.",
    },
    {
      'rating': "Short-term (P-1/P-2/P-3)",
      'desc':
          "Penilaian likuiditas jangka pendek; P-1 terbaik, P-3 paling lemah di investment grade short-term.",
    },
    {
      'rating': "Investment Grade vs Speculative",
      'desc':
          "Investment grade: Aaa – Baa3. Speculative (junk): Ba1 dan lebih rendah.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Moody's Ratings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0A2E), Color(0xFF0A0214)],
          ),
        ),
        child: ListView.separated(
          itemCount: _ratings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final r = _ratings[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['rating']!,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r['desc']!,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BasicKnowledgeScreenState extends State<BasicKnowledgeScreen> {
  String searchQuery = '';
  late PageController _newsPageController;
  int _currentNewsIndex = 0;
  Timer? _newsTimer;

  final ApiService _apiService = ApiService();
  List<dynamic> _topStories = [];
  bool _isTopNewsLoading = true;
  Map<String, String> _dynamicMarketTags = {}; // Dynamic tags from backend
  String _newsScope = 'IDN'; // or 'Global'

  final List<String> _globalKeywords = [
    'global',
    'war',
    'finance',
    'trump',
    'the fed',
    'thefed',
    'moody',
    'moody\'s',
    'msci',
    'ftse',
    'oil',
    'minyak',
    'technology',
    'tech',
    'market',
    'commodity',
  ];
  final List<String> _localIndicators = [
    '.id',
    'indonesia',
    'kompas',
    'kontan',
    'cnbc indonesia',
    'cnn indonesia',
    'antaranews',
    'bisnis',
    'tempo',
    'detik',
    'tribun',
  ];

  final List<Map<String, dynamic>> headlineNews = [
    {
      'news':
          'IHSG Melejit! Sektor Perbankan Pimpin Kenaikan di Tengah Arus Modal Asing.',
      'impact':
          'Sentimen Sangat Positif. Menandakan kepercayaan investor global meningkat.',
      'time': '10 mins ago',
      'image':
          'https://images.unsplash.com/photo-1611974717482-aa002b6624f1?w=500&auto=format',
      'url': 'https://finance.yahoo.com/quote/%5EJKSE',
    },
    {
      'news':
          'Saham GOTO Rebound Kuat setelah Rilis Laporan Kinerja Kuartalan yang Solid.',
      'impact':
          'Sentimen Positif. Memperbaiki psikologi pasar di sektor teknologi.',
      'time': '35 mins ago',
      'image':
          'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=500&auto=format',
      'url': 'https://finance.yahoo.com/quote/GOTO.JK',
    },
    {
      'news':
          'The Fed Pertahankan Suku Bunga: Sinyal Dovish Bikin Pasar Saham Bergairah.',
      'impact':
          'Sentimen Bullish. Likuiditas pasar berpotensi meningkat secara global.',
      'time': '1 hour ago',
      'image':
          'https://images.unsplash.com/photo-1535320485706-44d43b919500?w=500&auto=format',
      'url': 'https://www.google.com/search?q=fed+interest+rate',
    },
    {
      'news':
          'Harga Komoditas Nikel Melonjak tajam Akibat Gangguan Pasokan Global.',
      'impact':
          'Sentimen Sektoral. Prospek positif bagi emiten tambang nikel seperti INCO & ANTM.',
      'time': '2 hours ago',
      'image':
          'https://images.unsplash.com/photo-1518458028785-8fbcd101ebb9?w=500&auto=format',
      'url': 'https://www.tradingview.com/symbols/MCX-NICKEL1!/',
    },
    {
      'news':
          'Analisa AI: 5 Saham dengan Potensi Multibagger di Sektor Renewable Energy.',
      'impact':
          'Sentimen Jangka Panjang. Fokus pada transisi energi hijau di Indonesia.',
      'time': '4 hours ago',
      'image':
          'https://images.unsplash.com/photo-1466611653911-95282ee04d2e?w=500&auto=format',
      'url': 'https://www.google.com/search?q=saham+renewable+energy+indonesia',
    },
  ];

  @override
  void initState() {
    super.initState();
    _newsPageController = PageController();
    _startNewsTimer();
    _loadTopStories();
    _loadDynamicMarketTags();
  }

  Future<void> _loadDynamicMarketTags() async {
    try {
      final categories = await _apiService.fetchMarketCategories();
      final Map<String, String> newTags = {};

      if (categories.containsKey('MSCI')) {
        for (var stock in categories['MSCI']!) {
          newTags[stock['code']] = 'MSCI';
        }
      }
      if (categories.containsKey('Hype')) {
        for (var stock in categories['Hype']!) {
          newTags[stock['code']] = 'Hype';
        }
      }

      if (mounted && newTags.isNotEmpty) {
        setState(() {
          _dynamicMarketTags = newTags;
        });
      }
    } catch (e) {
      debugPrint('Error loading dynamic market tags: $e');
    }
  }

  Future<void> _loadTopStories() async {
    try {
      final data = await _apiService.fetchMarketNews();
      if (mounted) {
        setState(() {
          if (data['news'] != null) {
            _topStories = data['news'];
          }
          _isTopNewsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading top stories: $e');
      if (mounted) setState(() => _isTopNewsLoading = false);
    }
  }

  void _startNewsTimer() {
    _newsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_newsPageController.hasClients) {
        if (_currentNewsIndex < headlineNews.length - 1) {
          _currentNewsIndex++;
        } else {
          _currentNewsIndex = 0;
        }
        _newsPageController.animateToPage(
          _currentNewsIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _newsTimer?.cancel();
    _newsPageController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> brokers = [
    // FOREIGN BROKERS
    {
      'code': 'AK',
      'name': 'UBS Sekuritas',
      'type': 'Foreign',
      'origin': 'Switzerland',
      'flag': '🇨🇭',
      'aum': 'Rp 850T+',
      'pnl': '+14.2%',
      'risk': 'Medium',
      'dominance': 0.85,
      'desc':
          'Raksasa finansial Swiss dengan spesialisasi Arbitrase dan Institutional Order Flow.',
    },
    {
      'code': 'BK',
      'name': 'J.P. Morgan Sekuritas',
      'type': 'Foreign',
      'origin': 'USA',
      'flag': '🇺🇸',
      'aum': 'Rp 920T+',
      'pnl': '+15.5%',
      'risk': 'Medium',
      'dominance': 0.92,
      'desc':
          'Market leader global asal Amerika, sering menjadi indikator arah dana asing masuk ke IHSG.',
    },
    {
      'code': 'CS',
      'name': 'Credit Suisse Sekuritas',
      'type': 'Foreign',
      'origin': 'Switzerland',
      'flag': '🇨🇭',
      'aum': 'Rp 740T+',
      'pnl': '+11.8%',
      'risk': 'High',
      'dominance': 0.78,
      'desc':
          'Institusi besar Swiss yang fokus pada nasabah Ultra High Net Worth dan sektor komoditas.',
    },
    {
      'code': 'KZ',
      'name': 'CLSA Sekuritas',
      'type': 'Foreign',
      'origin': 'China/HK',
      'flag': '🇨🇳',
      'aum': 'Rp 680T+',
      'pnl': '+13.0%',
      'risk': 'Medium',
      'dominance': 0.81,
      'desc':
          'Broker asal Hong Kong (CITIC China) yang terkenal dengan riset kuantitatif mendalam.',
    },
    {
      'code': 'MS',
      'name': 'Morgan Stanley Sekuritas',
      'type': 'Foreign',
      'origin': 'USA',
      'flag': '🇺🇸',
      'aum': 'Rp 890T+',
      'pnl': '+16.1%',
      'risk': 'Medium',
      'dominance': 0.88,
      'desc':
          'Investment bank elit Amerika, ahli penempatan dana besar yang sering memicu breakout.',
    },
    {
      'code': 'RX',
      'name': 'Macquarie Sekuritas',
      'type': 'Foreign',
      'origin': 'Australia',
      'flag': '🇦🇺',
      'aum': 'Rp 560T+',
      'pnl': '+10.5%',
      'risk': 'Low',
      'dominance': 0.70,
      'desc':
          'Firma finansial Australia dengan fokus pada aset infrastruktur dan perbankan.',
    },
    {
      'code': 'YU',
      'name': 'CGS-CIMB Sekuritas',
      'type': 'Foreign',
      'origin': 'ASEAN',
      'flag': '🇸🇬',
      'aum': 'Rp 510T+',
      'pnl': '+11.2%',
      'risk': 'Medium',
      'dominance': 0.75,
      'desc':
          'Joint venture Malaysia-Singapura dengan penetrasi pasar luas di Asia Tenggara.',
    },
    {
      'code': 'ZP',
      'name': 'Maybank Sekuritas',
      'type': 'Foreign',
      'origin': 'Malaysia',
      'flag': '🇲🇾',
      'aum': 'Rp 480T+',
      'pnl': '+10.8%',
      'risk': 'Low',
      'dominance': 0.68,
      'desc':
          'Grup perbankan terbesar Malaysia, fokus pada portofolio institusi regional.',
    },
    {
      'code': 'DR',
      'name': 'RHB Sekuritas',
      'type': 'Foreign',
      'origin': 'Malaysia',
      'flag': '🇲🇾',
      'aum': 'Rp 420T+',
      'pnl': '+9.8%',
      'risk': 'Medium',
      'dominance': 0.65,
      'desc':
          'Broker Malaysia yang aktif dalam transaksi cross-border dan pendanaan korporasi.',
    },
    {
      'code': 'TJ',
      'name': 'Shinhan Sekuritas',
      'type': 'Foreign',
      'origin': 'South Korea',
      'flag': '🇰🇷',
      'aum': 'Rp 390T+',
      'pnl': '+12.1%',
      'risk': 'High',
      'dominance': 0.62,
      'desc':
          'Broker progresif Korea Selatan yang agresif di sektor teknologi dan digital.',
    },
    {
      'code': 'BS',
      'name': 'BancAmerica Sekuritas',
      'type': 'Foreign',
      'origin': 'USA',
      'flag': '🇺🇸',
      'aum': 'Rp 710T+',
      'pnl': '+13.5%',
      'risk': 'Medium',
      'dominance': 0.79,
      'desc':
          'Lengan investasi Bank of America, menangani aliran dana besar institusi AS.',
    },
    {
      'code': 'DB',
      'name': 'Deutsche Sekuritas',
      'type': 'Foreign',
      'origin': 'Germany',
      'flag': '🇩🇪',
      'aum': 'Rp 680T+',
      'pnl': '+11.9%',
      'risk': 'Medium',
      'dominance': 0.74,
      'desc':
          'Raksasa perbankan Jerman, spesialis instrumen derivatif dan institusi Eropa.',
    },

    // LOCAL RETAIL & POPULAR
    {
      'code': 'YP',
      'name': 'Mirae Asset Sekuritas',
      'type': 'Local Retail',
      'origin': 'South Korea',
      'flag': '🇰🇷',
      'aum': 'Rp 450T+',
      'pnl': '+18.2%',
      'risk': 'Very High',
      'dominance': 0.95,
      'desc':
          'Meskipun asal Korea, YP adalah pusat likuiditas retail terbesar di Indonesia.',
    },
    {
      'code': 'PD',
      'name': 'Indo Premier Sekuritas',
      'type': 'Local Retail',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 380T+',
      'pnl': '+14.5%',
      'risk': 'High',
      'dominance': 0.88,
      'desc':
          'Pelopor platform trading online retail lokal dengan fitur analisis terlengkap.',
    },
    {
      'code': 'XC',
      'name': 'Ajaib Sekuritas',
      'type': 'Local Retail',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 210T+',
      'pnl': '+15.2%',
      'risk': 'Very High',
      'dominance': 0.82,
      'desc':
          'Unicorn fintech lokal favorit milenial dengan pertumbuhan user tercepat.',
    },
    {
      'code': 'XL',
      'name': 'Stockbit Sekuritas',
      'type': 'Local Retail',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 190T+',
      'pnl': '+13.8%',
      'risk': 'High',
      'dominance': 0.79,
      'desc':
          'Platform sosial-investasi lokal yang terintegrasi dengan komunitas terbesar.',
    },
    {
      'code': 'EP',
      'name': 'MNC Sekuritas',
      'type': 'Local Retail',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 280T+',
      'pnl': '+11.5%',
      'risk': 'Medium',
      'dominance': 0.72,
      'desc':
          'Broker lokal bagian dari grup media MNC, kuat dalam dukungan riset korporasi.',
    },
    {
      'code': 'KK',
      'name': 'Phillip Sekuritas',
      'type': 'Local Retail',
      'origin': 'Singapore',
      'flag': '🇸🇬',
      'aum': 'Rp 320T+',
      'pnl': '+12.4%',
      'risk': 'Medium',
      'dominance': 0.75,
      'desc':
          'Broker asal Singapura yang menawarkan akses pasar global bagi retail lokal.',
    },
    {
      'code': 'DH',
      'name': 'Sinarmas Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 410T+',
      'pnl': '+13.1%',
      'risk': 'Medium',
      'dominance': 0.78,
      'desc':
          'Broker grup konglomerat Sinar Mas, dominan di transaksi institusi lokal.',
    },
    {
      'code': 'AZ',
      'name': 'Sucor Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 290T+',
      'pnl': '+16.5%',
      'risk': 'High',
      'dominance': 0.81,
      'desc':
          'Firma lokal legendaris yang terkenal dengan komunitas trader agresifnya.',
    },
    {
      'code': 'LG',
      'name': 'Trimegah Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 340T+',
      'pnl': '+12.9%',
      'risk': 'Medium',
      'dominance': 0.76,
      'desc':
          'Broker lokal papan atas yang fokus pada investment banking dan dana kakap.',
    },
    {
      'code': 'GR',
      'name': 'Panin Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 310T+',
      'pnl': '+11.2%',
      'risk': 'Low',
      'dominance': 0.70,
      'desc':
          'Broker lokal konservatif dengan fundamental riset pertahanan yang solid.',
    },
    {
      'code': 'IF',
      'name': 'Samuel Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 260T+',
      'pnl': '+12.8%',
      'risk': 'Medium',
      'dominance': 0.68,
      'desc':
          'Penyedia riset independen lokal yang tajam dan menjadi rujukan institusi.',
    },
    {
      'code': 'RG',
      'name': 'Profindo Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 150T+',
      'pnl': '+10.5%',
      'risk': 'Medium',
      'dominance': 0.55,
      'desc':
          'Melayani nasabah korporasi lokal menengah dan individu HNWI terpilih.',
    },
    {
      'code': 'MG',
      'name': 'Semesta Indovest',
      'type': 'Local (MM)',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 420T+',
      'pnl': '+22.1%',
      'risk': 'Extreme',
      'dominance': 0.89,
      'desc':
          'Pemain lokal yang sering dianggap sebagai penggerak utama likuiditas harian.',
    },
    {
      'code': 'AO',
      'name': 'Anugerah Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 120T+',
      'pnl': '+9.5%',
      'risk': 'Medium',
      'dominance': 0.52,
      'desc':
          'Fokus pada layanan personal bagi nasabah ritel tradisional di daerah.',
    },
    {
      'code': 'YI',
      'name': 'BCA Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 580T+',
      'pnl': '+13.4%',
      'risk': 'Low',
      'dominance': 0.86,
      'desc':
          'Keamanan grup BCA, fokus mengelola portofolio nasabah prioritas lokal.',
    },

    // BUMN / INSTITUTIONAL
    {
      'code': 'CC',
      'name': 'Mandiri Sekuritas',
      'type': 'Local (BUMN)',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 600T+',
      'pnl': '+12.7%',
      'risk': 'Low',
      'dominance': 0.85,
      'desc':
          'BUMN kebanggaan Indonesia, pengendali utama dana pensiun dan asuransi negara.',
    },
    {
      'code': 'NI',
      'name': 'BNI Sekuritas',
      'type': 'Local (BUMN)',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 380T+',
      'pnl': '+11.2%',
      'risk': 'Low',
      'dominance': 0.72,
      'desc':
          'Fokus pada sindikasi kredit korporasi BUMN dan transaksi institusi negara.',
    },
    {
      'code': 'OD',
      'name': 'BRI Danareksa Sekuritas',
      'type': 'Local (BUMN)',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 450T+',
      'pnl': '+12.1%',
      'risk': 'Low',
      'dominance': 0.78,
      'desc': 'Kekuatan BUMN di pasar mikro dan penjamin emisi efek terkemuka.',
    },
    {
      'code': 'DX',
      'name': 'Bahana Sekuritas',
      'type': 'Local (BUMN)',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 410T+',
      'pnl': '+11.8%',
      'risk': 'Low',
      'dominance': 0.75,
      'desc': 'Investment bank BUMN spesialis penasihat keuangan pemerintah.',
    },
    {
      'code': 'LS',
      'name': 'Reliance Sekuritas',
      'type': 'Local',
      'origin': 'India/Local',
      'flag': '🇮🇳',
      'aum': 'Rp 180T+',
      'pnl': '+10.2%',
      'risk': 'Medium',
      'dominance': 0.58,
      'desc':
          'Broker dengan latar belakang grup regional yang melayani dana pensiun swasta.',
    },
    {
      'code': 'YJ',
      'name': 'Lotus Andalan Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 140T+',
      'pnl': '+11.5%',
      'risk': 'Medium',
      'dominance': 0.54,
      'desc': 'Kuat di pergerakan harga saham grup terafiliasi secara lokal.',
    },
    {
      'code': 'XA',
      'name': 'NH Korindo Sekuritas',
      'type': 'Local',
      'origin': 'South Korea',
      'flag': '🇰🇷',
      'aum': 'Rp 290T+',
      'pnl': '+14.1%',
      'risk': 'High',
      'dominance': 0.72,
      'desc':
          'Broker asal Korea Selatan dengan fokus pada saham pertumbuhan dan IPO lokal.',
    },
    {
      'code': 'SF',
      'name': 'Surya Fajar Sekuritas',
      'type': 'Local',
      'origin': 'Lokal',
      'flag': '🇮🇩',
      'aum': 'Rp 110T+',
      'pnl': '+13.2%',
      'risk': 'High',
      'dominance': 0.48,
      'desc':
          'Aktif dalam mendampingi perusahaan lokal melakukan aksi korporasi.',
    },
    {
      'code': 'HD',
      'name': 'KGI Sekuritas Indonesia',
      'type': 'Local',
      'origin': 'Taiwan',
      'flag': '🇹🇼',
      'aum': 'Rp 220T+',
      'pnl': '+12.5%',
      'risk': 'Medium',
      'dominance': 0.62,
      'desc':
          'Jaringan raksasa Taiwan yang kuat di pasar derivatif dan ekuitas regional.',
    },
  ];

  final List<Map<String, dynamic>> terms = [
    {
      'name': 'MSCI Index',
      'code': 'MSCI',
      'type': 'Market Indicator',
      'origin': 'Global Standard',
      'flag': '🌎',
      'aum': r'$10T+ Global',
      'desc':
          'Indeks acuan global bentukan Morgan Stanley Capital International yang menjadi patokan bagi Fund Manager asing di seluruh dunia.',
      'features':
          'Rebalancing dua kali setahun (Mei & November). Saham yang masuk akan dibeli masif oleh dana asing.',
      'strategy':
          'Pantau pengumuman rebalancing. Masuk sebelum dana asing melakukan eksekusi beli di penutupan pasar.',
    },
    {
      'name': 'Big Whale',
      'code': 'WHALE',
      'type': 'Market Player',
      'origin': 'Institutional',
      'flag': '🐋',
      'aum': 'Rp 100T+',
      'desc':
          'Investor atau institusi dengan modal sangat besar yang mampu menggerakkan arah market secara signifikan.',
      'features':
          'Transaksi dalam volume raksasa (Block Trade), mampu menjaga harga di level tertentu (support/resistance).',
      'strategy':
          'Jangan melawan arus Whale. Ikuti jejak akumulasinya (Follow the Giant) untuk potensi profit besar.',
    },
    {
      'name': 'Megalodon',
      'code': 'MEGA',
      'type': 'Super Player',
      'origin': 'Top Tier Inst.',
      'flag': '🦈',
      'aum': 'Rp 500T+',
      'desc':
          'Pemain pasar tingkat tertinggi, biasanya Sovereign Wealth Fund (SWF) atau kolaborasi antar institusi keuangan raksasa.',
      'features':
          'Investasi jangka panjang, masuk ke saham Blue Chip, pergerakannya tidak terlihat harian namun sangat masif.',
      'strategy':
          'Sangat cocok untuk investasi jangka panjang. Megalodon masuk berarti emiten tersebut memiliki fundametal super solid.',
    },
    {
      'name': 'ARA (Auto Reject Atas)',
      'code': 'ARA',
      'type': 'Price Phenomenon',
      'origin': 'IDX Regulation',
      'flag': '🚀',
      'desc':
          'Batas kenaikan maksimal harga saham dalam satu hari perdagangan yang ditetapkan oleh bursa.',
      'features':
          'Harga tidak bisa naik lagi, antrean beli (bid) menumpuk sangat tebal di harga tertinggi tersebut.',
      'strategy':
          'Indikasi sentimen sangat positif. Biasanya akan berlanjut naik di hari berikutnya (Pre-opening surge).',
    },
    {
      'name': 'ARB (Auto Reject Bawah)',
      'code': 'ARB',
      'type': 'Price Phenomenon',
      'origin': 'IDX Regulation',
      'flag': '📉',
      'desc':
          'Batas penurunan maksimal harga saham dalam satu hari perdagangan yang ditetapkan oleh bursa.',
      'features':
          'Harga tidak bisa turun lagi, antrean jual (offer) menumpuk sangat tebal di harga terendah tersebut.',
      'strategy':
          'Jangan terburu-buru melakukan "Bottom Fishing". Tunggu antrean jual mencair sebelum masuk.',
    },
    {
      'name': 'Haka (Hajar Kanan)',
      'code': 'HAKA',
      'type': 'Trading Action',
      'origin': 'Market Order',
      'flag': '🔥',
      'desc':
          'Strategi membeli saham dengan langsung memasang harga di kolom Offer (harga jual terbaik saat itu).',
      'features':
          'Langsung mendapatkan barang (Done), biasanya dilakukan saat takut ketinggalan momentum (Urgency).',
      'strategy':
          'Lakukan Haka hanya jika volume bid di bawahnya sangat kuat dan harga baru saja breakout.',
    },
    {
      'name': 'Haki (Hajar Kiri)',
      'code': 'HAKI',
      'type': 'Trading Action',
      'origin': 'Market Order',
      'flag': '❄️',
      'desc':
          'Strategi menjual saham dengan langsung memasang harga di kolom Bid (harga beli terbaik saat itu).',
      'features':
          'Langsung menjual barang, dilakukan saat ingin segera keluar dari posisi (Panic Selling/Profit Taking).',
      'strategy':
          'Haki massal adalah tanda awal distribusi. Segera amankan profit jika melihat Haki dalam volume besar.',
    },
    {
      'name': 'Pump & Dump',
      'code': 'PUMP',
      'type': 'Market Game',
      'origin': 'Manipulation',
      'flag': '💉',
      'desc':
          'Permainan bandar untuk menaikkan harga secara tidak wajar (Pump) lalu menjualnya serentak (Dump) ke retail.',
      'features':
          'Kenaikan harga tajam tanpa ada berita fundamental, volume melonjak tiba-tiba, lalu harga jatuh sangat cepat.',
      'strategy':
          'Sangat berisiko tinggi. Jika sudah profit, segera keluar. Jangan pernah menahan saham tipe ini terlalu lama.',
    },
    {
      'name': 'Spoofing',
      'code': 'SPOOF',
      'type': 'Market Game',
      'origin': 'Mind Game',
      'flag': '�',
      'desc':
          'Memasang antrean beli/jual raksasa hanya untuk memancing minat retail, namun antrean tersebut dicabut (cancel) sebelum kejadian.',
      'features':
          'Bid terlihat sangat tebal tapi tiba-tiba hilang saat harga mendekati level tersebut (Fake Bid/Offer).',
      'strategy':
          'Waspada bid tebal yang tidak proporsional. Seringkali itu jebakan agar retail mau Haka di harga atas.',
    },
    {
      'name': 'Wash Trade',
      'code': 'WASH',
      'type': 'Market Game',
      'origin': 'Volume Play',
      'flag': '🧼',
      'desc':
          'Satu pihak (bandar) melakukan jual dan beli ke dirinya sendiri menggunakan beberapa akun berbeda.',
      'features':
          'Volume harian terlihat sangat ramai tapi harga hampir tidak bergerak (sideways).',
      'strategy':
          'Indikasi saham sedang berusaha masuk ke radar "Running Trade" atau ingin masuk filter teknikal tertentu.',
    },
    {
      'name': "Moody's Ratings",
      'code': 'MOODY',
      'type': 'Credit Rating',
      'origin': 'Credit Agency',
      'flag': '🔒',
      'desc':
          'Skala peringkat kredit internasional oleh Moody\'s Investors Service; digunakan untuk menilai risiko gagal bayar penerbit obligasi dan perusahaan.',
      'features':
          'Kategori Aaa -> C; tambahan notches 1/2/3 untuk pembagian dalam kategori. Pembagian Investment Grade vs Speculative (Junk).',
      'strategy':
          'Gunakan peringkat untuk menilai risiko kredit emiten; peringkat lebih tinggi menunjukkan kredit berkualitas dan biaya pinjaman lebih rendah.',
    },
    {
      'name': 'Cornering',
      'code': 'CORN',
      'type': 'Market Game',
      'origin': 'Monopoly',
      'flag': '📐',
      'desc':
          'Aksi menguasai sebagian besar saham publik sehingga bandar bisa mengontrol harga secara mutlak.',
      'features':
          'Saham tidak likuid, bid/offer sangat tipis, harga bisa ditarik naik atau turun sesuka hati bandar.',
      'strategy':
          'Hindari saham tipe ini karena likuiditas sangat rendah. Sulit untuk menjual kembali jika sudah masuk.',
    },
    {
      'name': 'Dividen Trap',
      'code': 'TRAP',
      'type': 'Market Trap',
      'origin': 'Dividend Play',
      'flag': '�',
      'desc':
          'Kondisi di mana harga saham jatuh lebih dalam dari jumlah dividen yang dibagikan tepat setelah Cum Date.',
      'features':
          'Kenaikan harga menjelang Cum Date, disusul penurunan tajam saat Ex Date.',
      'strategy':
          'Jika tujuan hanya trading, jual sebelum Cum Date. Jika investasi, perhatikan fundamental masa depan emiten.',
    },
    {
      'name': 'Window Dressing',
      'code': 'WD',
      'type': 'Seasonal Event',
      'origin': 'Year-End',
      'flag': '🖼️',
      'desc':
          'Upaya manajer investasi untuk memoles portofolio agar terlihat bagus di akhir tahun dengan menaikkan harga saham tertentu.',
      'features':
          'Biasanya terjadi di bulan Desember, fokus pada saham-saham Blue Chip dan emiten besar.',
      'strategy':
          'Akumulasi saham Blue Chip yang kinerjanya bagus namun harganya masih tertinggal di bulan November.',
    },
    {
      'name': 'Insider Trading',
      'code': 'INSIDE',
      'type': 'Illegal Act',
      'origin': 'Privileged Info',
      'flag': '�',
      'desc':
          'Transaksi saham berdasarkan informasi penting perusahaan yang belum dipublikasikan ke publik.',
      'features':
          'Volume beli/jual melonjak sangat tinggi beberapa hari sebelum ada pengumuman resmi korporasi.',
      'strategy':
          'Pantau anomali volume. Jika volume naik tanpa berita, kemungkinan ada berita besar yang akan segera rilis.',
    },
    {
      'name': 'FOMO',
      'code': 'FOMO',
      'type': 'Psychology',
      'origin': 'Retail Behavior',
      'flag': '😱',
      'desc':
          'Fear of Missing Out. Rasa takut ketinggalan kereta saat harga saham sedang naik tinggi (To the Moon).',
      'features':
          'Membeli saham di harga "pucuk" tanpa analisis, hanya ikut-ikutan kerumunan di media sosial.',
      'strategy':
          'Selalu miliki Trading Plan. Jika harga sudah naik terlalu jauh dari support, lebih baik menunggu koreksi.',
    },
    {
      'name': 'Smart Money',
      'code': 'SMF',
      'type': 'Market Strategy',
      'origin': 'Institutional',
      'flag': '🧠',
      'desc':
          'Aliran dana cerdas dari institusi yang melakukan akumulasi secara rahasia sebelum harga meledak.',
      'features':
          'Akumulasi bertahap, volume stabil namun konsisten net buy, harga dipertahankan di area sideways.',
      'strategy':
          'Identifikasi area akumulasi. Masuk bersamaan dengan Smart Money dan bersabarlah (Patient Investing).',
    },
    {
      'name': 'Short Squeeze',
      'code': 'SQUZ',
      'type': 'Price Action',
      'origin': 'Market Dynamics',
      'flag': '🗜️',
      'desc':
          'Kenaikan harga tajam yang memaksa para short-seller untuk membeli kembali saham mereka (cut loss), yang justru semakin mendorong harga naik tinggi.',
      'features':
          'Kenaikan harga ekstrim dalam waktu singkat, volume beli melonjak karena forced-buy.',
      'strategy':
          'Sangat berisiko tinggi. Jangan mencoba melawan tren naik yang didorong oleh Short Squeeze.',
    },
    {
      'name': 'Dark Pools',
      'code': 'DARK',
      'type': 'Market Venue',
      'origin': 'Off-Exchange',
      'flag': '🌑',
      'desc':
          'Bursa swasta yang digunakan oleh investor institusi besar untuk memperdagangkan blok saham dalam jumlah raksasa tanpa diketahui publik secara real-time.',
      'features':
          'Membantu institusi masuk ke posisi besar tanpa menyebabkan fluktuasi harga yang drastis di bursa reguler.',
      'strategy':
          'Pantau anomali data di akhir hari (Large Prints). Jika ada volume besar di harga tertentu off-market, itu area support kuat.',
    },
    {
      'name': 'High-Frequency Trading',
      'code': 'HFT',
      'type': 'Quant Strategy',
      'origin': 'Algorithmic',
      'flag': '⚡',
      'desc':
          'Metode perdagangan menggunakan algoritma super cepat untuk mengeksekusi ribuan order dalam hitungan milidetik.',
      'features':
          'Mencari profit dari selisih harga yang sangat kecil (micro-arbitrage), mendominasi volume bursa global.',
      'strategy':
          'Retail tidak bisa menang melawan kecepatan HFT. Gunakan timeframe yang lebih panjang untuk menghindari "noise" dari algoritma.',
    },
    {
      'name': 'VIX (Fear Index)',
      'code': 'VIX',
      'type': 'Volatility',
      'origin': 'CBOE / Global',
      'flag': '🌡️',
      'desc':
          'Indeks yang mengukur ekspektasi volatilitas pasar. Sering disebut sebagai Indeks Ketakutan.',
      'features':
          'VIX naik saat pasar panik/jatuh. VIX rendah biasanya terjadi saat pasar stabil atau terlalu optimis.',
      'strategy':
          'Beli saat VIX tinggi (saat semua orang takut), jual saat VIX rendah (saat semua orang rakus).',
    },
    {
      'name': 'Golden Cross',
      'code': 'GOLD',
      'type': 'Technical',
      'origin': 'Indicators',
      'flag': '✨',
      'desc':
          'Terjadi ketika moving average jangka pendek (misal: MA50) memotong ke atas moving average jangka panjang (misal: MA200).',
      'features':
          'Sinyal bahwa tren telah berubah dari bearish menjadi bullish secara jangka panjang.',
      'strategy':
          'Konfirmasi yang kuat untuk melakukan Buy & Hold. Tingkat keberhasilan lebih tinggi jika didukung volume.',
    },
    {
      'name': 'Death Cross',
      'code': 'DEATH',
      'type': 'Technical',
      'origin': 'Indicators',
      'flag': '☠️',
      'desc': 'Kebalikan dari Golden Cross; MA50 memotong ke bawah MA200.',
      'features':
          'Sinyal bahaya bahwa tren besar telah berubah menjadi bearish. Penurunan lebih lanjut sangat mungkin terjadi.',
      'strategy':
          'Gunakan sinyal ini untuk keluar dari posisi atau melakukan lindung nilai (hedging).',
    },
    {
      'name': 'Gamma Squeeze',
      'code': 'GAMMA',
      'type': 'Market Dynamics',
      'origin': 'Options Market',
      'flag': '🌀',
      'desc':
          'Ketika market maker dipaksa membeli saham dasar untuk melindungi nilai (hedging) posisi opsi jual-beli mereka, memicu kenaikan harga berantai.',
      'features':
          'Sering terjadi pada saham dengan minat opsi call yang sangat tinggi (seperti kasus GameStop).',
      'strategy':
          'Pantau rasio Put/Call. Gamma squeeze adalah bahan bakar bagi reli harga yang tidak masuk akal secara fundamental.',
    },
    {
      'name': 'Dead Cat Bounce',
      'code': 'DCB',
      'type': 'Price Action',
      'origin': 'Sentiment',
      'flag': '🐈',
      'desc':
          'Pemulihan harga sementara yang terjadi di tengah tren turun yang parah sebelum harga kembali jatuh lebih dalam.',
      'features':
          'Kenaikan harga tanpa didukung volume yang meyakinkan, sering menipu trader untuk masuk terlalu dini.',
      'strategy':
          'Waspada jebakan beli. Jangan anggap setiap kenaikan kecil adalah pembalikan arah (reversal).',
    },
    {
      'name': 'FTSE Index',
      'code': 'FTSE',
      'type': 'Market Indicator',
      'origin': 'London Stock Exchange',
      'flag': '🇬🇧',
      'aum': r'$4T+ Base',
      'desc':
          'Financial Times Stock Exchange Index. Pesaing utama MSCI dalam menentukan saham-saham pilihan yang layak investasi secara global.',
      'features':
          'Memiliki pengaruh besar pada arus modal asing (inflow/outflow) ke saham-saham Big Cap di Indonesia.',
      'strategy':
          'Seringkali rebalancing FTSE memiliki efek harga yang kontradiktif dengan MSCI. Gunakan sebagai konfirmasi tambahan.',
    },
    {
      'name': 'Blackrock',
      'code': 'BLK',
      'type': 'Institutional Giant',
      'origin': 'USA / Global',
      'flag': '🇺🇸',
      'aum': r'$10T+',
      'desc':
          'Manajer investasi terbesar di dunia. Pergerakan Blackrock bisa menentukan hidup-mati sebuah tren pasar global.',
      'features':
          'Menggunakan sistem AI raksasa bernama "Aladdin" untuk manajemen risiko dan eksekusi perdagangan.',
      'strategy':
          'Saham yang dimiliki Blackrock dalam jumlah besar cenderung stabil dan memiliki dukungan likuiditas yang sangat kuat.',
    },
    {
      'name': 'Vanguard',
      'code': 'VANG',
      'type': 'Institutional Giant',
      'origin': 'USA / Global',
      'flag': '🇺🇸',
      'aum': r'$8T+',
      'desc':
          'Raksasa investasi yang mempopulerkan dana indeks (Passive Investing). Pemilik hampir setiap saham besar di dunia.',
      'features':
          'Dikenal dengan strategi "Buy and Hold" jangka sangat panjang. Hampir tidak pernah melakukan spekulasi harian.',
      'strategy':
          'Jika Vanguard terus menambah porsi di sebuah saham, itu adalah sinyal "Long Term Validation" yang sangat kredibel.',
    },
    {
      'name': 'SWF (Sovereign Wealth Fund)',
      'code': 'SWF',
      'type': 'State Investment',
      'origin': 'Government',
      'flag': '🏛️',
      'aum': r'$15T+ Combined',
      'desc':
          'Dana investasi milik negara (seperti INA di Indonesia, GIC di Singapura, atau NBIM di Norwegia).',
      'features':
          'Investasi strategis, biasanya masuk ke proyek infrastruktur atau saham-saham penggerak ekonomi negara.',
      'strategy':
          'Masuknya SWF ke sebuah emiten seringkali merupakan sinyal "Restu Pemerintah" atau dukungan politik-ekonomi yang kuat.',
    },
    {
      'name': 'Milenial & Gen Z',
      'code': 'RETAIL',
      'type': 'Demographic',
      'origin': 'Social Change',
      'flag': '📱',
      'desc':
          'Gelombang baru investor ritel muda yang mendominasi jumlah SID (Single Investor Identification) baru di bursa.',
      'features':
          'Sangat bergantung pada informasi media sosial, menyukai saham teknologi, dan memiliki tingkat toleransi risiko tinggi.',
      'strategy':
          'Fenomena ini menciptakan likuiditas besar pada saham lapis 2 dan 3. Perlu waspada terhadap volatilitas ekstrim.',
    },
    {
      'name': 'Pom-pom / Influencer',
      'code': 'POM',
      'type': 'Market Sentiment',
      'origin': 'Social Media',
      'flag': '📢',
      'desc':
          'Aksi mengajak orang lain untuk membeli saham tertentu yang dilakukan oleh tokoh berpengaruh demi kepentingan pribadi atau kelompok.',
      'features':
          'Seringkali tanpa analisis fundamental yang jelas, hanya menonjolkan potensi kenaikan harga (to the moon).',
      'strategy':
          'Lakukan riset mandiri (DYOR). Jangan pernah membeli saham hanya karena ajakan tanpa Trading Plan yang jelas.',
    },
    {
      'name': 'Backdoor Listing',
      'code': 'BDL',
      'type': 'Corporate Action',
      'origin': 'M&A Strategy',
      'flag': '🚪',
      'desc':
          'Strategi perusahaan tertutup (private) untuk menjadi perusahaan terbuka (public) tanpa melalui proses IPO, biasanya dengan mengakuisisi perusahaan yang sudah listing.',
      'features':
          'Biasanya terjadi pada saham tidur atau perusahaan kecil yang tiba-tiba diakuisisi oleh grup besar.',
      'strategy':
          'Potensi keuntungan sangat besar (multibagger) jika berhasil masuk di tahap awal rumor atau pengumuman akuisisi.',
    },
  ];

  final List<Map<String, dynamic>> conglomerates = [
    {
      'name': 'Salim Group',
      'owner': 'Anthoni Salim',
      'assets': 'Rp 650T+',
      'stocks': [
        {'t': 'INDF', 's': 'Normal'},
        {'t': 'ICBP', 's': 'Normal'},
        {'t': 'LSIP', 's': 'Normal'},
        {'t': 'SIMP', 's': 'Normal'},
        {'t': 'BINA', 's': 'Hype'},
        {'t': 'IMAS', 's': 'Normal'},
        {'t': 'IMJS', 's': 'Normal'},
        {'t': 'DNET', 's': 'Normal'},
      ],
    },
    {
      'name': 'Hartono Group (Djarum)',
      'owner': 'Budi & Michael Hartono',
      'assets': 'Rp 1,480T+',
      'stocks': [
        {'t': 'BBCA', 's': 'MSCI'},
        {'t': 'TOWR', 's': 'Normal'},
        {'t': 'BELI', 's': 'Normal'},
        {'t': 'PRAS', 's': 'Normal'},
      ],
    },
    {
      'name': 'Sinar Mas Group',
      'owner': 'Keluarga Widjaja',
      'assets': 'Rp 960T+',
      'stocks': [
        {'t': 'BSDE', 's': 'Normal'},
        {'t': 'INKP', 's': 'Normal'},
        {'t': 'TKIM', 's': 'Normal'},
        {'t': 'SMMA', 's': 'Normal'},
        {'t': 'FREN', 's': 'Normal'},
        {'t': 'DMAS', 's': 'Normal'},
        {'t': 'DSSA', 's': 'Hype'},
        {'t': 'BSIM', 's': 'Normal'},
      ],
    },
    {
      'name': 'Barito Group',
      'owner': 'Prajogo Pangestu',
      'assets': 'Rp 780T+',
      'stocks': [
        {'t': 'BRPT', 's': 'Normal'},
        {'t': 'TPIA', 's': 'Normal'},
        {'t': 'BREN', 's': 'Hype'},
        {'t': 'CUAN', 's': 'Hype'},
        {'t': 'PTRO', 's': 'Hype'}, // Added PTRO (Prajogo's Group now)
      ],
    },
    {
      'name': 'Saratoga Group',
      'owner': 'Sandiaga Uno / Edwin S.',
      'assets': 'Rp 185T+',
      'stocks': [
        {'t': 'SRTG', 's': 'Normal'},
        {'t': 'ADRO', 's': 'MSCI'},
        {'t': 'MDKA', 's': 'MSCI'},
        {'t': 'MPMX', 's': 'Normal'},
        {'t': 'TBIG', 's': 'Normal'},
        {'t': 'ADMR', 's': 'Normal'},
      ],
    },
    {
      'name': 'DCI Group (Data Center)',
      'owner': 'Toto Sugiri',
      'assets': 'Rp 42T+',
      'stocks': [
        {'t': 'DCII', 's': 'Hype'},
        {'t': 'EDGE', 's': 'Normal'},
      ],
    },
    {
      'name': 'Harita Group',
      'owner': 'Lim Hariyanto Wijaya Sarwono',
      'assets': 'Rp 95T+',
      'stocks': [
        {'t': 'NCKL', 's': 'Hype'},
        {'t': 'CITA', 's': 'Normal'},
        {'t': 'PALM', 's': 'Normal'},
      ],
    },
    {
      'name': 'Astra Group',
      'owner': 'Jardine Cycle & Carriage',
      'assets': 'Rp 450T+',
      'stocks': [
        {'t': 'ASII', 's': 'MSCI'},
        {'t': 'UNTR', 's': 'Normal'},
        {'t': 'ASGR', 's': 'Normal'},
        {'t': 'AUTO', 's': 'Normal'},
        {'t': 'AALI', 's': 'Normal'},
      ],
    },
    {
      'name': 'Triputra Group',
      'owner': 'T.P. Rachmat (Teddy)',
      'assets': 'Rp 125T+',
      'stocks': [
        {'t': 'TAPG', 's': 'Normal'},
        {'t': 'ASSA', 's': 'Normal'},
        {'t': 'DSNG', 's': 'Normal'},
        {'t': 'DRMA', 's': 'Normal'},
      ],
    },
    {
      'name': 'Djarum Tech',
      'owner': 'Martin Hartono',
      'assets': 'Rp 88T+',
      'stocks': [
        {'t': 'BELI', 's': 'Normal'},
        {'t': 'GOTO', 's': 'Hype'},
      ],
    },
    {
      'name': 'PIK 2 Group (Agung Sedayu)',
      'owner': 'Sugianto Kusuma (Aguan)',
      'assets': 'Rp 115T+',
      'stocks': [
        {'t': 'PANI', 's': 'Hype'},
      ],
    },
    {
      'name': 'Ciputra Group',
      'owner': 'Keluarga Ciputra',
      'assets': 'Rp 48T+',
      'stocks': [
        {'t': 'CTRA', 's': 'MSCI'},
      ],
    },
    {
      'name': 'Lippo Group',
      'owner': 'James Riady',
      'assets': 'Rp 215T+',
      'stocks': [
        {'t': 'LPKR', 's': 'Normal'},
        {'t': 'LPPF', 's': 'Normal'},
        {'t': 'MLPL', 's': 'Normal'},
        {'t': 'MPPA', 's': 'Normal'},
      ],
    },
    {
      'name': 'CT Corp',
      'owner': 'Chairul Tanjung',
      'assets': 'Rp 235T+',
      'stocks': [
        {'t': 'MEGA', 's': 'Normal'},
        {'t': 'ALLO', 's': 'Hype'},
      ],
    },
    {
      'name': 'MNC Group',
      'owner': 'Hary Tanoesoedibjo',
      'assets': 'Rp 98T+',
      'stocks': [
        {'t': 'MNCN', 's': 'Normal'},
        {'t': 'BMTR', 's': 'Normal'},
        {'t': 'MSIN', 's': 'Normal'},
        {'t': 'BHIT', 's': 'Normal'},
        {'t': 'BABP', 's': 'Normal'},
      ],
    },
    {
      'name': 'Bakrie Group',
      'owner': 'Keluarga Bakrie',
      'assets': 'Rp 165T+',
      'stocks': [
        {'t': 'BUMI', 's': 'Hype'},
        {'t': 'BRMS', 's': 'Hype'},
        {'t': 'ENRG', 's': 'Normal'},
        {'t': 'DEWA', 's': 'Normal'},
      ],
    },
    {
      'name': 'Mayapada Group',
      'owner': 'Dato Sri Tahir',
      'assets': 'Rp 180T+',
      'stocks': [
        {'t': 'MAYA', 's': 'Normal'},
        {'t': 'SRAJ', 's': 'Normal'},
      ],
    },
    {
      'name': 'Pakuwon Group',
      'owner': 'Alexander Tedja',
      'assets': 'Rp 38T+',
      'stocks': [
        {'t': 'PWON', 's': 'Normal'},
      ],
    },
    {
      'name': 'Tobacco Giants',
      'owner': 'Various',
      'assets': 'Rp 155T+',
      'stocks': [
        {'t': 'GGRM', 's': 'Normal'},
        {'t': 'HMSP', 's': 'Normal'},
      ],
    },
    {
      'name': 'Panin Group',
      'owner': 'Mu\'min Ali Gunawan',
      'assets': 'Rp 225T+',
      'stocks': [
        {'t': 'PNBN', 's': 'Normal'},
        {'t': 'PNIN', 's': 'Normal'},
        {'t': 'PNLF', 's': 'Normal'},
        {'t': 'PANS', 's': 'Normal'},
      ],
    },
    {
      'name': 'Emtek Group',
      'owner': 'Eddy K. Sariaatmadja',
      'assets': 'Rp 110T+',
      'stocks': [
        {'t': 'EMTK', 's': 'Normal'},
        {'t': 'SCMA', 's': 'Normal'},
        {'t': 'BUKA', 's': 'Normal'},
      ],
    },
    {
      'name': 'Tancorp Group',
      'owner': 'Hermanto Tanoko',
      'assets': 'Rp 60T+',
      'stocks': [
        {'t': 'AVIA', 's': 'Normal'},
        {'t': 'CLEO', 's': 'Normal'},
        {'t': 'DEPO', 's': 'Normal'},
      ],
    },
    {
      'name': 'Rajawali Group',
      'owner': 'Peter Sondakh',
      'assets': 'Rp 45T+',
      'stocks': [
        {'t': 'BWPT', 's': 'Normal'},
        {'t': 'ARCI', 's': 'Normal'},
      ],
    },
  ];

  final List<Map<String, dynamic>> tacticalStrategies = [
    {
      'name': 'Deep Value',
      'definition':
          'Strategi mencari saham dengan valuasi sangat murah (undervalued) dibandingkan nilai intrinsiknya.',
      'characteristics': 'Low PBV, Low PER, High Margin of Safety.',
      'parameter': 'PBV < 1.0, PER < 10, AI Score > 80.',
      'influencer': 'Benjamin Graham, Warren Buffett (Early Years).',
    },
    {
      'name': 'Hyper Growth',
      'definition':
          'Fokus pada perusahaan dengan pertumbuhan pendapatan dan laba bersih yang sangat cepat (biasanya sektor teknologi).',
      'characteristics': 'High Revenue Growth, Scalable Business, High R&D.',
      'parameter': 'Net Profit Growth > 25%, AI Score > 85.',
      'influencer': 'Cathie Wood (ARK Invest), Peter Lynch.',
    },
    {
      'name': 'Dividend King',
      'definition':
          'Mencari perusahaan stabil yang rutin membagikan dividen besar secara konsisten kepada pemegang saham.',
      'characteristics': 'Mature Business, Strong Cash Flow, Low Debt.',
      'parameter': 'Dividend Yield > 5%, Payout Ratio < 70%, AI Score > 75.',
      'influencer': 'John Bogle, Dividend Growth Investors.',
    },
    {
      'name': 'Blue Chip',
      'definition':
          'Investasi pada saham penguasa pasar dengan kapitalisasi besar dan fundamental super solid.',
      'characteristics': 'Market Leader, High Liquidity, Sustainable Moat.',
      'parameter': 'Market Cap > 100T, High ROE, AI Score > 70.',
      'influencer': 'Institutional Investors (Dana Pensiun, SWF).',
    },
    {
      'name': 'Penny Gems',
      'definition':
          'Mencari "berlian" di saham lapis tiga (Small Cap) yang memiliki potensi pertumbuhan masif namun belum dilirik pasar.',
      'characteristics': 'Small Cap, Under the Radar, High Scalability.',
      'parameter': 'Price < 500, Free Float > 30%, AI Score > 75.',
      'influencer': 'Micro-cap Specialists, Individual Aggressive Traders.',
    },
    {
      'name': 'Momentum',
      'definition':
          'Strategi mengikuti tren harga yang sedang naik kuat, berprinsip "Buy High, Sell Higher".',
      'characteristics':
          'Uptrend Structure, Strong Moving Average, High Relative Strength.',
      'parameter': 'Price > MA50/MA20, RSI > 50, AI Score > 80.',
      'influencer': 'Richard Wyckoff, Jesse Livermore.',
    },
    {
      'name': 'Bottom Fish',
      'definition':
          'Strategi membeli saham yang harganya sudah jatuh sangat dalam (crash) dan diprediksi akan segera berbalik arah.',
      'characteristics':
          'Extreme Oversold, Near Strong Support, Negative Sentiment Peak.',
      'parameter': 'RSI < 30, AI Score 60-85, Support Rebound confirmation.',
      'influencer': 'Contrarian Investors, Hengki (Price Action Specialist).',
    },
    {
      'name': 'Institutional',
      'definition':
          'Mengikuti jejak (flow) pergerakan beli/akumulasi dari broker-broker institusi besar atau asing (Big Money).',
      'characteristics': 'Consistent Foreign Flow, Large Volume Accumulation.',
      'parameter': 'Net Foreign Buy > 10M (daily), AI Score > 85.',
      'influencer': 'Global Fund Managers (BlackRock, Vanguard).',
    },
    {
      'name': 'Smart Money',
      'definition':
          'Mendeteksi pergerakan "uang pintar" atau Insider yang seringkali memiliki informasi lebih awal daripada publik.',
      'characteristics':
          'Unusual Volume, Silent Accumulation, High Net Buy Index.',
      'parameter':
          'AI Score > 90, Volume > 2x Avg, Negative Price Correlation.',
      'influencer': 'Andri Hakim (Bandarmology Expert), Hedge Fund Managers.',
    },
    {
      'name': 'Scalper',
      'definition':
          'Strategi trading super cepat (hitungan menit/detik) untuk mengambil keuntungan kecil namun dilakukan berkali-kali.',
      'characteristics':
          'High Volatility, Focus on Order Book (Bid-Offer), High Liquidity.',
      'parameter': 'Volume Per Minute High, Free Float > 40%, High Volatility.',
      'influencer': 'Professional Day Traders, Fast Action Traders.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredBrokers = brokers
        .where(
          (b) =>
              b['code']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
              b['name']!.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Knowledge',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
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
              Tab(text: 'News'),
              Tab(text: 'Education'),
              Tab(text: 'Tactical'),
              Tab(text: 'Brokers'),
              Tab(text: 'Terms'),
              Tab(text: 'Groups'),
            ],
          ),
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0A2E), Color(0xFF0A0214)],
            ),
          ),
          child: SafeArea(
            child: TabBarView(
              children: [
                _buildNewsTab(),
                _buildEducationLibrary(),
                _buildTacticalList(),
                _buildBrokerList(filteredBrokers),
                _buildTermsList(),
                _buildConglomerateList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEducationLibrary() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTopicCard(
          'Introduction to Stock Market',
          'Learn the basics of how the stock market works.',
          Icons.account_balance_rounded,
        ),
        _buildTopicCard(
          'Fundamental Analysis',
          'Understanding financial statements, PER, PBV, and ROE.',
          Icons.analytics_rounded,
        ),
        _buildTopicCard(
          'Technical Analysis',
          'Reading candlesticks, support/resistance, and indicators.',
          Icons.show_chart_rounded,
        ),
        _buildTopicCard(
          'Money Management',
          'Managing your risk and position sizing.',
          Icons.account_balance_wallet_rounded,
        ),
        _buildTopicCard(
          'Psychology of Trading',
          'Control your emotions: greed and fear.',
          Icons.psychology_rounded,
        ),
        const SizedBox(height: 8),
        _buildActionCard(
          'Rebalancing MSCI',
          'Jadwal, data, dan informasi rebalancing MSCI di Mei dan November',
          Icons.calendar_today_rounded,
          const Color(0xFF39FF14),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MSCIRebalancingScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Kalender Finance',
          'Jadwal lengkap: RUPS, Dividen, FOMC, Fed, dan event finansial lainnya',
          Icons.event_rounded,
          const Color(0xFFC800FF),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FinancialCalendarScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Glosarium Fundamental',
          'Penjelasan istilah fundamental (ROE, PER, PBV, FCF, EPS, dll.)',
          Icons.menu_book_rounded,
          const Color(0xFF10B981),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FundamentalGlossaryScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          "Moodys' Credit Ratings",
          "Penjelasan singkat skala rating Moody's dan arti setiap kategori",
          Icons.security_rounded,
          const Color(0xFF6B7FF1),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MoodysRatingsScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFC800FF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.15),
              accentColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: accentColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBrokerList(List<Map<String, dynamic>> filteredBrokers) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search Broker...',
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: filteredBrokers.length,
            itemBuilder: (context, index) {
              final broker = filteredBrokers[index];
              final isForeign = broker['type']!.contains('Foreign');
              final accentColor = isForeign
                  ? Colors.orangeAccent
                  : Colors.cyanAccent;

              return InkWell(
                onTap: () => _showAnalyticalDetail(broker),
                borderRadius: BorderRadius.circular(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              broker['code']!,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            broker['name']!,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            broker['type']!,
                            style: GoogleFonts.outfit(
                              fontSize: 8,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermsList() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: terms.length,
      itemBuilder: (context, index) {
        final term = terms[index];
        return InkWell(
          onTap: () {
            if ((term['code'] ?? '').toString().toUpperCase() == 'MOODY') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoodysRatingsScreen(),
                ),
              );
              return;
            }
            _showAnalyticalDetail(term);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC800FF).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    term['code'] ?? term['flag'] ?? (term['name']?[0] ?? 'T'),
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFC800FF),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  term['name'] ?? term['term'] ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  (term['type'] ?? 'Trading').toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: GoogleFonts.outfit(
                    fontSize: 6.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConglomerateList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conglomerates.length,
            itemBuilder: (context, index) {
              final conglo = conglomerates[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conglo['name']!,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC800FF),
                          ),
                        ),
                        const Icon(
                          Icons.business_rounded,
                          color: Colors.white24,
                        ),
                      ],
                    ),
                    Text(
                      conglo['owner']!,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'TOTAL ASSETS: ',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          conglo['assets'] ?? 'N/A',
                          style: GoogleFonts.outfit(
                            color: Colors.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (conglo['stocks'] as List<Map<String, String>>)
                          .map((stock) {
                            final ticker = stock['t']!;
                            // Dynamic override from backend tags
                            final status =
                                (_dynamicMarketTags.containsKey(ticker)
                                        ? _dynamicMarketTags[ticker]
                                        : stock['s'])!
                                    .toLowerCase();
                            Color color = const Color(0xFFC800FF);
                            if (status == 'hype') color = Colors.cyanAccent;
                            if (status == 'msci')
                              color = const Color(0xFF39FF14);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  if (status != 'normal')
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: Text(
                                ticker,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  Widget _buildTacticalList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tacticalStrategies.length,
      itemBuilder: (context, index) {
        final strategy = tacticalStrategies[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC800FF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFC800FF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    strategy['name']!,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTacticalDetail('PENGERTIAN', strategy['definition']!),
              _buildTacticalDetail('CIRI-CIRI', strategy['characteristics']!),
              _buildTacticalDetail('PARAMETER AI', strategy['parameter']!),
              _buildTacticalDetail(
                'TOKOH / INFLUENCER',
                strategy['influencer']!,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAnalyticalDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF13081E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFC800FF),
              blurRadius: 20,
              spreadRadius: -10,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC800FF).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      item['code'] ?? item['flag'] ?? item['name'][0],
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC800FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name']!,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item['type'] ?? 'Knowledge Base',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
              _buildDetailSection(
                'PENGERTIAN',
                item['desc'] ??
                    item['definition'] ??
                    'Analisis sedang diproses.',
                Colors.white,
              ),
              if (item['features'] != null)
                _buildDetailSection(
                  'CIRI-CIRI / KARAKTERISTIK',
                  item['features']!,
                  Colors.cyanAccent,
                ),
              if (item['strategy'] != null)
                _buildDetailSection(
                  'TIPS & STRATEGI QUANTS',
                  item['strategy']!,
                  const Color(0xFFC800FF),
                ),
              if (item['aum'] != null && item['aum'] != 'N/A')
                _buildDetailSection(
                  'ESTIMASI KELOLAAN DANA',
                  item['aum']!,
                  const Color(0xFF39FF14),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String content, Color contentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFFC800FF),
            letterSpacing: 2,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            content,
            style: GoogleFonts.outfit(
              color: contentColor.withValues(alpha: 0.9),
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTacticalDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC800FF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem('Hype', Colors.cyanAccent),
          _legendItem('MSCI', const Color(0xFF39FF14)),
          _legendItem('Normal', const Color(0xFFC800FF)),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildNewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _newsPageController,
            onPageChanged: (index) => setState(() => _currentNewsIndex = index),
            itemCount: headlineNews.length,
            itemBuilder: (context, index) {
              return _buildHeadlineNewsCard(headlineNews[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: headlineNews.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentNewsIndex == entry.key
                    ? Colors.redAccent
                    : Colors.white24,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildTopStoriesHeader(),
        const SizedBox(height: 12),
        if (_isTopNewsLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          )
        else if (_topStories.isEmpty)
          const Center(
            child: Text(
              'No news available',
              style: TextStyle(color: Colors.white54),
            ),
          )
        else
          ..._filteredTopStories()
              .map((news) => _buildNewsListItem(news))
              .toList(),
        const SizedBox(height: 30),
      ],
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'Recent';
    // If it already looks like "X jam lalu" or "Baru saja", return it
    if (timeStr.contains('jam') ||
        timeStr.contains('Baru') ||
        timeStr.contains('menit')) {
      return timeStr;
    }
    try {
      // Handle Google News RSS format: "Fri, 14 Feb 2025 07:00:00 GMT"
      final date = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(timeStr);
      final diff = DateTime.now().difference(date);
      if (diff.inHours < 1) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return DateFormat('MMM dd').format(date);
    } catch (e) {
      return timeStr; // Return as is if parsing fails
    }
  }

  Widget _buildTopStoriesHeader() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _newsScope = 'IDN'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _newsScope == 'IDN'
                    ? Colors.purpleAccent.withOpacity(0.15)
                    : Colors.white10.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _newsScope == 'IDN'
                      ? Colors.purpleAccent
                      : Colors.white10,
                ),
              ),
              child: Center(
                child: Text(
                  'IDN',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _newsScope = 'Global'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _newsScope == 'Global'
                    ? Colors.purpleAccent.withOpacity(0.15)
                    : Colors.white10.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _newsScope == 'Global'
                      ? Colors.purpleAccent
                      : Colors.white10,
                ),
              ),
              child: Center(
                child: Text(
                  'Global',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<dynamic> _filteredTopStories() {
    try {
      var filtered = _topStories.where((news) => _matchesScope(news)).toList();

      // Convert to list with parsed dates
      final now = DateTime.now();
      List<Map<String, dynamic>> withDates = filtered.map((n) {
        return {'news': n, 'date': _extractNewsDate(n) ?? now};
      }).toList();

      // Keep only items within the last 7 days for Global scope, otherwise keep IDN recent
      if (_newsScope == 'Global') {
        withDates = withDates
            .where((e) => now.difference(e['date']).inDays <= 7)
            .toList();
      }

      // Sort descending by date
      withDates.sort((a, b) => b['date'].compareTo(a['date']));

      // Limit to max 15
      var result = withDates.take(15).map((e) => e['news']).toList();

      // If not enough global items, try to expand by including close matches within 7 days
      if (_newsScope == 'Global' && result.length < 15) {
        final additional = _topStories
            .where((n) => !_matchesScope(n))
            .where((n) {
              final d = _extractNewsDate(n) ?? now;
              return now.difference(d).inDays <= 7;
            })
            .where((n) {
              // include if contains any global keyword even if not matched earlier
              final t = (n['title'] ?? n['news'] ?? '')
                  .toString()
                  .toLowerCase();
              for (var k in _globalKeywords) if (t.contains(k)) return true;
              return false;
            })
            .take(15 - result.length)
            .toList();

        result.addAll(additional);
      }

      // Fallback: if still empty, include recent (<=7d) items regardless of scope up to 15
      if (result.isEmpty) {
        final fallback = _topStories.where((n) {
          final d = _extractNewsDate(n) ?? now;
          return now.difference(d).inDays <= 7;
        }).toList();
        result = fallback.take(15).toList();
      }

      return result;
    } catch (e) {
      return _topStories.take(15).toList();
    }
  }

  DateTime? _extractNewsDate(dynamic news) {
    try {
      final t = news['time'] ?? news['publishedAt'] ?? news['pubDate'] ?? '';
      if (t == null) return null;
      final s = t.toString();

      // ISO parse
      final dp = DateTime.tryParse(s);
      if (dp != null) return dp.toLocal();

      // Google RSS format: "Fri, 14 Feb 2025 07:00:00 GMT"
      try {
        final parsed = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(s);
        return parsed.toLocal();
      } catch (e) {}

      // Relative times like '10 mins ago', '2 hours ago', '10 jam lalu'
      final lower = s.toLowerCase();
      final now = DateTime.now();
      final minMatch = RegExp(r"(\d+)\s*mins?").firstMatch(lower);
      if (minMatch != null)
        return now.subtract(Duration(minutes: int.parse(minMatch.group(1)!)));
      final hourMatch = RegExp(r"(\d+)\s*hours?").firstMatch(lower);
      if (hourMatch != null)
        return now.subtract(Duration(hours: int.parse(hourMatch.group(1)!)));
      final jamMatch = RegExp(r"(\d+)\s*jam").firstMatch(lower);
      if (jamMatch != null)
        return now.subtract(Duration(hours: int.parse(jamMatch.group(1)!)));
      final hariMatch = RegExp(r"(\d+)\s*hari").firstMatch(lower);
      if (hariMatch != null)
        return now.subtract(Duration(days: int.parse(hariMatch.group(1)!)));

      return null;
    } catch (e) {
      return null;
    }
  }

  bool _matchesScope(dynamic news) {
    if (news == null) return false;
    final title = (news['title'] ?? news['news'] ?? '')
        .toString()
        .toLowerCase();
    final source = (news['source'] ?? news['category'] ?? '')
        .toString()
        .toLowerCase();
    final url = (news['url'] ?? '').toString().toLowerCase();

    if (_newsScope == 'Global') {
      // Exclude obvious local sources/domains first
      for (var li in _localIndicators) {
        if (title.contains(li) || source.contains(li) || url.contains(li))
          return false;
      }

      // Prefer known global outlets or external hosts
      final globalOutlets = [
        'reuters',
        'bloomberg',
        'ft.com',
        'wsj',
        'nytimes',
        'cnn',
        'cnbc',
        'marketwatch',
        'bbc',
        'guardian',
        'economist',
      ];

      // If url host or source/title matches global outlets, accept
      try {
        final uri = Uri.tryParse(url ?? '');
        final host = uri?.host?.toLowerCase() ?? '';
        for (var g in globalOutlets) {
          if (host.contains(g) || title.contains(g) || source.contains(g))
            return true;
        }
      } catch (e) {
        // ignore
      }

      // Finally, match by global keywords in title/source/url
      for (var k in _globalKeywords) {
        if (title.contains(k) || source.contains(k) || url.contains(k))
          return true;
      }

      return false;
    }

    // IDN scope: prefer Indonesian sources or .id domains
    final idnSources = [
      'indonesia',
      'kompas',
      'kontan',
      'cnbc indonesia',
      'cnn indonesia',
      'antaranews',
      'bisnis',
      'tempo',
      'detik',
      'tribun',
      '.id',
    ];
    for (var s in idnSources)
      if (title.contains(s) || source.contains(s) || url.contains(s))
        return true;

    return false;
  }

  Widget _buildHeadlineNewsCard(Map<String, dynamic> news) {
    return GestureDetector(
      onTap: () async {
        final url = news['url'];
        if (url != null) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1B3D).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'BIG NEWS 🚨',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news['news'] ?? '',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'BREAKING: ${news['time']}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                height: 1.3,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Impact: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: news['impact'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (news['image'] != null) ...[
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          news['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 8),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Source: Google News',
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.open_in_new, color: Colors.white38, size: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsListItem(dynamic news) {
    final title = (news['title'] ?? news['news'] ?? '').toString();
    final source = (news['source'] ?? news['category'] ?? 'Market').toString();
    final imageUrl = (news['imageUrl'] ?? news['image'])?.toString();
    final url = (news['url'] ?? '').toString();
    final pubDate = _extractNewsDate(news);
    final dateLabel = pubDate != null
        ? DateFormat('yyyy-MM-dd').format(pubDate)
        : _formatTime(news['time']);

    return GestureDetector(
      onTap: () async {
        if (url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        source.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFC800FF),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(color: Colors.white24, fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (imageUrl != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
