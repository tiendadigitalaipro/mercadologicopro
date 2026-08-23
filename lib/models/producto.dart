class Producto {
  final int id;
  final String code;
  final String name;
  final String category;
  final double cost;
  final double price;
  final int stock;
  final int minStock;
  final String sku;

  const Producto({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.cost,
    required this.price,
    this.stock = 0,
    this.minStock = 0,
    required this.sku,
  });

  bool get stockBajo => stock <= minStock;

  Producto copyWith({
    String? code,
    String? name,
    String? category,
    double? cost,
    double? price,
    int? stock,
    int? minStock,
    String? sku,
  }) {
    return Producto(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      sku: sku ?? this.sku,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'category': category,
        'cost': cost,
        'price': price,
        'stock': stock,
        'minStock': minStock,
        'sku': sku,
      };

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json['id'] as int,
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        cost: (json['cost'] as num?)?.toDouble() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        stock: json['stock'] ?? 0,
        minStock: json['minStock'] ?? 0,
        sku: json['sku'] ?? '',
      );
}
