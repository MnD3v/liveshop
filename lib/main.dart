import 'package:flutter/material.dart';
import 'package:liveshop/config/theme_config.dart';
import 'package:liveshop/router.dart';
import 'package:provider/provider.dart';
import 'package:liveshop/providers/live_event_provider.dart';
import 'package:liveshop/providers/cart_provider.dart';
import 'package:liveshop/providers/user_provider.dart';
import 'package:liveshop/services/api_service.dart';
import 'package:liveshop/services/socket_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate services
    // Ideally use GetIt or similar for DI, but strictly following Provider requirement and structure.
    // Ensure these are singletons or scoped appropriately.
    final apiService = ApiService();
    final socketService = SocketService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LiveEventProvider(apiService, socketService),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider(apiService)),
        ChangeNotifierProvider(
          create: (_) => UserProvider(apiService)..loadUserData(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Live Shopping',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
