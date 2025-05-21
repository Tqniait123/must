import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

// ANSI color codes for terminal output
class ConsoleColors {
  static const String reset = '\x1B[0m';
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String brightGreen = '\x1B[92m';
  static const String brightCyan = '\x1B[96m';

  // Background colors
  static const String bgBlack = '\x1B[40m';
  static const String bgRed = '\x1B[41m';
  static const String bgGreen = '\x1B[42m';
  static const String bgYellow = '\x1B[43m';
  static const String bgBlue = '\x1B[44m';
  static const String bgMagenta = '\x1B[45m';
  static const String bgCyan = '\x1B[46m';
  static const String bgWhite = '\x1B[47m';

  // Text formatting
  static const String bold = '\x1B[1m';
  static const String underline = '\x1B[4m';
}

void main(List<String> args) async {
  print('${ConsoleColors.cyan}🌐 Dart Auto Translator ${ConsoleColors.reset}');
  print(
    '${ConsoleColors.yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${ConsoleColors.reset}',
  );

  if (args.isEmpty) {
    print(
      '${ConsoleColors.red}❌ Error: Missing arguments${ConsoleColors.reset}',
    );
    print(
      '${ConsoleColors.yellow}Usage: dart auto_translate.dart <english_text> [field_key]${ConsoleColors.reset}',
    );
    exit(1);
  }

  final englishText = args[0];

  print(
    '${ConsoleColors.cyan}⏳ Processing translation...${ConsoleColors.reset}',
  );

  // Generate field key if not provided
  final fieldKey =
      args.length > 1 && args[1].isNotEmpty
          ? args[1]
          : generateFieldKey(englishText);

  // Get Arabic translation using free method
  final arabicTranslation = await translateToArabic(englishText);

  final projectRoot = Directory.current.path;
  final enPath = '$projectRoot/assets/translations/en.json';
  final arPath = '$projectRoot/assets/translations/ar.json';

  // Add to English file
  addTranslation(enPath, fieldKey, englishText);

  // Add to Arabic file
  addTranslation(arPath, fieldKey, arabicTranslation);

  // Create and display the beautiful output table
  printTranslationTable(fieldKey, englishText, arabicTranslation);
}

// Generate a snake_case key from the English text
String generateFieldKey(String text) {
  // Convert to lowercase, replace spaces with underscores, remove special chars
  String key =
      text
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters
          .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
          .trim();

  // Limit key length
  if (key.length > 30) {
    key = key.substring(0, 30);
  }

  return key;
}

// Use completely free Google Translate API without API key
Future<String> translateToArabic(String text) async {
  try {
    // URL encode the text
    final encodedText = Uri.encodeComponent(text);
    final url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=ar&dt=t&q=$encodedText';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the response which is a nested JSON structure
      final List<dynamic> data = json.decode(response.body);
      final List<dynamic> translations = data[0];

      String arabicText = '';
      for (var translation in translations) {
        if (translation[0] != null) {
          arabicText += translation[0];
        }
      }

      return arabicText;
    } else {
      print(
        '${ConsoleColors.red}Translation API error (${response.statusCode}): ${response.body}${ConsoleColors.reset}',
      );
      print(
        '${ConsoleColors.yellow}Using placeholder Arabic translation. Please update manually.${ConsoleColors.reset}',
      );
      return '(ARABIC TRANSLATION NEEDED)';
    }
  } catch (e) {
    print('${ConsoleColors.red}Translation error: $e${ConsoleColors.reset}');
    print(
      '${ConsoleColors.yellow}Using placeholder Arabic translation. Please update manually.${ConsoleColors.reset}',
    );
    return '(ARABIC TRANSLATION NEEDED)';
  }
}

void addTranslation(String filePath, String key, String value) {
  final file = File(filePath);

  if (!file.existsSync()) {
    print(
      '${ConsoleColors.red}❌ Error: File not found: $filePath${ConsoleColors.reset}',
    );
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

  final fileName = filePath.split('/').last;
  print(
    '${ConsoleColors.green}✓ Added "${ConsoleColors.yellow}$key${ConsoleColors.green}" to ${ConsoleColors.cyan}$fileName${ConsoleColors.reset}',
  );
}

void printTranslationTable(
  String fieldKey,
  String englishText,
  String arabicText,
) {
  // Calculate table width based on text lengths
  final keyLength = fieldKey.length;
  final englishLength = englishText.length;
  final arabicLength = arabicText.length;

  final maxLength = math.max(math.max(keyLength, englishLength), arabicLength);
  final tableWidth = math.max(60, maxLength + 15); // Minimum width of 60 chars

  print(
    '\n${ConsoleColors.bgBlue}${ConsoleColors.white}${ConsoleColors.bold} 🎯 TRANSLATION ADDED SUCCESSFULLY ${ConsoleColors.reset}',
  );

  // Print the table header
  printTableDivider('╔', '═', '╗', tableWidth);
  printTableRow(
    '║',
    '${ConsoleColors.bold}Field Key${ConsoleColors.reset}',
    fieldKey,
    '║',
    tableWidth,
  );
  printTableDivider('╠', '═', '╣', tableWidth);

  // Print the English row
  printTableRow(
    '║',
    '${ConsoleColors.brightGreen}🇺🇸 English${ConsoleColors.reset}',
    englishText,
    '║',
    tableWidth,
  );

  // Print the Arabic row
  printTableRow(
    '║',
    '${ConsoleColors.brightCyan}🇸🇦 Arabic${ConsoleColors.reset}',
    arabicText,
    '║',
    tableWidth,
    rightAlign: true,
  );

  // Print the table footer
  printTableDivider('╚', '═', '╝', tableWidth);
}

void printTableDivider(String start, String middle, String end, int width) {
  print(
    '${ConsoleColors.yellow}$start${middle * (width - 2)}$end${ConsoleColors.reset}',
  );
}

void printTableRow(
  String start,
  String label,
  String content,
  String end,
  int width, {
  bool rightAlign = false,
}) {
  final contentLength = content.length;
  final labelLength = 12; // Fixed label column width

  final contentWidth = width - labelLength - 4; // -4 for margin spaces

  String contentDisplay;
  String alignment;

  if (contentLength > contentWidth) {
    // If content is too long, truncate it
    contentDisplay = '${content.substring(0, contentWidth - 3)}...';
  } else {
    contentDisplay = content;
  }

  if (rightAlign) {
    // For Arabic, right-align
    final spaces = contentWidth - contentLength;
    alignment = ' ' * spaces + contentDisplay;
  } else {
    // For English, left-align
    alignment = contentDisplay + ' ' * (contentWidth - contentLength);
  }

  print(
    '${ConsoleColors.yellow}$start${ConsoleColors.reset} $label ${ConsoleColors.yellow}|${ConsoleColors.reset} $alignment ${ConsoleColors.yellow}$end${ConsoleColors.reset}',
  );
}
