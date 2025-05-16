import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_view_model.dart';
import '../viewmodels/header_view_model.dart';
import '../widgets/stock_list_item.dart';
import '../widgets/stock_shimmer.dart';
import '../widgets/header_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupScrollController();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final viewModel = Provider.of<StockViewModel>(context, listen: false);
        if (!viewModel.isLoadingMore && viewModel.hasMoreResults) {
          viewModel.loadMoreResults();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _onSearchChanged(String query, StockViewModel viewModel) {
    viewModel.searchStocks(query);
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const HeaderWidget(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<StockViewModel>(
              builder: (context, viewModel, child) => TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search stocks',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (query) => _onSearchChanged(query, viewModel),
              ),
            ),
          ),
          Expanded(
            child: Consumer<StockViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const StockShimmer();
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${viewModel.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (viewModel.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'No stocks found',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      itemCount: viewModel.searchResults.length + (viewModel.hasMoreResults ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= viewModel.searchResults.length) {
                          return _buildLoadingIndicator();
                        }

                        final stock = viewModel.searchResults[index];
                        final isInWatchlist = viewModel.watchlist.any(
                          (s) => s.symbol == stock.symbol,
                        );
                        return StockListItem(
                          stock: stock,
                          isInWatchlist: isInWatchlist,
                          onWatchlistToggle: () {
                            if (isInWatchlist) {
                              viewModel.removeFromWatchlist(stock);
                            } else {
                              viewModel.addToWatchlist(stock);
                            }
                          },
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/stock_detail',
                            arguments: stock,
                          ),
                        );
                      },
                    ),
                    if (viewModel.isLoadingMore)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 200,
                          color: Colors.black.withOpacity(0.7),
                          child: const StockShimmer(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 