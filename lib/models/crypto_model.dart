class Crypto {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final double currentPrice;
  final double priceChange24h;
  final int rank;
  final double marketCap;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double circulatingSupply;
  final List<String>? exchanges;

  Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.priceChange24h,
    required this.rank,
    required this.marketCap,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.circulatingSupply,
    this.exchanges,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      image: json['image'],
      currentPrice: json['current_price']?.toDouble() ?? 0.0,
      priceChange24h: json['price_change_percentage_24h']?.toDouble() ?? 0.0,
      rank: json['market_cap_rank'] ?? 0,
      marketCap: json['market_cap']?.toDouble() ?? 0.0,
      totalVolume: json['total_volume']?.toDouble() ?? 0.0,
      high24h: json['high_24h']?.toDouble() ?? 0.0,
      low24h: json['low_24h']?.toDouble() ?? 0.0,
      circulatingSupply: json['circulating_supply']?.toDouble() ?? 0.0,
    );
  }
}