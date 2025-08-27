import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';

class UnifiedCard extends StatelessWidget {
  final bool isCollapsed;
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  const UnifiedCard({
    super.key,
    required this.child,
    this.isCollapsed = false,
    this.onTap,
    this.backgroundColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isCollapsed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            gradient:
                gradientColors != null
                    ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: gradientColors!)
                    : null,
            borderRadius: BorderRadius.circular(isCollapsed ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: isCollapsed ? 15 : 20,
                offset: Offset(0, isCollapsed ? 3 : 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isCollapsed ? 12 : 20),
          width: MediaQuery.sizeOf(context).width,
          child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(isCollapsed ? 12 : 16), child: child),
        ),
      ),
    );
  }
}

class UnifiedCardContent extends StatelessWidget {
  final bool isCollapsed;
  final String title;
  final String mainText;
  final String? subtitle;
  final Color accentColor;
  final Widget? actionButton;
  final IconData? icon;

  const UnifiedCardContent({
    super.key,
    required this.title,
    required this.mainText,
    required this.accentColor,
    this.isCollapsed = false,
    this.subtitle,
    this.actionButton,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          Row(
            children: [
              AnimatedScale(
                scale: isCollapsed ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  width: isCollapsed ? 3 : 4,
                  height: isCollapsed ? 36 : 48,
                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              SizedBox(width: isCollapsed ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedScale(
                      scale: isCollapsed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: AutoSizeText(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: isCollapsed ? 12 : 14,
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: isCollapsed ? 2 : 4),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedScale(
                            scale: isCollapsed ? 0.9 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: AutoSizeText(
                              mainText,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: isCollapsed ? 18 : 24,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(width: isCollapsed ? 6 : 8),
                          Flexible(
                            child: AnimatedScale(
                              scale: isCollapsed ? 0.9 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: AutoSizeText(
                                subtitle!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(fontSize: isCollapsed ? 12 : 14, color: accentColor),
                                maxLines: 1,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (icon != null && isCollapsed) ...[
                SizedBox(width: 8),
                AnimatedScale(
                  scale: isCollapsed ? 0.8 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(icon, color: accentColor, size: 16),
                ),
              ],
            ],
          ),
          if (!isCollapsed && actionButton != null) ...[
            SizedBox(height: 20),
            AnimatedScale(
              scale: isCollapsed ? 0.8 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: actionButton!,
            ),
          ],
        ],
      ),
    );
  }
}
