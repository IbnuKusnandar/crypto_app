import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/format_helper.dart';
import '../models/crypto_model.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';

class DetailScreen extends StatefulWidget {
  final Crypto crypto;
  const DetailScreen({super.key, required this.crypto});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<List<double>> _priceChart;
  late Future<List<Map<String, dynamic>>> _exchangeData;
  int _currentPage = 1;
  int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _priceChart = ApiService().fetchPriceChart(widget.crypto.id);
    _exchangeData = ApiService().fetchExchangeData(widget.crypto.id);
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust items per page based on screen width
    _itemsPerPage = screenWidth < 600 ? 5 : 7;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.crypto.name),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: theme.appBarTheme.iconTheme?.color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 24 : 16,
              vertical: 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(theme, isDarkMode),
                  const SizedBox(height: 24),
                  _buildPriceChartSection(theme, isDarkMode),
                  const SizedBox(height: 24),
                  _buildMarketDataSection(theme),
                  const SizedBox(height: 24),
                  _buildExchangeListSection(theme, constraints.maxWidth),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Image.network(
                      widget.crypto.image,
                      height: 40,
                      width: 40,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.currency_bitcoin, size: 40),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.crypto.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Text(
                  '\$${widget.crypto.currentPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Cap',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${FormatHelper.formatCurrency(widget.crypto.marketCap)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '24h Change',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.crypto.priceChange24h >= 0 ? '+' : ''}${widget.crypto.priceChange24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.crypto.priceChange24h >= 0
                            ? isDarkMode
                            ? AppColors.darkPositive
                            : AppColors.lightPositive
                            : isDarkMode
                            ? AppColors.darkNegative
                            : AppColors.lightNegative,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChartSection(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Chart (7 Days)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 200,
            child: FutureBuilder<List<double>>(
              future: _priceChart,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.primaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load chart',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                      ),
                    ),
                  );
                } else {
                  final prices = snapshot.data!;
                  return LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: prices.length.toDouble() - 1,
                      minY: prices.reduce((a, b) => a < b ? a : b) * 0.99,
                      maxY: prices.reduce((a, b) => a > b ? a : b) * 1.01,
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[800]!
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (prices.reduce((a, b) => a > b ? a : b) -
                            prices.reduce((a, b) => a < b ? a : b)) /
                            4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDarkMode
                                ? Colors.grey[800]!
                                : Colors.grey[100]!,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: prices.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: theme.primaryColor,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.primaryColor.withOpacity(0.1),
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketDataSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          children: [
            _buildMarketDataItem(
              context,
              'Market Cap',
              '\$${FormatHelper.formatCurrency(widget.crypto.marketCap)}',
            ),
            _buildMarketDataItem(
              context,
              '24h Volume',
              '\$${FormatHelper.formatCurrency(widget.crypto.totalVolume)}',
            ),
            _buildMarketDataItem(
              context,
              '24h High',
              '\$${widget.crypto.high24h.toStringAsFixed(2)}',
            ),
            _buildMarketDataItem(
              context,
              '24h Low',
              '\$${widget.crypto.low24h.toStringAsFixed(2)}',
            ),
            _buildMarketDataItem(
              context,
              'Circulating Supply',
              '${widget.crypto.circulatingSupply.toStringAsFixed(0)} ${widget.crypto.symbol.toUpperCase()}',
            ),
            _buildMarketDataItem(
              context,
              'Liquidity',
              '${(widget.crypto.totalVolume / widget.crypto.marketCap * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExchangeListSection(ThemeData theme, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Exchanges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _exchangeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                'Failed to load exchanges',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(
                'No exchange data available',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              );
            } else {
              final exchanges = snapshot.data!;
              final startIndex = (_currentPage - 1) * _itemsPerPage;
              final endIndex = startIndex + _itemsPerPage;
              final paginatedExchanges = exchanges.sublist(
                startIndex,
                endIndex > exchanges.length ? exchanges.length : endIndex,
              );

              return Column(
                children: [
                  ...paginatedExchanges.map((exchange) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${exchanges.indexOf(exchange) + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        exchange['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (exchange['trustScore'] != 'none')
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: exchange['trustScore'] == 'green'
                                              ? Colors.green.withOpacity(0.2)
                                              : exchange['trustScore'] == 'yellow'
                                              ? Colors.orange.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          exchange['trustScore'],
                                          style: TextStyle(
                                            color: exchange['trustScore'] == 'green'
                                                ? Colors.green
                                                : exchange['trustScore'] == 'yellow'
                                                ? Colors.orange
                                                : Colors.red,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      exchange['pair'],
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\$${FormatHelper.formatCurrency(exchange['volume'])}',
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            color: AppColors.lightPositive,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  _buildPaginationControls(theme, exchanges.length),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaginationControls(ThemeData theme, int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1
              ? () => _changePage(_currentPage - 1)
              : null,
        ),
        if (isWideScreen)
          ...List.generate(totalPages, (index) {
            final page = index + 1;
            return TextButton(
              onPressed: () => _changePage(page),
              child: Text(
                '$page',
                style: TextStyle(
                  color: _currentPage == page
                      ? theme.primaryColor
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            );
          })
        else
          Text(
            'Page $_currentPage of $totalPages',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () => _changePage(_currentPage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildMarketDataItem(BuildContext context, String title, String value) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}