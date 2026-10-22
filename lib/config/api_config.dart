import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';

/// Endereco da API do ReservaFans (backend Node.js + SQLite).
/// O valor escolhido pelo usuario fica salvo no aparelho/navegador.
class ApiConfig {
  static const _prefsKey = 'rf_api_url';
  static String _baseUrl = defaultUrl();

  static String get baseUrl => _baseUrl;

  /// Web: localhost. Emulador Android: 10.0.2.2 e o "localhost" do computador.
  /// Em celular fisico, informe o IP do computador na tela de login.
  static String defaultUrl() {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  /// Origem do servidor (sem /api), usada para montar a URL das imagens.
  static String get origin => _baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

  static String? assetUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$origin$path';
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_prefsKey) ?? defaultUrl();
  }

  static Future<void> save(String url) async {
    var value = url.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, value);
    _baseUrl = value;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _baseUrl = defaultUrl();
  }
}
