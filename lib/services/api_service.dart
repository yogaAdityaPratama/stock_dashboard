import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://127.0.0.1:5000/api';
  }

  Future<Map<String, dynamic>> screenStocks(String analystStyle) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/screen'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'analyst_style': analystStyle}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load screening data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  Future<Map<String, dynamic>> getStrategies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/strategies'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load strategies');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  Future<Map<String, dynamic>> screenStocksV2({
    required String mode,
    String? tacticalStrategy,
    required String timeframe,
    Map<String, dynamic>? filters,
    String? userPrompt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/screen_v2'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mode': mode,
          'tactical_strategy': tacticalStrategy,
          'timeframe': timeframe,
          'filters': filters ?? {},
          'user_prompt': userPrompt,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load screening data v2: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  Future<Map<String, dynamic>> aiChat({
    required String prompt,
    List<Map<String, dynamic>>? screeningResults,
    String? timeframe,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai_chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'screening_results': screeningResults ?? [],
          'timeframe': timeframe ?? 'Monthly',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('AI Chat failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('AI Chat Error: $e');
      return {
        'response':
            'Maaf, saya sedang mengalami masalah teknis. Silakan coba lagi.',
        'suggestions': [],
      };
    }
  }

  Future<Map<String, dynamic>> getForecast(String stockCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forecast'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': stockCode}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  /// Memanggil endpoint Advanced Forecast (LSTM + BlackRock)
  Future<Map<String, dynamic>> getAdvancedForecast(String stockCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forecast_advanced'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': stockCode}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Advanced Forecast Failed: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      debugPrint('Advanced Forecast Connection Error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getSentiment(String stockCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sentiment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': stockCode}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      debugPrint('Sentiment AI Error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getChartPatterns(String stockCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patterns'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': stockCode}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      debugPrint('Pattern AI Error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getFullAnalysis(String stockCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analysis'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': stockCode}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      debugPrint('Full Analysis API Error: $e');
      return {};
    }
  }

  /// Mengambil data fundamental saham (ROE, PBV, PER, DER, Dividend, etc)
  Future<Map<String, dynamic>> getFundamentalData(String stockCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fundamental'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': stockCode}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      debugPrint('Fundamental Data API Error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getStockNews(String stockCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/news'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': stockCode}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      debugPrint('News API Error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getBrokerSummary(String stockCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/broker-summary/$stockCode'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      debugPrint('Broker Summary API Error: ${response.statusCode}');
      return {};
    } catch (e) {
      debugPrint('Broker Summary Connection Error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchMarketNews() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/news-list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': 'IHSG'}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      debugPrint('Market News API Error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchSectors() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/sectors'))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      debugPrint('Sector API Error: $e');
      return {};
    }
  }

  // Cache for market data to reduce API calls and speed up UI
  Map<String, List<Map<String, dynamic>>>? _cachedCategories;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  // Fetch multiple stock prices at once with optimized symbol conversion
  Future<List<Map<String, dynamic>>> getMultipleStockPrices(
    List<String> stockCodes,
  ) async {
    if (stockCodes.isEmpty) return [];

    try {
      final symbols = stockCodes
          .map((s) => s.endsWith('.JK') ? s : '$s.JK')
          .join(',');
      final uri = Uri.parse(
        'https://query1.finance.yahoo.com/v7/finance/quote?symbols=$symbols',
      );

      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('Backend Error: API returned status ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body);
      final List results = data['quoteResponse']?['result'] ?? [];

      return results.map<Map<String, dynamic>>((item) {
        final String symbol = item['symbol'] ?? '';
        final String code = symbol.replaceAll('.JK', '');
        final double price =
            (item['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
        final double changePercent =
            (item['regularMarketChangePercent'] as num?)?.toDouble() ?? 0.0;
        final String name = item['longName'] ?? item['shortName'] ?? code;

        return {
          'code': code,
          'name': name,
          'price': price,
          'changeNum': changePercent,
          'change':
              '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
        };
      }).toList();
    } catch (e) {
      debugPrint('Critical Failure in getMultipleStockPrices: $e');
      return [];
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>>
  fetchMarketCategories() async {
    // Check if we have valid cached data
    if (_cachedCategories != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _cachedCategories!;
    }

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/market-dynamics'))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final Map<String, List<Map<String, dynamic>>> result = {
          'Gainer': List<Map<String, dynamic>>.from(data['Gainer'] ?? []),
          'Hype': List<Map<String, dynamic>>.from(data['Hype'] ?? []),
          'MSCI': List<Map<String, dynamic>>.from(data['MSCI'] ?? []),
          'FTSE': List<Map<String, dynamic>>.from(data['FTSE'] ?? []),
          'Loser': List<Map<String, dynamic>>.from(data['Loser'] ?? []),
        };

        _cachedCategories = result;
        _lastFetch = DateTime.now();
        return result;
      }
      return _cachedCategories ?? {};
    } catch (e) {
      debugPrint('Error in fetchMarketCategories (backend sync): $e');
      return _cachedCategories ?? {};
    }
  }

  Future<Map<String, dynamic>> getStockPrice(String stockCode) async {
    try {
      final symbol = stockCode.endsWith('.JK') ? stockCode : '$stockCode.JK';
      final uri = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1m&range=1d',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['chart']?['result']?[0];
        if (result == null) return {};

        final meta = result['meta'];
        final double currentPrice =
            (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
        final double prevClose =
            (meta['previousClose'] as num?)?.toDouble() ?? 0.0;
        final double change = currentPrice - prevClose;
        final double changePercent = prevClose != 0
            ? (change / prevClose) * 100
            : 0.0;

        return {
          'price': currentPrice,
          'previousClose': prevClose,
          'change': change,
          'changePercent': changePercent,
          'symbol': symbol,
        };
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching price for $stockCode: $e');
      return {};
    }
  }
}
