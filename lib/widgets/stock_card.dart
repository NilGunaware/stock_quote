import 'package:flutter/material.dart';
import '../models/stock.dart';
import 'package:intl/intl.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final bool isInWatchlist;
  final VoidCallback? onWatchlistToggle;

  const StockCard({
    Key? key,
    required this.stock,
    this.isInWatchlist = false,
    this.onWatchlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          // Navigate to detail view
          Navigator.pushNamed(context, '/stock_detail', arguments: stock);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.symbol,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stock.companyName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (onWatchlistToggle != null)
                    IconButton(
                      icon: Icon(
                        isInWatchlist ? Icons.star : Icons.star_border,
                        color: isInWatchlist ? Colors.amber : Colors.grey,
                      ),
                      onPressed: onWatchlistToggle,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormat.format(stock.currentPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        stock.priceChange >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: stock.priceChange >= 0
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currencyFormat.format(stock.priceChange)} (${percentFormat.format(stock.priceChangePercentage / 100)})',
                        style: TextStyle(
                          color: stock.priceChange >= 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (stock.sector.isNotEmpty || stock.industry.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${stock.sector} • ${stock.industry}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 