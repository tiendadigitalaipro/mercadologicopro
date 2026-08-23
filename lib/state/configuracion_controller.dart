import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/app_config.dart';
import '../models/usuario.dart';

/// Configuración del negocio + tasa de cambio USD/Bs + usuarios/cajeros —
/// equivalente al módulo CFG de mercado-logic-pro/index.html.
class ConfiguracionController extends ChangeNotifier {
  AppConfig config = const AppConfig();
  final List<Usuario> usuarios = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    final json = AppDatabase.getJson('config') as Map<String, dynamic>?;
    config = json != null ? AppConfig.fromJson(json) : const AppConfig();

    final usersJson = AppDatabase.getJson('users') as List?;
    usuarios
      ..clear()
      ..addAll((usersJson ?? _defaultUsers()).map((u) => u is Usuario ? u : Usuario.fromJson(u)));
    if (usersJson == null) await _guardarUsuarios();
    notifyListeners();
  }

  List<Usuario> _defaultUsers() => const [
        Usuario(id: 1, name: 'Admin Master', role: 'Admin', pin: '1234'),
        Usuario(id: 2, name: 'Cajero', role: 'Cajero', pin: '0000'),
      ];

  Future<void> guardarConfig(AppConfig nuevo) async {
    config = nuevo;
    await AppDatabase.setJson('config', config.toJson());
    notifyListeners();
  }

  Future<void> _guardarUsuarios() async {
    await AppDatabase.setJson('users', usuarios.map((u) => u.toJson()).toList());
  }

  int _siguienteIdUsuario() =>
      usuarios.isEmpty ? 1 : (usuarios.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<void> crearUsuario(Usuario usuario) async {
    usuarios.add(Usuario(
      id: _siguienteIdUsuario(),
      name: usuario.name,
      role: usuario.role,
      pin: usuario.pin,
    ));
    await _guardarUsuarios();
    notifyListeners();
  }

  Future<void> alternarActivo(int id) async {
    final i = usuarios.indexWhere((u) => u.id == id);
    if (i < 0) return;
    usuarios[i] = usuarios[i].copyWith(active: !usuarios[i].active);
    await _guardarUsuarios();
    notifyListeners();
  }

  Future<void> eliminarUsuario(int id) async {
    usuarios.removeWhere((u) => u.id == id);
    await _guardarUsuarios();
    notifyListeners();
  }
}
