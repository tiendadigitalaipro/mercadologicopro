import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/analytics_service.dart';
import '../../state/cart_controller.dart';
import '../../state/caja_controller.dart';
import '../../state/configuracion_controller.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';

enum _Moneda { usd, bs, mixto }

class _Metodo {
  final String nombre;
  final IconData icon;
  final _Moneda moneda;
  final bool esEfectivo;
  const _Metodo(this.nombre, this.icon, this.moneda, {this.esEfectivo = false});
}

const _metodos = [
  _Metodo('Efectivo \$', Icons.attach_money, _Moneda.usd, esEfectivo: true),
  _Metodo('Zelle', Icons.account_balance, _Moneda.usd),
  _Metodo('Binance / USDT', Icons.currency_bitcoin, _Moneda.usd),
  _Metodo('Zinli', Icons.account_balance_wallet, _Moneda.usd),
  _Metodo('Efectivo Bs', Icons.payments, _Moneda.bs, esEfectivo: true),
  _Metodo('Pago Móvil', Icons.phone_android, _Moneda.bs),
  _Metodo('Transferencia', Icons.swap_horiz, _Moneda.bs),
  _Metodo('Punto de venta', Icons.point_of_sale, _Moneda.bs),
  _Metodo('Mixto', Icons.sync_alt, _Moneda.mixto),
];

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({super.key});

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  _Metodo? _seleccionado;
  final _recibidoCtrl = TextEditingController();
  bool _procesando = false;

  @override
  void dispose() {
    _recibidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final metodo = _seleccionado;
    if (metodo == null) return;
    final cart = context.read<CartController>();
    final productos = context.read<ProductosController>();
    final config = context.read<ConfiguracionController>().config;
    final caja = context.read<CajaController>();
    final cashier = caja.turnoActivo?.responsable ?? 'Cajero';
    final total = cart.total(config);

    setState(() => _procesando = true);
    try {
      double cashReceivedUsd;
      if (metodo.esEfectivo) {
        final recibido = double.tryParse(_recibidoCtrl.text) ?? total;
        cashReceivedUsd = metodo.moneda == _Moneda.bs ? recibido / config.tasaCambio : recibido;
      } else {
        cashReceivedUsd = total;
      }

      final items = List.of(cart.items);
      final venta = await cart.confirmarVenta(
        config: config,
        metodo: metodo.nombre,
        cashReceived: cashReceivedUsd,
        cashier: cashier,
      );
      for (final item in items) {
        await productos.descontarStock(item.productId, item.qty);
      }
      AnalyticsService.track('venta_registrada', {
        'metodo_pago': metodo.nombre,
        'total_usd': venta.total,
        'cantidad_items': items.length,
        'folio': venta.folio,
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Venta registrada — Folio #${venta.folio}'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final config = context.watch<ConfiguracionController>().config;
    final total = cart.total(config);

    double recibido = double.tryParse(_recibidoCtrl.text) ?? 0;
    double cambio = 0;
    if (_seleccionado?.esEfectivo == true) {
      if (_seleccionado!.moneda == _Moneda.bs) {
        cambio = recibido - (total * config.tasaCambio);
      } else {
        cambio = recibido - total;
      }
    }

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
              const Text('Método de pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Total: ${formatMoney(total)}  ·  ${formatBs(total, config.tasaCambio)}',
                  style: const TextStyle(color: AppColors.harvest, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.6,
                ),
                itemCount: _metodos.length,
                itemBuilder: (context, i) {
                  final m = _metodos[i];
                  final activo = m == _seleccionado;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _seleccionado = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: activo ? AppColors.harvest.withValues(alpha: 0.15) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: activo ? AppColors.harvest : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(m.icon, color: activo ? AppColors.harvest : Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m.nombre,
                              style: TextStyle(color: activo ? Colors.white : Colors.white70, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_seleccionado?.esEfectivo == true) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _recibidoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _seleccionado!.moneda == _Moneda.bs ? 'Monto recibido (Bs)' : 'Monto recibido (\$)',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cambio: ${_seleccionado!.moneda == _Moneda.bs ? formatBs(cambio, 1) : formatMoney(cambio)}',
                  style: TextStyle(color: cambio < 0 ? Colors.redAccent : AppColors.olive, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_seleccionado == null || _procesando) ? null : _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.harvest,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _procesando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('✅ Confirmar venta', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
