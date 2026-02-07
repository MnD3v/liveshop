import 'package:flutter/material.dart';
import 'package:liveshop/models/live_event.dart';
import 'package:liveshop/models/chat_message.dart';
import 'package:liveshop/services/api_service.dart';
import 'package:liveshop/services/socket_service.dart';
import 'package:liveshop/models/category.dart';

class LiveEventProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;

  LiveEvent? _currentEvent;
  List<LiveEvent> _events = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  LiveEvent? get currentEvent => _currentEvent;
  List<LiveEvent> get events => _events;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<ChatMessage> get chatStream => _socketService.messageStream;

  LiveEventProvider(this._apiService, this._socketService) {
    _setupSocketListeners();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _apiService.getLiveEvents();
      _categories = await _apiService.getCategories();

      // Load products for all events
      final allProducts = await _apiService.getProducts();
      _events = _events.map((event) {
        final eventProducts = allProducts
            .where((p) => event.productIds.contains(p.id))
            .toList();
        return event.copyWith(productsList: eventProducts);
      }).toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      // Connect first if needed
      if (!_socketService.isConnected) {
        await _socketService.connect();
      }

      _currentEvent = await _apiService.getLiveEventById(eventId);
      _socketService.joinLiveEvent(eventId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void leaveEvent() {
    if (_currentEvent != null) {
      _socketService.leaveLiveEvent(_currentEvent!.id);
      _currentEvent = null;
      notifyListeners();
    }
  }

  void sendMessage(String message) {
    if (_currentEvent != null) {
      _socketService.sendChatMessage(message);
    }
  }

  void _setupSocketListeners() {
    _socketService.viewerCountStream.listen((count) {
      if (_currentEvent != null) {
        _currentEvent = _currentEvent!.copyWith(viewerCount: count);
        notifyListeners();
      }
    });

    // Handle incoming chat messages logic if strictly needed here,
    // but StreamBuilder in UI handles display.

    // Feature product updates
    _socketService.productFeaturedStream.listen((productId) {
      if (_currentEvent != null) {
        try {
          // Find product in populated list
          final product = _currentEvent!.productsList.firstWhere(
            (p) => p.id == productId,
          );
          _currentEvent = _currentEvent!.copyWith(
            featuredProductId: productId,
            featuredProduct: product,
          );
          notifyListeners();
        } catch (e) {
          debugPrint('Featured product not found in event list: $productId');
        }
      }
    });
  }
}
