import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/broker_summary_model.dart';
import '../providers/broker_summary_provider.dart';
import '../screens/knowledge_screen.dart';

class BrokerSummaryModal extends StatelessWidget {
  final String stockCode;

  const BrokerSummaryModal({super.key, required this.stockCode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrokerSummaryProvider()..loadBrokerSummary(stockCode),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1E1E2E).withValues(alpha: 0.98),
                const Color(0xFF0F0F1A).withValues(alpha: 0.99),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: Consumer<BrokerSummaryProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.cyanAccent,
                        ),
                      );
                    }

                    if (provider.error != null) {
                      return Center(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    final data = provider.data;
                    if (data == null) {
                      return const Center(
                        child: Text(
                          'No Data',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => provider.loadBrokerSummary(stockCode),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildHeader(data, provider),
                            const SizedBox(height: 20),
                            _buildMarketMakerCard(data),
                            const SizedBox(height: 20),
                            _buildBrokerLists(context, data),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BrokerSummaryModel data, BrokerSummaryProvider provider) {
    final isAccumulation = data.marketMakerAction == 'BUYING';
    final badgeColor = isAccumulation
        ? Colors.green
        : (data.marketMakerAction == 'SELLING' ? Colors.red : Colors.grey);
    final badgeText = isAccumulation
        ? 'ACCUMULATION'
        : (data.marketMakerAction == 'SELLING' ? 'DISTRIBUTION' : 'NEUTRAL');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'BROKER SUMMARY',
                      style: GoogleFonts.robotoMono(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildLiveIndicator(provider.isConnected),
                  ],
                ),
                Text(
                  'Smart Money Analysis',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Last Updated: ${DateFormat('hh:mm:ss aa').format(DateTime.parse(data.lastUpdated).toLocal())}',
              style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white30),
            ),
            if (!provider.isConnected)
              Text(
                'Reconnecting...',
                style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.orange),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveIndicator(bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isConnected 
            ? Colors.green.withOpacity(0.2) 
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(isActive: isConnected),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'LIVE' : 'OFFLINE',
            style: GoogleFonts.robotoMono(
              fontSize: 8,
              color: isConnected ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketMakerCard(BrokerSummaryModel data) {
    final isBuying = data.marketMakerAction == 'BUYING';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.purpleAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Market Maker Action',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Row(
                  children: [
                    Text(
                      data.dominantBroker,
                      style: GoogleFonts.robotoMono(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isBuying ? Colors.green : Colors.red)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.marketMakerAction,
                        style: TextStyle(
                          color: isBuying
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Avg Price',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                NumberFormat.decimalPattern('id').format(data.avgPrice),
                style: GoogleFonts.robotoMono(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrokerLists(BuildContext context, BrokerSummaryModel data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildListHeader('TOP BUYER', Colors.greenAccent),
              const SizedBox(height: 10),
              ...data.topBuyers.map(
                (b) => _buildBrokerRow(context, b, Colors.greenAccent),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildListHeader('TOP SELLER', Colors.redAccent),
              const SizedBox(height: 10),
              ...data.topSellers.map(
                (s) => _buildBrokerRow(context, s, Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color, width: 2)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrokerRow(BuildContext context, TopBroker broker, Color color) {
    return InkWell(
      onTap: () async {
        // Close modal first, then navigate to Knowledge screen and auto-open broker pop-art
        final code = broker.broker.toString();
        try {
          Navigator.of(context).pop();
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 200));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BasicKnowledgeScreen(initialBrokerCode: code),
        ));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white10,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  broker.broker,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11, // Increased size slightly
                    shadows: [
                      const Shadow(blurRadius: 2.0, color: Colors.black45),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    broker.value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            NumberFormat.decimalPattern('id').format(broker.avgPrice),
            style: GoogleFonts.robotoMono(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final bool isActive;

  const _PulsingDot({required this.isActive});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive
                ? Colors.green.withValues(alpha: _animation.value)
                : Colors.orange.withValues(alpha: 0.5),
          ),
        );
      },
    );
  }
}
