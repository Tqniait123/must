import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

/// Configuration class for HTML rendering customization
class HtmlConfig {
  final Color? primaryColor;
  final Color? textColor;
  final double? fontSize;
  final double? lineHeight;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final Function(String url)? onLinkTap;
  final Map<String, Style>? customStyles;
  final bool cleanHtml;
  final bool showDebugLogs;

  const HtmlConfig({
    this.primaryColor,
    this.textColor,
    this.fontSize = 16,
    this.lineHeight = 1.6,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.boxShadow,
    this.backgroundColor = Colors.white,
    this.onLinkTap,
    this.customStyles,
    this.cleanHtml = true,
    this.showDebugLogs = false,
  });

  /// Create a copy of this config with updated values
  HtmlConfig copyWith({
    Color? primaryColor,
    Color? textColor,
    double? fontSize,
    double? lineHeight,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    Function(String url)? onLinkTap,
    Map<String, Style>? customStyles,
    bool? cleanHtml,
    bool? showDebugLogs,
  }) {
    return HtmlConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      onLinkTap: onLinkTap ?? this.onLinkTap,
      customStyles: customStyles ?? this.customStyles,
      cleanHtml: cleanHtml ?? this.cleanHtml,
      showDebugLogs: showDebugLogs ?? this.showDebugLogs,
    );
  }
}

