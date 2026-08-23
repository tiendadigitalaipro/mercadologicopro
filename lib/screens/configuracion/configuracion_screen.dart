import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../state/configuracion_controller.dart';
import '../../state/license_controller.dart';
import '../../theme/app_theme.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _tasaCtrl = TextEditingController();
  final _ivaCtrl = TextEditingController();
  bool _cargado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cargado) {
      _cargado = true;
      final cfg = context.read<ConfiguracionController>().config;
      _nombreCtrl.text = cfg.name;
      _direccionCtrl.text = cfg.address;
      _telefonoCtrl.text = cfg.phone;
      _tasaCtrl.text = cfg.tasaCambio.toString();
      _ivaCtrl.text = cfg.taxRate.toString();
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _tasaCtrl.dispose();
    _ivaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final controller = context.read<ConfiguracionController>();
    await controller.guardarConfig(controller.config.copyWith(
      name: _nombreCtrl.text.trim(),
      address: _direccionCtrl.text.trim(),
      phone: _telefonoCtrl.text.trim(),
      tasaCambio: double.tryParse(_tasaCtrl.text) ?? controller.config.tasaCambio,
      taxRate: double.tryParse(_ivaCtrl.text) ?? controller.config.taxRate,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuración guardada')));
    }
  }

  void _nuevoUsuario(BuildContext context) {
    final nameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    String role = 'Cajero';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Nuevo usuario', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'PIN'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Cajero', child: Text('Cajero')),
                ],
                onChanged: (v) => setDialogState(() => role = v ?? 'Cajero'),
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || pinCtrl.text.trim().isEmpty) return;
                context.read<ConfiguracionController>().crearUsuario(
                      Usuario(id: 0, name: nameCtrl.text.trim(), role: role, pin: pinCtrl.text.trim()),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Crear', style: TextStyle(color: AppColors.harvest)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final licencia = context.watch<LicenseController>();
    final usuarios = context.watch<ConfiguracionController>().usuarios;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  licencia.estado == EstadoLicencia.activa ? Icons.verified : Icons.timer_outlined,
                  color: licencia.estado == EstadoLicencia.activa ? Colors.greenAccent : AppColors.harvest,
                ),
                title: Text(
                  licencia.estado == EstadoLicencia.activa ? 'Licencia activa' : 'Modo de prueba',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  licencia.estado == EstadoLicencia.activa ? (licencia.licenciaKey ?? '') : '${licencia.diasRestantesDemo ?? '—'} días restantes de la demo',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Datos del negocio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nombreCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Nombre del negocio'),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _direccionCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Dirección'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _telefonoCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tasaCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Tasa de cambio (Bs por \$)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _ivaCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'IVA %'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.harvest, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: _guardar,
                        child: const Text('Guardar cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Usuarios / Cajeros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.person_add, color: AppColors.harvest),
                  onPressed: () => _nuevoUsuario(context),
                ),
              ],
            ),
            ...usuarios.map((u) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.harvest.withValues(alpha: 0.15),
                      child: Icon(u.role == 'Admin' ? Icons.admin_panel_settings : Icons.person, color: AppColors.harvest, size: 18),
                    ),
                    title: Text(u.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(u.role, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: Switch(
                      value: u.active,
                      activeThumbColor: AppColors.harvest,
                      onChanged: (_) => context.read<ConfiguracionController>().alternarActivo(u.id),
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Elaborado por A2K Digital Studio', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
