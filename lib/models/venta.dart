import 'cart_item.dart';

class Venta {
  final int id;
  final int folio;
  final DateTime date;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String method;
  final double cashReceived;
  final double change;
  final String cashier;

  const Venta({
    required this.id,
    required this.folio,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.method,
    required this.cashReceived,
    required this.change,
    required this.cashier,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'folio': folio,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'tax': tax,
        'total': total,
        'method': method,
        'cashReceived': cashReceived,
        'change': change,
        'cashier': cashier,
      };

  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
        id: json['id'] as int,
        folio: json['folio'] ?? 0,
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        items: ((json['items'] as List?) ?? [])
            .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        method: json['method'] ?? '',
        cashReceived: (json['cashReceived'] as num?)?.toDouble() ?? 0,
        change: (json['change'] as num?)?.toDouble() ?? 0,
        cashier: json['cashier'] ?? '',
      );
}
