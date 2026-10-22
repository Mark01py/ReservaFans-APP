import 'package:flutter/material.dart';

import '../models/reserva.dart';
import '../services/api_client.dart';
import '../services/reservafans_api.dart';
import '../utils/formatters.dart';
import '../widgets/error_view.dart';
import '../widgets/status_chip.dart';

/// Consulta + atualizacao da interface: lista as reservas do usuario e permite cancelar.
class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  static const _filtros = {
    null: 'Todas',
    'ativa': 'Ativas',
    'em_uso': 'Em uso',
    'devolvida': 'Devolvidas',
    'cancelada': 'Canceladas',
  };

  final _api = ReservaFansApi();
  String? _status;
  late Future<List<Reserva>> _reservas;

  @override
  void initState() {
    super.initState();
    _reservas = _api.minhasReservas();
  }

  void _recarregar() {
    setState(() => _reservas = _api.minhasReservas(status: _status));
  }

  Future<void> _cancelar(Reserva r) async {
    final ok = await confirmar(context, 'Cancelar reserva',
        'Deseja cancelar a reserva de "${r.recursoNome}"?');
    if (!ok) return;
    try {
      await _api.cancelarReserva(r.id);
      if (!mounted) return;
      showSnack(context, 'Reserva cancelada.');
      _recarregar();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            children: [
              for (final e in _filtros.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: _status == e.key,
                    onSelected: (_) {
                      _status = e.key;
                      _recarregar();
                    },
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Reserva>>(
            future: _reservas,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ErrorView(error: snap.error!, onRetry: _recarregar);
              }
              final lista = snap.data!;
              if (lista.isEmpty) {
                return const EmptyView('Nenhuma reserva encontrada para este filtro.');
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _recarregar();
                  try {
                    await _reservas;
                  } catch (_) {}
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: lista.length,
                  itemBuilder: (context, i) => _ReservaCard(
                    reserva: lista[i],
                    onCancelar: lista[i].emAberto ? () => _cancelar(lista[i]) : null,
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

class _ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final VoidCallback? onCancelar;
  const _ReservaCard({required this.reserva, this.onCancelar});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(reserva.recursoNome,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                StatusChip.reserva(reserva.status),
              ],
            ),
            Text(reserva.categoriaNome, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Início: ${fmtDateTime(reserva.dataInicio)}'),
            Text('Devolução prevista: ${fmtDateTime(reserva.dataFimPrevista)}'),
            if ((reserva.observacoes ?? '').isNotEmpty) Text('Obs.: ${reserva.observacoes}'),
            if (onCancelar != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancelar,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFB3261E)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
