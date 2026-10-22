import 'package:flutter/material.dart';

import '../models/recurso.dart';
import '../services/api_client.dart';
import '../services/reservafans_api.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/error_view.dart';
import 'catalog_screen.dart' show RecursoThumb;

enum _Modo { unica, periodo }

/// Cadastro: cria reservas (unica ou por periodo) enviando os dados para a API.
class ResourceDetailScreen extends StatefulWidget {
  final Recurso recurso;
  const ResourceDetailScreen({super.key, required this.recurso});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  final _api = ReservaFansApi();
  final _formUnica = GlobalKey<FormState>();
  final _formPeriodo = GlobalKey<FormState>();
  final _dataCtrl = TextEditingController();
  final _inicioCtrl = TextEditingController(text: '18:50');
  final _fimCtrl = TextEditingController(text: '22:25');
  final _dIniCtrl = TextEditingController();
  final _dFimCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  _Modo _modo = _Modo.unica;
  DateTime? _data;
  TimeOfDay? _inicio = const TimeOfDay(hour: 18, minute: 50);
  TimeOfDay? _fim = const TimeOfDay(hour: 22, minute: 25);
  DateTime? _dIni;
  DateTime? _dFim;
  bool _enviando = false;
  String? _erro;
  String? _dispTexto;
  bool _dispOk = true;

