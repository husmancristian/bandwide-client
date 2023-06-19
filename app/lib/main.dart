import 'package:app/screens/connect.dart';

import 'screens/browse.dart';
import 'screens/following.dart';
import 'screens/search.dart';
import 'theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.instance;
    return ValueListenableBuilder<ColorScheme>(
        valueListenable: appTheme.currentColorScheme,
        builder: ((context, colorScheme, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData.from(colorScheme: colorScheme),
            home: MyHomePage(),
          );
        }));
  }
}

class MyHomePage extends StatefulWidget {
/////////////////////////////////////////TO-DO IMPLEMENT BACK
  static const List<BottomNavigationBarItem> navBarElements = [
    BottomNavigationBarItem(
      label: "Following",
      icon: Icon(Icons.favorite),
    ),
    BottomNavigationBarItem(
      label: "Browse",
      icon: Icon(Icons.dataset),
    ),
    BottomNavigationBarItem(
      label: "Search",
      icon: Icon(Icons.search),
    ),
    BottomNavigationBarItem(
      label: "Connect",
      icon: Icon(Icons.connected_tv),
    ),
  ];

  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int currentIndex;
  late List<Widget> navBarTabs;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    navBarTabs = [
      const Following(),
      const Browse(),
      const Search(),
      ConnectPage()
    ];
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.instance;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (index) => setState(() {
          currentIndex = index;
          pageController.jumpToPage(index);
        }),
        items: MyHomePage.navBarElements
            .map((e) => BottomNavigationBarItem(
                  icon: e.icon,
                  label: e.label,
                ))
            .toList(),
      ),
      floatingActionButton: ValueListenableBuilder<ColorScheme>(
          valueListenable: appTheme.currentColorScheme,
          builder: ((context, colorScheme, child) {
            return FloatingActionButton(
                onPressed: (() => {
                      appTheme.toggleTheme(),
                    }),
                child: appTheme.isDarkThemeApplied
                    ? const Icon(Icons.dark_mode)
                    : const Icon(Icons.light_mode));
          })),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: PageView(
        controller: pageController,
        children: navBarTabs,
      ),
    );
  }
}
