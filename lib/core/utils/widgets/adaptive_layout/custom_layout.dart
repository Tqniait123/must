import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';

class CustomLayout extends StatelessWidget {
  final List<Widget> children;
  final bool withPadding;
  final String? title;
  final bool? isNotification;
  final Widget? widget;
  const CustomLayout({
    super.key,
    required this.children,
    this.title,
    this.withPadding = true,
    this.isNotification = false,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,

      body: Container(
        color: AppColors.primary,
        alignment: AlignmentDirectional.topStart,
        child: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.topStart,
          children: [
            Positioned(
              // left: -100,
              top: -200,
              child: Opacity(
                opacity: 0.3,
                child: AppIcons.splashPattern.svg(
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  height: MediaQuery.sizeOf(context).height * 0.8,
                  // fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      title != null
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget ??
                                  Hero(
                                    tag: 'title',
                                    child: Text(
                                      title ?? '',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge!.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                              const SizedBox(width: 40),
                              if (isNotification == true)
                                GestureDetector(
                                  onTap: () {
                                    // context.push(Routes.notifications);
                                  },
                                  child: AppIcons.notificationsIc.icon(),
                                ),
                            ],
                          )
                          : Hero(
                            tag: 'header',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // CustomIconButton(
                                //   color: AppColors.white,
                                //   iconAsset: AppIcons.drawerIc,
                                //   onPressed: () {
                                //     // Open the drawer when the button is pressed
                                //     Constants.drawerKey.currentState
                                //         ?.openDrawer();
                                //   },
                                // ),
                                // AppIcons.logoHIc.svg(),
                                // GestureDetector(
                                //     onTap: () {
                                //       context.push(Routes.notification);
                                //     },
                                //     child: AppIcons.notificationsIc.icon())
                              ],
                            ),
                          ),
                ),
                const SizedBox(height: 200),
                Expanded(
                  child: AnimatedContainer(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 700),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SingleChildScrollView(
                        child:
                            withPadding
                                ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(children: children),
                                )
                                : Column(children: children),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
