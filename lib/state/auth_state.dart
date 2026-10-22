import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/reservafans_api.dart';

/// Estado de autenticacao. A sessao (token + usuario) fica salva com
/// shared_preferences, entao o usuario continua logado ao fechar e reabrir o app.
class AuthState extends ChangeNotifier {
  static const _tokenKey = 'rf_token';
  static const _userKey = 'rf_user';

  final ReservaFansApi _api = ReservaFansApi();
  Usuario? usuario;

  bool get logado => usuario != null;
  bool get isAdmin => usuario?.isAdmin ?? false;

  Future<void> init() async {
    await ApiConfig.load();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token != null && userJson != null) {
      try {
        ApiClient.instance.token = token;
        usuario = Usuario.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        // Confirma no servidor que a sessao salva ainda e valida.
        final atual = await _api.perfil();
        usuario = atual;
        await prefs.setString(_userKey, jsonEncode(atual.toJson()));
      } on ApiException catch (e) {
        // Sessao expirada: volta para o login. Falha de conexao: mantem a sessao salva.
        if (e.isUnauthorized) await _limpar();
      } catch (_) {
        await _limpar();
      }
    }
    ApiClient.instance.onUnauthorized = () {
      if (logado) logout();
    };
    notifyListeners();
  }

  Future<void> login(String email, String senha) async {
    final r = await _api.login(email.trim(), senha);
    ApiClient.instance.token = r.token;
    usuario = r.usuario;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, r.token);
    await prefs.setString(_userKey, jsonEncode(r.usuario.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    await _limpar();
    notifyListeners();
  }

  Future<void> _limpar() async {
    ApiClient.instance.token = null;
    usuario = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
