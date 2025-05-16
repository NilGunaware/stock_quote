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

  // Pagination properties
  bool _isLoadingMore = false;
  List<Stock> _allSearchResults = [];
  static const int _pageSize = 10;
  String _lastSearchQuery = '';

  // Default stocks to show
  final List<String> _defaultSymbols = [
    'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'META',
    'TSLA', 'NVDA', 'JPM', 'BAC', 'WMT',
    'JNJ', 'PG', 'XOM', 'V', 'MA',
    'DIS', 'NFLX', 'INTC', 'AMD', 'CSCO'
  ];

  StockViewModel(this._stockApiService, this._storageService) {
    _loadWatchlist();
    startAutoRefresh();
    loadAllStocks(); // Load all stocks when initialized
  }

  // Getters
  List<Stock> get searchResults => _searchResults;
  List<Stock> get watchlist => _watchlist;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreResults => _searchResults.length < _allSearchResults.length;

  // Load all default stocks
  Future<void> loadAllStocks() async {
    try {
      _setLoading(true);
      _clearError();

      List<Stock> allStocks = [];
      for (String symbol in _defaultSymbols) {
        try {
          final stock = await _stockApiService.getStockQuote(symbol);
          allStocks.add(stock);
        } catch (e) {
          debugPrint('Error loading stock $symbol: $e');
        }
      }

      _allSearchResults = allStocks;
      _searchResults = _allSearchResults.take(_pageSize).toList();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
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

  // Search functionality
  Future<void> searchStocks(String query) async {
    if (query.isEmpty) {
      loadAllStocks(); // Reset to show all stocks
      return;
    }

    if (query != _lastSearchQuery) {
      _lastSearchQuery = query;
      _allSearchResults = [];
      _searchResults = [];
    }

    try {
      _setLoading(true);
      _clearError();
      _allSearchResults = await _stockApiService.searchStocks(query);
      _searchResults = _allSearchResults.take(_pageSize).toList();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreResults() async {
    if (!hasMoreResults || _isLoadingMore) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      final currentLength = _searchResults.length;
      final nextBatch = _allSearchResults
          .skip(currentLength)
          .take(_pageSize)
          .toList();
      
      _searchResults.addAll(nextBatch);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Watchlist functionality
  Future<void> _loadWatchlist() async {
    try {
      _setLoading(true);
      final symbols = await _storageService.getWatchlist();
      final List<Stock> newWatchlist = [];
      final List<String> failedSymbols = [];

      for (final symbol in symbols) {
        try {
          final stock = await _stockApiService.getStockQuote(symbol);
          newWatchlist.add(stock);
        } catch (e) {
          debugPrint('Error loading stock $symbol: $e');
          failedSymbols.add(symbol);
        }
      }

      _watchlist = newWatchlist;
      
      if (failedSymbols.isNotEmpty) {
        _setError('Failed to load some stocks: ${failedSymbols.join(", ")}');
      } else {
        _clearError();
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load watchlist: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshWatchlist() async {
    if (_isLoading) return; // Prevent multiple simultaneous refreshes
    await _loadWatchlist();
  }

  Future<void> addToWatchlist(Stock stock) async {
    try {
      if (_watchlist.any((s) => s.symbol == stock.symbol)) {
        return; // Stock already in watchlist
      }

      await _storageService.addToWatchlist(stock.symbol);
      _watchlist.add(stock);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add ${stock.symbol} to watchlist: ${e.toString()}');
    }
  }

  Future<void> removeFromWatchlist(Stock stock) async {
    try {
      await _storageService.removeFromWatchlist(stock.symbol);
      _watchlist.removeWhere((s) => s.symbol == stock.symbol);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove ${stock.symbol} from watchlist: ${e.toString()}');
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