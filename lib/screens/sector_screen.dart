import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock.dart';
import '../viewmodels/stock_view_model.dart';
import '../widgets/stock_list_item.dart';

class SectorScreen extends StatefulWidget {
  const SectorScreen({Key? key}) : super(key: key);

  @override
  State<SectorScreen> createState() => _SectorScreenState();
}

class _SectorScreenState extends State<SectorScreen> {
  final List<String> sectors = const [
    'Technology',
    'Healthcare',
    'Financial Services',
    'Consumer Cyclical',
    'Industrials',
    'Energy',
    'Materials',
    'Consumer Defensive',
    'Real Estate',
    'Utilities',
    'Communication Services',
  ];

  Map<String, bool> _loadedSectors = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sectors'),
      ),
      body: Consumer<StockViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            itemCount: sectors.length,
            itemBuilder: (context, index) {
              final sector = sectors[index];
              return ExpansionTile(
                title: Text(sector),
                leading: const Icon(Icons.business),
                onExpansionChanged: (expanded) {
                  if (expanded && !_loadedSectors[sector]!) {
                    setState(() {
                      _loadedSectors[sector] = true;
                    });
                    viewModel.loadSectorStocks(sector);
                  }
                },
                children: [
                  if (_loadedSectors[sector] == true)
                    if (viewModel.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (viewModel.error != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error: ${viewModel.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (viewModel.sectorStocks[sector]?.isEmpty ?? true)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No stocks found in this sector'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.sectorStocks[sector]?.length ?? 0,
                        itemBuilder: (context, index) {
                          final stock = viewModel.sectorStocks[sector]![index];
                          return StockListItem(
                            stock: stock,
                            isInWatchlist: viewModel.watchlist.any(
                              (s) => s.symbol == stock.symbol,
                            ),
                            onWatchlistToggle: () {
                              final isInWatchlist = viewModel.watchlist.any(
                                (s) => s.symbol == stock.symbol,
                              );
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
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadedSectors = {for (var sector in sectors) sector: false};
  }
} 