  @override
  void dispose() {
    for (final c in [_dataCtrl, _inicioCtrl, _fimCtrl, _dIniCtrl, _dFimCtrl, _obsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _escolherData(DateTime? atual) {
    final hoje = DateTime.now();
    final base = DateTime(hoje.year, hoje.month, hoje.day);
    return showDatePicker(
      context: context,
      initialDate: atual != null && !atual.isBefore(base) ? atual : base,
      firstDate: base,
      lastDate: base.add(const Duration(days: 365)),
    );
  }

  Future<void> _pickData() async {
    final d = await _escolherData(_data);
    if (d == null) return;
    setState(() {
      _data = d;
      _dataCtrl.text = fmtDate(d);
    });
    _checarDisponibilidade();
  }

  Future<void> _pickHora(bool inicio) async {
    final t = await showTimePicker(
      context: context,
      initialTime: (inicio ? _inicio : _fim) ??
          TimeOfDay(hour: inicio ? 18 : 22, minute: inicio ? 50 : 25),
    );
    if (t == null) return;
    setState(() {
      if (inicio) {
        _inicio = t;
        _inicioCtrl.text = fmtTod(t);
      } else {
        _fim = t;
        _fimCtrl.text = fmtTod(t);
      }
    });
    _checarDisponibilidade();
  }

  Future<void> _pickPeriodo(bool inicial) async {
    final d = await _escolherData(inicial ? _dIni : _dFim);
    if (d == null) return;
    setState(() {
      if (inicial) {
        _dIni = d;
        _dIniCtrl.text = fmtDate(d);
      } else {
        _dFim = d;
        _dFimCtrl.text = fmtDate(d);
      }
    });
  }

  String? _validarFim(String? _) {
    final base = Validators.horarioAula(_fim);
    if (base != null) return base;
    if (_inicio != null &&
        _fim!.hour * 60 + _fim!.minute <= _inicio!.hour * 60 + _inicio!.minute) {
      return 'A devolução deve ser depois do início';
    }
    return null;
  }

  bool get _unicaPronta =>
      _data != null &&
      Validators.horarioAula(_inicio) == null &&
      _validarFim(null) == null;

  Future<void> _checarDisponibilidade() async {
    if (!_unicaPronta) return;
    try {
      final d = await _api.disponibilidade(
        widget.recurso.id,
        isoBrasilia(_data!, _inicio!),
        isoBrasilia(_data!, _fim!),
      );
      if (!mounted) return;
      setState(() {
        _dispOk = d.disponivel;
        _dispTexto = d.disponivel
            ? '${d.quantidade} unidade(s) disponível(is) neste horário.'
            : 'Sem unidades disponíveis neste horário.';
      });
    } on ApiException {
      if (mounted) setState(() => _dispTexto = null);
    }
  }

  Future<void> _enviar() async {
    final form = _modo == _Modo.unica ? _formUnica : _formPeriodo;
    if (!form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      String msg;
      if (_modo == _Modo.unica) {
        await _api.criarReserva(
          recursoId: widget.recurso.id,
          inicioIso: isoBrasilia(_data!, _inicio!),
          fimIso: isoBrasilia(_data!, _fim!),
          observacoes: _obsCtrl.text.trim(),
        );
        msg = 'Reserva confirmada com sucesso!';
      } else {
        final total = await _api.criarReservaPeriodo(
          recursoId: widget.recurso.id,
          dataInicio: isoDate(_dIni!),
          dataFim: isoDate(_dFim!),
          observacoes: _obsCtrl.text.trim(),
        );
        msg = '$total reserva(s) criada(s) com sucesso!';
      }
      if (!mounted) return;
      showSnack(context, msg);
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recurso;
    return Scaffold(
      appBar: AppBar(title: const Text('Nova reserva')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    RecursoThumb(fotoUrl: r.fotoUrl, size: 88),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.categoriaNome.toUpperCase(),
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(r.nome,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                          if ((r.descricao ?? '').isNotEmpty) Text(r.descricao!),
                          const SizedBox(height: 4),
                          Text('Disponível agora: ${r.quantidadeDisponivel} de ${r.quantidadeTotal}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SegmentedButton<_Modo>(
                  segments: const [
                    ButtonSegment(value: _Modo.unica, label: Text('Reserva única')),
                    ButtonSegment(value: _Modo.periodo, label: Text('Por período')),
                  ],
                  selected: {_modo},
                  onSelectionChanged: (s) => setState(() {
                    _modo = s.first;
                    _erro = null;
                  }),
                ),
                const SizedBox(height: 8),
                const Text('As reservas só podem ser feitas no horário de aula (18:50 às 22:25).',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                if (_erro != null) ErrorBanner(_erro!),
                if (_modo == _Modo.unica) _formularioUnica() else _formularioPeriodo(),
                const SizedBox(height: 12),
                TextField(
                  controller: _obsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Observações (opcional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _enviando ? null : _enviar,
                  child: _enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Confirmar reserva'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoToque(TextEditingController c, String label, VoidCallback onTap,
      String? Function(String?)? validator, IconData icone) {
    return TextFormField(
      controller: c,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder(), suffixIcon: Icon(icone)),
    );
  }

  Widget _formularioUnica() {
    return Form(
      key: _formUnica,
      child: Column(
        children: [
          _campoToque(_dataCtrl, 'Data', _pickData,
              (v) => Validators.obrigatorio(v, 'A data'), Icons.calendar_today),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _campoToque(_inicioCtrl, 'Início', () => _pickHora(true),
                    (_) => Validators.horarioAula(_inicio), Icons.schedule),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campoToque(_fimCtrl, 'Devolução', () => _pickHora(false),
                    _validarFim, Icons.schedule),
              ),
            ],
          ),
          if (_dispTexto != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_dispTexto!,
                  style: TextStyle(
                      color: _dispOk ? const Color(0xFF1E7A34) : const Color(0xFFB3261E),
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _formularioPeriodo() {
    return Form(
      key: _formPeriodo,
      child: Column(
        children: [
          _campoToque(_dIniCtrl, 'Reservar de (data inicial)', () => _pickPeriodo(true),
              (v) => Validators.obrigatorio(v, 'A data inicial'), Icons.calendar_today),
          const SizedBox(height: 12),
          _campoToque(_dFimCtrl, 'Até (data final)', () => _pickPeriodo(false), (v) {
            final erro = Validators.obrigatorio(v, 'A data final');
            if (erro != null) return erro;
            if (_dIni != null && _dFim!.isBefore(_dIni!)) {
              return 'A data final deve ser igual ou posterior à inicial';
            }
            if (_dIni != null && _dFim!.difference(_dIni!).inDays > 89) {
              return 'O período máximo é de 90 dias';
            }
            return null;
          }, Icons.calendar_today),
          const SizedBox(height: 8),
          const Text(
              'Será criada uma reserva para cada dia do período, sempre das 18:50 às 22:25.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