/// Extension to convert HTML strings to Flutter widgets
extension HtmlExtension on String {
  /// Convert HTML string to a Flutter widget with customizable styling
  Widget toHtml({BuildContext? context, HtmlConfig? config}) {
    final htmlConfig = config ?? const HtmlConfig();

    try {
      // Clean HTML if enabled
      final processedHtml = htmlConfig.cleanHtml ? _cleanHtmlContent(htmlConfig.showDebugLogs) : this;

      if (htmlConfig.showDebugLogs) {
        print('Processed HTML: $processedHtml');
      }

      // Get theme colors if context is provided
      final primaryColor = htmlConfig.primaryColor ?? (context != null ? Theme.of(context).primaryColor : Colors.blue);
      final textColor = htmlConfig.textColor ?? (context != null ? Colors.grey[800] : Colors.grey[800]);

      // Build default styles
      final defaultStyles = _buildDefaultStyles(htmlConfig, primaryColor, textColor);

      // Merge with custom styles if provided
      final finalStyles = {...defaultStyles};
      if (htmlConfig.customStyles != null) {
        finalStyles.addAll(htmlConfig.customStyles!);
      }

      // Create the HTML widget
      final htmlWidget = Html(
        data: processedHtml,
        style: finalStyles,
        onLinkTap: (url, context, attributes) {
          if (url != null) {
            if (htmlConfig.onLinkTap != null) {
              htmlConfig.onLinkTap!(url);
            } else {
              _defaultLaunchUrl(url);
            }
          }
        },
      );

      // Wrap in container if styling is provided
      if (htmlConfig.backgroundColor != null || htmlConfig.borderRadius != null || htmlConfig.boxShadow != null) {
        return Container(
          decoration: BoxDecoration(
            color: htmlConfig.backgroundColor,
            borderRadius: htmlConfig.borderRadius,
            boxShadow:
                htmlConfig.boxShadow ??
                [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: ClipRRect(borderRadius: htmlConfig.borderRadius ?? BorderRadius.zero, child: htmlWidget),
        );
      }

      return htmlWidget;
    } catch (e) {
      if (htmlConfig.showDebugLogs) {
        print('Error rendering HTML: $e');
      }
      return _buildErrorWidget(e.toString(), htmlConfig);
    }
  }

  /// Convert HTML string to a simple text widget (strips HTML tags)
  Widget toHtmlText({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool cleanHtml = true,
  }) {
    try {
      final processedHtml = cleanHtml ? _cleanHtmlContent(false) : this;
      final document = html_parser.parse(processedHtml);
      final plainText = document.body?.text ?? processedHtml;

      return Text(plainText, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow);
    } catch (e) {
      return Text('Error parsing HTML: $e', style: style?.copyWith(color: Colors.red));
    }
  }

  /// Get plain text from HTML string
  String toPlainText({bool cleanHtml = true}) {
    try {
      final processedHtml = cleanHtml ? _cleanHtmlContent(false) : this;
      final document = html_parser.parse(processedHtml);
      return document.body?.text ?? processedHtml;
    } catch (e) {
      return this;
    }
  }

  /// Clean HTML content by removing escape characters and invalid attributes
  String _cleanHtmlContent(bool showDebugLogs) {
    try {
      // Step 1: Replace escaped characters
      String cleaned = replaceAll('\\"', '"')
          .replaceAll('\\/', '/')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('\\r\\n', '')
          .replaceAll('\\n', '')
          .replaceAll('\\t', '');

      // Step 2: Remove wrapping quotes if they exist
      if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }

      // Step 3: Parse HTML and clean up
      final document = html_parser.parse(cleaned);

      // Remove problematic attributes
      document.querySelectorAll('*').forEach((element) {
        element.attributes.removeWhere(
          (key, value) =>
              (key as String).startsWith('data-') ||
              (key).startsWith('on') || // Remove event handlers
              key == 'style', // Remove inline styles for consistency
        );
      });

      // Step 4: Convert back to HTML string
      cleaned = document.body?.innerHtml ?? cleaned;

      // Step 5: Decode remaining HTML entities
      cleaned = cleaned
          .replaceAll('&ndash;', '–')
          .replaceAll('&mdash;', '—')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&hellip;', '…')
          .replaceAll('&copy;', '©')
          .replaceAll('&reg;', '®')
          .replaceAll('&trade;', '™');

      if (showDebugLogs) {
        print('Original HTML length: $length');
        print('Cleaned HTML length: ${cleaned.length}');
        print('Cleaned HTML preview: ${cleaned.length > 200 ? '${cleaned.substring(0, 200)}...' : cleaned}');
      }

      return cleaned;
    } catch (e) {
      if (showDebugLogs) {
        print('Error cleaning HTML: $e');
      }
      return this; // Return original if cleaning fails
    }
  }

  /// Build default HTML styles
  Map<String, Style> _buildDefaultStyles(HtmlConfig config, Color primaryColor, Color? textColor) {
    return {
      "body": Style(
        fontSize: FontSize(config.fontSize!),
        lineHeight: LineHeight(config.lineHeight!),
        color: textColor,
        padding: HtmlPaddings.symmetric(
          horizontal: config.padding!.horizontal / 2,
          vertical: config.padding!.vertical / 2,
        ),
        margin: Margins.zero,
      ),
      "p": Style(margin: Margins.only(bottom: 12), fontSize: FontSize(config.fontSize!), color: textColor),
      "strong": Style(fontWeight: FontWeight.bold),
      "b": Style(fontWeight: FontWeight.bold),
      "em": Style(fontStyle: FontStyle.italic),
      "i": Style(fontStyle: FontStyle.italic),
      "a": Style(color: primaryColor, textDecoration: TextDecoration.underline),
      "h1": Style(
        fontSize: FontSize(config.fontSize! + 8),
        fontWeight: FontWeight.bold,
        color: primaryColor,
        margin: Margins.only(bottom: 16, top: 8),
      ),
      "h2": Style(
        fontSize: FontSize(config.fontSize! + 4),
        fontWeight: FontWeight.w600,
        color: textColor,
        margin: Margins.only(top: 20, bottom: 12),
      ),
      "h3": Style(
        fontSize: FontSize(config.fontSize! + 2),
        fontWeight: FontWeight.w600,
        color: textColor,
        margin: Margins.only(top: 16, bottom: 8),
      ),
      "h4": Style(
        fontSize: FontSize(config.fontSize!),
        fontWeight: FontWeight.w600,
        color: textColor,
        margin: Margins.only(top: 12, bottom: 6),
      ),
      "ul": Style(margin: Margins.only(left: 16, bottom: 12)),
      "ol": Style(margin: Margins.only(left: 16, bottom: 12)),
      "li": Style(margin: Margins.only(bottom: 8)),
      "blockquote": Style(
        backgroundColor: Colors.grey[100],
        padding: HtmlPaddings.all(16),
        border: Border(left: BorderSide(color: primaryColor, width: 4)),
        margin: Margins.only(left: 16, right: 16, bottom: 16),
        fontStyle: FontStyle.italic,
      ),
      "code": Style(
        backgroundColor: Colors.grey[200],
        padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
        fontSize: FontSize(config.fontSize! - 1),
        fontFamily: 'monospace',
      ),
      "pre": Style(
        backgroundColor: Colors.grey[100],
        padding: HtmlPaddings.all(12),
        margin: Margins.symmetric(vertical: 8),
        fontSize: FontSize(config.fontSize! - 1),
        fontFamily: 'monospace',
      ),
      "table": Style(margin: Margins.symmetric(vertical: 8)),
      "th": Style(backgroundColor: Colors.grey[200], padding: HtmlPaddings.all(8), fontWeight: FontWeight.bold),
      "td": Style(padding: HtmlPaddings.all(8), border: Border.all(color: Colors.grey[300]!)),
      "img": Style(margin: Margins.symmetric(vertical: 8)),
      "hr": Style(margin: Margins.symmetric(vertical: 16)),
    };
  }

  /// Build error widget when HTML rendering fails
  Widget _buildErrorWidget(String error, HtmlConfig config) {
    return Container(
      padding: config.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: config.borderRadius,
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 32),
          const SizedBox(height: 8),
          Text(
            'Failed to render HTML content',
            style: TextStyle(fontSize: config.fontSize, fontWeight: FontWeight.bold, color: Colors.red[700]),
          ),
          const SizedBox(height: 4),
          if (config.showDebugLogs)
            Text(
              error,
              style: TextStyle(fontSize: config.fontSize! - 2, color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  /// Default URL launcher
  static Future<void> _defaultLaunchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
