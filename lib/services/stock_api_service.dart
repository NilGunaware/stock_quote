 import 'package:dio/dio.dart';
 import '../models/stock.dart';
import 'package:flutter/foundation.dart';

class StockApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://www.alphavantage.co/query';
  final String _apiKey = 'demo';
  bool _isDemo = true;

  StockApiService() {
    debugPrint('StockApiService initialized with demo API key');
    _setupDio();
  }

  void _setupDio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, handler) {
        debugPrint('API Error: ${error.message}');
        return handler.next(error);
      },
      onResponse: (Response response, handler) {
        if (response.data == null) {
          debugPrint('Empty response received');
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              error: 'Empty response received',
            ),
          );
        }
        return handler.next(response);
      },
    ));
  }

  Future<Stock> getStockQuote(String symbol) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'function': 'TIME_SERIES_INTRADAY',
          'symbol': symbol,
          'interval': '5min',
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        print("Nil testing");
        final data = response.data;
        print("Nil testing and ${data}");
         if (data is Map<String, dynamic> && data.containsKey('Error Message')) {
          print('API Error: ${data['Error Message']}');
          return _getDemoStock(symbol);
        }

         if (data is Map<String, dynamic> && data.containsKey('Note')) {
          debugPrint('API Rate Limit: ${data['Note']}');
          return _getDemoStock(symbol);
        }

        if (data is Map<String, dynamic> && 
            data.containsKey('Time Series (5min)') && 
            data.containsKey('Meta Data')) {
          try {
             final timeSeries = data['Time Series (5min)'] as Map<String, dynamic>;
            if (timeSeries.isEmpty) {
              debugPrint('Empty time series data for symbol: $symbol');
              return _getDemoStock(symbol);
            }

            final latestTime = timeSeries.keys.first;
            final quote = timeSeries[latestTime];

             final metaData = data['Meta Data'];
            final stockSymbol = metaData['2. Symbol'] ?? symbol;

             final currentPrice = double.tryParse(quote['4. close'] ?? '') ?? 0.0;
            final openPrice = double.tryParse(quote['1. open'] ?? '') ?? 0.0;
            final highPrice = double.tryParse(quote['2. high'] ?? '') ?? 0.0;
            final lowPrice = double.tryParse(quote['3. low'] ?? '') ?? 0.0;
            final volume = int.tryParse(quote['5. volume'] ?? '') ?? 0;

             final priceChange = currentPrice - openPrice;
            final priceChangePercentage = openPrice != 0 ? (priceChange / openPrice) * 100 : 0.0;

            return Stock(
              symbol: stockSymbol,
              companyName: '$stockSymbol Stock',
              currentPrice: currentPrice,
              priceChange: priceChange,
              priceChangePercentage: priceChangePercentage,
              marketCap: 0,
              peRatio: 0,
              sector: _getSectorForSymbol(stockSymbol),
              industry: _getIndustryForSymbol(stockSymbol),
              highPrice: highPrice,
              lowPrice: lowPrice,
              openPrice: openPrice,
              volume: volume,
              lastUpdated: DateTime.tryParse(latestTime) ?? DateTime.now(),
            );
          } catch (e) {
            debugPrint('Error parsing stock data for $symbol: $e');
            return _getDemoStock(symbol);
          }
        }
        debugPrint('Invalid response format for $symbol: missing required data');
        return _getDemoStock(symbol);
      }
      debugPrint('Failed to load stock data: status code ${response.statusCode}');
      return _getDemoStock(symbol);
    } catch (e) {
      debugPrint('Error fetching stock data for $symbol: $e');
      return _getDemoStock(symbol);
    }
  }

  Future<List<Stock>> getStocksByIndustry(String sector) async {
     return _getDemoStocksList(sector);
  }

  Future<List<Stock>> searchStocks(String query) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'function': 'SYMBOL_SEARCH',
          'keywords': query,
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data.containsKey('bestMatches')) {
        List<dynamic> results = response.data['bestMatches'];
        List<Stock> stocks = [];
        
        for (var result in results.take(5)) { // Limit to 5 results to avoid API rate limits
          try {
            final stockResponse = await getStockQuote(result['1. symbol']);
            stocks.add(stockResponse);
          } catch (e) {
            debugPrint('Error fetching details for ${result['1. symbol']}: $e');
          }
        }
        
        return stocks;
      } else {
        throw Exception('Failed to search stocks');
      }
    } catch (e) {
      if (_isDemo) {
        return _getDemoSearchResults(query);
      }
      throw Exception('Error searching stocks: $e');
    }
  }
