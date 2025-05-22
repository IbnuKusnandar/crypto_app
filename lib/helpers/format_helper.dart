class FormatHelper {
  static String formatCurrency(double value) {
    if (value > 1e12) return '\$${(value/1e12).toStringAsFixed(2)}T';
    if (value > 1e9) return '\$${(value/1e9).toStringAsFixed(2)}B';
    if (value > 1e6) return '\$${(value/1e6).toStringAsFixed(2)}M';
    return '\$${value.toStringAsFixed(2)}';
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(2)}%';
  }
}