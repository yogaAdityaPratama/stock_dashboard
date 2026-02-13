import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// ============================================================================
/// TRADINGVIEW CHART WIDGET
/// ============================================================================
///
/// Deskripsi:
/// Widget ini berfungsi untuk merender grafik real-time dari TradingView menggunakan
/// library webview_flutter. Mengikuti prinsip-prinsip Clean Code dan OOP.
///
/// Author: Senior Stock Programmer
/// Language: Dart (Flutter)
/// ============================================================================

class TradingViewChart extends StatefulWidget {
  /// Kode saham (contoh: BBCA, TLKM)
  final String symbol;

  /// Tema grafik ('light' atau 'dark')
  final String theme;

  /// Tinggi widget
  final double height;

  const TradingViewChart({
    super.key,
    required this.symbol,
    this.theme = 'dark',
    this.height = 300,
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
    _initializeWebViewController();
  }

  /// Inisialisasi controller WebView dengan konfigurasi TradingView
  void _initializeWebViewController() {
    // Memastikan format simbol sesuai standar TradingView (IDX:TICKER)
    final String formattedSymbol = widget.symbol.contains(':')
        ? widget.symbol
        : 'IDX:${widget.symbol}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadHtmlString(_getHtmlContent(formattedSymbol, widget.theme));
  }

  /// Menghasilkan konten HTML untuk widget TradingView
  /// Menggunakan Template String untuk injeksi parameter
  String _getHtmlContent(String symbol, String theme) {
    return '''
    <!DOCTYPE html>
    <html lang="id">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        body, html {
          margin: 0;
          padding: 0;
          height: 100%;
          width: 100%;
          background-color: transparent;
          overflow: hidden;
        }
        #tradingview_container {
          height: 100vh;
          width: 100vw;
        }
      </style>
    </head>
    <body>
      <div id="tradingview_container"></div>
      <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
      <script type="text/javascript">
        new TradingView.widget({
          "autosize": true,
          "symbol": "$symbol",
          "interval": "D",
          "timezone": "Asia/Jakarta",
          "theme": "$theme",
          "style": "1",
          "locale": "id",
          "toolbar_bg": "#f1f3f6",
          "enable_publishing": false,
          "hide_top_toolbar": false,
          "hide_legend": false,
          "save_image": false,
          "container_id": "tradingview_container"
        });
      </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Widget WebView Utama
          WebViewWidget(controller: _controller),

          // Loading Indicator (Shimmer/Overlay)
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFC800FF)),
            ),
        ],
      ),
    );
  }
}
