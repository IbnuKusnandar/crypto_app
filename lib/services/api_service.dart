import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_model.dart';

class ApiService {
  final String _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<Crypto>> fetchTopCryptos() async {
    final url = Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=1&sparkline=false');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Crypto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cryptos');
    }
  }

  Future<List<double>> fetchPriceChart(String id) async {
    final url = Uri.parse('$_baseUrl/coins/$id/market_chart?vs_currency=usd&days=7');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List prices = data['prices'];
      return prices.map<double>((e) => (e[1] as num).toDouble()).toList();
    } else {
      throw Exception('Failed to load price chart');
    }
  }

  Future<List<Map<String, dynamic>>> fetchExchangeData(String id) async {
    final url = Uri.parse('$_baseUrl/coins/$id/tickers?include_exchange_logo=false');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List exchanges = data['tickers'];
      return exchanges.map<Map<String, dynamic>>((e) {
        return {
          'name': e['market']['name'] as String,
          'pair': '${e['base']}/${e['target']}',
          'volume': (e['volume'] as num).toDouble(),
          'trustScore': e['trust_score'] ?? 'none',
        };
      }).toList();
    } else {
      throw Exception('Failed to load exchanges');
    }
  }
}