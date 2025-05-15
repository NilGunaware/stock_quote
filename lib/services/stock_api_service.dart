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
    return Stock(
      symbol: symbol,
      companyName: 'Demo Company',
      currentPrice: 100.0,
      priceChange: 2.5,
      priceChangePercentage: 2.5,
      marketCap: 1000000000,
      peRatio: 15.5,
      sector: 'Technology',
      industry: 'Software',
    );
  }

  List<Stock> _getDemoStocksList(String sector) {
    return [
      Stock(
        symbol: 'DEMO1',
        companyName: 'Demo Company 1',
        currentPrice: 100.0,
        priceChange: 2.5,
        priceChangePercentage: 2.5,
        sector: sector,
        industry: 'Industry 1',
      ),
      Stock(
        symbol: 'DEMO2',
        companyName: 'Demo Company 2',
        currentPrice: 200.0,
        priceChange: -1.5,
        priceChangePercentage: -0.75,
        sector: sector,
        industry: 'Industry 2',
      ),
    ];
  }

  List<Stock> _getDemoSearchResults(String query) {
    return [
      Stock(
        symbol: 'DEMO',
        companyName: 'Demo Company ($query)',
        currentPrice: 150.0,
        priceChange: 3.5,
        priceChangePercentage: 2.33,
        sector: 'Technology',
        industry: 'Software',
      ),
    ];
  }
} 