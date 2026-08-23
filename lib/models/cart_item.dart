class CartItem {
  final int productId;
  final String code;
  final String name;
  final String category;
  final double price;
  final double cost;
  final int qty;

  const CartItem({
    required this.productId,
    required this.code,
    required this.name,
    required this.category,
    required this.price,
    required this.cost,
    this.qty = 1,
  });

  double get subtotal => price * qty;

  CartItem copyWith({int? qty}) => CartItem(
        productId: productId,
        code: code,
        name: name,
        category: category,
        price: price,
        cost: cost,
        qty: qty ?? this.qty,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'code': code,
        'name': name,
        'category': category,
        'price': price,
        'cost': cost,
        'qty': qty,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId'] as int,
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        cost: (json['cost'] as num?)?.toDouble() ?? 0,
        qty: json['qty'] ?? 1,
      );
}
