import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';

class ProductoFormSheet extends StatefulWidget {
  final Producto? producto;

  const ProductoFormSheet({super.key, this.producto});

  @override
  State<ProductoFormSheet> createState() => _ProductoFormSheetState();
}

class _ProductoFormSheetState extends State<ProductoFormSheet> {
  late final _nameCtrl = TextEditingController(text: widget.producto?.name ?? '');
  late final _codeCtrl = TextEditingController(text: widget.producto?.code ?? '');
  late final _skuCtrl = TextEditingController(text: widget.producto?.sku ?? '');
  late final _catCtrl = TextEditingController(text: widget.producto?.category ?? '');
  late final _costCtrl = TextEditingController(text: widget.producto?.cost.toString() ?? '0');
  late final _priceCtrl = TextEditingController(text: widget.producto?.price.toString() ?? '');
  late final _stockCtrl = TextEditingController(text: widget.producto?.stock.toString() ?? '0');
  late final _minCtrl = TextEditingController(text: widget.producto?.minStock.toString() ?? '0');
  late final _marginCtrl = TextEditingController(
    text: widget.producto != null && widget.producto!.cost > 0
        ? (((widget.producto!.price - widget.producto!.cost) / widget.producto!.cost) * 100).toStringAsFixed(0)
        : '',
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _skuCtrl.dispose();
    _catCtrl.dispose();
    _costCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _minCtrl.dispose();
    _marginCtrl.dispose();
    super.dispose();
  }

  /// Igual que mpCalcPrice() del original: si hay margen deseado, deriva
  /// el precio de venta a partir del costo.
  void _calcularPrecio() {
    final cost = double.tryParse(_costCtrl.text) ?? 0;
    final margin = double.tryParse(_marginCtrl.text);
    if (cost > 0 && margin != null && margin >= 0) {
      _priceCtrl.text = (cost * (1 + margin / 100)).toStringAsFixed(2);
    }
    setState(() {});
  }

  double get _ganancia => (double.tryParse(_priceCtrl.text) ?? 0) - (double.tryParse(_costCtrl.text) ?? 0);

  void _guardar() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    final controller = context.read<ProductosController>();
    final datos = Producto(
      id: widget.producto?.id ?? 0,
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      category: _catCtrl.text.trim(),
      cost: double.tryParse(_costCtrl.text) ?? 0,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      minStock: int.tryParse(_minCtrl.text) ?? 0,
      sku: _skuCtrl.text.trim().toUpperCase().isEmpty ? 'S/C' : _skuCtrl.text.trim().toUpperCase(),
    );
    if (widget.producto != null) {
      controller.guardar(datos);
    } else {
      controller.crear(datos);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.producto != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editando ? 'Editar producto' : 'Nuevo producto',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nombre del producto *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Código de barras'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _skuCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'SKU'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _catCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 16),
              const Text('Precio', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _costCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Costo'),
                      onChanged: (_) => _calcularPrecio(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _marginCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: '% ganancia', hintText: 'ej: 30'),
                      onChanged: (_) => _calcularPrecio(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Precio venta *'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              if ((double.tryParse(_costCtrl.text) ?? 0) > 0 && (double.tryParse(_priceCtrl.text) ?? 0) > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Ganancia: \$${_ganancia.toStringAsFixed(2)} por unidad',
                    style: const TextStyle(color: AppColors.harvest, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Stock'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Stock mínimo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.harvest,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(editando ? 'Guardar cambios' : 'Agregar producto', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
