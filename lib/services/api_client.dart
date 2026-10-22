import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';

/// Erro de comunicacao/negocio com mensagem pronta para exibir ao usuario.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Cliente HTTP unico do app: injeta o token JWT, aplica timeout e traduz
/// falhas de conexao e respostas de erro da API em [ApiException].
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? token;
  void Function()? onUnauthorized;

  Map<String, String> _headers({bool json = true}) => {
        if (json) 'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse('${ApiConfig.baseUrl}$path');
    if (query == null || query.isEmpty) return base;
    return base.replace(queryParameters: {...base.queryParameters, ...query});
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send(() => http.get(_uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send(() => http.post(
            _uri(path),
            headers: auth ? _headers() : {'Content-Type': 'application/json'},
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> patch(String path) =>
      _send(() => http.patch(_uri(path), headers: _headers()));

  Future<dynamic> delete(String path) =>
      _send(() => http.delete(_uri(path), headers: _headers()));

  /// Envia campos de formulario + (opcionalmente) uma imagem no campo "foto".
  Future<dynamic> multipart(
    String method,
    String path, {
    required Map<String, String> fields,
    List<int>? fileBytes,
    String? fileName,
    String? mimeType,
  }) =>
      _send(() async {
        final req = http.MultipartRequest(method, _uri(path));
        req.headers.addAll(_headers(json: false));
        req.fields.addAll(fields);
        if (fileBytes != null) {
          req.files.add(http.MultipartFile.fromBytes(
            'foto',
            fileBytes,
            filename: fileName ?? 'foto.jpg',
            contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
          ));
        }
        final streamed = await req.send();
        return http.Response.fromStream(streamed);
      });

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response res;
    try {
      res = await request().timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw ApiException(
          'O servidor demorou para responder. Verifique a conexão e tente novamente.');
    } catch (_) {
      throw ApiException(
          'Falha de conexão com o servidor (${ApiConfig.baseUrl}). Verifique se a API está em execução e se o endereço está correto.');
    }

    dynamic data;
    if (res.bodyBytes.isNotEmpty) {
      try {
        data = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        data = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return data;

    final msg = (data is Map && data['erro'] is String)
        ? data['erro'] as String
        : 'Erro inesperado do servidor (${res.statusCode}).';
    if (res.statusCode == 401) onUnauthorized?.call();
    throw ApiException(msg, statusCode: res.statusCode);
  }
}
