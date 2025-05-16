import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../theme/app_theme.dart';

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
    final changePercentage = stock.priceChangePercentage.abs().toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: AppTheme.stockItemDecoration,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          stock.symbol,
                          style: AppTheme.symbolStyle,
                        ),
                        if (onWatchlistToggle != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onWatchlistToggle,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                isInWatchlist ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isInWatchlist ? Colors.amber : AppTheme.subtitleColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stock.companyName,
                      style: AppTheme.companyNameStyle,
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
                    '\$${stock.currentPrice.toStringAsFixed(2)}',
                    style: AppTheme.priceStyle,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: AppTheme.percentageDecoration(isPositive),
                    child: Text(
                      '${isPositive ? "+" : "-"}${changePercentage}%',
                      style: AppTheme.percentageStyle(isPositive),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 