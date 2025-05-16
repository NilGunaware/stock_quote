import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/stock.dart';
import '../repositories/stock_repository.dart';

class StockViewModel extends ChangeNotifier {
  final StockRepository _repository;
  
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
  ];

  StockViewModel(this._repository) {
    _loadWatchlist();
    startAutoRefresh();
    loadAllStocks();
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

      // Start a timer for minimum loading time
      final minimumLoadingTimer = Future.delayed(const Duration(seconds: 2));

      List<Stock> allStocks = [];
      for (String symbol in _defaultSymbols) {
        try {
          final stock = await _repository.getStockQuote(symbol);
          allStocks.add(stock);
        } catch (e) {
          debugPrint('Error loading stock $symbol: $e');
        }
      }

      // Wait for both the data loading and minimum timer
      await Future.wait([
        Future.value(allStocks),
        minimumLoadingTimer,
      ]);

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
      loadAllStocks();
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

      // Start a timer for minimum loading time
      final minimumLoadingTimer = Future.delayed(const Duration(seconds: 2));

      final stocksFuture = _repository.searchStocks(query);

      // Wait for both the API call and minimum timer
      final results = await Future.wait([
        stocksFuture,
        minimumLoadingTimer,
      ]);

      _allSearchResults = results[0] as List<Stock>;
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

      await Future.delayed(const Duration(milliseconds: 500));
      
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
      final symbols = await _repository.getWatchlist();
      _watchlist = [];
      
      for (var symbol in symbols) {
        try {
          final stock = await _repository.getStockQuote(symbol);
          _watchlist.add(stock);
        } catch (e) {
          debugPrint('Error loading watchlist stock $symbol: $e');
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load watchlist: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshWatchlist() async {
    final currentSymbols = _watchlist.map((s) => s.symbol).toList();
    for (var symbol in currentSymbols) {
      try {
        final updatedStock = await _repository.getStockQuote(symbol);
        final index = _watchlist.indexWhere((s) => s.symbol == symbol);
        if (index != -1) {
          _watchlist[index] = updatedStock;
        }
      } catch (e) {
        debugPrint('Error refreshing stock $symbol: $e');
      }
    }
    notifyListeners();
  }

  Future<void> addToWatchlist(Stock stock) async {
    try {
      await _repository.addToWatchlist(stock);
      if (!_watchlist.any((s) => s.symbol == stock.symbol)) {
        _watchlist.add(stock);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to add to watchlist: $e');
    }
  }

  Future<void> removeFromWatchlist(Stock stock) async {
    try {
      await _repository.removeFromWatchlist(stock.symbol);
      _watchlist.removeWhere((s) => s.symbol == stock.symbol);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove from watchlist: $e');
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

      final stocks = await _repository.getStocksByIndustry(sector);
      sectorStocks[sector] = stocks;
    } catch (e) {
      _error = 'Failed to load sector stocks: $e';
      sectorStocks[sector] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 