import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/recurso.dart';
import '../services/api_client.dart';
import '../services/reservafans_api.dart';
import '../utils/validators.dart';
import '../widgets/error_view.dart';

/// Cadastro/edicao de recurso, com categoria dinamica e foto enviada do aparelho.
class ResourceFormScreen extends StatefulWidget {
  final Recurso? recurso;
  const ResourceFormScreen({super.key, this.recurso});

  @override
  State<ResourceFormScreen> createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends State<ResourceFormScreen> {
  final _api = ReservaFansApi();
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _qtd;
  late final TextEditingController _desc;

  List<Categoria> _categorias = [];
  int? _categoriaId;
  bool _carregandoCats = true;
  bool _salvando = false;
  String? _erro;

  XFile? _foto;
  List<int>? _fotoBytes;

  bool get _edicao => widget.recurso != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recurso;
    _nome = TextEditingController(text: r?.nome ?? '');
    _qtd = TextEditingController(text: '${r?.quantidadeTotal ?? 1}');
    _desc = TextEditingController(text: r?.descricao ?? '');
    _categoriaId = r?.categoriaId;
    _carregarCategorias();
  }

  @override
  void dispose() {
    _nome.dispose();
    _qtd.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    try {
      final cats = await _api.listarCategorias();
      if (!mounted) return;
      setState(() {
        _categorias = cats;
        _categoriaId ??= cats.isNotEmpty ? cats.first.id : null;
        _carregandoCats = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.message;
          _carregandoCats = false;
        });
      }
    }
  }

  Future<void> _novaCategoria() async {
    final ctrl = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova categoria'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome da categoria'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Adicionar')),
        ],
      ),
    );
    ctrl.dispose();
    if (nome == null || nome.isEmpty) return;
    try {
      final nova = await _api.criarCategoria(nome);
      if (!mounted) return;
      setState(() {
        _categorias = [..._categorias, nova]..sort((a, b) => a.nome.compareTo(b.nome));
        _categoriaId = nova.id;
      });
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  Future<void> _escolherFoto() async {
    final f = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (!mounted) return;
    setState(() {
      _foto = f;
      _fotoBytes = bytes;
    });
  }

  String _mimePorNome(String nome) {
    final n = nome.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await _api.salvarRecurso(
        id: widget.recurso?.id,
        campos: {
          'nome': _nome.text.trim(),
          'categoriaId': '$_categoriaId',
          'quantidadeTotal': _qtd.text.trim(),
          if (_desc.text.trim().isNotEmpty) 'descricao': _desc.text.trim(),
        },
        fotoBytes: _fotoBytes,
        fotoNome: _foto?.name,
        fotoMime: _foto == null ? null : _mimePorNome(_foto!.name),
      );
      if (!mounted) return;
      showSnack(context, _edicao ? 'Recurso atualizado.' : 'Recurso cadastrado.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_edicao ? 'Editar recurso' : 'Novo recurso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_erro != null) ErrorBanner(_erro!),
                  TextFormField(
                    controller: _nome,
                    decoration: const InputDecoration(
                        labelText: 'Nome', border: OutlineInputBorder()),
                    validator: (v) => Validators.obrigatorio(v, 'O nome'),
                  ),
                  const SizedBox(height: 14),
                  if (_carregandoCats)
                    const LinearProgressIndicator()
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _categoriaId,
                            decoration: const InputDecoration(
                                labelText: 'Categoria', border: OutlineInputBorder()),
                            items: [
                              for (final c in _categorias)
                                DropdownMenuItem(value: c.id, child: Text(c.nome)),
                            ],
                            onChanged: (v) => setState(() => _categoriaId = v),
                            validator: (v) => v == null ? 'Selecione uma categoria' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Nova categoria',
                          onPressed: _novaCategoria,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _qtd,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Quantidade total', border: OutlineInputBorder()),
                    validator: Validators.inteiroNaoNegativo,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _desc,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  if (_fotoBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(Uint8List.fromList(_fotoBytes!),
                          height: 160, fit: BoxFit.cover),
                    ),
                  OutlinedButton.icon(
                    onPressed: _escolherFoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(_foto == null ? 'Escolher foto (opcional)' : 'Trocar foto'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _salvando ? null : _salvar,
                    child: _salvando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_edicao ? 'Salvar alterações' : 'Cadastrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
