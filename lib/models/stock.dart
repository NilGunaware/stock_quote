class Stock {
  final String symbol;
  final String companyName;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercentage;
  final double marketCap;
  final double peRatio;
  final String sector;
  final String industry;

  Stock({
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercentage,
    this.marketCap = 0.0,
    this.peRatio = 0.0,
    this.sector = '',
    this.industry = '',
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      companyName: json['companyName'] ?? '',
      currentPrice: double.tryParse(json['latestPrice']?.toString() ?? '0') ?? 0.0,
      priceChange: double.tryParse(json['change']?.toString() ?? '0') ?? 0.0,
      priceChangePercentage: double.tryParse(json['changePercent']?.toString() ?? '0') ?? 0.0,
      marketCap: double.tryParse(json['marketCap']?.toString() ?? '0') ?? 0.0,
      peRatio: double.tryParse(json['peRatio']?.toString() ?? '0') ?? 0.0,
      sector: json['sector'] ?? '',
      industry: json['industry'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'companyName': companyName,
      'currentPrice': currentPrice,
      'priceChange': priceChange,
      'priceChangePercentage': priceChangePercentage,
      'marketCap': marketCap,
      'peRatio': peRatio,
      'sector': sector,
      'industry': industry,
    };
  }
} 