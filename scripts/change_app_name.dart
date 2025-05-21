import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart change_app_name.dart "New App Name"');
    exit(1);
  }

  final newAppName = args[0];
  print('Changing app name to: $newAppName');

  // Use rename package to update app name across platforms
  _updateAppName(newAppName);

  print('Successfully updated app name to: $newAppName');
}

void _updateAppName(String newAppName) {
  // Check if rename package is installed globally
  final result = Process.runSync('flutter', ['pub', 'global', 'list']);
  final output = result.stdout.toString();

  if (!output.contains('rename')) {
    print('Installing rename package globally...');
    final installResult = Process.runSync('flutter', [
      'pub',
      'global',
      'activate',
      'rename',
    ]);

    if (installResult.exitCode != 0) {
      print('Failed to install rename package. Error: ${installResult.stderr}');
      print(
        'Please install it manually with: flutter pub global activate rename',
      );
      exit(1);
    }

    print('Rename package installed successfully.');
  }

  // Update app name for Android and iOS platforms
  print('Updating app name for Android and iOS...');
  final setAppNameResult = Process.runSync('flutter', [
    'pub',
    'global',
    'run',
    'rename',
    'setAppName',
    '--targets',
    'android,ios',
    '--value',
    newAppName,
  ]);

  if (setAppNameResult.exitCode != 0) {
    print('Failed to update app name. Error: ${setAppNameResult.stderr}');
    exit(1);
  }

  print(setAppNameResult.stdout);

  // Update bundle ID in pubspec.yaml (optional)
  _updatePubspecName(newAppName);
}

void _updatePubspecName(String newAppName) {
  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    print('pubspec.yaml not found');
    return;
  }

  final content = pubspecFile.readAsStringSync();
  final updatedContent = content.replaceAll(
    RegExp(r'name: [^\n]+'),
    'name: ${newAppName.toLowerCase().replaceAll(' ', '_')}',
  );

  pubspecFile.writeAsStringSync(updatedContent);
  print('Updated project name in pubspec.yaml');
}
