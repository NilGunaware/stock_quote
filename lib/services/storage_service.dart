import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock.dart';

class StorageService {
  static const String _watchlistKey = 'watchlist';
  static const String _stockCachePrefix = 'stock_cache_';
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
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
    final key = _stockCachePrefix + stock.symbol;
    final stockData = jsonEncode(stock.toJson());
    await _prefs.setString(key, stockData);
  }

  Future<Stock?> getCachedStock(String symbol) async {
    final key = _stockCachePrefix + symbol;
    final stockData = _prefs.getString(key);
    if (stockData != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(stockData);
        return Stock.fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<List<Stock>> getCachedStocks() async {
    final List<Stock> stocks = [];
    final allKeys = _prefs.getKeys();
    
    for (final key in allKeys) {
      if (key.startsWith(_stockCachePrefix)) {
        final stockData = _prefs.getString(key);
        if (stockData != null) {
          try {
            final Map<String, dynamic> json = jsonDecode(stockData);
            stocks.add(Stock.fromJson(json));
          } catch (e) {
            // Skip invalid cache entries
            continue;
          }
        }
      }
    }
    
    return stocks;
  }

  Future<void> clearCache() async {
    final allKeys = _prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_stockCachePrefix)) {
        await _prefs.remove(key);
      }
    }
  }
} 