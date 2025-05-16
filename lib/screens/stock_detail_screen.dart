import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/stock.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_view_model.dart';

class StockDetailScreen extends StatelessWidget {
  final Stock stock;

  const StockDetailScreen({Key? key, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
    final viewModel = Provider.of<StockViewModel>(context);
    final isInWatchlist = viewModel.watchlist.any((s) => s.symbol == stock.symbol);

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.symbol),
        actions: [
          IconButton(
            icon: Icon(
              isInWatchlist ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isInWatchlist ? Colors.amber : null,
            ),
            onPressed: () {
              if (isInWatchlist) {
                viewModel.removeFromWatchlist(stock);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${stock.symbol} removed from watchlist'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => viewModel.addToWatchlist(stock),
                    ),
                  ),
                );
              } else {
                viewModel.addToWatchlist(stock);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${stock.symbol} added to watchlist'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => viewModel.removeFromWatchlist(stock),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stock.companyName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currencyFormat.format(stock.currentPrice),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    stock.priceChange >= 0
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: stock.priceChange >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  Text(
                                    currencyFormat.format(stock.priceChange),
                                    style: TextStyle(
                                      color: stock.priceChange >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                percentFormat
                                    .format(stock.priceChangePercentage / 100),
                                style: TextStyle(
                                  color: stock.priceChange >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Market Cap',
                          currencyFormat.format(stock.marketCap)),
                      _buildInfoRow('P/E Ratio', stock.peRatio.toString()),
                      _buildInfoRow('Sector', stock.sector),
                      _buildInfoRow('Industry', stock.industry),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Chart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      currencyFormat.format(value),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    final date = DateTime.now()
                                        .subtract(Duration(days: (30 - value).toInt()));
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        DateFormat('MM/dd').format(date),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getChartData(),
                                isCurved: true,
                                color: stock.priceChange >= 0
                                    ? Colors.green
                                    : Colors.red,
                                barWidth: 2,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: (stock.priceChange >= 0
                                          ? Colors.green
                                          : Colors.red)
                                      .withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartData() {
    final List<FlSpot> spots = [];
    final random = Random();
    double price = stock.currentPrice;

    for (int i = 0; i <= 30; i++) {
      spots.add(FlSpot(i.toDouble(), price));
      price += (price * (0.02 * (random.nextDouble() - 0.5)));
    }

    return spots;
  }
} 