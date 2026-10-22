import 'package:flutter/material.dart';

import '../models/reserva.dart';
import '../services/api_client.dart';
import '../services/reservafans_api.dart';
import '../utils/formatters.dart';
import '../widgets/error_view.dart';
import '../widgets/status_chip.dart';

/// Controle de uso e devolucao: o administrador registra a devolucao dos itens.
class AdminReturnsScreen extends StatefulWidget {
  const AdminReturnsScreen({super.key});

  @override
  State<AdminReturnsScreen> createState() => _AdminReturnsScreenState();
}

class _AdminReturnsScreenState extends State<AdminReturnsScreen> {
  final _api = ReservaFansApi();
  late Future<List<Reserva>> _itens;

  @override
  void initState() {
    super.initState();
    _itens = _carregar();
  }

  Future<List<Reserva>> _carregar() async {
    final ativas = await _api.listarReservas(status: 'ativa');
    final emUso = await _api.listarReservas(status: 'em_uso');
    final todas = [...ativas, ...emUso]
      ..sort((a, b) => a.dataFimPrevista.compareTo(b.dataFimPrevista));
    return todas;
  }

  void _recarregar() => setState(() => _itens = _carregar());

  Future<void> _devolver(Reserva r) async {
    final ok = await confirmar(context, 'Registrar devolução',
        'Confirmar a devolução de "${r.recursoNome}" por ${r.usuarioNome ?? 'usuário'}?');
    if (!ok) return;
    try {
      await _api.registrarDevolucao(r.id);
      if (!mounted) return;
      showSnack(context, 'Devolução registrada.');
      _recarregar();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reserva>>(
      future: _itens,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return ErrorView(error: snap.error!, onRetry: _recarregar);
        final lista = snap.data!;
        if (lista.isEmpty) {
          return const EmptyView('Nenhum item reservado ou em uso no momento.');
        }
        return RefreshIndicator(
          onRefresh: () async {
            _recarregar();
            try {
              await _itens;
            } catch (_) {}
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final r = lista[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(r.recursoNome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                          StatusChip.reserva(r.status, atrasada: r.atrasada),
                        ],
                      ),
                      Text('Solicitante: ${r.usuarioNome ?? '—'}'),
                      Text('Início: ${fmtDateTime(r.dataInicio)}'),
                      Text('Devolução prevista: ${fmtDateTime(r.dataFimPrevista)}'),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () => _devolver(r),
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          label: const Text('Marcar devolvido'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
