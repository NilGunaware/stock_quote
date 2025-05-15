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

  Map<String, Future<List<Stock>>?> _sectorFutures = {};

  void _loadSectorStocks(String sector, StockViewModel viewModel) {
    setState(() {
      _sectorFutures[sector] = viewModel.getStocksByIndustry(sector);
    });
  }

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
                  if (expanded && _sectorFutures[sector] == null) {
                    _loadSectorStocks(sector, viewModel);
                  }
                },
                children: [
                  if (_sectorFutures[sector] != null)
                    FutureBuilder<List<Stock>>(
                      future: _sectorFutures[sector],
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final stocks = snapshot.data ?? [];
                        if (stocks.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No stocks found in this sector'),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stocks.length,
                          itemBuilder: (context, index) {
                            final stock = stocks[index];
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
                ],
              );
            },
          );
        },
      ),
    );
  }
} 