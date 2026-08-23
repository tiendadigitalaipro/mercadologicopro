class Usuario {
  final int id;
  final String name;
  final String role;
  final String pin;
  final bool active;

  const Usuario({
    required this.id,
    required this.name,
    required this.role,
    required this.pin,
    this.active = true,
  });

  Usuario copyWith({String? name, String? role, String? pin, bool? active}) {
    return Usuario(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'pin': pin,
        'active': active,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as int,
        name: json['name'] ?? '',
        role: json['role'] ?? 'Cajero',
        pin: json['pin'] ?? '0000',
        active: json['active'] ?? true,
      );
}
