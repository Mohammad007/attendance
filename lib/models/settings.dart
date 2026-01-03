class Settings {
  final int? id;
  final String language;
  final String currency;
  final String? appPin;
  final String themeMode;

  Settings({
    this.id,
    this.language = 'English',
    this.currency = '₹',
    this.appPin,
    this.themeMode = 'light',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language': language,
      'currency': currency,
      'app_pin': appPin,
      'theme_mode': themeMode,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as int?,
      language: map['language'] as String? ?? 'English',
      currency: map['currency'] as String? ?? '₹',
      appPin: map['app_pin'] as String?,
      themeMode: map['theme_mode'] as String? ?? 'light',
    );
  }

  Settings copyWith({
    int? id,
    String? language,
    String? currency,
    String? appPin,
    String? themeMode,
  }) {
    return Settings(
      id: id ?? this.id,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      appPin: appPin ?? this.appPin,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
