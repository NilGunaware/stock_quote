import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/stock.dart';
import '../services/stock_api_service.dart';
import '../services/storage_service.dart';

class StockViewModel extends ChangeNotifier {
  final StockApiService _apiService;
  final StorageService _storageService;
  
  List<Stock> searchResults = [];
  List<Stock> watchlistStocks = [];
  Map<String, List<Stock>> sectorStocks = {};
  bool isLoading = false;
  String error = '';
  Timer? _refreshTimer;

  StockViewModel(this._apiService, this._storageService) {
    loadWatchlist();
    startAutoRefresh();
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      refreshWatchlist();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> searchStocks(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      error = '';
      notifyListeners();

      searchResults = await _apiService.searchStocks(query);
      
      for (var stock in searchResults) {
        await _storageService.cacheStockData(stock);
      }
    } catch (e) {
      error = 'Failed to search stocks: $e';
      searchResults = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWatchlist() async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      final symbols = await _storageService.getWatchlist();
      watchlistStocks = [];

      for (String symbol in symbols) {
        try {
          final cachedStock = await _storageService.getCachedStockData(symbol);
          if (cachedStock != null) {
            watchlistStocks.add(cachedStock);
          }
          
          final stock = await _apiService.getStockQuote(symbol);
          watchlistStocks.removeWhere((s) => s.symbol == symbol);
          watchlistStocks.add(stock);
          await _storageService.cacheStockData(stock);
        } catch (e) {
          print('Error loading stock $symbol: $e');
        }
      }
    } catch (e) {
      error = 'Failed to load watchlist: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWatchlist(String symbol) async {
    await _storageService.addToWatchlist(symbol);
    await loadWatchlist();
  }

  Future<void> removeFromWatchlist(String symbol) async {
    await _storageService.removeFromWatchlist(symbol);
    await loadWatchlist();
  }

  Future<void> refreshWatchlist() async {
    await loadWatchlist();
  }

  Future<void> loadSectorStocks(String sector) async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      final stocks = await _apiService.getStocksByIndustry(sector);
      sectorStocks[sector] = stocks;

      for (var stock in stocks) {
        await _storageService.cacheStockData(stock);
      }
    } catch (e) {
      error = 'Failed to load sector stocks: $e';
      sectorStocks[sector] = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
} 