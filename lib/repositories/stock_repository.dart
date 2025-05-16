import '../models/stock.dart';
import '../services/stock_api_service.dart';
import '../services/storage_service.dart';

class StockRepository {
  final StockApiService _apiService;
  final StorageService _storageService;

  StockRepository(this._apiService, this._storageService);

  Future<List<Stock>> searchStocks(String query) async {
    try {
      final stocks = await _apiService.searchStocks(query);
      // Cache the results
      for (var stock in stocks) {
        await _storageService.cacheStockData(stock);
      }
      return stocks;
    } catch (e) {
      // Try to get from cache if API fails
      final cachedStocks = await _storageService.getCachedStocks();
      return cachedStocks.where((stock) => 
        stock.symbol.toLowerCase().contains(query.toLowerCase()) ||
        stock.companyName.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  Future<Stock> getStockQuote(String symbol) async {
    try {
      final stock = await _apiService.getStockQuote(symbol);
      await _storageService.cacheStockData(stock);
      return stock;
    } catch (e) {
      final cachedStock = await _storageService.getCachedStock(symbol);
      if (cachedStock != null) {
        return cachedStock;
      }
      rethrow;
    }
  }

  Future<List<Stock>> getStocksByIndustry(String sector) async {
    try {
      final stocks = await _apiService.getStocksByIndustry(sector);
      for (var stock in stocks) {
        await _storageService.cacheStockData(stock);
      }
      return stocks;
    } catch (e) {
      final cachedStocks = await _storageService.getCachedStocks();
      return cachedStocks.where((stock) => stock.sector == sector).toList();
    }
  }

  Future<List<String>> getWatchlist() async {
    return _storageService.getWatchlist();
  }

  Future<void> addToWatchlist(Stock stock) async {
    await _storageService.addToWatchlist(stock.symbol);
    await _storageService.cacheStockData(stock);
  }

  Future<void> removeFromWatchlist(String symbol) async {
    await _storageService.removeFromWatchlist(symbol);
  }
} 