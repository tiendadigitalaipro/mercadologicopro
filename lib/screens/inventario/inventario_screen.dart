import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import 'producto_form_sheet.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  void _abrirFormulario(BuildContext context, {Producto? producto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: context.read<ProductosController>(),
        child: ProductoFormSheet(producto: producto),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Producto p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar producto', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${p.name}"? Esta acción no se puede deshacer.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<ProductosController>().eliminar(p.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductosController>().productos;
    final bajoStock = productos.where((p) => p.stockBajo).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'inventario_fab',
        backgroundColor: AppColors.harvest,
        foregroundColor: Colors.black,
        onPressed: () => _abrirFormulario(context),
        tooltip: 'Agregar producto',
        child: const Icon(Icons.add),
      ),
      body: productos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2, size: 56, color: Colors.white24),
                    const SizedBox(height: 12),
                    const Text('Todavía no tienes productos en inventario.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 4),
                    const Text('Toca el botón + para agregar el primero.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: productos.length + (bajoStock > 0 ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (bajoStock > 0 && i == 0) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$bajoStock producto${bajoStock != 1 ? 's' : ''} con stock bajo',
                            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final p = productos[i - (bajoStock > 0 ? 1 : 0)];
                return Card(
                  child: ListTile(
                    onTap: () => _abrirFormulario(context, producto: p),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.harvest.withValues(alpha: 0.15),
                      child: const Icon(Icons.shopping_basket, color: AppColors.harvest, size: 20),
                    ),
                    title: Text(p.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '${p.sku} · Stock: ${p.stock}${p.category.isNotEmpty ? ' · ${p.category}' : ''}',
                      style: TextStyle(color: p.stockBajo ? Colors.orangeAccent : Colors.white54, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatMoney(p.price), style: const TextStyle(color: AppColors.harvest, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white38),
                          onPressed: () => _confirmarEliminar(context, p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
