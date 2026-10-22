import 'package:flutter/material.dart' show TimeOfDay;

String two(int n) => n.toString().padLeft(2, '0');
String fmtDate(DateTime d) => '${two(d.day)}/${two(d.month)}/${d.year}';
String fmtTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';
String fmtDateTime(DateTime d) => '${fmtDate(d)} ${fmtTime(d)}';
String isoDate(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';
String fmtTod(TimeOfDay t) => '${two(t.hour)}:${two(t.minute)}';

/// Junta data e hora no formato ISO com o deslocamento fixo de Brasilia
/// (-03:00), que e o que a API espera para validar o horario de aula.
String isoBrasilia(DateTime data, TimeOfDay hora) =>
    '${isoDate(data)}T${fmtTod(hora)}:00-03:00';

const statusLabels = {
  'ativa': 'Ativa',
  'em_uso': 'Em uso',
  'devolvida': 'Devolvida',
  'cancelada': 'Cancelada',
};
