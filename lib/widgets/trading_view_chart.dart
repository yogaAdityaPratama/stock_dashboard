import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// ============================================================================
/// TRADINGVIEW CHART WIDGET - V2 (UPDATED)
/// ============================================================================
///
/// Upgrade Notes (March 2026):
/// - Migrated from deprecated `tv.js` to TradingView Widget V2 library
/// - Added cache-busting timestamp to prevent stale data
/// - Fixed WebView caching causing chart to freeze at old dates
/// - Proper no-cache meta headers to force fresh data on every load
///
/// The old `https://s3.tradingview.com/tv.js` widget has known issues with
/// data staleness in embedded WebViews. The new widget script from
/// `https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js`
/// provides more reliable real-time data updates.
/// ============================================================================

class TradingViewChart extends StatefulWidget {
  final String symbol;
  final String theme;
  final double height;
  final String interval;

  const TradingViewChart({
    super.key,
    required this.symbol,
    this.theme = 'dark',
    this.height = 320,
    this.interval = 'D',
  });

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChart();
  }

  void _initializeChart() {
    // Ensure IDX symbol format
    final String cleanSymbol = widget.symbol
        .replaceAll('IDX:', '')
        .replaceAll('.JK', '')
        .trim();
    final String formattedSymbol = 'IDX:$cleanSymbol';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1A0A2E))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('TradingView Error: ${error.description}');
          },
        ),
      )
      // Clear cache before loading to ensure fresh data
      ..clearCache()
      ..clearLocalStorage()
      ..loadHtmlString(_getChartHtml(formattedSymbol));
  }

  /// Generate HTML for TradingView Advanced Chart Widget (V2)
  ///
  /// KEY CHANGES from V1:
  /// 1. Uses `embed-widget-advanced-chart.js` instead of deprecated `tv.js`
  /// 2. Cache-busting timestamp in script URL prevents stale JS from WebView cache
  /// 3. No-cache meta headers force WebView to fetch fresh data
  /// 4. `isTransparent: true` for seamless dark mode integration
  String _getChartHtml(String symbol) {
    // Cache-busting: append current timestamp to script URL
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;

    return '''
      <!DOCTYPE html>
      <html lang="id">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <!-- CRITICAL: Force no-cache to prevent stale chart data -->
          <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
          <meta http-equiv="Pragma" content="no-cache">
          <meta http-equiv="Expires" content="0">
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            html, body { 
              margin: 0; 
              padding: 0; 
              background-color: #1A0A2E;
              overflow: hidden; 
              width: 100vw;
              height: 100vh;
              -webkit-overflow-scrolling: touch;
            }
            .tradingview-widget-container { 
              width: 100%; 
              height: 100%;
              background-color: #1A0A2E;
            }
            .tradingview-widget-container__widget {
              width: 100%;
              height: 100%;
            }
            /* Hide TradingView branding for cleaner look */
            .tradingview-widget-copyright { display: none !important; }
            iframe { border: none !important; }
            ::-webkit-scrollbar { width: 4px; }
            ::-webkit-scrollbar-thumb {
              background: rgba(255, 255, 255, 0.1);
              border-radius: 10px;
            }
          </style>
        </head>
        <body>
          <div class="tradingview-widget-container">
            <div class="tradingview-widget-container__widget"></div>
            <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js?v=$cacheBuster" async>
            {
              "autosize": true,
              "symbol": "$symbol",
              "interval": "${widget.interval}",
              "timezone": "Asia/Jakarta",
              "theme": "${widget.theme}",
              "style": "1",
              "locale": "id",
              "backgroundColor": "rgba(26, 10, 46, 1)",
              "gridColor": "rgba(255, 255, 255, 0.05)",
              "allow_symbol_change": true,
              "calendar": false,
              "hide_volume": false,
              "support_host": "https://www.tradingview.com",
              "studies": [
                "RSI@tv-basicstudies",
                "MASimple@tv-basicstudies"
              ]
            }
            </script>
          </div>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            WebViewWidget(
              controller: _controller,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
            if (_isLoading)
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
