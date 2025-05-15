import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stock_quote/services/stock_api_service.dart';
import 'package:stock_quote/services/storage_service.dart';
import 'package:stock_quote/viewmodels/stock_view_model.dart';
import 'package:stock_quote/models/stock.dart';

import 'stock_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<StockApiService>(),
  MockSpec<StorageService>(),
])
void main() {
  late MockStockApiService mockApiService;
  late MockStorageService mockStorageService;
  late StockViewModel viewModel;
  late Stock testStock;

  setUp(() {
    mockApiService = MockStockApiService();
    mockStorageService = MockStorageService();
    
    // Setup default behavior for getWatchlist
    when(mockStorageService.getWatchlist()).thenAnswer((_) async => []);
    
    testStock = Stock(
      symbol: 'AAPL',
      companyName: 'Apple Inc',
      currentPrice: 150.0,
      priceChange: 2.5,
      priceChangePercentage: 1.67,
      marketCap: 0,
      peRatio: 0,
      sector: 'Technology',
      industry: 'Consumer Electronics',
    );

    // Setup default behavior for getStockQuote
    when(mockApiService.getStockQuote(testStock.symbol))
        .thenAnswer((_) async => testStock);

    viewModel = StockViewModel(mockApiService, mockStorageService);
  });

  group('StockViewModel Tests', () {
    test('searchStocks updates searchResults on success', () async {
      final testStocks = [testStock];

      // Setup mock behavior
      when(mockApiService.searchStocks('AAPL'))
          .thenAnswer((_) async => testStocks);

      // Execute the test
      await viewModel.searchStocks('AAPL');

      // Verify the results
      expect(viewModel.searchResults, equals(testStocks));
      expect(viewModel.error, isNull);
      expect(viewModel.isLoading, isFalse);
      verify(mockApiService.searchStocks('AAPL')).called(1);
    });

    test('searchStocks handles errors properly', () async {
      // Setup mock behavior
      when(mockApiService.searchStocks('INVALID'))
          .thenThrow(Exception('API Error'));

      // Execute the test
      await viewModel.searchStocks('INVALID');

      // Verify the results
      expect(viewModel.searchResults, isEmpty);
      expect(viewModel.error, isNotNull);
      expect(viewModel.isLoading, isFalse);
      verify(mockApiService.searchStocks('INVALID')).called(1);
    });

    test('addToWatchlist adds stock successfully', () async {
      // Setup mock behavior
      when(mockStorageService.addToWatchlist(testStock.symbol))
          .thenAnswer((_) async => true);
      when(mockStorageService.getWatchlist())
          .thenAnswer((_) async => [testStock.symbol]);

      // Execute the test
      await viewModel.addToWatchlist(testStock);

      // Wait for the watchlist to update
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the results
      expect(viewModel.watchlist.length, equals(1));
      expect(viewModel.watchlist.first.symbol, equals(testStock.symbol));
      expect(viewModel.error, isNull);
      verify(mockStorageService.addToWatchlist(testStock.symbol)).called(1);
    });

    test('removeFromWatchlist removes stock successfully', () async {
      // Setup initial state with the stock in watchlist
      when(mockStorageService.addToWatchlist(testStock.symbol))
          .thenAnswer((_) async => true);
      when(mockStorageService.getWatchlist())
          .thenAnswer((_) async => [testStock.symbol]);
      await viewModel.addToWatchlist(testStock);

      // Wait for the watchlist to update
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify initial state
      expect(viewModel.watchlist.length, equals(1));

      // Setup remove mock behavior
      when(mockStorageService.removeFromWatchlist(testStock.symbol))
          .thenAnswer((_) async => true);
      when(mockStorageService.getWatchlist())
          .thenAnswer((_) async => []);

      // Execute the test
      await viewModel.removeFromWatchlist(testStock);

      // Wait for the watchlist to update
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the results
      expect(viewModel.watchlist.isEmpty, isTrue);
      expect(viewModel.error, isNull);
      verify(mockStorageService.removeFromWatchlist(testStock.symbol)).called(1);
    });
  });
} 