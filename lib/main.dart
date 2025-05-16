import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/stock_detail_screen.dart';
import 'services/stock_api_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/stock_view_model.dart';
import 'models/stock.dart';
import 'theme/app_theme.dart';
import 'viewmodels/header_view_model.dart';
import 'services/date_service.dart';
import 'repositories/stock_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
    final storageService = await StorageService.initialize();
  final stockApiService = StockApiService();
  final dateService = DateService();

   final stockRepository = StockRepository(stockApiService, storageService);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => storageService),
        Provider<StockApiService>(create: (_) => stockApiService),
        Provider<DateService>(create: (_) => dateService),
        
         Provider<StockRepository>(create: (_) => stockRepository),
        
         ChangeNotifierProvider(
          create: (context) => StockViewModel(
            context.read<StockRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HeaderViewModel(dateService),
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
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
      routes: {
        '/stock_detail': (context) => StockDetailScreen(
          stock: ModalRoute.of(context)!.settings.arguments as Stock,
        ),
      },
    );
  }
}
