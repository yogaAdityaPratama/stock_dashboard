class BrokerSummaryModel {
  final String symbol;
  final String marketMakerAction;
  final String dominantBroker;
  final double avgPrice;
  final List<TopBroker> topBuyers;
  final List<TopBroker> topSellers;
  final String lastUpdated;

  BrokerSummaryModel({
    required this.symbol,
    required this.marketMakerAction,
    required this.dominantBroker,
    required this.avgPrice,
    required this.topBuyers,
    required this.topSellers,
    required this.lastUpdated,
  });

  factory BrokerSummaryModel.fromJson(Map<String, dynamic> json) {
    return BrokerSummaryModel(
      symbol: json['symbol'] ?? '',
      marketMakerAction: json['market_maker_action'] ?? 'NEUTRAL',
      dominantBroker: json['dominant_broker'] ?? 'N/A',
      avgPrice: (json['avg_price'] ?? 0).toDouble(),
      topBuyers:
          (json['top_buyers'] as List<dynamic>?)
              ?.map((e) => TopBroker.fromJson(e))
              .toList() ??
          [],
      topSellers:
          (json['top_sellers'] as List<dynamic>?)
              ?.map((e) => TopBroker.fromJson(e))
              .toList() ??
          [],
      lastUpdated: json['last_updated'] ?? '',
    );
  }
}

class TopBroker {
  final String broker;
  final String value;
  final double avgPrice;
  final int volume;

  TopBroker({
    required this.broker,
    required this.value,
    required this.avgPrice,
    required this.volume,
  });

  factory TopBroker.fromJson(Map<String, dynamic> json) {
    return TopBroker(
      broker: json['broker'] ?? '',
      value: json['value'] ?? '',
      avgPrice: (json['avg_price'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
    );
  }
}
