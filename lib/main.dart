import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/stock_detail_screen.dart';
import 'services/stock_api_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/stock_view_model.dart';
import 'models/stock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to load .env file, but continue if it doesn't exist
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found. Using default configuration.');
  }
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StockApiService>(
          create: (_) => StockApiService(),
          lazy: false,
        ),
        Provider<StorageService>(
          create: (_) => StorageService(prefs),
          lazy: false,
        ),
        ChangeNotifierProxyProvider2<StockApiService, StorageService, StockViewModel>(
          create: (context) => StockViewModel(
            Provider.of<StockApiService>(context, listen: false),
            Provider.of<StorageService>(context, listen: false),
          ),
          update: (context, stockService, storageService, previous) =>
            previous ?? StockViewModel(stockService, storageService),
        ),
      ],
      child: MaterialApp(
        title: 'Stock Quote App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const MainScreen(),
        routes: {
          '/stock-detail': (context) => StockDetailScreen(
            stock: ModalRoute.of(context)!.settings.arguments as Stock,
          ),
        },
      ),
    );
  }
}
