import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_view_model.dart';
import '../widgets/stock_list_item.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: Consumer<StockViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Text(
                'Error: ${viewModel.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (viewModel.watchlist.isEmpty) {
            return const Center(
              child: Text('No stocks in watchlist'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshWatchlist(),
            child: ListView.builder(
              itemCount: viewModel.watchlist.length,
              itemBuilder: (context, index) {
                final stock = viewModel.watchlist[index];
                return Dismissible(
                  key: Key(stock.symbol),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
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
                  },
                  child: StockListItem(
                    stock: stock,
                    isInWatchlist: true,
                    onWatchlistToggle: () {
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
                    },
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/stock_detail',
                      arguments: stock,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 