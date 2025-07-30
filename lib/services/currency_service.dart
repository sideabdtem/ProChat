class CurrencyService {
  // Exchange rates relative to USD (as base currency)
  static const Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'AED': 3.67,  // 1 USD = 3.67 AED
    'GBP': 0.79,  // 1 USD = 0.79 GBP
  };

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'AED': 'د.إ',
    'GBP': '£',
  };

  static const Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'AED': 'UAE Dirham',
    'GBP': 'British Pound',
  };

  static const Map<String, String> _currencyNamesArabic = {
    'USD': 'الدولار الأمريكي',
    'AED': 'الدرهم الإماراتي',
    'GBP': 'الجنيه الإسترليني',
  };

  /// Convert amount from one currency to another
  static double convertCurrency(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    final fromRate = _exchangeRates[fromCurrency] ?? 1.0;
    final toRate = _exchangeRates[toCurrency] ?? 1.0;
    
    // Convert to USD first, then to target currency
    final usdAmount = amount / fromRate;
    return usdAmount * toRate;
  }

  /// Get currency symbol for a given currency code
  static String getCurrencySymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? currencyCode;
  }

  /// Get currency name for a given currency code
  static String getCurrencyName(String currencyCode, {bool isArabic = false}) {
    if (isArabic) {
      return _currencyNamesArabic[currencyCode] ?? currencyCode;
    }
    return _currencyNames[currencyCode] ?? currencyCode;
  }

  /// Format price with currency symbol and proper decimal places
  static String formatPrice(double amount, String currencyCode, {bool showSymbol = true}) {
    final symbol = showSymbol ? getCurrencySymbol(currencyCode) : '';
    
    // Format based on currency
    switch (currencyCode) {
      case 'AED':
        return '${symbol}${amount.toStringAsFixed(2)}';
      case 'GBP':
        return '${symbol}${amount.toStringAsFixed(2)}';
      case 'USD':
      default:
        return '${symbol}${amount.toStringAsFixed(2)}';
    }
  }

  /// Get all available currencies
  static List<String> getAvailableCurrencies() {
    return _exchangeRates.keys.toList();
  }

  /// Check if currency is supported
  static bool isCurrencySupported(String currencyCode) {
    return _exchangeRates.containsKey(currencyCode);
  }

  /// Get default currency for a region
  static String getDefaultCurrencyForRegion(String region) {
    switch (region) {
      case 'UAE':
        return 'AED';
      case 'UK':
        return 'GBP';
      default:
        return 'USD';
    }
  }

  /// Convert and format price for display
  static String convertAndFormatPrice(
    double amount, 
    String fromCurrency, 
    String toCurrency, 
    {bool showSymbol = true}
  ) {
    final convertedAmount = convertCurrency(amount, fromCurrency, toCurrency);
    return formatPrice(convertedAmount, toCurrency, showSymbol: showSymbol);
  }
}