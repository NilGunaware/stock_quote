import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock.dart';

class StorageService {
  final SharedPreferences _prefs;
  static const String _watchlistKey = 'watchlist';

  StorageService(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<List<String>> getWatchlist() async {
    return _prefs.getStringList(_watchlistKey) ?? [];
  }

  Future<void> addToWatchlist(String symbol) async {
    final watchlist = await getWatchlist();
    if (!watchlist.contains(symbol)) {
      watchlist.add(symbol);
      await _prefs.setStringList(_watchlistKey, watchlist);
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final watchlist = await getWatchlist();
    watchlist.remove(symbol);
    await _prefs.setStringList(_watchlistKey, watchlist);
  }

  Future<void> cacheStockData(Stock stock) async {
    final String key = 'stock_${stock.symbol}';
    await _prefs.setString(key, jsonEncode(stock.toJson()));
  }

  Future<Stock?> getCachedStockData(String symbol) async {
    final String key = 'stock_${symbol}';
    final String? data = _prefs.getString(key);
    if (data != null) {
      return Stock.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> clearCache() async {
    final List<String> watchlist = await getWatchlist();
    await _prefs.clear();
    await _prefs.setStringList(_watchlistKey, watchlist);
  }
} 