import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:must_invest/core/static/icons.dart';

// =============================================================================
// LANGUAGE SELECTION DIALOG
// =============================================================================

/// Show language selection dialog
void showLanguageSelectionDialog({
  required BuildContext context,
  required Function(String languageCode) onLanguageSelected,
  required String currentLanguage,
}) {
  final List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: 'en',
      title: 'English',
      subtitle: 'English',
      flagAsset: AppIcons.en,
    ),
    LanguageOption(
      code: 'ar',
      title: 'العربية',
      subtitle: 'العربية',
      flagAsset: AppIcons.ar,
    ),
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Language options
              ...supportedLanguages.map((language) {
                final isSelected = language.code == currentLanguage;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onLanguageSelected(language.code);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue.withOpacity(0.1) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.blue 
                            : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Flag
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: ClipOval(
                            child: SvgPicture.asset(
                              language.flagAsset!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => Container(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Language info
                        Expanded(
                          child: Text(
                            language.title,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.black87,
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        
                        // Selection indicator
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 16),
              
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// =============================================================================
// LANGUAGE MODELS
// =============================================================================

/// Model class representing a language option
class LanguageOption {
  final String code; // Language code (e.g., 'en', 'ar')
  final String title; // Display name (e.g., 'English', 'العربية')
  final String subtitle; // Additional info (e.g., 'United States', 'مصر')
  final String? flagAsset; // Path to flag asset (optional)

  const LanguageOption({required this.code, required this.title, required this.subtitle, this.flagAsset});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LanguageOption && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'LanguageOption(code: $code, title: $title)';
}

/// Configuration class for customizing the language selector appearance
class LanguageSelectorConfig {
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final Color borderColor;
  final Color selectedBorderColor;
  final Color textColor;
  final Color selectedTextColor;
  final Color subtitleColor;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets itemPadding;
  final double flagSize;
  final TextStyle? textStyle;
  final TextStyle? subtitleStyle;
  final bool showSubtitle;
  final bool showFlag;
  final IconData dropdownIcon;

  const LanguageSelectorConfig({
    this.backgroundColor = const Color(0xFF1F1F1F),
    this.selectedBackgroundColor = const Color(0x1A007AFF),
    this.borderColor = const Color(0x4DFFFFFF),
    this.selectedBorderColor = const Color(0xFF007AFF),
    this.textColor = Colors.white,
    this.selectedTextColor = const Color(0xFF007AFF),
    this.subtitleColor = Colors.grey,
    this.iconColor = Colors.white,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.flagSize = 20.0,
    this.textStyle,
    this.subtitleStyle,
    this.showSubtitle = true,
    this.showFlag = true,
    this.dropdownIcon = Icons.keyboard_arrow_down,
  });

  LanguageSelectorConfig copyWith({
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? borderColor,
    Color? selectedBorderColor,
    Color? textColor,
    Color? selectedTextColor,
    Color? subtitleColor,
    Color? iconColor,
    double? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? itemPadding,
    double? flagSize,
    TextStyle? textStyle,
    TextStyle? subtitleStyle,
    bool? showSubtitle,
    bool? showFlag,
    IconData? dropdownIcon,
  }) {
    return LanguageSelectorConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedBackgroundColor: selectedBackgroundColor ?? this.selectedBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      textColor: textColor ?? this.textColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      itemPadding: itemPadding ?? this.itemPadding,
      flagSize: flagSize ?? this.flagSize,
      textStyle: textStyle ?? this.textStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      showSubtitle: showSubtitle ?? this.showSubtitle,
      showFlag: showFlag ?? this.showFlag,
      dropdownIcon: dropdownIcon ?? this.dropdownIcon,
    );
  }
}

// =============================================================================
// MAIN LANGUAGE SELECTOR WIDGET
// =============================================================================

/// A reusable language selector widget that can be customized for any app
///
/// Features:
/// - Dropdown style selection
/// - Customizable appearance
/// - Support for flag icons (SVG/PNG)
/// - Loading states
/// - Smooth animations
/// - Accessibility support
class LanguageSelector extends StatefulWidget {
  /// List of available language options
  final List<LanguageOption> languages;

  /// Currently selected language code
  final String selectedLanguageCode;

  /// Callback when language is selected
  final Function(String languageCode) onLanguageSelected;

  /// Visual configuration for the selector
  final LanguageSelectorConfig config;

  /// Whether the selector is in loading state
  final bool isLoading;

  /// Custom loading widget (optional)
  final Widget? loadingWidget;

  /// Whether to show only the language code in collapsed state
  final bool showOnlyCode;

  const LanguageSelector({
    super.key,
    required this.languages,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
    this.config = const LanguageSelectorConfig(),
    this.isLoading = false,
    this.loadingWidget,
    this.showOnlyCode = true,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> with SingleTickerProviderStateMixin {
  bool _isDropdownOpen = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get the currently selected language option
  LanguageOption get _selectedLanguage {
    return widget.languages.firstWhere(
      (lang) => lang.code == widget.selectedLanguageCode,
      orElse: () => widget.languages.first,
    );
  }

  /// Toggle dropdown visibility
  void _toggleDropdown() {
    if (widget.isLoading) return;

    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });

    if (_isDropdownOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// Handle language selection
  void _selectLanguage(String languageCode) {
    if (languageCode != widget.selectedLanguageCode && !widget.isLoading) {
      widget.onLanguageSelected(languageCode);
    }
    _closeDropdown();
  }

  /// Close the dropdown
  void _closeDropdown() {
    setState(() {
      _isDropdownOpen = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.config.padding,
              decoration: BoxDecoration(
                color: widget.config.backgroundColor,
                borderRadius: BorderRadius.circular(widget.config.borderRadius),
                border: Border.all(
                  color: _isDropdownOpen ? widget.config.selectedBorderColor : widget.config.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flag (if enabled and available)
                  if (widget.config.showFlag && _selectedLanguage.flagAsset != null)
                    _buildFlag(_selectedLanguage.flagAsset!),

                  if (widget.config.showFlag && _selectedLanguage.flagAsset != null) const SizedBox(width: 8),

                  // Language text
                  _buildLanguageText(),

                  const SizedBox(width: 4),

                  // Dropdown icon or loading indicator
                  _buildTrailingIcon(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build flag widget
  Widget _buildFlag(String flagAsset) {
    return Container(
      width: widget.config.flagSize,
      height: widget.config.flagSize,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.config.borderColor)),
      child: ClipOval(child: _buildFlagImage(flagAsset)),
    );
  }

  /// Build flag image (supports both SVG and regular images)
  Widget _buildFlagImage(String flagAsset) {
    if (flagAsset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        flagAsset,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => Container(color: Colors.grey.withOpacity(0.3)),
      );
    } else {
      return Image.asset(
        flagAsset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.withOpacity(0.3)),
      );
    }
  }

  /// Build language text
  Widget _buildLanguageText() {
    if (widget.showOnlyCode) {
      return Text(
        _selectedLanguage.code.toUpperCase(),
        style:
            widget.config.textStyle?.copyWith(color: widget.config.textColor) ??
            TextStyle(color: widget.config.textColor, fontSize: 12, fontWeight: FontWeight.w500),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedLanguage.title,
            style:
                widget.config.textStyle?.copyWith(color: widget.config.textColor) ??
                TextStyle(color: widget.config.textColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (widget.config.showSubtitle)
            Text(
              _selectedLanguage.subtitle,
              style:
                  widget.config.subtitleStyle?.copyWith(color: widget.config.subtitleColor) ??
                  TextStyle(color: widget.config.subtitleColor, fontSize: 11),
            ),
        ],
      );
    }
  }

  /// Build trailing icon (dropdown arrow or loading indicator)
  Widget _buildTrailingIcon() {
    if (widget.isLoading) {
      return widget.loadingWidget ??
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.config.iconColor),
            ),
          );
    }

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 3.14159, // π radians = 180 degrees
          child: Icon(widget.config.dropdownIcon, color: widget.config.iconColor, size: 16),
        );
      },
    );
  }
}

// =============================================================================
// LANGUAGE DROPDOWN OVERLAY
// =============================================================================

/// Overlay widget that shows the language options dropdown
class LanguageDropdownOverlay extends StatefulWidget {
  /// List of available language options
  final List<LanguageOption> languages;

  /// Currently selected language code
  final String selectedLanguageCode;

  /// Callback when language is selected
  final Function(String languageCode) onLanguageSelected;

  /// Callback when overlay should be dismissed
  final VoidCallback onDismiss;

  /// Visual configuration
  final LanguageSelectorConfig config;

  /// Position for the dropdown (optional, uses global positioning if null)
  final Offset? position;

  /// Width of the dropdown
  final double width;

  const LanguageDropdownOverlay({
    super.key,
    required this.languages,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
    required this.onDismiss,
    this.config = const LanguageSelectorConfig(),
    this.position,
    this.width = 160,
  });

  @override
  State<LanguageDropdownOverlay> createState() => _LanguageDropdownOverlayState();
}

class _LanguageDropdownOverlayState extends State<LanguageDropdownOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handle language selection
  void _selectLanguage(String languageCode) {
    widget.onLanguageSelected(languageCode);
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  /// Handle dismiss
  void _handleDismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleDismiss,
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Position the dropdown
            Positioned(
              top: widget.position?.dy ?? 100,
              right: 16,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      alignment: Alignment.topRight,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: widget.width,
                          decoration: BoxDecoration(
                            color: widget.config.backgroundColor,
                            borderRadius: BorderRadius.circular(widget.config.borderRadius),
                            border: Border.all(color: widget.config.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                widget.languages.map((language) {
                                  return _buildLanguageItem(language);
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual language item
  Widget _buildLanguageItem(LanguageOption language) {
    final isSelected = language.code == widget.selectedLanguageCode;

    return GestureDetector(
      onTap: () => _selectLanguage(language.code),
      child: Container(
        padding: widget.config.itemPadding,
        decoration: BoxDecoration(
          color: isSelected ? widget.config.selectedBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Flag
            if (widget.config.showFlag && language.flagAsset != null) ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.config.borderColor)),
                child: ClipOval(child: _buildFlagImage(language.flagAsset!)),
              ),
              const SizedBox(width: 12),
            ],

            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.title,
                    style: TextStyle(
                      color: isSelected ? widget.config.selectedTextColor : widget.config.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.config.showSubtitle)
                    Text(language.subtitle, style: TextStyle(color: widget.config.subtitleColor, fontSize: 11)),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected) Icon(Icons.check_circle, color: widget.config.selectedTextColor, size: 16),
          ],
        ),
      ),
    );
  }

  /// Build flag image (supports both SVG and regular images)
  Widget _buildFlagImage(String flagAsset) {
    if (flagAsset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        flagAsset,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => Container(color: Colors.grey.withOpacity(0.3)),
      );
    } else {
      return Image.asset(
        flagAsset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.withOpacity(0.3)),
      );
    }
  }
}

// =============================================================================
// COMPLETE LANGUAGE SELECTOR WITH DROPDOWN
// =============================================================================

/// Complete language selector widget with built-in dropdown functionality
/// This is the main widget you'll use in most cases
class CompleteLanguageSelector extends StatefulWidget {
  /// List of available language options
  final List<LanguageOption> languages;

  /// Currently selected language code
  final String selectedLanguageCode;

  /// Callback when language is selected
  final Function(String languageCode) onLanguageSelected;

  /// Visual configuration
  final LanguageSelectorConfig config;

  /// Whether the selector is in loading state
  final bool isLoading;

  /// Whether to show only the language code in collapsed state
  final bool showOnlyCode;

  const CompleteLanguageSelector({
    super.key,
    required this.languages,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
    this.config = const LanguageSelectorConfig(),
    this.isLoading = false,
    this.showOnlyCode = true,
  });

  @override
  State<CompleteLanguageSelector> createState() => _CompleteLanguageSelectorState();
}

class _CompleteLanguageSelectorState extends State<CompleteLanguageSelector> {
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  /// Show the dropdown overlay
  void _showDropdown() {
    if (widget.isLoading || _isDropdownOpen) return;

    setState(() {
      _isDropdownOpen = true;
    });

    _overlayEntry = OverlayEntry(
      builder:
          (context) => LanguageDropdownOverlay(
            languages: widget.languages,
            selectedLanguageCode: widget.selectedLanguageCode,
            onLanguageSelected: (languageCode) {
              widget.onLanguageSelected(languageCode);
              _hideDropdown();
            },
            onDismiss: _hideDropdown,
            config: widget.config,
            position: _getDropdownPosition(),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide the dropdown overlay
  void _hideDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  /// Calculate dropdown position
  Offset _getDropdownPosition() {
    // Get the RenderBox of the current widget
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      return Offset(position.dx, position.dy + renderBox.size.height + 8);
    }
    return const Offset(0, 100);
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDropdown,
      child: LanguageSelector(
        languages: widget.languages,
        selectedLanguageCode: widget.selectedLanguageCode,
        onLanguageSelected: widget.onLanguageSelected,
        config: widget.config,
        isLoading: widget.isLoading,
        showOnlyCode: widget.showOnlyCode,
      ),
    );
  }
}
