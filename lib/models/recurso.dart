class Categoria {
  final int id;
  final String nome;

  const Categoria({required this.id, required this.nome});

  factory Categoria.fromJson(Map<String, dynamic> j) =>
      Categoria(id: (j['id'] as num).toInt(), nome: j['nome'] as String);
}

class Recurso {
  final int id;
  final String nome;
  final int categoriaId;
  final String categoriaNome;
  final String? descricao;
  final String? fotoUrl;
  final int quantidadeTotal;
  final int quantidadeDisponivel;

  const Recurso({
    required this.id,
    required this.nome,
    required this.categoriaId,
    required this.categoriaNome,
    this.descricao,
    this.fotoUrl,
    required this.quantidadeTotal,
    required this.quantidadeDisponivel,
  });

  factory Recurso.fromJson(Map<String, dynamic> j) {
    final ref = j['categoriaRef'];
    final total = (j['quantidadeTotal'] as num?)?.toInt() ?? 0;
    return Recurso(
      id: (j['id'] as num).toInt(),
      nome: j['nome'] as String,
      categoriaId: (j['categoriaId'] as num?)?.toInt() ?? 0,
      categoriaNome: ref is Map ? (ref['nome'] as String? ?? '—') : '—',
      descricao: j['descricao'] as String?,
      fotoUrl: j['fotoUrl'] as String?,
      quantidadeTotal: total,
      quantidadeDisponivel: (j['quantidadeDisponivel'] as num?)?.toInt() ?? total,
    );
  }
}

class Disponibilidade {
  final bool disponivel;
  final int quantidade;

  const Disponibilidade({required this.disponivel, required this.quantidade});

  factory Disponibilidade.fromJson(Map<String, dynamic> j) => Disponibilidade(
        disponivel: j['disponivel'] as bool,
        quantidade: (j['quantidadeDisponivel'] as num).toInt(),
      );
}
