import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/stock.dart';

class StockApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://cloud.iexapis.com/stable';
  late final String _apiKey;
  bool _isDemo = false;

  StockApiService() {
    _apiKey = dotenv.env['IEX_CLOUD_API_KEY'] ?? '';
    _isDemo = _apiKey.isEmpty;
  }

  Future<Stock> getStockQuote(String symbol) async {
    if (_isDemo) {
      return _getDemoStock(symbol);
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/stock/$symbol/quote',
        queryParameters: {'token': _apiKey},
      );

      if (response.statusCode == 200) {
        return Stock.fromJson(response.data);
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      throw Exception('Error fetching stock data: $e');
    }
  }

  Future<List<Stock>> getStocksByIndustry(String sector) async {
    if (_isDemo) {
      return _getDemoStocksList(sector);
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/stock/market/collection/sector',
        queryParameters: {
          'token': _apiKey,
          'collectionName': sector,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> stocksJson = response.data;
        return stocksJson.map((json) => Stock.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sector data');
      }
    } catch (e) {
      throw Exception('Error fetching sector data: $e');
    }
  }

  Future<List<Stock>> searchStocks(String query) async {
    if (_isDemo) {
      return _getDemoSearchResults(query);
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'token': _apiKey,
          'q': query,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> results = response.data;
        List<Stock> stocks = [];
        
        for (var result in results) {
          final stockResponse = await getStockQuote(result['symbol']);
          stocks.add(stockResponse);
        }
        
        return stocks;
      } else {
        throw Exception('Failed to search stocks');
      }
    } catch (e) {
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