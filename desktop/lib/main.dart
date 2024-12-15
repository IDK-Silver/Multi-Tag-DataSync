// import 'package:flutter/material.dart';
// import 'pages/file/file_page.dart';
// import 'pages/search_page.dart';
// import 'pages/settings_page.dart';
// import 'pages/account.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MTDS',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'MTDS Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 2;

//   final List<Widget> _pages = const [
//     FilePage(),
//     SearchPage(),
//     AccountPage(),
//     SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           NavigationRail(
//             selectedIndex: _selectedIndex,
//             onDestinationSelected: (int index) {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//             labelType: NavigationRailLabelType.none,
//             destinations: const [
//               NavigationRailDestination(
//                 icon: Icon(Icons.folder_outlined),
//                 selectedIcon: Icon(Icons.folder),
//                 label: Text('檔案'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.search_outlined),
//                 selectedIcon: Icon(Icons.search),
//                 label: Text('搜尋'),
//               ),
//               NavigationRailDestination(
//                   icon: Icon(Icons.account_box), label: Text('帳號')),
//               NavigationRailDestination(
//                 icon: Icon(Icons.settings_outlined),
//                 selectedIcon: Icon(Icons.settings),
//                 label: Text('設定'),
//               ),
//             ],
//           ),
//           const VerticalDivider(thickness: 1, width: 1),
//           Expanded(
//             child: _pages[_selectedIndex],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'pages/file/file_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/account.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 這個 widget 是您的應用程式的根
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MTDS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MTDS Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2;

  // 移除 const，確保頁面實例只被創建一次並保持狀態
  final List<Widget> _pages = [
    FilePage(),
    SearchPage(),
    AccountPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: Text('檔案'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text('搜尋'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_box),
                label: Text('帳號'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('設定'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // 使用 IndexedStack 保留頁面狀態
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
