import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_view_model.dart';
import '../widgets/stock_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, StockViewModel viewModel) {
    if (query.isEmpty) {
      setState(() => _isSearching = false);
      return;
    }
    setState(() => _isSearching = true);
    viewModel.searchStocks(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Stocks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<StockViewModel>(
              builder: (context, viewModel, child) => SearchBar(
                controller: _searchController,
                hintText: 'Search by symbol or company name',
                leading: const Icon(Icons.search),
                onChanged: (query) => _onSearchChanged(query, viewModel),
              ),
            ),
          ),
          Expanded(
            child: Consumer<StockViewModel>(
              builder: (context, viewModel, child) {
                if (!_isSearching) {
                  return const Center(
                    child: Text('Enter a symbol or company name to search'),
                  );
                }

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

                if (viewModel.searchResults.isEmpty) {
                  return const Center(
                    child: Text('No results found'),
                  );
                }

                return ListView.builder(
                  itemCount: viewModel.searchResults.length,
                  itemBuilder: (context, index) {
                    final stock = viewModel.searchResults[index];
                    return StockListItem(
                      stock: stock,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/stock-detail',
                        arguments: stock,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 