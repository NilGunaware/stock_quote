import 'package:flutter/material.dart';
import '../models/stock.dart';

class StockListItem extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;
  final bool isInWatchlist;
  final VoidCallback? onWatchlistToggle;

  const StockListItem({
    Key? key,
    required this.stock,
    this.onTap,
    this.isInWatchlist = false,
    this.onWatchlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.priceChange >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changePercentage = stock.priceChangePercentage.abs().toStringAsFixed(1);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stock.companyName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${stock.currentPrice.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isPositive ? "+" : "-"}${changePercentage}%',
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 