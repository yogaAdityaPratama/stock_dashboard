import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../models/broker_summary_model.dart';
import '../services/broker_summary_websocket_service.dart';

class BrokerSummaryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final BrokerSummaryWebSocketService _wsService = BrokerSummaryWebSocketService();

  BrokerSummaryModel? _data;
  bool _isLoading = false;
  String? _error;
  String? _currentSymbol;
  StreamSubscription? _dataSubscription;
  StreamSubscription? _stateSubscription;
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;

  BrokerSummaryModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  WebSocketConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == WebSocketConnectionState.connected;

  BrokerSummaryProvider() {
    _dataSubscription = _wsService.dataStream.listen(_onDataReceived);
    _stateSubscription = _wsService.connectionState.listen(_onStateChanged);
  }

  void _onDataReceived(BrokerSummaryModel data) {
    _data = data;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _onStateChanged(WebSocketConnectionState state) {
    _connectionState = state;
    if (state == WebSocketConnectionState.disconnected) {
      _error = 'Connection lost. Reconnecting...';
    } else if (state == WebSocketConnectionState.connected) {
      _error = null;
    }
    notifyListeners();
  }

  Future<void> loadBrokerSummary(String symbol) async {
    if (_currentSymbol == symbol && _data != null) return;

    _currentSymbol = symbol;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getBrokerSummary(symbol);
      if (result.isNotEmpty && result.containsKey('symbol')) {
        _data = BrokerSummaryModel.fromJson(result);
        _error = null;
      } else {
        _error = 'Data brokerage tidak tersedia';
      }
    } catch (e) {
      _error = 'Gagal memuat data: $e';
      debugPrint('Broker Summary Provider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    _wsService.connect(symbol);
  }

  void disconnect() {
    _wsService.disconnect();
  }

  void reconnect() {
    if (_currentSymbol != null) {
      _wsService.connect(_currentSymbol!);
    }
  }

  Future<void> refresh() async {
    if (_currentSymbol != null) {
      await loadBrokerSummary(_currentSymbol!);
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _stateSubscription?.cancel();
    _wsService.dispose();
    super.dispose();
  }
}
