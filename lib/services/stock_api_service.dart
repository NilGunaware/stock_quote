import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/stock.dart';
import 'package:flutter/foundation.dart';

class StockApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://www.alphavantage.co/query';
  final String _apiKey = 'demo'; // Using the demo API key
  bool _isDemo = true;

  StockApiService() {
    debugPrint('StockApiService initialized with demo API key');
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
        final data = response.data;
        if (data.containsKey('Time Series (5min)') && data.containsKey('Meta Data')) {
          // Get the most recent quote from Time Series
          final timeSeries = data['Time Series (5min)'] as Map<String, dynamic>;
          final latestTime = timeSeries.keys.first;
          final quote = timeSeries[latestTime];

          // Get metadata
          final metaData = data['Meta Data'];
          final stockSymbol = metaData['2. Symbol'] ?? symbol;

          // Parse price data
          final currentPrice = double.parse(quote['4. close']);
          final openPrice = double.parse(quote['1. open']);
          final highPrice = double.parse(quote['2. high']);
          final lowPrice = double.parse(quote['3. low']);
          final volume = int.parse(quote['5. volume']);

          // Calculate price change
          final priceChange = currentPrice - openPrice;
          final priceChangePercentage = (priceChange / openPrice) * 100;

          return Stock(
            symbol: stockSymbol,
            companyName: '$stockSymbol Stock',
            currentPrice: currentPrice,
            priceChange: priceChange,
            priceChangePercentage: priceChangePercentage,
            marketCap: 0, // Not available in this endpoint
            peRatio: 0, // Not available in this endpoint
            sector: 'Technology', // Not available in this endpoint
            industry: 'Technology', // Not available in this endpoint
            highPrice: highPrice,
            lowPrice: lowPrice,
            openPrice: openPrice,
            volume: volume,
            lastUpdated: DateTime.parse(latestTime),
          );
        }
        debugPrint('Invalid response format: missing required data');
        return _getDemoStock(symbol);
      }
      debugPrint('Failed to load stock data: status code ${response.statusCode}');
      return _getDemoStock(symbol);
    } catch (e) {
      debugPrint('Error fetching stock data: $e');
      return _getDemoStock(symbol);
    }
  }

  Future<List<Stock>> getStocksByIndustry(String sector) async {
    // Alpha Vantage doesn't have a direct endpoint for sector-based queries
    // Returning demo data instead
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

  // Demo data methods
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