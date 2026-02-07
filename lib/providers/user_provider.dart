import 'package:flutter/material.dart';
import 'package:liveshop/models/order.dart';
import 'package:liveshop/models/user_notification.dart';
import 'package:liveshop/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Order> _orders = [];
  List<UserNotification> _notifications = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  List<UserNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  UserProvider(this._apiService);

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getOrders(),
        _apiService.getNotifications(),
      ]);
      _orders = results[0] as List<Order>;
      _notifications = results[1] as List<UserNotification>;
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
