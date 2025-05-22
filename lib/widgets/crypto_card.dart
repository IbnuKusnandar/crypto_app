import 'package:flutter/material.dart';
import '../models/crypto_model.dart';
import '../constants/colors.dart';
import '../screens/detail_screen.dart';
import '../helpers/format_helper.dart';

class CryptoCard extends StatelessWidget {
  final Crypto crypto;

  const CryptoCard({required this.crypto, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(crypto: crypto),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
          children: [
          Container(
          width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${crypto.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: theme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              crypto.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            FormatHelper.formatCurrency(crypto.currentPrice),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMarketDataItem(
              context,
              'Market Cap',
              FormatHelper.formatCurrency(crypto.marketCap)),
              _buildMarketDataItem(
                  context,
                  '24h Vol',
                  FormatHelper.formatCurrency(crypto.totalVolume)),
              _buildMarketDataItem(
                  context,
                  'Liquidity',
                  '${(crypto.totalVolume / crypto.marketCap * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: crypto.priceChange24h >= 0
                      ? AppColors.lightPositive.withOpacity(0.1)
                      : AppColors.lightNegative.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${crypto.priceChange24h >= 0 ? '+' : ''}${crypto.priceChange24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: crypto.priceChange24h >= 0
                        ? AppColors.lightPositive
                        : AppColors.lightNegative,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildMarketDataItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}