class Proveedor {
  final int id;
  final String name;
  final String contact;
  final String phone;
  final double debt;

  const Proveedor({
    required this.id,
    required this.name,
    this.contact = '',
    this.phone = '',
    this.debt = 0,
  });

  Proveedor copyWith({
    String? name,
    String? contact,
    String? phone,
    double? debt,
  }) {
    return Proveedor(
      id: id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      phone: phone ?? this.phone,
      debt: debt ?? this.debt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'phone': phone,
        'debt': debt,
      };

  factory Proveedor.fromJson(Map<String, dynamic> json) => Proveedor(
        id: json['id'] as int,
        name: json['name'] ?? '',
        contact: json['contact'] ?? '',
        phone: json['phone'] ?? '',
        debt: (json['debt'] as num?)?.toDouble() ?? 0,
      );
}
