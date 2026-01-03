class CurrencyFormatter {
  static String format(double amount, {String currency = '₹'}) {
    return '$currency${amount.toStringAsFixed(2)}';
  }

  static String formatWithoutSymbol(double amount) {
    return amount.toStringAsFixed(2);
  }

  static String formatCompact(double amount, {String currency = '₹'}) {
    if (amount >= 100000) {
      return '$currency${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$currency${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currency: currency);
  }
}
