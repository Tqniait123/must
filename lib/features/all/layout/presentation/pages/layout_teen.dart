import 'package:flutter/material.dart';
import 'package:must_invest/core/static/constants.dart';

class LayoutTeen extends StatefulWidget {
  const LayoutTeen({super.key});

  @override
  State<LayoutTeen> createState() => _LayoutTeenState();
}

class _LayoutTeenState extends State<LayoutTeen> {
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
      //           tooltip: 'Savings',
      //           icon: CustomBottomNavigationBarItem(
      //             title: LocaleKeys.home.tr(), // Translate 'Requests'
      //             iconPath: AppIcons.savingsIc,
      //             iconFilledPath: AppIcons.savingsFilledIc,
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
      //           tooltip: 'Learn & Earn',
      //           icon: CustomBottomNavigationBarItem(
      //             title: LocaleKeys.home.tr(), // Translate 'Chats'
      //             iconPath: AppIcons.outlineMoneyIc,
      //             iconFilledPath: AppIcons.filledMoneyIc,
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
      //           tooltip: 'Services',
      //           icon: CustomBottomNavigationBarItem(
      //             title: LocaleKeys.home.tr(), // Translate 'Requests'
      //             iconPath: AppIcons.outlinedServicesIc,
      //             iconFilledPath: AppIcons.filledServicesIc,
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
      //           tooltip: 'More',
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
