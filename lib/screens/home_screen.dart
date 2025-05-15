import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_view_model.dart';
import '../widgets/stock_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _sectors = [
    'Technology',
    'Healthcare',
    'Financial',
    'Consumer',
    'Industrial',
    'Energy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Quote App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Watchlist'),
            Tab(text: 'Sectors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildWatchlistTab(),
          _buildSectorsTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search stocks by symbol or name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<StockViewModel>().searchStocks('');
                },
              ),
            ),
            onChanged: (value) {
              context.read<StockViewModel>().searchStocks(value);
            },
          ),
        ),
        Expanded(
          child: Consumer<StockViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error.isNotEmpty) {
                return Center(
                  child: Text(
                    viewModel.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (viewModel.searchResults.isEmpty) {
                return const Center(
                  child: Text('No results found'),
                );
              }

              return ListView.builder(
                itemCount: viewModel.searchResults.length,
                itemBuilder: (context, index) {
                  final stock = viewModel.searchResults[index];
                  final isInWatchlist = viewModel.watchlistStocks
                      .any((s) => s.symbol == stock.symbol);

                  return StockCard(
                    stock: stock,
                    isInWatchlist: isInWatchlist,
                    onWatchlistToggle: () {
                      if (isInWatchlist) {
                        viewModel.removeFromWatchlist(stock.symbol);
                      } else {
                        viewModel.addToWatchlist(stock.symbol);
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWatchlistTab() {
    return Consumer<StockViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error.isNotEmpty) {
          return Center(
            child: Text(
              viewModel.error,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (viewModel.watchlistStocks.isEmpty) {
          return const Center(
            child: Text('No stocks in watchlist'),
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.refreshWatchlist,
          child: ListView.builder(
            itemCount: viewModel.watchlistStocks.length,
            itemBuilder: (context, index) {
              final stock = viewModel.watchlistStocks[index];
              return StockCard(
                stock: stock,
                isInWatchlist: true,
                onWatchlistToggle: () {
                  viewModel.removeFromWatchlist(stock.symbol);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectorsTab() {
    return Consumer<StockViewModel>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          itemCount: _sectors.length,
          itemBuilder: (context, index) {
            final sector = _sectors[index];
            return ExpansionTile(
              title: Text(sector),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  viewModel.loadSectorStocks(sector);
                }
              },
              children: [
                if (viewModel.sectorStocks.containsKey(sector))
                  ...viewModel.sectorStocks[sector]!.map(
                    (stock) => StockCard(
                      stock: stock,
                      isInWatchlist: viewModel.watchlistStocks
                          .any((s) => s.symbol == stock.symbol),
                      onWatchlistToggle: () {
                        if (viewModel.watchlistStocks
                            .any((s) => s.symbol == stock.symbol)) {
                          viewModel.removeFromWatchlist(stock.symbol);
                        } else {
                          viewModel.addToWatchlist(stock.symbol);
                        }
                      },
                    ),
                  ),
                if (viewModel.isLoading &&
                    !viewModel.sectorStocks.containsKey(sector))
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        );
      },
    );
  }
} 