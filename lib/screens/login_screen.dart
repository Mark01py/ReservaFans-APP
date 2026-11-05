import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/api_client.dart';
import '../state/auth_state.dart';
import '../utils/validators.dart';
import '../widgets/error_view.dart';

class LoginScreen extends StatefulWidget {
  final AuthState auth;
  const LoginScreen({super.key, required this.auth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _entrando = false;
  bool _ocultar = true;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _entrando = true;
      _erro = null;
    });
    try {
      await widget.auth.login(_email.text, _senha.text);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  Future<void> _configurarServidor() async {
    final controller = TextEditingController(text: ApiConfig.baseUrl);
    final formKey = GlobalKey<FormState>();
    final salvou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Servidor da API'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Endereço da API'),
                validator: Validators.urlServidor,
              ),
              const SizedBox(height: 8),
              const Text(
                'Servidor de producao:\n'
                'https://reservafans-api-production.up.railway.app/api\n\n'
                'O endereco pode ser alterado manualmente, se necessario.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ApiConfig.reset();
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Padrão'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ApiConfig.save(controller.text);
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (salvou == true && mounted) {
      showSnack(context, 'Servidor: ${ApiConfig.baseUrl}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.event_available, size: 56, color: Color(0xFF2F6FED)),
                    const SizedBox(height: 8),
                    Text('ReservaFans',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800, color: const Color(0xFF2F6FED))),
                    const SizedBox(height: 4),
                    const Text('Reserva de salas, auditórios e equipamentos da FANS',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    if (_erro != null) ErrorBanner(_erro!),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                          labelText: 'E-mail', border: OutlineInputBorder()),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _senha,
                      obscureText: _ocultar,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _ocultar = !_ocultar),
                        ),
                      ),
                      validator: Validators.senha,
                      onFieldSubmitted: (_) => _entrar(),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _entrando ? null : _entrar,
                      child: _entrando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Entrar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _configurarServidor,
                      icon: const Icon(Icons.settings_ethernet),
                      label: const Text('Configurar servidor'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
