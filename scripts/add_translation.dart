import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length != 3) {
    print('Usage: dart add_translation.dart <field_key> <english_translation> <arabic_translation>');
    exit(1);
  }

  final fieldKey = args[0];
  final englishTranslation = args[1];
  final arabicTranslation = args[2];

  final projectRoot = '${Directory.current.path}';
  final enPath = '$projectRoot/assets/translations/en.json';
  final arPath = '$projectRoot/assets/translations/ar.json';

  // Add to English file
  addTranslation(enPath, fieldKey, englishTranslation);
  
  // Add to Arabic file
  addTranslation(arPath, fieldKey, arabicTranslation);

  print('✅ Successfully added "$fieldKey" to translation files!');
}

void addTranslation(String filePath, String key, String value) {
  final file = File(filePath);
  
  if (!file.existsSync()) {
    print('Error: File not found: $filePath');
    exit(1);
  }

  // Read and parse the JSON file
  final jsonString = file.readAsStringSync();
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  
  // Add the new key-value pair
  jsonMap[key] = value;
  
  // Write the updated JSON back to the file with pretty printing
  final encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(jsonMap));
  
  print('Added "$key" to ${file.path.split('/').last}');
}
