import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/recurso.dart';
import '../services/reservafans_api.dart';
import '../widgets/error_view.dart';
import 'resource_detail_screen.dart';

/// Consulta: lista os recursos (estoque) vindos da API, com filtro por categoria.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _api = ReservaFansApi();
  int? _categoriaId;
  late Future<List<Categoria>> _categorias;
  late Future<List<Recurso>> _recursos;

  @override
  void initState() {
    super.initState();
    _categorias = _api.listarCategorias();
    _recursos = _api.listarRecursos();
  }

  void _recarregar() {
    setState(() {
      _categorias = _api.listarCategorias();
      _recursos = _api.listarRecursos(categoriaId: _categoriaId);
    });
  }

  Future<void> _puxarParaAtualizar() async {
    _recarregar();
    try {
      await _recursos;
    } catch (_) {}
  }

  Future<void> _abrir(Recurso r) async {
    final reservou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ResourceDetailScreen(recurso: r)),
    );
    if (reservou == true) _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: FutureBuilder<List<Categoria>>(
            future: _categorias,
            builder: (context, snap) {
              final cats = snap.data ?? const <Categoria>[];
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Todas'),
                      selected: _categoriaId == null,
                      onSelected: (_) {
                        _categoriaId = null;
                        _recarregar();
                      },
                    ),
                  ),
                  for (final c in cats)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.nome),
                        selected: _categoriaId == c.id,
                        onSelected: (_) {
                          _categoriaId = c.id;
                          _recarregar();
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Recurso>>(
            future: _recursos,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ErrorView(error: snap.error!, onRetry: _recarregar);
              }
              final itens = snap.data!;
              if (itens.isEmpty) {
                return const EmptyView('Nenhum item cadastrado nesta categoria.');
              }
              return RefreshIndicator(
                onRefresh: _puxarParaAtualizar,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: itens.length,
                  itemBuilder: (context, i) => _RecursoCard(
                    recurso: itens[i],
                    onTap: () => _abrir(itens[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecursoThumb extends StatelessWidget {
  final String? fotoUrl;
  final double size;
  const RecursoThumb({super.key, required this.fotoUrl, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.assetUrl(fotoUrl);
    final placeholder = Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null
          ? placeholder
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}

class _RecursoCard extends StatelessWidget {
  final Recurso recurso;
  final VoidCallback onTap;
  const _RecursoCard({required this.recurso, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final semEstoque = recurso.quantidadeDisponivel <= 0;
    final cor = semEstoque ? const Color(0xFFB3261E) : const Color(0xFF1E7A34);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              RecursoThumb(fotoUrl: recurso.fotoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recurso.categoriaNome.toUpperCase(),
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(recurso.nome,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      semEstoque
                          ? 'Indisponível agora'
                          : '${recurso.quantidadeDisponivel} disponível(is) de ${recurso.quantidadeTotal}',
                      style: TextStyle(color: cor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
