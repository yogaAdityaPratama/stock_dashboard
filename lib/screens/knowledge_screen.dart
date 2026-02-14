import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class BasicKnowledgeScreen extends StatefulWidget {
  const BasicKnowledgeScreen({super.key});

  @override
  State<BasicKnowledgeScreen> createState() => _BasicKnowledgeScreenState();
}

class _BasicKnowledgeScreenState extends State<BasicKnowledgeScreen> {
  String searchQuery = '';
  late PageController _newsPageController;
  int _currentNewsIndex = 0;
  Timer? _newsTimer;

  final ApiService _apiService = ApiService();
  List<dynamic> _topStories = [];
  bool _isTopNewsLoading = true;

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
  }

  Future<void> _loadTopStories() async {
    try {
      final data = await _apiService.fetchMarketNews();
      if (mounted && data['news'] != null) {
        setState(() {
          _topStories = data['news'];
          _isTopNewsLoading = false;
        });
      }
    } catch (e) {
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
    // --- MARKET PARTICIPANTS ---
    {
      'name': 'Big Whale',
      'code': 'WHALE',
      'type': 'Market Player',
      'origin': 'Institutional',
      'flag': '🐋',
      'desc':
          'Entitas pemilik modal raksasa yang mampu menggerakkan harga pasar. Jejak mereka terlihat dari volume spike yang tidak wajar.',
    },
    {
      'name': 'Megalodon',
      'code': 'MEGA',
      'type': 'Super Player',
      'origin': 'Top Tier Inst.',
      'flag': '🦈',
      'desc':
          'Level tertinggi Big Money. Gabungan institusi raksasa atau Sovereign Wealth Fund. Saat mereka masuk, tren jangka panjang terbentuk.',
    },
    {
      'name': 'Market Maker',
      'code': 'MM',
      'type': 'Liquidity',
      'origin': 'System',
      'flag': '🏦',
      'desc':
          'Penyedia likuiditas yang bertugas menjaga ketersediaan order beli dan jual (Bid-Offer) agar pasar tetap cair dan teratur.',
    },
    {
      'name': 'Smart Money',
      'code': 'SMF',
      'type': 'Strategy',
      'origin': 'Institutional',
      'flag': '🧠',
      'desc':
          'Dana yang dikelola oleh investor profesional/institusi yang memiliki akses informasi dan sumber daya analisis lebih baik dari ritel.',
    },
    {
      'name': 'Retail / Plankton',
      'code': 'RETL',
      'type': 'Market Player',
      'origin': 'Individual',
      'flag': '🦐',
      'desc':
          'Investor perorangan dengan modal kecil. Sering menjadi target likuiditas bagi Big Money saat fase distribusi.',
    },
    {
      'name': 'Scalper',
      'code': 'SCALP',
      'type': 'Trader Type',
      'origin': 'Style',
      'flag': '⚡',
      'desc':
          'Trader yang mencari profit cepat (menit/detik) dengan memanfaatkan volatilitas kecil berkali-kali dalam sehari.',
    },

    // --- MARKET PHASES & ACTION ---
    {
      'name': 'Accumulation',
      'code': 'ACC',
      'type': 'Market Phase',
      'origin': 'Price Action',
      'flag': '📦',
      'desc':
          'Fase di mana Big Money diam-diam mengumpulkan barang di harga bawah sebelum harga dinaikkan (Mark-up).',
    },
    {
      'name': 'Mark-Up',
      'code': 'UP',
      'type': 'Market Phase',
      'origin': 'Price Action',
      'flag': '🚀',
      'desc':
          'Fase kenaikan harga yang didorong oleh Big Money setelah akumulasi selesai. Retail biasanya mulai masuk di fase ini.',
    },
    {
      'name': 'Distribution',
      'code': 'DIST',
      'type': 'Market Phase',
      'origin': 'Price Action',
      'flag': '🎁',
      'desc':
          'Fase Big Money menjual barang kepada retail di harga atas. Biasanya ditandai dengan berita bagus yang memancing FOMO.',
    },
    {
      'name': 'Mark-Down',
      'code': 'DOWN',
      'type': 'Market Phase',
      'origin': 'Price Action',
      'flag': '🩸',
      'desc':
          'Fase penurunan harga secara tajam setelah distribusi selesai. Retail yang "nyangkut" biasanya panic sell di sini.',
    },
    {
      'name': 'Breakout',
      'code': 'BO',
      'type': 'Price Action',
      'origin': 'Technical',
      'flag': '💥',
      'desc':
          'Harga berhasil menembus level resisten kuat dengan volume tinggi, menandakan potensi kelanjutan tren naik.',
    },
    {
      'name': 'Rejection',
      'code': 'REJ',
      'type': 'Price Action',
      'origin': 'Technical',
      'flag': '✋',
      'desc':
          'Gagal menembus support atau resisten, biasanya meninggalkan "ekor" panjang pada candle (Shadow/Wick).',
    },

    // --- QUANTITATIVE & INDICATORS ---
    {
      'name': 'MSCI Index',
      'code': 'MSCI',
      'type': 'Indicator',
      'origin': 'Global',
      'flag': '🌎',
      'desc':
          'Morgan Stanley Capital International. Masuk indeks ini berarti saham akan dibeli otomatis oleh ribuan reksa dana global.',
    },
    {
      'name': 'VWAP',
      'code': 'VWAP',
      'type': 'Indicator',
      'origin': 'Quant',
      'flag': '📊',
      'desc':
          'Volume Weighted Average Price. Harga rata-rata sesungguhnya berdasarkan volume. Acuan utama institusi untuk entry/exit.',
    },
    {
      'name': 'Order Book',
      'code': 'OB',
      'type': 'Data',
      'origin': 'Exchange',
      'flag': '📖',
      'desc':
          'Daftar antrian beli (Bid) dan jual (Offer). Analisis Tape Reading melihat perilaku antrian ini untuk mendeteksi Bandar.',
    },
    {
      'name': 'Ara & Arb',
      'code': 'LIMIT',
      'type': 'Regulation',
      'origin': 'IDX',
      'flag': '🛑',
      'desc':
          'Auto Rejection Atas/Bawah. Batas kenaikan atau penurunan harga maksimal dalam sehari yang diizinkan bursa.',
    },
    {
      'name': 'Gap',
      'code': 'GAP',
      'type': 'Price Action',
      'origin': 'Technical',
      'flag': '🕳️',
      'desc':
          'Celah harga kosong antara penutupan kemarin dan pembukaan hari ini. "Gap must be filled" adalah mitos yang sering dipercaya.',
    },

    // --- TRADER SLANG (INDO) ---
    {
      'name': 'HAKA',
      'code': 'BUY',
      'type': 'Slang',
      'origin': 'Trader Indo',
      'flag': '🥊',
      'desc':
          'Hajar Kanan. Membeli saham langsung di harga Offer (Ask) tanpa antri, karena yakin harga akan naik cepat.',
    },
    {
      'name': 'HAKI',
      'code': 'SELL',
      'type': 'Slang',
      'origin': 'Trader Indo',
      'flag': '🏃',
      'desc':
          'Hajar Kiri. Menjual saham langsung di harga Bid (langsung laku) karena panik atau ingin segera keluar.',
    },
    {
      'name': 'Sangkuter',
      'code': 'BAG',
      'type': 'Status',
      'origin': 'Trader Indo',
      'flag': '🗿',
      'desc':
          'Istilah untuk trader yang membeli di pucuk dan harga turun drastis, kini memegang saham rugi (Bag Holder).',
    },
    {
      'name': 'Serok',
      'code': 'DIP',
      'type': 'Action',
      'origin': 'Trader Indo',
      'flag': '🥄',
      'desc':
          'Membeli saham saat harga sedang turun (Buy on Weakness), berharap harga akan memantul naik (Rebound).',
    },
    {
      'name': 'Pom-Pom',
      'code': 'HYPE',
      'type': 'Manipulation',
      'origin': 'Influencer',
      'flag': '📢',
      'desc':
          'Aktivitas menghasut orang lain untuk membeli saham tertentu agar harga naik, biasanya dilakukan oleh influencer saham.',
    },
    {
      'name': 'Cuan',
      'code': 'PROFIT',
      'type': 'Goal',
      'origin': 'Hokkian',
      'flag': '💰',
      'desc': 'Profit atau keuntungan. Kata suci bagi setiap trader saham.',
    },
    {
      'name': 'Boncos',
      'code': 'LOSS',
      'type': 'Result',
      'origin': 'Slang',
      'flag': '💸',
      'desc':
          'Rugi bandar. Kondisi ketika selling price lebih rendah dari average buying price.',
    },

    // --- SPECIAL EVENTS ---
    {
      'name': 'Wash Trade',
      'code': 'WASH',
      'type': 'Manipulation',
      'origin': 'Illegal',
      'flag': '🧼',
      'desc':
          'Transaksi semu di mana pembeli dan penjual adalah pihak yang sama untuk memanipulasi volume dan memancing retail.',
    },
    {
      'name': 'Short Squeeze',
      'code': 'SQZ',
      'type': 'Event',
      'origin': 'Market',
      'flag': '🍋',
      'desc':
          'Kenaikan harga tajam karena para Short Seller terpaksa melakukan Buyback untuk menutup kerugian mereka.',
    },
    {
      'name': 'Dead Cat Bounce',
      'code': 'DCB',
      'type': 'Trap',
      'origin': 'Market',
      'flag': '🐈',
      'desc':
          'Kenaikan harga sementara dalam tren turun yang kuat. "Bahkan kucing mati pun akan memantul jika dijatuhkan dari cukup tinggi".',
    },
    {
      'name': 'IPO',
      'code': 'IPO',
      'type': 'Event',
      'origin': 'Corporate',
      'flag': '👶',
      'desc':
          'Initial Public Offering. Penawaran saham perdana ke publik. Sering menjadi ajang "gorengan" di hari pertama listing.',
    },
    {
      'name': 'Rights Issue',
      'code': 'RI',
      'type': 'Event',
      'origin': 'Corporate',
      'flag': '🎫',
      'desc':
          'Penerbitan saham baru (HMETD). Harga saham lama biasanya akan terdilusi (turun) menyesuaikan harga teoritis baru.',
    },
    {
      'name': 'Stock Split',
      'code': 'SS',
      'type': 'Event',
      'origin': 'Corporate',
      'flag': '✂️',
      'desc':
          'Pemecahan nominal saham agar lebih murah dan likuid. Contoh: Harga 10.000 menjadi 2.000 (Split 1:5).',
    },
    {
      'name': 'Dividen Trap',
      'code': 'TRAP',
      'type': 'Trap',
      'origin': 'Market',
      'flag': '🪤',
      'desc':
          'Penurunan harga saham secara drastis saat Ex-Date dividen, seringkali lebih besar dari nilai dividen yang didapat.',
    },
    {
      'name': 'UMA',
      'code': 'UMA',
      'type': 'Status',
      'origin': 'IDX',
      'flag': '⚠️',
      'desc':
          'Unusual Market Activity. Peringatan dari bursa karena pergerakan harga/volume saham dinilai tidak wajar.',
    },
    {
      'name': 'Suspend',
      'code': 'SUSP',
      'type': 'Status',
      'origin': 'IDX',
      'flag': '🔒',
      'desc':
          'Penghentian sementara perdagangan saham oleh bursa. Bisa karena UMA berkepanjangan atau masalah korporasi.',
    },
    {
      'name': 'FCA',
      'code': 'WATCH',
      'type': 'Status',
      'origin': 'IDX',
      'flag': '👁️',
      'desc':
          'Full Call Auction. Metode perdagangan khusus untuk saham dalam pemantauan khusus, order tidak langsung match (Blind Order).',
    },
    {
      'name': 'FOMO',
      'code': 'FOMO',
      'origin': 'Psychology',
      'type': 'Emotion',
      'flag': '😱',
      'desc':
          'Fear Of Missing Out. Rasa takut ketinggalan profit yang membuat trader membeli di harga pucuk tanpa analisa.',
    },
    {
      'name': 'FUD',
      'code': 'FUD',
      'origin': 'Psychology',
      'type': 'Emotion',
      'flag': '😨',
      'desc':
          'Fear, Uncertainty, Doubt. Penyebaran berita negatif untuk menakut-nakuti investor agar menjual saham mereka (Cut Loss).',
    },
  ];

  final List<Map<String, dynamic>> conglomerates = [
    {
      'name': 'Salim Group',
      'owner': 'Anthoni Salim',
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
      'stocks': [
        {'t': 'BRPT', 's': 'Normal'},
        {'t': 'TPIA', 's': 'Normal'},
        {'t': 'BREN', 's': 'Hype'},
        {'t': 'CUAN', 's': 'Hype'},
      ],
    },
    {
      'name': 'Saratoga Group',
      'owner': 'Sandiaga Uno / Edwin S.',
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
      'stocks': [
        {'t': 'DCII', 's': 'Hype'},
        {'t': 'EDGE', 's': 'Normal'},
      ],
    },
    {
      'name': 'Harita Group',
      'owner': 'Lim Hariyanto Wijaya Sarwono',
      'stocks': [
        {'t': 'NCKL', 's': 'Hype'},
        {'t': 'CITA', 's': 'Normal'},
        {'t': 'PALM', 's': 'Normal'},
      ],
    },
    {
      'name': 'Astra Group',
      'owner': 'Jardine Cycle & Carriage',
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
      'stocks': [
        {'t': 'BELI', 's': 'Normal'},
        {'t': 'GOTO', 's': 'Hype'},
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
            'Kamus Brocksum',
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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: terms.length,
      itemBuilder: (context, index) {
        final term = terms[index];
        return InkWell(
          onTap: () => _showTermDefinition(term),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC800FF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    term['code'] ?? term['flag'] ?? (term['name']?[0] ?? 'T'),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC800FF),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  term['name'] ?? term['term'] ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  term['type'] ?? 'Trading Term',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.white38,
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
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (conglo['stocks'] as List<Map<String, String>>)
                          .map((stock) {
                            final ticker = stock['t']!;
                            final status = stock['s']!.toLowerCase();
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

  void _showTermDefinition(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
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
          padding: const EdgeInsets.all(32),
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC800FF).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      item['code'] ?? item['flag'] ?? 'T',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (item['type'] ?? 'Knowledge').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (item['origin'] != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                item['origin'],
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'DEFINITION / PENGERTIAN',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFC800FF),
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  item['desc'] ?? item['definition'] ?? 'No Description',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    height: 1.6,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              Text(
                'QUANTS ANALYTICS REPORT',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFC800FF),
                  letterSpacing: 2,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    'AUM',
                    item['aum'] ?? 'Confidential',
                    Icons.account_balance_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Origin',
                    '${item['flag'] ?? ""} ${item['origin'] ?? "Global"}',
                    Icons.public_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard(
                    'PNL/Year',
                    item['pnl'] ?? '+12.5% Avg',
                    Icons.insights_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Market Dominance',
                    '${((item['dominance'] ?? 0.75) * 100).toInt()}%',
                    Icons.leaderboard_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard(
                    'Risk Profile',
                    item['risk'] ?? 'Moderate',
                    Icons.warning_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'QUALITATIVE ANALYSIS',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFC800FF),
                  letterSpacing: 2,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  item['desc'] ??
                      item['definition'] ??
                      'Analisis mendalam sedang diproses oleh sistem.',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
              ),
              if (item['parameter'] != null) ...[
                const SizedBox(height: 32),
                Text(
                  'TECHNICAL PARAMETERS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFC800FF),
                    letterSpacing: 2,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item['parameter']!,
                  style: GoogleFonts.outfit(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white24, size: 18),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
        Text(
          'Top Stories',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          ..._topStories
              .map(
                (news) => _buildNewsListItem(
                  news['news'] ?? '',
                  news['category'] ?? 'Market',
                  _formatTime(news['time']),
                  news['image'],
                  news['url'],
                ),
              )
              .toList(),
        const SizedBox(height: 30),
      ],
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'Recent';
    try {
      // Handle Google News RSS format: "Fri, 14 Feb 2025 07:00:00 GMT"
      final date = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(timeStr);
      final diff = DateTime.now().difference(date);
      if (diff.inHours < 1) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return DateFormat('MMM dd').format(date);
    } catch (e) {
      return timeStr.split(' ').take(3).join(' '); // Fallback
    }
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

  Widget _buildNewsListItem(
    String title,
    String tag,
    String time,
    String? imageUrl,
    String? url,
  ) {
    return GestureDetector(
      onTap: () async {
        if (url != null) {
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
                        tag.toUpperCase(),
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
                        time,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
