class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });

  final String code;
  final String symbol;
  final String name;
}

class CurrencyFormatter {
  const CurrencyFormatter._();

  static const Map<String, CurrencyInfo> supportedCurrencies = {
    'NGN': CurrencyInfo(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
    'KES': CurrencyInfo(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling'),
    'GHS': CurrencyInfo(code: 'GHS', symbol: 'GH₵', name: 'Ghanaian Cedi'),
    'USD': CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar'),
    'EUR': CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    'GBP': CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound'),
    'ZAR': CurrencyInfo(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
  };

  static String format(int amountMinor, {String currencyCode = 'NGN'}) {
    final info =
        supportedCurrencies[currencyCode.toUpperCase()] ??
        CurrencyInfo(
          code: currencyCode,
          symbol: currencyCode,
          name: currencyCode,
        );

    final major = amountMinor / 100.0;
    return '${info.symbol}${major.toStringAsFixed(2)}';
  }

  static String getSymbol(String currencyCode) {
    return supportedCurrencies[currencyCode.toUpperCase()]?.symbol ??
        currencyCode;
  }
}
