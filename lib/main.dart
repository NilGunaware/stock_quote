import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/stock_detail_screen.dart';
import 'services/stock_api_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/stock_view_model.dart';
import 'models/stock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = await StorageService.initialize();
  final stockApiService = StockApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => storageService),
        Provider<StockApiService>(create: (_) => stockApiService),
        ChangeNotifierProvider(
          create: (context) => StockViewModel(
            context.read<StockApiService>(),
            context.read<StorageService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Quote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      routes: {
        '/stock_detail': (context) => StockDetailScreen(
          stock: ModalRoute.of(context)!.settings.arguments as Stock,
        ),
      },
    );
  }
}
