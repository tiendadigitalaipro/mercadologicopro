class Compra {
  final int id;
  final int provId;
  final String concepto;
  final double amount;
  final bool credito;
  final DateTime date;

  const Compra({
    required this.id,
    required this.provId,
    required this.concepto,
    required this.amount,
    this.credito = false,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'provId': provId,
        'concepto': concepto,
        'amount': amount,
        'credito': credito,
        'date': date.toIso8601String(),
      };

  factory Compra.fromJson(Map<String, dynamic> json) => Compra(
        id: json['id'] as int,
        provId: json['provId'] as int,
        concepto: json['concepto'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        credito: json['credito'] ?? false,
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );
}
