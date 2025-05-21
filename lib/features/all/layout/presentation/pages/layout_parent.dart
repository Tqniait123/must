import 'package:flutter/material.dart';
import 'package:must_invest/core/static/constants.dart';

class LayoutParent extends StatefulWidget {
  const LayoutParent({super.key});

  @override
  State<LayoutParent> createState() => _LayoutParentState();
}

class _LayoutParentState extends State<LayoutParent> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(); // Add this line

  final List<Widget> _pages = [
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  // final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: Constants.drawerKey,

      // drawer: const CustomDrawer(),
      body: SizedBox(
        child: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) {
            // if (index == 2) {
            //   // Constants.drawerKey.currentState!.openDrawer();
            // } else {
            setState(() {
              _currentIndex = index;
            });
            // }
          },
        ),
      ),
      // bottomNavigationBar: Hero(
      //   tag: 'button',
      //   child: SizedBox(
      //     // height: 90,
      //     child: BottomNavigationBar(
      //       showSelectedLabels: false,
      //       showUnselectedLabels: false,
      //       type: BottomNavigationBarType.fixed,
      //       unselectedIconTheme: const IconThemeData(size: 50),
      //       selectedIconTheme: const IconThemeData(size: 50),
      //       elevation: 0,
      //       currentIndex: _currentIndex,
      //       onTap: (index) {
      //         // if (index == 2) {
      //         //   // Constants.drawerKey.currentState!.openDrawer();
      //         // } else {
      //         _pageController.animateToPage(
      //           index,
      //           duration: const Duration(milliseconds: 300),
      //           curve: Curves.ease,
      //         );
      //         // }
      //       },
      //       items: [
      //         BottomNavigationBarItem(
      //           tooltip: 'Home',
      //           icon: CustomBottomNavigationBarItem(
      //             title: LocaleKeys.home.tr(), // Translate 'Home'
      //             iconPath: AppIcons.homeIc,
      //             iconFilledPath: AppIcons.homeFilledIc,
      //             isSelected: _currentIndex == 0,
      //             onTap:
      //                 () => setState(() {
      //                   _currentIndex = 0;
      //                   _pageController.animateToPage(
      //                     0,
      //                     duration: const Duration(milliseconds: 300),
      //                     curve: Curves.ease,
      //                   );
      //                 }),
      //           ),
      //           label: '',
      //         ),
      //         BottomNavigationBarItem(
      //           tooltip: 'Teen',
      //           icon: CustomBottomNavigationBarItem(
      //             title: LocaleKeys.home.tr(), // Translate 'Requests'
      //             iconPath: AppIcons.teenIc,
      //             iconFilledPath: AppIcons.teenFilledIc,
      //             isSelected: _currentIndex == 1,
      //             onTap:
      //                 () => setState(() {
      //                   _currentIndex = 1;
      //                   _pageController.animateToPage(
      //                     1,
      //                     duration: const Duration(milliseconds: 300),
      //                     curve: Curves.ease,
      //                   );
      //                 }),
      //           ),
      //           label: '',
      //         ),
      //         // const BottomNavigationBarItem(
      //         //   tooltip: '',
      //         //   icon: SizedBox.shrink(),
      //         //   label: '',
      //         // ),
      //         BottomNavigationBarItem(
      //           tooltip: 'Goals & Achievements',
      //           icon: CustomBottomNavigationBarItem(
      //             title:
      //                 LocaleKeys.home
      //                     .tr(), // Translate 'Chats'
      //             iconPath: AppIcons.goalsIc,
      //             iconFilledPath: AppIcons.goalsFilledIc,
      //             isSelected: _currentIndex == 2,
      //             onTap:
      //                 () => setState(() {
      //                   _currentIndex = 2;
      //                   _pageController.animateToPage(
      //                     2,
      //                     duration: const Duration(milliseconds: 300),
      //                     curve: Curves.ease,
      //                   );
      //                 }),
      //           ),
      //           label: '',
      //         ),
      //         BottomNavigationBarItem(
      //           tooltip: 'Subscriptions',
      //           icon: CustomBottomNavigationBarItem(
      //             title: LocaleKeys.home.tr(), // Translate 'Requests'
      //             iconPath: AppIcons.reportsIc,
      //             iconFilledPath: AppIcons.reportsFilledIc,
      //             isSelected: _currentIndex == 3,
      //             onTap:
      //                 () => setState(() {
      //                   _currentIndex = 3;
      //                   _pageController.animateToPage(
      //                     3,
      //                     duration: const Duration(milliseconds: 300),
      //                     curve: Curves.ease,
      //                   );
      //                 }),
      //           ),
      //           label: '',
      //         ),
      //         BottomNavigationBarItem(
      //           tooltip: 'Subscriptions',
      //           icon: CustomBottomNavigationBarItem(
      //             title: LocaleKeys.more.tr(), // Translate 'Requests'
      //             iconPath: AppIcons.moreIc,
      //             iconFilledPath: AppIcons.moreFilledIc,
      //             isSelected: _currentIndex == 4,
      //             onTap:
      //                 () => setState(() {
      //                   _currentIndex = 4;
      //                   _pageController.animateToPage(
      //                     4,
      //                     duration: const Duration(milliseconds: 300),
      //                     curve: Curves.ease,
      //                   );
      //                 }),
      //           ),
      //           label: '',
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
