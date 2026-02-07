import 'package:flutter/material.dart';
import 'package:liveshop/models/cart_item.dart';
import 'package:liveshop/models/product.dart';
import 'package:liveshop/models/order.dart'; // For ShippingAddress
import 'package:liveshop/services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  CartProvider(this._apiService) {
    // Optionally load cart on init, or manually
    // loadCart();
  }

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get total => _items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _apiService.getCart();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(
    Product product,
    int quantity, {
    Map<String, String>? variations,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.addToCart(product.id, quantity, variations: variations);
      // Refresh mock cart
      await loadCart();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItem(String itemId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.removeFromCart(itemId);
      await loadCart();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.clearCart();
      await loadCart();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkout(ShippingAddress address) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.checkout(address);
      await loadCart(); // Should be empty
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
