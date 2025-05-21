import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title = '',
    this.elevation = 0,
    this.hideDrawer = true,
    this.actions,
    required this.drawerKey,
    required this.profileImage,
  });

  final String title;
  final double? elevation;
  final bool hideDrawer;
  final List<Widget>? actions;
  final GlobalKey<ScaffoldState> drawerKey;
  final String profileImage;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      // actions: actions,
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.blue20),
      ),
      centerTitle: true,
      leading:
          !hideDrawer
              ? IconButton(
                icon: Icon(
                  Icons.menu, // Drawer Icon
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  drawerKey.currentState!.openDrawer();
                },
              )
              : null,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(profileImage),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
