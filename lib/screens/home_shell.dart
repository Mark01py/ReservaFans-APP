import 'package:flutter/material.dart';

import '../state/auth_state.dart';
import '../widgets/error_view.dart';
import 'admin_dashboard_screen.dart';
import 'admin_resources_screen.dart';
import 'admin_returns_screen.dart';
import 'catalog_screen.dart';
import 'my_reservations_screen.dart';

/// Estrutura principal: abas diferentes para usuario e administrador (niveis de acesso).
class HomeShell extends StatefulWidget {
  final AuthState auth;
  const HomeShell({super.key, required this.auth});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  List<NavigationDestination> get _destinos => widget.auth.isAdmin
      ? const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Painel'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Recursos'),
          NavigationDestination(icon: Icon(Icons.assignment_return_outlined), label: 'Devoluções'),
        ]
      : const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Catálogo'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), label: 'Minhas reservas'),
        ];

  Widget get _pagina {
    if (widget.auth.isAdmin) {
      switch (_indice) {
        case 1:
          return const AdminResourcesScreen();
        case 2:
          return const AdminReturnsScreen();
        default:
          return const AdminDashboardScreen();
      }
    }
    return _indice == 1 ? const MyReservationsScreen() : const CatalogScreen();
  }

  Future<void> _sair() async {
    final ok = await confirmar(context, 'Sair', 'Deseja sair da sua conta?');
    if (ok) await widget.auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.auth.usuario!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.auth.isAdmin ? 'ReservaFans · Admin' : 'ReservaFans'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(u.nome.split(' ').first),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      // Sem IndexedStack: cada aba e recriada ao ser aberta e busca dados atualizados na API.
      body: _pagina,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: _destinos,
      ),
    );
  }
}
