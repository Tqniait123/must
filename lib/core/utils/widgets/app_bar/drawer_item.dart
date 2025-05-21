import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isSelected ? const Color(0xff232447) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: icon.icon(),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15.r,
          color: isSelected ? Colors.white : const Color(0xff535763),
        ),
      ),
      onTap: onTap, // Trigger the onTap callback
    );
  }
}
