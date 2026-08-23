import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/producto.dart';
import '../services/analytics_service.dart';

class ProductosController extends ChangeNotifier {
  final List<Producto> productos = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    final json = AppDatabase.getJson('products') as List?;
    productos
      ..clear()
      ..addAll((json ?? []).map((p) => Producto.fromJson(p)));
    notifyListeners();
  }

  Future<void> _guardar() async {
    await AppDatabase.setJson(
      'products',
      productos.map((p) => p.toJson()).toList(),
    );
  }

  List<String> get categorias =>
      productos.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()..sort();

  List<Producto> get stockBajo => productos.where((p) => p.stockBajo).toList();

  int _siguienteId() =>
      productos.isEmpty ? 1 : (productos.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<void> guardar(Producto producto) async {
    final i = productos.indexWhere((p) => p.id == producto.id);
    if (i >= 0) {
      productos[i] = producto;
    } else {
      productos.add(producto);
    }
    await _guardar();
    notifyListeners();
  }

  Future<Producto> crear(Producto producto) async {
    final nuevo = Producto(
      id: _siguienteId(),
      code: producto.code,
      name: producto.name,
      category: producto.category,
      cost: producto.cost,
      price: producto.price,
      stock: producto.stock,
      minStock: producto.minStock,
      sku: producto.sku,
    );
    productos.add(nuevo);
    await _guardar();
    notifyListeners();
    AnalyticsService.track('producto_agregado', {'es_primer_producto': productos.length == 1});
    return nuevo;
  }

  Future<void> eliminar(int id) async {
    productos.removeWhere((p) => p.id == id);
    await _guardar();
    notifyListeners();
  }

  Future<void> descontarStock(int id, int cantidad) async {
    final i = productos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final nuevoStock = (productos[i].stock - cantidad).clamp(0, 1 << 30);
    productos[i] = productos[i].copyWith(stock: nuevoStock);
    await _guardar();
    notifyListeners();
  }

  Future<void> ajustarStock(int id, int nuevoStock) async {
    final i = productos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    productos[i] = productos[i].copyWith(stock: nuevoStock.clamp(0, 1 << 30));
    await _guardar();
    notifyListeners();
  }

  List<Producto> buscar(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return productos
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.code.contains(q) ||
            p.sku.toLowerCase().contains(q))
        .take(8)
        .toList();
  }
}
