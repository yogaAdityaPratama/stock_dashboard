import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/broker_summary_model.dart';

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class BrokerSummaryWebSocketService {
  io.Socket? _socket;
  final _dataController = StreamController<BrokerSummaryModel>.broadcast();
  final _connectionStateController = 
      StreamController<WebSocketConnectionState>.broadcast();
  
  String? _currentSymbol;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const int _reconnectDelaySeconds = 3;

  Stream<BrokerSummaryModel> get dataStream => _dataController.stream;
  Stream<WebSocketConnectionState> get connectionState => 
      _connectionStateController.stream;
  
  WebSocketConnectionState _currentState = WebSocketConnectionState.disconnected;
  WebSocketConnectionState get currentState => _currentState;

  static const String _wsBaseUrl = 'http://10.0.2.2:5000';

  void connect(String symbol) {
    if (_currentSymbol == symbol && 
        _currentState == WebSocketConnectionState.connected) {
      return;
    }
    
    disconnect();
    _currentSymbol = symbol;
    _connect();
  }

  void _connect() {
    if (_currentSymbol == null) return;
    
    _updateState(WebSocketConnectionState.connecting);
    
    try {
      _socket = io.io(
        _wsBaseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setReconnectionDelay(_reconnectDelaySeconds * 1000)
            .build(),
      );

      _socket!.onConnect((_) {
        _updateState(WebSocketConnectionState.connected);
        _reconnectAttempts = 0;
        
        // Subscribe to broker summary for the symbol
        _socket!.emit('subscribe', {'symbol': _currentSymbol});
      });

      _socket!.on('broker_summary_data', (data) {
        try {
          final json = Map<String, dynamic>.from(data as Map);
          if (json.containsKey('symbol')) {
            final brokerData = BrokerSummaryModel.fromJson(json);
            _dataController.add(brokerData);
          }
        } catch (e) {
          // Ignore parsing errors
        }
      });

      _socket!.on('subscribed', (data) {
        // Subscription confirmed
      });

      _socket!.on('broker_summary_error', (data) {
        final error = Map<String, dynamic>.from(data as Map);
        _dataController.addError(error['error'] ?? 'Unknown error');
      });

      _socket!.onDisconnect((_) {
        _updateState(WebSocketConnectionState.disconnected);
        _scheduleReconnect();
      });

      _socket!.onConnectError((error) {
        _updateState(WebSocketConnectionState.disconnected);
        _scheduleReconnect();
      });

      _socket!.connect();
      
    } catch (e) {
      _updateState(WebSocketConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }
    
    _updateState(WebSocketConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: _reconnectDelaySeconds * (_reconnectAttempts + 1)),
      () {
        _reconnectAttempts++;
        _connect();
      },
    );
  }

  void _updateState(WebSocketConnectionState state) {
    _currentState = state;
    _connectionStateController.add(state);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    if (_socket != null) {
      if (_currentSymbol != null) {
        _socket!.emit('unsubscribe', {'symbol': _currentSymbol});
      }
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _currentSymbol = null;
    _reconnectAttempts = 0;
    _updateState(WebSocketConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _dataController.close();
    _connectionStateController.close();
  }
}
