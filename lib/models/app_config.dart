class AppConfig {
  final String name;
  final String rfc;
  final String address;
  final String phone;
  final String email;
  final String currency;
  final double taxRate;
  final bool taxIncluded;
  final double tasaCambio;
  final bool autoPrint;

  const AppConfig({
    this.name = 'A2K DIGITAL STUDIO',
    this.rfc = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.currency = '\$',
    this.taxRate = 16,
    this.taxIncluded = false,
    this.tasaCambio = 50.00,
    this.autoPrint = false,
  });

  AppConfig copyWith({
    String? name,
    String? rfc,
    String? address,
    String? phone,
    String? email,
    String? currency,
    double? taxRate,
    bool? taxIncluded,
    double? tasaCambio,
    bool? autoPrint,
  }) {
    return AppConfig(
      name: name ?? this.name,
      rfc: rfc ?? this.rfc,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      taxIncluded: taxIncluded ?? this.taxIncluded,
      tasaCambio: tasaCambio ?? this.tasaCambio,
      autoPrint: autoPrint ?? this.autoPrint,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'rfc': rfc,
        'address': address,
        'phone': phone,
        'email': email,
        'currency': currency,
        'taxRate': taxRate,
        'taxIncluded': taxIncluded,
        'tasaCambio': tasaCambio,
        'autoPrint': autoPrint,
      };

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        name: json['name'] ?? 'A2K DIGITAL STUDIO',
        rfc: json['rfc'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        currency: json['currency'] ?? '\$',
        taxRate: (json['taxRate'] as num?)?.toDouble() ?? 16,
        taxIncluded: json['taxIncluded'] ?? false,
        tasaCambio: (json['tasaCambio'] as num?)?.toDouble() ?? 50.00,
        autoPrint: json['autoPrint'] ?? false,
      );
}
