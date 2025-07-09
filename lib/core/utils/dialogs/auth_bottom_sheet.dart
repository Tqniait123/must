import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/services/biometric_service.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class ImprovedAuthenticationSelectionSheet extends StatefulWidget {
  final Function(BiometricRecommendationType) onAuthMethodSelected;
  final Function() onCancel;

  const ImprovedAuthenticationSelectionSheet({super.key, required this.onAuthMethodSelected, required this.onCancel});

  @override
  State<ImprovedAuthenticationSelectionSheet> createState() => _ImprovedAuthenticationSelectionSheetState();
}

class _ImprovedAuthenticationSelectionSheetState extends State<ImprovedAuthenticationSelectionSheet>
    with TickerProviderStateMixin {
  List<AuthenticationMethodInfo> _authMethods = [];
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _loadAuthenticationMethods();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthenticationMethods() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final methods = await BiometricService.getAuthenticationCapabilities();

      // Create simplified two-option list
      final simplifiedMethods = _createSimplifiedMethods(methods);

      setState(() {
        _authMethods = simplifiedMethods;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = LocaleKeys.error_loading_auth_options.tr();
      });
    }
  }

  List<AuthenticationMethodInfo> _createSimplifiedMethods(List<AuthenticationMethodInfo> methods) {
    List<AuthenticationMethodInfo> simplifiedMethods = [];

    // 1. Create PIN option (always available)
    final pinMethod = AuthenticationMethodInfo(
      type: BiometricRecommendationType.pin,
      displayName: LocaleKeys.pin_authentication.tr(),
      description: LocaleKeys.use_pin_to_authenticate.tr(),
      icon: Icons.pin,
      isAvailable: true,
      isEnrolled: true,
      availableBiometricTypes: null,
    );
    simplifiedMethods.add(pinMethod);

    // 2. Create merged biometric option (face or fingerprint)
    final biometricMethods =
        methods
            .where(
              (method) =>
                  method.type == BiometricRecommendationType.faceRecognition ||
                  method.type == BiometricRecommendationType.faceId ||
                  method.type == BiometricRecommendationType.fingerprint,
            )
            .toList();

    if (biometricMethods.isNotEmpty) {
      final hasAvailableBiometric = biometricMethods.any((method) => method.canAuthenticate);
      final hasAnyAvailable = biometricMethods.any((method) => method.isAvailable);

      // Determine the primary biometric type to use for callback
      final primaryBiometricType =
          biometricMethods.firstWhere((method) => method.canAuthenticate, orElse: () => biometricMethods.first).type;

      final mergedBiometric = AuthenticationMethodInfo(
        type: primaryBiometricType,
        displayName: LocaleKeys.biometric_authentication.tr(),
        description: LocaleKeys.use_face_or_fingerprint.tr(),
        icon: Icons.fingerprint,
        isAvailable: hasAnyAvailable,
        isEnrolled: hasAvailableBiometric,
        availableBiometricTypes: biometricMethods.map((m) => m.type).toList(),
      );

      simplifiedMethods.add(mergedBiometric);
    }

    return simplifiedMethods;
  }

  Future<void> _handleAuthMethodSelection(AuthenticationMethodInfo method) async {
    if (!method.isAvailable) {
      _showErrorSnackBar(LocaleKeys.auth_method_not_available.tr());
      return;
    }

    if (method.needsSetup) {
      final shouldOpenSettings = await _showSetupDialog(method);
      if (shouldOpenSettings) {
        await BiometricService.openBiometricSettings(method.type);
        _loadAuthenticationMethods();
      }
      return;
    }

    if (method.canAuthenticate) {
      widget.onAuthMethodSelected(method.type);
    }
  }

  Future<bool> _showSetupDialog(AuthenticationMethodInfo method) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(LocaleKeys.setup_required.tr()),
              ],
            ),
            content: Text(LocaleKeys.setup_auth_method_message.tr().replaceAll('{authMethod}', method.displayName)),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(LocaleKeys.cancel.tr())),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(LocaleKeys.open_settings.tr()),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 48,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.security, color: primaryColor, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.choose_authentication_method.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.select_preferred_auth_method.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24), child: _buildContent()),
          ),

          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              ),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: TextStyle(color: Colors.red[600], fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAuthenticationMethods,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(LocaleKeys.retry.tr()),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Authentication methods (now only 2 options)
            ..._authMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutCubic,
                child: _buildAuthMethodTile(method),
              );
            }),

            const SizedBox(height: 32),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: widget.onCancel,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  LocaleKeys.cancel.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthMethodTile(AuthenticationMethodInfo method) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isAvailable = method.canAuthenticate;
    final needsSetup = method.needsSetup && method.isAvailable;

    Color backgroundColor;
    Color borderColor;
    Color iconColor;

    if (isAvailable) {
      backgroundColor = primaryColor.withOpacity(0.08);
      borderColor = primaryColor.withOpacity(0.3);
      iconColor = primaryColor;
    } else if (needsSetup) {
      backgroundColor = Colors.orange[50]!;
      borderColor = Colors.orange[200]!;
      iconColor = Colors.orange[600]!;
    } else {
      backgroundColor = Colors.grey[50]!;
      borderColor = Colors.grey[200]!;
      iconColor = Colors.grey[500]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleAuthMethodSelection(method),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                // Method icon with background
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildMethodIcon(method, iconColor),
                ),
                const SizedBox(width: 16),

                // Method info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method.description,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(method.status),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_getStatusIcon(method.status), color: iconColor, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodIcon(AuthenticationMethodInfo method, Color iconColor) {
    // For PIN authentication
    if (method.type == BiometricRecommendationType.pin) {
      return Icon(Icons.pin, color: iconColor, size: 24);
    }

    // For biometric methods - show combined icon if multiple types available
    if (method.availableBiometricTypes != null && method.availableBiometricTypes!.length > 1) {
      return Stack(
        children: [
          Icon(Icons.fingerprint, color: iconColor, size: 24),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Icon(Icons.face, color: iconColor, size: 12),
            ),
          ),
        ],
      );
    }

    return Icon(method.icon, color: iconColor, size: 24);
  }

  Color _getStatusColor(AuthenticationMethodStatus status) {
    switch (status) {
      case AuthenticationMethodStatus.availableAndEnrolled:
        return Theme.of(context).primaryColor;
      case AuthenticationMethodStatus.availableNotEnrolled:
        return Colors.orange[600]!;
      case AuthenticationMethodStatus.notAvailable:
        return Colors.grey[500]!;
    }
  }

  IconData _getStatusIcon(AuthenticationMethodStatus status) {
    switch (status) {
      case AuthenticationMethodStatus.availableAndEnrolled:
        return Icons.check_circle;
      case AuthenticationMethodStatus.availableNotEnrolled:
        return Icons.settings;
      case AuthenticationMethodStatus.notAvailable:
        return Icons.block;
    }
  }

  String _getStatusText(AuthenticationMethodStatus status) {
    switch (status) {
      case AuthenticationMethodStatus.availableAndEnrolled:
        return LocaleKeys.ready_to_use.tr();
      case AuthenticationMethodStatus.availableNotEnrolled:
        return LocaleKeys.tap_to_setup.tr();
      case AuthenticationMethodStatus.notAvailable:
        return LocaleKeys.not_available.tr();
    }
  }
}

// Extension to show the improved bottom sheet
extension ImprovedAuthenticationSelectionExtension on BuildContext {
  Future<BiometricRecommendationType?> showImprovedAuthenticationSelectionSheet() async {
    BiometricRecommendationType? selectedMethod;

    await showModalBottomSheet<void>(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder:
          (context) => ImprovedAuthenticationSelectionSheet(
            onAuthMethodSelected: (type) {
              selectedMethod = type;
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
    );

    return selectedMethod;
  }
}

// Extension to show the improved bottom sheet
extension ModernAuthenticationSelectionExtension on BuildContext {
  Future<BiometricRecommendationType?> showModernAuthenticationSelectionSheet() async {
    BiometricRecommendationType? selectedMethod;

    await showModalBottomSheet<void>(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder:
          (context) => ImprovedAuthenticationSelectionSheet(
            onAuthMethodSelected: (type) {
              selectedMethod = type;
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
    );

    return selectedMethod;
  }
}
