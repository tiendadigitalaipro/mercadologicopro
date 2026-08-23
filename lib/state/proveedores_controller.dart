import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/compra.dart';
import '../models/proveedor.dart';

/// Proveedores + compras a crédito — equivalente al módulo PROV de
/// mercado-logic-pro/index.html.
class ProveedoresController extends ChangeNotifier {
  final List<Proveedor> proveedores = [];
  final List<Compra> compras = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    final provJson = AppDatabase.getJson('proveedores') as List?;
    proveedores
      ..clear()
      ..addAll((provJson ?? []).map((p) => Proveedor.fromJson(p)));

    final compJson = AppDatabase.getJson('compras') as List?;
    compras
      ..clear()
      ..addAll((compJson ?? []).map((c) => Compra.fromJson(c)));
    notifyListeners();
  }

  Future<void> _guardarProveedores() async {
    await AppDatabase.setJson('proveedores', proveedores.map((p) => p.toJson()).toList());
  }

  Future<void> _guardarCompras() async {
    await AppDatabase.setJson('compras', compras.map((c) => c.toJson()).toList());
  }

  double get deudaTotal => proveedores.fold(0, (s, p) => s + p.debt);

  int _siguienteIdProveedor() =>
      proveedores.isEmpty ? 1 : (proveedores.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1);

  int _siguienteIdCompra() =>
      compras.isEmpty ? 1 : (compras.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<void> guardarProveedor(Proveedor proveedor) async {
    final i = proveedores.indexWhere((p) => p.id == proveedor.id);
    if (i >= 0) {
      proveedores[i] = proveedor;
    } else {
      proveedores.add(Proveedor(
        id: _siguienteIdProveedor(),
        name: proveedor.name,
        contact: proveedor.contact,
        phone: proveedor.phone,
        debt: proveedor.debt,
      ));
    }
    await _guardarProveedores();
    notifyListeners();
  }

  Future<void> eliminarProveedor(int id) async {
    proveedores.removeWhere((p) => p.id == id);
    await _guardarProveedores();
    notifyListeners();
  }

  Future<void> registrarCompra({
    required int provId,
    required String concepto,
    required double amount,
    required bool credito,
  }) async {
    compras.add(Compra(
      id: _siguienteIdCompra(),
      provId: provId,
      concepto: concepto,
      amount: amount,
      credito: credito,
      date: DateTime.now(),
    ));
    await _guardarCompras();

    if (credito) {
      final i = proveedores.indexWhere((p) => p.id == provId);
      if (i >= 0) {
        proveedores[i] = proveedores[i].copyWith(debt: proveedores[i].debt + amount);
        await _guardarProveedores();
      }
    }
    notifyListeners();
  }

  Future<void> abonarDeuda(int provId, double monto) async {
    final i = proveedores.indexWhere((p) => p.id == provId);
    if (i < 0) return;
    final nuevaDeuda = (proveedores[i].debt - monto).clamp(0.0, double.infinity);
    proveedores[i] = proveedores[i].copyWith(debt: nuevaDeuda);
    await _guardarProveedores();
    notifyListeners();
  }
}
