import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservafans_app/models/recurso.dart';
import 'package:reservafans_app/models/reserva.dart';
import 'package:reservafans_app/utils/formatters.dart';
import 'package:reservafans_app/utils/validators.dart';

void main() {
  group('Validators', () {
    test('e-mail', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('prof@fans.edu.br'), isNull);
    });

    test('quantidade', () {
      expect(Validators.inteiroNaoNegativo('3'), isNull);
      expect(Validators.inteiroNaoNegativo('-1'), isNotNull);
      expect(Validators.inteiroNaoNegativo('x'), isNotNull);
    });

    test('horario de aula 18:50-22:25', () {
      expect(Validators.horarioAula(const TimeOfDay(hour: 18, minute: 50)), isNull);
      expect(Validators.horarioAula(const TimeOfDay(hour: 22, minute: 25)), isNull);
      expect(Validators.horarioAula(const TimeOfDay(hour: 18, minute: 49)), isNotNull);
      expect(Validators.horarioAula(const TimeOfDay(hour: 22, minute: 26)), isNotNull);
      expect(Validators.horarioAula(null), isNotNull);
    });
  });

  group('Formatadores', () {
    test('ISO com offset de Brasilia', () {
      expect(isoBrasilia(DateTime(2026, 11, 2), const TimeOfDay(hour: 18, minute: 50)),
          '2026-11-02T18:50:00-03:00');
    });
  });

  group('Models', () {
    test('Recurso.fromJson le categoria e estoque', () {
      final r = Recurso.fromJson({
        'id': 1,
        'nome': 'Projetor',
        'categoriaId': 3,
        'categoriaRef': {'id': 3, 'nome': 'Equipamento Audiovisual'},
        'quantidadeTotal': 5,
        'quantidadeDisponivel': 2,
      });
      expect(r.categoriaNome, 'Equipamento Audiovisual');
      expect(r.quantidadeDisponivel, 2);
    });

    test('Reserva atrasada', () {
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      final r = Reserva.fromJson({
        'id': 1,
        'status': 'em_uso',
        'dataInicio': ontem.subtract(const Duration(hours: 3)).toUtc().toIso8601String(),
        'dataFimPrevista': ontem.toUtc().toIso8601String(),
        'recurso': {'nome': 'Microfone'},
      });
      expect(r.atrasada, isTrue);
    });
  });
}
