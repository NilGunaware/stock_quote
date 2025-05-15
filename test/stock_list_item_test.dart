import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/stock.dart';
import '../lib/widgets/stock_list_item.dart';

void main() {
  testWidgets('StockListItem displays stock information correctly',
      (WidgetTester tester) async {
    final stock = Stock(
      symbol: 'AAPL',
      companyName: 'Apple Inc',
      currentPrice: 150.0,
      priceChange: 2.5,
      priceChangePercentage: 1.67,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockListItem(
            stock: stock,
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify that the stock symbol is displayed
    expect(find.text('AAPL'), findsOneWidget);
    
    // Verify that the company name is displayed
    expect(find.text('Apple Inc'), findsOneWidget);
    
    // Verify that the price is displayed
    expect(find.text('\$150.00'), findsOneWidget);
    
    // Verify that the price change is displayed
    expect(find.text('\$2.50 (1.67%)'), findsOneWidget);
  });

  testWidgets('StockListItem handles tap correctly',
      (WidgetTester tester) async {
    bool tapped = false;
    
    final stock = Stock(
      symbol: 'AAPL',
      companyName: 'Apple Inc',
      currentPrice: 150.0,
      priceChange: 2.5,
      priceChangePercentage: 1.67,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockListItem(
            stock: stock,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Tap the list item
    await tester.tap(find.byType(StockListItem));
    
    // Verify that the onTap callback was called
    expect(tapped, isTrue);
  });
} 