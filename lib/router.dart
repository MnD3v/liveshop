import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liveshop/screens/home/home_screen.dart';
import 'package:liveshop/screens/live/live_event_screen.dart';
import 'package:liveshop/screens/checkout/checkout_screen.dart';
import 'package:liveshop/screens/notifications/notifications_screen.dart'; // Import NotificationsScreen
// import 'package:liveshop/screens/product/product_detail_screen.dart';
// import 'package:liveshop/screens/profile/profile_screen.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'live/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return LiveEventScreen(eventId: id);
          },
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    ),
  ],
);
