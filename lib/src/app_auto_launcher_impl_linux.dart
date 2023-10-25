import 'dart:io';

import 'package:launch_at_startup/src/app_auto_launcher.dart';
import 'package:path/path.dart' as p;

class AppAutoLauncherImplLinux extends AppAutoLauncher {
  AppAutoLauncherImplLinux({
    required String appName,
    required String appPath,
    List<String> args = const [],
  }) : super(appName: appName, appPath: appPath, args: args);

  String get _desktopFileName => p.normalize(
        p.join(
          Platform.environment['HOME']!,
          '..',
          '..',
          '..',
          '.config/autostart/$appName.desktop',
        ),
      );

  String get _tempFileName =>
      p.join(Platform.environment['HOME']!, '$appName.desktop');

  @override
  Future<bool> isEnabled() async {
    return File(_desktopFileName).existsSync();
  }

  @override
  Future<bool> enable() async {
    String contents = '''
[Desktop Entry]
Type=Application
Name=$appName
Comment=$appName startup script
Exec=${args.isEmpty ? appPath : '$appPath ${args.join(' ')}'}
StartupNotify=false
Terminal=false
''';
    File tempFile = File(_tempFileName);
    if (!tempFile.existsSync()) {
      tempFile.createSync(recursive: true);
    }
    tempFile.writeAsStringSync(contents);
    tempFile.renameSync(_desktopFileName);
    return true;
  }

  @override
  Future<bool> disable() async {
    File desktopFile = File(_desktopFileName);
    if (desktopFile.existsSync()) {
      desktopFile.deleteSync();
    }
    return true;
  }
}
