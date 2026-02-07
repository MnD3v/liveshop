import 'package:flutter/material.dart';
import 'package:liveshop/config/theme_config.dart';
import 'package:liveshop/router.dart';
import 'package:provider/provider.dart';
import 'package:liveshop/providers/live_event_provider.dart';
import 'package:liveshop/providers/cart_provider.dart';
import 'package:liveshop/providers/user_provider.dart';
import 'package:liveshop/services/api_service.dart';
import 'package:liveshop/services/socket_service.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancier les services
    // Idéalement, utilisez GetIt ou similaire pour l'injection de dépendances,
    // mais ici on suit strictement la structure requise avec Provider.
    // Assurez-vous que ce sont des singletons ou qu'ils sont scopés correctement.
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
