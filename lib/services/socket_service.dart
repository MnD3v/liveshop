import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:liveshop/models/chat_message.dart';
import 'dart:math';

class SocketService {
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _viewerCountController = StreamController<int>.broadcast();

  Timer? _viewerCountTimer;
  Timer?
  _chatSimulationTimer; // For simulating incoming chat messages automatically

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<int> get viewerCountStream => _viewerCountController.stream;

  // Mock streams for other events
  final _productFeaturedController = StreamController<String>.broadcast();
  Stream<String> get productFeaturedStream => _productFeaturedController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));
    _isConnected = true;
    _connectionController.add(true);
    debugPrint('Mock Socket Connected');
  }

  void disconnect() {
    _isConnected = false;
    _connectionController.add(false);
    _viewerCountTimer?.cancel();
    _chatSimulationTimer?.cancel();
    debugPrint('Mock Socket Disconnected');
  }

  void joinLiveEvent(String eventId) {
    if (!_isConnected) return;
    debugPrint('Joined room: $eventId');

    // Start simulating viewer count updates
    _viewerCountTimer?.cancel();
    _viewerCountTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Simulate random viewer count
      final count = 200 + Random().nextInt(50);
      _viewerCountController.add(count);
    });

    // Start stimulating incoming chat messages from others
    _chatSimulationTimer?.cancel();
    _chatSimulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      final mockMessages = [
        "J'adore ce produit ! 😍",
        "Est-ce disponible en rouge ?",
        "La qualité a l'air top.",
        "Livraison rapide ?",
        "Hello tout le monde ! 👋",
      ];
      final randomMsg = mockMessages[Random().nextInt(mockMessages.length)];
      final senderName = "User${Random().nextInt(100)}";

      _messageController.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'mock_user_${Random().nextInt(100)}',
          senderName: senderName,
          message: randomMsg,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void leaveLiveEvent(String eventId) {
    debugPrint('Left room: $eventId');
    _viewerCountTimer?.cancel();
    _chatSimulationTimer?.cancel();
  }

  void sendChatMessage(String message) {
    if (!_isConnected) return;

    // Simulate sending with a small delay and local echo
    Future.delayed(const Duration(milliseconds: 200), () {
      final chatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'current_user',
        senderName: 'Vous',
        message: message,
        timestamp: DateTime.now(),
      );
      _messageController.add(chatMessage);
    });
  }

  void dispose() {
    _messageController.close();
    _connectionController.close();
    _viewerCountController.close();
    _productFeaturedController.close();
    _viewerCountTimer?.cancel();
    _chatSimulationTimer?.cancel();
  }
}
