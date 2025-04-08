class CountryUtils {
  static String getFlagEmoji(String countryName) {
    // Convert country name to country code
    final countryCode = _getCountryCode(countryName);
    if (countryCode == null) return '🏁'; // Default flag if country not found

    // Convert country code to flag emoji
    final firstChar = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondChar = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  static String? _getCountryCode(String countryName) {
    // Map of country names to ISO 3166-1 alpha-2 country codes
    final countryCodes = {
      'Australia': 'AU',
      'Austria': 'AT',
      'Azerbaijan': 'AZ',
      'Bahrain': 'BH',
      'Belgium': 'BE',
      'Brazil': 'BR',
      'Canada': 'CA',
      'China': 'CN',
      'Denmark': 'DK',
      'Finland': 'FI',
      'France': 'FR',
      'Germany': 'DE',
      'Hungary': 'HU',
      'India': 'IN',
      'Italy': 'IT',
      'Japan': 'JP',
      'Mexico': 'MX',
      'Monaco': 'MC',
      'Netherlands': 'NL',
      'Qatar': 'QA',
      'Russia': 'RU',
      'Saudi Arabia': 'SA',
      'Singapore': 'SG',
      'Spain': 'ES',
      'Sweden': 'SE',
      'Switzerland': 'CH',
      'Turkey': 'TR',
      'United Arab Emirates': 'AE',
      'UAE': 'AE',
      'United Kingdom': 'GB', 
      'UK': 'GB',
      'United States': 'US',
      'USA': 'US',
    };

    return countryCodes[countryName];
  }
} 