import 'dart:io';

void main() {
  const String iconsPath = 'assets/images/icons';
  final Directory dir = Directory(iconsPath);

  if (!dir.existsSync()) {
    print('Directory does not exist');
    return;
  }

  final List<FileSystemEntity> files = dir.listSync();
  final List<String> icons = [];

  for (final FileSystemEntity entity in files) {
    if (entity is File && entity.path.endsWith('.svg')) {
      final String fileName = entity.uri.pathSegments.last;
      final String nameWithoutExtension = fileName.split('.').first;
      final String variableName = _toCamelCase(nameWithoutExtension);
      icons
          .add("static const String $variableName = '\$_iconsPath/$fileName';");
    }
  }

  final String classContent = '''
class AppIcons {
  static const String _iconsPath = '$iconsPath';
${icons.join('\n')}
}
''';

  const String outputFilePath = 'lib/core/static/icons.dart';
  final File outputFile = File(outputFilePath);
  outputFile.createSync(recursive: true); // Ensure the directory exists
  outputFile.writeAsStringSync(classContent);
  print('AppIcons class generated successfully at $outputFilePath.');
}

String _toCamelCase(String text) {
  final RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
  final List<String> words = text.split(regExp);
  if (words.isEmpty) return text;

  return words.map((word) {
    if (words.indexOf(word) == 0) {
      return word.toLowerCase();
    } else {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
  }).join();
}
