import '../models/recurso.dart';
import '../models/relatorios.dart';
import '../models/reserva.dart';
import '../models/usuario.dart';
import 'api_client.dart';

class LoginResult {
  final String token;
  final Usuario usuario;
  const LoginResult(this.token, this.usuario);
}

/// Um metodo por endpoint da API REST do ReservaFans.
class ReservaFansApi {
  final ApiClient _c = ApiClient.instance;

  // ---- Autenticacao ----
  Future<LoginResult> login(String email, String senha) async {
    final d = await _c.post('/auth/login',
        body: {'email': email, 'senha': senha}, auth: false);
    return LoginResult(
      d['token'] as String,
      Usuario.fromJson(d['usuario'] as Map<String, dynamic>),
    );
  }

  Future<Usuario> perfil() async =>
      Usuario.fromJson(await _c.get('/auth/perfil') as Map<String, dynamic>);

  // ---- Categorias ----
  Future<List<Categoria>> listarCategorias() async {
    final d = await _c.get('/categorias') as List<dynamic>;
    return d.map((e) => Categoria.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Categoria> criarCategoria(String nome) async => Categoria.fromJson(
      await _c.post('/categorias', body: {'nome': nome}) as Map<String, dynamic>);

  // ---- Recursos (catalogo / estoque) ----
  Future<List<Recurso>> listarRecursos({int? categoriaId}) async {
    final d = await _c.get('/recursos',
        query: categoriaId == null ? null : {'categoriaId': '$categoriaId'}) as List<dynamic>;
    return d.map((e) => Recurso.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Disponibilidade> disponibilidade(
      int id, String inicioIso, String fimIso) async {
    final d = await _c.get('/recursos/$id/disponibilidade',
        query: {'inicio': inicioIso, 'fim': fimIso});
    return Disponibilidade.fromJson(d as Map<String, dynamic>);
  }

  Future<void> salvarRecurso({
    int? id,
    required Map<String, String> campos,
    List<int>? fotoBytes,
    String? fotoNome,
    String? fotoMime,
  }) async {
    await _c.multipart(
      id == null ? 'POST' : 'PUT',
      id == null ? '/recursos' : '/recursos/$id',
      fields: campos,
      fileBytes: fotoBytes,
      fileName: fotoNome,
      mimeType: fotoMime,
    );
  }

  Future<void> removerRecurso(int id) async {
    await _c.delete('/recursos/$id');
  }

  // ---- Reservas ----
  Future<void> criarReserva({
    required int recursoId,
    required String inicioIso,
    required String fimIso,
    String? observacoes,
  }) async {
    await _c.post('/reservas', body: {
      'resourceId': recursoId,
      'dataInicio': inicioIso,
      'dataFimPrevista': fimIso,
      if (observacoes != null && observacoes.isNotEmpty) 'observacoes': observacoes,
    });
  }

  /// Reserva "de tal dia ate tal dia", sempre no horario de aula. Retorna quantas reservas foram criadas.
  Future<int> criarReservaPeriodo({
    required int recursoId,
    required String dataInicio,
    required String dataFim,
    String? observacoes,
  }) async {
    final d = await _c.post('/reservas/periodo', body: {
      'resourceId': recursoId,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      if (observacoes != null && observacoes.isNotEmpty) 'observacoes': observacoes,
    });
    return (d['totalCriadas'] as num).toInt();
  }

  Future<List<Reserva>> minhasReservas({String? status}) async {
    final d = await _c.get('/reservas/minhas',
        query: status == null ? null : {'status': status}) as List<dynamic>;
    return d.map((e) => Reserva.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cancelarReserva(int id) async {
    await _c.patch('/reservas/$id/cancelar');
  }

  Future<List<Reserva>> listarReservas({String? status}) async {
    final d = await _c.get('/reservas',
        query: status == null ? null : {'status': status}) as List<dynamic>;
    return d.map((e) => Reserva.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> registrarDevolucao(int id) async {
    await _c.patch('/reservas/$id/devolucao');
  }

  // ---- Relatorios (admin) ----
  Future<Resumo> resumo() async =>
      Resumo.fromJson(await _c.get('/relatorios/resumo') as Map<String, dynamic>);

  Future<List<ItemMaisSolicitado>> maisSolicitados() async {
    final d = await _c.get('/relatorios/mais-solicitados') as List<dynamic>;
    return d
        .map((e) => ItemMaisSolicitado.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
