import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// ============================================================================
/// TRADINGVIEW CHART WIDGET
/// ============================================================================
///
/// Deskripsi:
/// Widget responsif untuk menampilkan data market real-time.
/// Dioptimalkan untuk "dark mode" dan tampilan mobile.
///
/// Updates:
/// - Removed unnecessary white shimmer/loading
/// - Improved HTML template for responsiveness
/// - Added robust error handling
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
    this.height = 280, // Default adjusted for compact view
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
    // Ensure idx symbol format
    final String cleanSymbol = widget.symbol.replaceAll('IDX:', '');
    final String formattedSymbol = 'IDX:$cleanSymbol';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
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
      ..loadHtmlString(_getChartHtml(formattedSymbol));
  }

  /// Generate HTML untuk TradingView chart dengan dark theme optimization
  ///
  /// IMPORTANT: Menggunakan background color solid (#1A0A2E) instead of transparent
  /// untuk menghindari white flash saat loading di WebView. Color ini matching
  /// dengan app theme utama untuk seamless experience.
  String _getChartHtml(String symbol) {
    return '''
      <!DOCTYPE html>
      <html lang="id">
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            html, body { 
              margin: 0; 
              padding: 0; 
              background-color: #1A0A2E; 
              overflow: hidden; 
              width: 100%;
              height: 100%;
            }
            #tradingview_chart { 
              position: absolute; 
              top: 0; 
              left: 0; 
              width: 100%; 
              height: 100%; 
              background-color: #1A0A2E;
            }
          </style>
        </head>
        <body>
          <div id="tradingview_chart"></div>
          <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
          <script type="text/javascript">
            new TradingView.widget({
              "autosize": true,
              "symbol": "$symbol",
              "interval": "${widget.interval}",
              "timezone": "Asia/Jakarta",
              "theme": "${widget.theme}",
              "style": "1",
              "locale": "id",
              "enable_publishing": false,
              "allow_symbol_change": true,
              "container_id": "tradingview_chart",
              "hide_side_toolbar": false,
              "hide_top_toolbar": false,
              "save_image": false,
              "backgroundColor": "#1A0A2E",
              "gridColor": "rgba(255, 255, 255, 0.05)"
            });
          </script>
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
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
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
    );
  }
}
