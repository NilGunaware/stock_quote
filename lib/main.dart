import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/stock_detail_screen.dart';
import 'screens/passcode_screen.dart';
import 'services/stock_api_service.dart';
import 'services/storage_service.dart';
import 'services/user_service.dart';
import 'viewmodels/stock_view_model.dart';
import 'viewmodels/passcode_view_model.dart';
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
  final userService = UserService();
  final stockRepository = StockRepository(stockApiService, storageService);
  
  // Check if user has entered passcode before
  final prefs = await SharedPreferences.getInstance();
  final hasEnteredApp = prefs.getBool('has_entered_app') ?? false;

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => storageService),
        Provider<StockApiService>(create: (_) => stockApiService),
        Provider<DateService>(create: (_) => dateService),
        Provider<UserService>(create: (_) => userService),
        Provider<StockRepository>(create: (_) => stockRepository),
        ChangeNotifierProvider(
          create: (context) => StockViewModel(
            context.read<StockRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HeaderViewModel(dateService),
        ),
        ChangeNotifierProvider(
          create: (context) => PasscodeViewModel(
            context.read<UserService>(),
          ),
        ),
      ],
      child: MyApp(hasEnteredApp: hasEnteredApp),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasEnteredApp;
  
  const MyApp({
    super.key,
    required this.hasEnteredApp,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Quote',
      theme: AppTheme.darkTheme,
      initialRoute: hasEnteredApp ? '/home' : '/passcode',
      routes: {
        '/passcode': (context) => const PasscodeScreen(),
        '/home': (context) => const MainScreen(),
        '/stock_detail': (context) => StockDetailScreen(
          stock: ModalRoute.of(context)!.settings.arguments as Stock,
        ),
      },
    );
  }
}
