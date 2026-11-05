import 'package:flutter/material.dart' show TimeOfDay;

/// Horario de aula: 18:50 as 22:25 (regra do sistema).
const int inicioAulaMin = 18 * 60 + 50;
const int fimAulaMin = 22 * 60 + 25;

bool dentroDoHorarioDeAula(TimeOfDay t) {
  final m = t.hour * 60 + t.minute;
  return m >= inicioAulaMin && m <= fimAulaMin;
}

class Validators {
  static String? obrigatorio(String? v, [String campo = 'Este campo']) {
    if (v == null || v.trim().isEmpty) return '$campo é obrigatório';
    return null;
  }

  static String? email(String? v) {
    final erro = obrigatorio(v, 'E-mail');
    if (erro != null) return erro;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim());
    return ok ? null : 'Informe um e-mail válido';
  }

  static String? senha(String? v) {
    if (v == null || v.isEmpty) return 'Senha é obrigatória';
    if (v.length < 3) return 'A senha deve ter ao menos 3 caracteres';
    return null;
  }

  static String? inteiroNaoNegativo(String? v, [String campo = 'Quantidade']) {
    final erro = obrigatorio(v, campo);
    if (erro != null) return erro;
    final n = int.tryParse(v!.trim());
    if (n == null) return '$campo deve ser um número inteiro';
    if (n < 0) return '$campo não pode ser negativa';
    return null;
  }

  static String? urlServidor(String? v) {
    final erro = obrigatorio(v, 'Endereço');
    if (erro != null) return erro;
    final uri = Uri.tryParse(v!.trim());
    final ok = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? null : 'Informe um endereco valido, iniciado por http:// ou https://';
  }

  static String? horarioAula(TimeOfDay? t) {
    if (t == null) return 'Informe o horário';
    if (!dentroDoHorarioDeAula(t)) return 'Use um horário entre 18:50 e 22:25';
    return null;
  }
}
