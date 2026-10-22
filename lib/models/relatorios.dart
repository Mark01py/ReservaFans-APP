class Resumo {
  final int itensCadastrados;
  final int emUsoAgora;
  final int reservasHoje;
  final int devolucoesAtrasadas;

  const Resumo({
    required this.itensCadastrados,
    required this.emUsoAgora,
    required this.reservasHoje,
    required this.devolucoesAtrasadas,
  });

  factory Resumo.fromJson(Map<String, dynamic> j) => Resumo(
        itensCadastrados: (j['itensCadastrados'] as num).toInt(),
        emUsoAgora: (j['emUsoAgora'] as num).toInt(),
        reservasHoje: (j['reservasHoje'] as num).toInt(),
        devolucoesAtrasadas: (j['devolucoesAtrasadas'] as num).toInt(),
      );
}

class ItemMaisSolicitado {
  final String nome;
  final String categoriaNome;
  final int total;

  const ItemMaisSolicitado({
    required this.nome,
    required this.categoriaNome,
    required this.total,
  });

  factory ItemMaisSolicitado.fromJson(Map<String, dynamic> j) {
    final rec = j['recurso'] is Map
        ? j['recurso'] as Map<String, dynamic>
        : <String, dynamic>{};
    final cat = rec['categoriaRef'] is Map
        ? rec['categoriaRef'] as Map<String, dynamic>
        : <String, dynamic>{};
    return ItemMaisSolicitado(
      nome: rec['nome'] as String? ?? '—',
      categoriaNome: cat['nome'] as String? ?? '—',
      total: int.tryParse('${j['totalReservas']}') ?? 0,
    );
  }
}
