import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/proveedor.dart';
import '../../state/proveedores_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';

class ProveedoresScreen extends StatelessWidget {
  const ProveedoresScreen({super.key});

  void _abrirFormulario(BuildContext context, {Proveedor? proveedor}) {
    final nameCtrl = TextEditingController(text: proveedor?.name ?? '');
    final contactCtrl = TextEditingController(text: proveedor?.contact ?? '');
    final phoneCtrl = TextEditingController(text: proveedor?.phone ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                proveedor != null ? 'Editar proveedor' : 'Nuevo proveedor',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nombre del proveedor *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Persona de contacto'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.harvest, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    context.read<ProveedoresController>().guardarProveedor(Proveedor(
                          id: proveedor?.id ?? 0,
                          name: nameCtrl.text.trim(),
                          contact: contactCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          debt: proveedor?.debt ?? 0,
                        ));
                    Navigator.pop(ctx);
                  },
                  child: Text(proveedor != null ? 'Guardar cambios' : 'Agregar proveedor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registrarCompra(BuildContext context, Proveedor proveedor) {
    final conceptoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    bool credito = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Compra a ${proveedor.name}', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: conceptoCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Concepto *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Monto \$'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Compra a crédito', style: TextStyle(color: Colors.white70, fontSize: 13)),
                value: credito,
                activeThumbColor: AppColors.harvest,
                onChanged: (v) => setDialogState(() => credito = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final monto = double.tryParse(montoCtrl.text) ?? 0;
                if (monto <= 0 || conceptoCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Concepto y monto son obligatorios'), backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                context.read<ProveedoresController>().registrarCompra(
                      provId: proveedor.id,
                      concepto: conceptoCtrl.text.trim(),
                      amount: monto,
                      credito: credito,
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Registrar', style: TextStyle(color: AppColors.harvest)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Proveedor p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar proveedor', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${p.name}"? Esta acción no se puede deshacer.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<ProveedoresController>().eliminarProveedor(p.id);
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
    final controller = context.watch<ProveedoresController>();
    final proveedores = controller.proveedores;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'proveedores_fab',
        backgroundColor: AppColors.harvest,
        foregroundColor: Colors.black,
        onPressed: () => _abrirFormulario(context),
        tooltip: 'Agregar proveedor',
        child: const Icon(Icons.add),
      ),
      body: proveedores.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_shipping, size: 56, color: Colors.white24),
                    const SizedBox(height: 12),
                    const Text('No hay proveedores registrados.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 4),
                    const Text('Toca el botón + para agregar el primero.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Card(
                  color: AppColors.surfaceLight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${proveedores.length} proveedores', style: const TextStyle(color: Colors.white70)),
                        Text('Deuda total: ${formatMoney(controller.deudaTotal)}', style: const TextStyle(color: AppColors.harvest, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...proveedores.map((p) => Card(
                      child: ListTile(
                        onTap: () => _abrirFormulario(context, proveedor: p),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.harvest.withValues(alpha: 0.15),
                          child: const Icon(Icons.local_shipping, color: AppColors.harvest, size: 18),
                        ),
                        title: Text(p.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          p.debt > 0 ? 'Debe ${formatMoney(p.debt)}' : 'Al día',
                          style: TextStyle(color: p.debt > 0 ? Colors.orangeAccent : Colors.white54, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart, color: AppColors.olive),
                              tooltip: 'Registrar compra',
                              onPressed: () => _registrarCompra(context, p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white38),
                              onPressed: () => _confirmarEliminar(context, p),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
