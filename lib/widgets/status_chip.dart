import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.reserva(String status, {bool atrasada = false}) {
    if (atrasada) {
      return const StatusChip(label: 'Atrasada', color: Color(0xFFB3261E));
    }
    final cores = {
      'ativa': const Color(0xFF1E7A34),
      'em_uso': const Color(0xFF2555BF),
      'devolvida': const Color(0xFF6B7280),
      'cancelada': const Color(0xFFB3261E),
    };
    return StatusChip(
      label: statusLabels[status] ?? status,
      color: cores[status] ?? const Color(0xFF6B7280),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
