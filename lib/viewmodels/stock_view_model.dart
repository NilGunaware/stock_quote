import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/stock.dart';
import '../services/stock_api_service.dart';
import '../services/storage_service.dart';

class StockViewModel extends ChangeNotifier {
  final StockApiService _stockApiService;
  final StorageService _storageService;
  
  List<Stock> _searchResults = [];
  List<Stock> _watchlist = [];
  Map<String, List<Stock>> sectorStocks = {};
  String? _error;
  bool _isLoading = false;
  Timer? _refreshTimer;

  StockViewModel(this._stockApiService, this._storageService) {
    _loadWatchlist();
    startAutoRefresh();
  }

  // Getters
  List<Stock> get searchResults => _searchResults;
  List<Stock> get watchlist => _watchlist;
  String? get error => _error;
  bool get isLoading => _isLoading;

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

  // Search functionality
  Future<void> searchStocks(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      _searchResults = await _stockApiService.searchStocks(query);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Watchlist functionality
  Future<void> _loadWatchlist() async {
    try {
      _setLoading(true);
      final symbols = await _storageService.getWatchlist();
      _watchlist = [];
      for (final symbol in symbols) {
        try {
          final stock = await _stockApiService.getStockQuote(symbol);
          _watchlist.add(stock);
        } catch (e) {
          debugPrint('Error loading stock $symbol: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshWatchlist() async {
    await _loadWatchlist();
  }

  Future<void> addToWatchlist(Stock stock) async {
    try {
      await _storageService.addToWatchlist(stock.symbol);
      if (!_watchlist.any((s) => s.symbol == stock.symbol)) {
        _watchlist.add(stock);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> removeFromWatchlist(Stock stock) async {
    try {
      await _storageService.removeFromWatchlist(stock.symbol);
      _watchlist.removeWhere((s) => s.symbol == stock.symbol);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Sector functionality
  Future<List<Stock>> getStocksByIndustry(String sector) async {
    try {
      if (_error != null) {
        _error = null;
      }
      return await _stockApiService.getStocksByIndustry(sector);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadSectorStocks(String sector) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final stocks = await _stockApiService.getStocksByIndustry(sector);
      sectorStocks[sector] = stocks;

      for (var stock in stocks) {
        await _storageService.cacheStockData(stock);
      }
    } catch (e) {
      _error = 'Failed to load sector stocks: $e';
      sectorStocks[sector] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 