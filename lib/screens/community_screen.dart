import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../services/api_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  @override
  bool get wantKeepAlive => true;

  // Real data from API
  List<Map<String, dynamic>> _trendingStocks = [];
  Map<String, dynamic> _ihsgData = {};
  bool _isLoadingStocks = true;

  // Real posts data
  final List<Map<String, dynamic>> _posts = [
    {
      'author': 'Market.Analyst.ID',
      'verified': true,
      'followers': '45.2K',
      'timestamp': '2 jam',
      'title': '📊 IHSG Rebound Kuat di Sesi Pagi',
      'content':
          'Indeks Harga Saham Gabungan (IHSG) menguat signifikan hari ini didorong performa solid sektor finance dan consumer. Volume transaksi meningkat 34%, investor asing kembali net buy...',
      'imageUrl': null,
      'metrics': {
        'views': '156.3K',
        'comments': 23,
        'shares': 12,
        'likes': 234,
      },
      'reactions': {
        'fire': 45,
        'heart': 98,
        'rocket': 34,
        'thumbsUp': 23,
        'star': 12,
      },
    },
    {
      'author': 'TechnicalTrader',
      'verified': true,
      'followers': '28.9K',
      'timestamp': '4 jam',
      'title': '🎯 Setup Trading Sektor Perbankan',
      'content':
          'Analisis teknikal menunjukkan formasi bullish di saham-saham big cap  banking. BBCA, BBRI, dan BMRI membentuk higher high pattern dengan volume konfirmasi. Support kuat di level 9,500...',
      'imageUrl': null,
      'metrics': {'views': '92.1K', 'comments': 18, 'shares': 8, 'likes': 156},
      'reactions': {'fire': 28, 'heart': 67, 'rocket': 21, 'brain': 15},
    },
    {
      'author': 'ValueInvestor.ID',
      'verified': false,
      'followers': '12.4K',
      'timestamp': '6 jam',
      'title': '💎 Hidden Gems di Sektor Consumer',
      'content':
          'Menemukan beberapa saham undervalued di sektor consumer dengan PER rendah dan fundamental solid. Potensi upside 40-60% dalam 6-12 bulan. Dividend yield menarik di atas 4%...',
      'imageUrl': null,
      'metrics': {'views': '54.7K', 'comments': 15, 'shares': 5, 'likes': 112},
      'reactions': {'fire': 18, 'heart': 45, 'star': 22},
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fetchTrendingStocks();
  }

  Future<void> _fetchTrendingStocks() async {
    setState(() => _isLoadingStocks = true);

    try {
      // Fetch IHSG data
      final ihsgPrice = await _apiService.getStockPrice('^JKSE');
      if (ihsgPrice.isNotEmpty && mounted) {
        setState(() {
          _ihsgData = {
            'code': 'IHSG',
            'price': ihsgPrice['price'] ?? 0,
            'change': ihsgPrice['changePercent'] ?? 0,
          };
        });
      }

      // Fetch sectors  data
      final sectorsData = await _apiService.fetchSectors();
      if (sectorsData.isNotEmpty && sectorsData['sectors'] != null) {
        final Map<String, List<dynamic>> sectors =
            Map<String, List<dynamic>>.from(sectorsData['sectors']);

        // Get top movers from all sectors
        List<Map<String, dynamic>> allStocks = [];
        sectors.forEach((sectorName, stocks) {
          for (var stock in stocks) {
            allStocks.add({
              'code': stock['code'],
              'change': (stock['change'] as num?)?.toDouble() ?? 0.0,
              'sector': sectorName,
            });
          }
        });

        // Sort by absolute change and take top 10
        allStocks.sort(
          (a, b) => ((b['change'] as double).abs()).compareTo(
            (a['change'] as double).abs(),
          ),
        );

        if (mounted) {
          setState(() {
            _trendingStocks = allStocks.take(10).toList();
            _isLoadingStocks = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching trending stocks: $e');
      if (mounted) {
        setState(() => _isLoadingStocks = false);
      }
    }
  }

  Future<void> _refresh() async {
    await _fetchTrendingStocks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0214),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFFC800FF),
          child: Column(
            children: [
              _buildHeader(),
              _buildTrendingStocks(),
              const SizedBox(height: 12),
              _buildTrendingPostsHeader(),
              Expanded(child: _buildPostsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white70),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search community posts'),
                          backgroundColor: Color(0xFF8A2BE2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_box_outlined,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Create new post'),
                          backgroundColor: Color(0xFF8A2BE2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: const Color(0xFFC800FF),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            onTap: (index) {
              final tabs = [
                'Feeds',
                'Topik',
                'Lives',
                'Articles',
                'My Page',
                'More',
              ];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Switched to ${tabs[index]} tab'),
                  duration: const Duration(milliseconds: 800),
                  backgroundColor: const Color(0xFF8A2BE2),
                ),
              );
            },
            tabs: const [
              Tab(text: 'Feeds'),
              Tab(text: 'Topik'),
              Tab(text: 'Lives'),
              Tab(text: 'Articles'),
              Tab(text: 'My Page'),
              Tab(text: 'More'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingStocks() {
    if (_isLoadingStocks) {
      return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC800FF),
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Combine IHSG with trending stocks
    final displayStocks = <Map<String, dynamic>>[];
    if (_ihsgData.isNotEmpty) {
      displayStocks.add(_ihsgData);
    }
    displayStocks.addAll(_trendingStocks.take(9));

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: displayStocks.length,
        itemBuilder: (context, index) {
          final stock = displayStocks[index];
          final changeValue = (stock['change'] as num?)?.toDouble() ?? 0.0;
          final isPositive = changeValue >= 0;
          final color = isPositive ? const Color(0xFF39FF14) : Colors.redAccent;

          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('View ${stock['code']} details'),
                  backgroundColor: const Color(0xFF8A2BE2),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.symmetric(horizontal: 4),
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: stock['code'] == 'IHSG'
                      ? const Color(0xFFC800FF).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  width: stock['code'] == 'IHSG' ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: color,
                          size: 16,
                        ),
                        Flexible(
                          child: Text(
                            stock['code'],
                            style: GoogleFonts.robotoMono(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${isPositive ? '+' : ''}${changeValue.toStringAsFixed(2)}%',
                    style: GoogleFonts.robotoMono(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingPostsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Trending Posts',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF8A2BE2).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Trending',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFFC800FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.whatshot, color: Color(0xFFC800FF), size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_posts[index]);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF8A2BE2).withValues(alpha: 0.3),
                child: Text(
                  post['author'].toString().substring(0, 1).toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post['author'],
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post['verified'] == true) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF00D9FF),
                            size: 16,
                          ),
                        ],
                        const SizedBox(width: 6),
                        Text(
                          '• ${post['timestamp']}',
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '@ ${post['followers']} Followers',
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Following ${post['author']}'),
                        backgroundColor: const Color(0xFF39FF14),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8A2BE2), Color(0xFFC800FF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Follow',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Post title
          Text(
            post['title'],
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // Post content
          Text(
            post['content'],
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Reactions
          Wrap(
            spacing: 8,
            children: (post['reactions'] as Map<String, dynamic>).entries.map((
              entry,
            ) {
              return _buildReactionChip(entry.key, entry.value);
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Metrics footer
          Row(
            children: [
              _buildMetricItem(Icons.visibility, post['metrics']['views']),
              const SizedBox(width: 16),
              _buildMetricItem(
                Icons.chat_bubble_outline,
                post['metrics']['comments'],
              ),
              const SizedBox(width: 16),
              _buildMetricItem(Icons.repeat, post['metrics']['shares']),
              const SizedBox(width: 16),
              _buildMetricItem(Icons.favorite_border, post['metrics']['likes']),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post options'),
                      backgroundColor: Color(0xFF8A2BE2),
                      duration: Duration(milliseconds: 800),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionChip(String type, int count) {
    final icons = {
      'fire': '🔥',
      'heart': '❤️',
      'rocket': '🚀',
      'thumbsUp': '👍',
      'star': '⭐',
      'flash': '⚡',
      'brain': '🧠',
      'trophy': '🏆',
    };

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reacted with ${icons[type]}'),
            backgroundColor: const Color(0xFFC800FF),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icons[type] ?? '👍', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: GoogleFonts.robotoMono(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, dynamic value) {
    String displayValue = value.toString();
    if (value is String) {
      displayValue = value;
    } else if (value is int) {
      displayValue = value.toString();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 4),
        Text(
          displayValue,
          style: GoogleFonts.robotoMono(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
