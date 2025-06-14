import 'package:flutter/material.dart';
import '../widgets/settings.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  // final int langId = AppSettings.getDefaultLanguage() as int;
  CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> navigations = [
    AppSettings.getNameValue('home_page'),
    AppSettings.getNameValue('bible_page'),
    AppSettings.getNameValue('catalogue_page'),
    AppSettings.getNameValue('listen_page'),
    AppSettings.getNameValue('account_page'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Theme.of(context).hintColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: navigations[0]),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: navigations[1]),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: navigations[2]),
        BottomNavigationBarItem(
          icon: Icon(Icons.headset),
          label: navigations[3],
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: navigations[4],
        ),
      ],
    );
  }
}

class ListenPage extends StatelessWidget {
  const ListenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Listen Page'));
  }
}
