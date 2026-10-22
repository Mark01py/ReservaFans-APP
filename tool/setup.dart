// Gera as pastas de plataforma (android/ e web/) e prepara o projeto.
// Uso (na pasta do projeto):   dart tool/setup.dart
import 'dart:io';

Future<void> main() async {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln('Execute este script na pasta do projeto (onde esta o pubspec.yaml).');
    exit(1);
  }

  // 1) Guarda o codigo do projeto, pois o "flutter create" gera arquivos de exemplo.
  final backup = Directory.systemTemp.createTempSync('rf_overlay_');
  _copiar(Directory('lib'), Directory('${backup.path}/lib'));
  _copiar(Directory('test'), Directory('${backup.path}/test'));
  File('pubspec.yaml').copySync('${backup.path}/pubspec.yaml');

  // 2) Gera android/ e web/.
  await _rodar('flutter', [
    'create',
    '--project-name',
    'reservafans_app',
    '--org',
    'br.edu.fans',
    '--platforms=android,web',
    '.',
  ]);

  // 3) Restaura o codigo do ReservaFans por cima dos arquivos de exemplo.
  Directory('lib').deleteSync(recursive: true);
  Directory('test').deleteSync(recursive: true);
  _copiar(Directory('${backup.path}/lib'), Directory('lib'));
  _copiar(Directory('${backup.path}/test'), Directory('test'));
  File('${backup.path}/pubspec.yaml').copySync('pubspec.yaml');
  backup.deleteSync(recursive: true);

  // 4) Android: permissao de internet e HTTP sem TLS (a API local roda em http://).
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  var xml = manifest.readAsStringSync();
  if (!xml.contains('android.permission.INTERNET')) {
    xml = xml.replaceFirst('<application',
        '<uses-permission android:name="android.permission.INTERNET"/>\n    <application');
  }
  if (!xml.contains('usesCleartextTraffic')) {
    xml = xml.replaceFirst(
        '<application', '<application android:usesCleartextTraffic="true"');
  }
  manifest.writeAsStringSync(xml);

  // 5) Baixa as dependencias.
  await _rodar('flutter', ['pub', 'get']);

  stdout.writeln('\nPronto! Rode:  flutter run -d chrome   ou   flutter run -d <android>');
}

void _copiar(Directory origem, Directory destino) {
  destino.createSync(recursive: true);
  for (final e in origem.listSync()) {
    final nome = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (e is Directory) {
      _copiar(e, Directory('${destino.path}/$nome'));
    } else if (e is File) {
      e.copySync('${destino.path}/$nome');
    }
  }
}

Future<void> _rodar(String exe, List<String> args) async {
  final p = await Process.start(exe, args,
      runInShell: true, mode: ProcessStartMode.inheritStdio);
  final code = await p.exitCode;
  if (code != 0) exit(code);
}
