import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/app_config.dart';
import '../models/cart_item.dart';
import '../models/producto.dart';
import '../models/venta.dart';

enum TipoDescuento { percent, fixed }

/// Estado del carrito y checkout — equivalente al objeto POS de
/// mercado-logic-pro/index.html (cart, discount, confirmPayment).
class CartController extends ChangeNotifier {
  final List<CartItem> items = [];
  TipoDescuento discountType = TipoDescuento.percent;
  double discountValue = 0;
  int _folioCounter = 29400;
  final List<Venta> historialVentas = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    _folioCounter = AppDatabase.getInt('folioCounter') ?? 29400;
    final ventasJson = AppDatabase.getJson('sales') as List?;
    historialVentas
      ..clear()
      ..addAll((ventasJson ?? []).map((v) => Venta.fromJson(v)));
    notifyListeners();
  }

  double get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);

  double get discountAmount {
    if (discountValue <= 0) return 0;
    return discountType == TipoDescuento.percent
        ? subtotal * (discountValue / 100)
        : discountValue.clamp(0, subtotal);
  }

  double taxAmount(AppConfig config) {
    if (config.taxIncluded) return 0;
    return (subtotal - discountAmount) * (config.taxRate / 100);
  }

  double total(AppConfig config) => subtotal - discountAmount + taxAmount(config);

  void agregarProducto(Producto p) {
    final existente = items.indexWhere((i) => i.productId == p.id);
    if (existente >= 0) {
      items[existente] = items[existente].copyWith(qty: items[existente].qty + 1);
    } else {
      items.add(CartItem(
        productId: p.id,
        code: p.code,
        name: p.name,
        category: p.category,
        price: p.price,
        cost: p.cost,
      ));
    }
    notifyListeners();
  }

  void cambiarCantidad(int index, int delta) {
    final nuevaQty = items[index].qty + delta;
    if (nuevaQty <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(qty: nuevaQty);
    }
    notifyListeners();
  }

  void quitar(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void setDescuento(TipoDescuento tipo, double valor) {
    discountType = tipo;
    discountValue = valor;
    notifyListeners();
  }

  void vaciar() {
    items.clear();
    discountType = TipoDescuento.percent;
    discountValue = 0;
    notifyListeners();
  }

  Future<Venta> confirmarVenta({
    required AppConfig config,
    required String metodo,
    required double cashReceived,
    required String cashier,
  }) async {
    final sub = subtotal;
    final disc = discountAmount;
    final tax = taxAmount(config);
    final tot = total(config);

    _folioCounter++;
    final venta = Venta(
      id: DateTime.now().millisecondsSinceEpoch,
      folio: _folioCounter,
      date: DateTime.now(),
      items: List.of(items),
      subtotal: sub,
      discount: disc,
      tax: tax,
      total: tot,
      method: metodo,
      cashReceived: cashReceived,
      change: cashReceived - tot,
      cashier: cashier,
    );

    historialVentas.add(venta);
    await AppDatabase.setJson('sales', historialVentas.map((v) => v.toJson()).toList());
    await AppDatabase.setInt('folioCounter', _folioCounter);

    vaciar();
    notifyListeners();
    return venta;
  }
}