//demo data
   Stock _getDemoStock(String symbol) {
    final demoData = {
      'AAPL': ('Apple Inc.', 180.5, 2.5),
      'GOOGL': ('Alphabet Inc.', 140.2, -1.2),
      'MSFT': ('Microsoft Corporation', 375.8, 3.2),
      'AMZN': ('Amazon.com Inc.', 145.2, 1.8),
      'META': ('Meta Platforms Inc.', 335.0, 4.5),
      'TSLA': ('Tesla Inc.', 240.5, -2.1),
      'NVDA': ('NVIDIA Corporation', 480.3, 5.2),
      'JPM': ('JPMorgan Chase & Co.', 170.4, 1.1),
      'BAC': ('Bank of America Corp.', 33.2, -0.5),
      'WMT': ('Walmart Inc.', 160.8, 0.8),
    };

    final defaultData = (symbol, 100.0, 2.5);
    final (companyName, price, change) = demoData[symbol] ?? defaultData;
    final changePercent = (change / price) * 100;

    return Stock(
      symbol: symbol,
      companyName: companyName,
      currentPrice: price,
      priceChange: change,
      priceChangePercentage: changePercent,
      marketCap: price * 1000000000,
      peRatio: 15.5,
      sector: _getSectorForSymbol(symbol),
      industry: _getIndustryForSymbol(symbol),
      highPrice: price * 1.02,
      lowPrice: price * 0.98,
      openPrice: price - (change / 2),
      volume: 1000000,
      lastUpdated: DateTime.now(),
    );
  }

  String _getSectorForSymbol(String symbol) {
    final sectorMap = {
      'AAPL': 'Technology',
      'GOOGL': 'Technology',
      'MSFT': 'Technology',
      'AMZN': 'Consumer Cyclical',
      'META': 'Technology',
      'TSLA': 'Consumer Cyclical',
      'NVDA': 'Technology',
      'JPM': 'Financial Services',
      'BAC': 'Financial Services',
      'WMT': 'Consumer Defensive',
    };
    return sectorMap[symbol] ?? 'Technology';
  }

  String _getIndustryForSymbol(String symbol) {
    final industryMap = {
      'AAPL': 'Consumer Electronics',
      'GOOGL': 'Internet Content & Information',
      'MSFT': 'Software - Infrastructure',
      'AMZN': 'Internet Retail',
      'META': 'Internet Content & Information',
      'TSLA': 'Auto Manufacturers',
      'NVDA': 'Semiconductors',
      'JPM': 'Banks - Diversified',
      'BAC': 'Banks - Diversified',
      'WMT': 'Discount Stores',
    };
    return industryMap[symbol] ?? 'Software';
  }

  List<Stock> _getDemoStocksList(String sector) {
    final allStocks = [
      'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'META',
      'TSLA', 'NVDA', 'JPM', 'BAC', 'WMT',
    ].map(_getDemoStock).toList();

    return allStocks.where((stock) => stock.sector == sector).toList();
  }

  List<Stock> _getDemoSearchResults(String query) {
    final allStocks = [
      'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'META',
      'TSLA', 'NVDA', 'JPM', 'BAC', 'WMT',
    ];

    query = query.toUpperCase();
    final matchingStocks = allStocks
        .where((symbol) => symbol.contains(query) || 
            _getDemoStock(symbol).companyName.toUpperCase().contains(query))
        .map(_getDemoStock)
        .toList();

    return matchingStocks.isEmpty ? [_getDemoStock(query)] : matchingStocks;
  }
} 