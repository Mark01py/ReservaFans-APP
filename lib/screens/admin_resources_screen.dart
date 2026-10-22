import 'package:flutter/material.dart';

import '../models/recurso.dart';
import '../services/api_client.dart';
import '../services/reservafans_api.dart';
import '../widgets/error_view.dart';
import 'catalog_screen.dart' show RecursoThumb;
import 'resource_form_screen.dart';

/// Gestao de recursos (estoque): listar, cadastrar, editar e remover.
class AdminResourcesScreen extends StatefulWidget {
  const AdminResourcesScreen({super.key});

  @override
  State<AdminResourcesScreen> createState() => _AdminResourcesScreenState();
}

class _AdminResourcesScreenState extends State<AdminResourcesScreen> {
  final _api = ReservaFansApi();
  late Future<List<Recurso>> _recursos;

  @override
  void initState() {
    super.initState();
    _recursos = _api.listarRecursos();
  }

  void _recarregar() => setState(() => _recursos = _api.listarRecursos());

  Future<void> _abrirFormulario([Recurso? r]) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ResourceFormScreen(recurso: r)),
    );
    if (salvou == true) _recarregar();
  }

  Future<void> _remover(Recurso r) async {
    final ok = await confirmar(context, 'Remover recurso',
        'Remover "${r.nome}" do catálogo? As reservas já feitas são mantidas.');
    if (!ok) return;
    try {
      await _api.removerRecurso(r.id);
      if (!mounted) return;
      showSnack(context, 'Recurso removido.');
      _recarregar();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo recurso'),
      ),
      body: FutureBuilder<List<Recurso>>(
        future: _recursos,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return ErrorView(error: snap.error!, onRetry: _recarregar);
          final itens = snap.data!;
          if (itens.isEmpty) return const EmptyView('Nenhum recurso cadastrado ainda.');
          return RefreshIndicator(
            onRefresh: () async {
              _recarregar();
              try {
                await _recursos;
              } catch (_) {}
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: itens.length,
              itemBuilder: (context, i) {
                final r = itens[i];
                return Card(
                  child: ListTile(
                    leading: RecursoThumb(fotoUrl: r.fotoUrl, size: 52),
                    title: Text(r.nome),
                    subtitle: Text(
                        '${r.categoriaNome} · ${r.quantidadeDisponivel}/${r.quantidadeTotal} disponível(is)'),
                    onTap: () => _abrirFormulario(r),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
                      onPressed: () => _remover(r),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
