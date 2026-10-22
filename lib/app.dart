import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/auth_state.dart';

class ReservaFansApp extends StatefulWidget {
  final AuthState auth;
  const ReservaFansApp({super.key, required this.auth});

  @override
  State<ReservaFansApp> createState() => _ReservaFansAppState();
}

class _ReservaFansAppState extends State<ReservaFansApp> {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    widget.auth.addListener(_aoMudarSessao);
  }

  @override
  void dispose() {
    widget.auth.removeListener(_aoMudarSessao);
    super.dispose();
  }

  // Ao sair (ou se a sessao expirar), fecha telas empilhadas e volta ao login.
  void _aoMudarSessao() {
    if (!widget.auth.logado) {
      _navKey.currentState?.popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReservaFans',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6FED)),
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
      ),
      home: ListenableBuilder(
        listenable: widget.auth,
        builder: (context, _) => widget.auth.logado
            ? HomeShell(key: ValueKey(widget.auth.usuario!.id), auth: widget.auth)
            : LoginScreen(auth: widget.auth),
      ),
    );
  }
}
