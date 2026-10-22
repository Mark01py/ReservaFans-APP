import 'package:flutter/material.dart';

import '../models/relatorios.dart';
import '../services/reservafans_api.dart';
import '../widgets/error_view.dart';

class _DashData {
  final Resumo resumo;
  final List<ItemMaisSolicitado> ranking;
  const _DashData(this.resumo, this.ranking);
}

/// Painel do administrador: indicadores e itens mais solicitados (dados reais do banco).
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api = ReservaFansApi();
  late Future<_DashData> _dados;

  @override
  void initState() {
    super.initState();
    _dados = _carregar();
  }

  Future<_DashData> _carregar() async {
    final resumo = await _api.resumo();
    final ranking = await _api.maisSolicitados();
    return _DashData(resumo, ranking);
  }

  void _recarregar() => setState(() => _dados = _carregar());

  Widget _card(String titulo, int valor, {Color? cor}) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo.toUpperCase(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 6),
              Text('$valor',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: cor)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashData>(
      future: _dados,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return ErrorView(error: snap.error!, onRetry: _recarregar);
        final d = snap.data!;
        return RefreshIndicator(
          onRefresh: () async {
            _recarregar();
            try {
              await _dados;
            } catch (_) {}
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _card('Itens cadastrados', d.resumo.itensCadastrados),
                  _card('Em uso agora', d.resumo.emUsoAgora),
                  _card('Reservas hoje', d.resumo.reservasHoje),
                  _card('Devoluções atrasadas', d.resumo.devolucoesAtrasadas,
                      cor: d.resumo.devolucoesAtrasadas > 0 ? const Color(0xFFB3261E) : null),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Itens mais solicitados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (d.ranking.isEmpty)
                const EmptyView('Ainda não há reservas suficientes para o ranking.')
              else
                for (final item in d.ranking)
                  Card(
                    child: ListTile(
                      title: Text(item.nome),
                      subtitle: Text(item.categoriaNome),
                      trailing: Text('${item.total} reserva(s)',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
