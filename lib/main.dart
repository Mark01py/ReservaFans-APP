import 'package:flutter/material.dart';

import 'app.dart';
import 'state/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthState();
  await auth.init(); // restaura a sessao salva (persistencia) antes de abrir a primeira tela
  runApp(ReservaFansApp(auth: auth));
}
