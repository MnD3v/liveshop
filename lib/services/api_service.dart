import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:liveshop/models/live_event.dart';
import 'package:liveshop/models/product.dart';
import 'package:liveshop/models/cart_item.dart';
import 'package:liveshop/models/order.dart';
import 'package:liveshop/models/category.dart';
import 'package:liveshop/models/user_notification.dart';

class ApiService {
  Map<String, dynamic>? _data;
  final List<CartItem> _mockCart = []; // Local mock cart state
  bool _cartLoaded = false;

  // Initialize and load mock data
  Future<void> _loadMockData() async {
    if (_data == null) {
      final jsonString = await rootBundle.loadString(
        'assets/mock-api-data.json',
      );
      _data = json.decode(jsonString);
    }
  }

  Future<List<LiveEvent>> getLiveEvents() async {
    await _loadMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    final eventsJson = _data!['liveEvents'] as List;
    final events = eventsJson.map((e) => LiveEvent.fromJson(e)).toList();

    // Populate products for each event logic could be here if needed,
    // but we can also just return the LiveEvent which has productIds.
    return events;
  }

  Future<LiveEvent> getLiveEventById(String id) async {
    await _loadMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    final eventsJson = _data!['liveEvents'] as List;
    final eventJson = eventsJson.firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw Exception('Event not found'),
    );

    var event = LiveEvent.fromJson(eventJson);

    // Populate products
    if (event.productIds.isNotEmpty) {
      final allProducts = await getProducts();
      final eventProducts = allProducts
          .where((p) => event.productIds.contains(p.id))
          .toList();
      event = event.copyWith(productsList: eventProducts);

      if (event.featuredProductId != null) {
        try {
          final featured = allProducts.firstWhere(
            (p) => p.id == event.featuredProductId,
          );
          event = event.copyWith(featuredProduct: featured);
        } catch (_) {}
      }
    }

    return event;
  }

  Future<List<Product>> getProducts([String? eventId]) async {
    await _loadMockData();
    // In a real API, we might filter by eventId on the server.
    // Here we just return all products from the JSON structure for simplicity
    // or we could filter if the JSON structure had a mapping.
    // The LiveEvents have `products` list (IDs).

    final productsJson = _data!['products'] as List;
    final products = productsJson.map((e) => Product.fromJson(e)).toList();

    if (eventId != null) {
      // This logic is redundant if we use getLiveEventById, but good for separate call
      final event = await getLiveEventById(eventId);
      return products.where((p) => event.productIds.contains(p.id)).toList();
    }

    return products;
  }

  Future<List<Order>> getOrders() async {
    await _loadMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    if (_data!['orders'] == null) return [];
    final ordersJson = _data!['orders'] as List;
    return ordersJson.map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Category>> getCategories() async {
    await _loadMockData();
    if (_data!['categories'] == null) return [];
    final catsJson = _data!['categories'] as List;
    return catsJson.map((e) => Category.fromJson(e)).toList();
  }

  Future<List<UserNotification>> getNotifications() async {
    await _loadMockData();
    await Future.delayed(const Duration(milliseconds: 200));
    if (_data!['notifications'] == null) return [];
    final notifsJson = _data!['notifications'] as List;
    return notifsJson.map((e) => UserNotification.fromJson(e)).toList();
  }

  // Cart Management
  Future<List<CartItem>> getCart() async {
    await _loadMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_cartLoaded && _mockCart.isEmpty && _data!['cart'] != null) {
      final cartData = _data!['cart'];
      if (cartData['items'] != null) {
        final itemsJson = cartData['items'] as List;
        final allProducts = await getProducts();

        for (var itemJson in itemsJson) {
          final productId = itemJson['productId'];
          try {
            final product = allProducts.firstWhere((p) => p.id == productId);
            _mockCart.add(
              CartItem(
                id: itemJson['id'],
                productId: productId,
                product: product,
                quantity: itemJson['quantity'],
                selectedVariations: itemJson['selectedVariations'] != null
                    ? Map<String, String>.from(itemJson['selectedVariations'])
                    : null,
              ),
            );
          } catch (e) {
            // Product not found, skip
          }
        }
      }
      _cartLoaded = true;
    }

    // Ensure products are populated if they are missing (legacy or added without product)
    if (_mockCart.isNotEmpty && _mockCart.any((item) => item.product == null)) {
      final allProducts = await getProducts();
      for (int i = 0; i < _mockCart.length; i++) {
        if (_mockCart[i].product == null) {
          try {
            final product = allProducts.firstWhere(
              (p) => p.id == _mockCart[i].productId,
            );
            _mockCart[i] = _mockCart[i].copyWith(product: product);
          } catch (_) {}
        }
      }
    }

    return List.from(_mockCart);
  }

  Future<void> addToCart(
    String productId,
    int quantity, {
    Map<String, String>? variations,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existingIndex = _mockCart.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      final existingItem = _mockCart[existingIndex];
      _mockCart[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Need to fetch product to populate properly, or just store ID and populate on get
      // Let's try to populate immediately for better UX in this mock
      final allProducts = await getProducts();
      final product = allProducts.firstWhere((p) => p.id == productId);

      _mockCart.add(
        CartItem(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          product: product,
          quantity: quantity,
          selectedVariations: variations,
        ),
      );
    }
  }

  Future<void> removeFromCart(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockCart.removeWhere((item) => item.id == itemId);
  }

  Future<void> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockCart.clear();
  }

  Future<void> checkout(ShippingAddress address) async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulating payment processing
    if (_mockCart.isEmpty) throw Exception('Cart is empty');
    _mockCart.clear();
  }
}
