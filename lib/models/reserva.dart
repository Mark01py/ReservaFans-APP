class Reserva {
  final int id;
  final String status;
  final DateTime dataInicio;
  final DateTime dataFimPrevista;
  final DateTime? dataDevolucaoReal;
  final String? observacoes;
  final String recursoNome;
  final String categoriaNome;
  final String? usuarioNome;

  const Reserva({
    required this.id,
    required this.status,
    required this.dataInicio,
    required this.dataFimPrevista,
    this.dataDevolucaoReal,
    this.observacoes,
    required this.recursoNome,
    required this.categoriaNome,
    this.usuarioNome,
  });

  bool get emAberto => status == 'ativa' || status == 'em_uso';

  /// Devolucao atrasada: ainda em aberto e o prazo previsto ja passou.
  bool get atrasada => emAberto && dataFimPrevista.isBefore(DateTime.now());

  factory Reserva.fromJson(Map<String, dynamic> j) {
    final rec = j['recurso'] is Map
        ? j['recurso'] as Map<String, dynamic>
        : <String, dynamic>{};
    final cat = rec['categoriaRef'] is Map
        ? rec['categoriaRef'] as Map<String, dynamic>
        : <String, dynamic>{};
    final usr = j['usuario'] is Map
        ? j['usuario'] as Map<String, dynamic>
        : <String, dynamic>{};
    final devolucao = j['dataDevolucaoReal'] as String?;
    return Reserva(
      id: (j['id'] as num).toInt(),
      status: j['status'] as String,
      dataInicio: DateTime.parse(j['dataInicio'] as String).toLocal(),
      dataFimPrevista: DateTime.parse(j['dataFimPrevista'] as String).toLocal(),
      dataDevolucaoReal:
          devolucao == null ? null : DateTime.parse(devolucao).toLocal(),
      observacoes: j['observacoes'] as String?,
      recursoNome: rec['nome'] as String? ?? '—',
      categoriaNome: cat['nome'] as String? ?? '—',
      usuarioNome: usr['nome'] as String?,
    );
  }
}
