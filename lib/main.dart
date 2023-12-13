import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanner3d/src/presentation/icons/scanner_icons.dart';
import 'package:scanner3d/src/presentation/pages/connection_page.dart';
import 'package:scanner3d/src/presentation/pages/current_scan_page.dart';
import 'package:scanner3d/src/presentation/pages/scan_list_page.dart';
import 'package:scanner3d/src/presentation/pages/splash_view_page.dart';
import 'package:scanner3d/src/presentation/widgets/connection_status_app_bar.dart';
import 'package:scanner3d/src/services/scan_provider.dart';
import 'package:scanner3d/src/services/socket_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => SocketService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanner 3D',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 36, 161, 157),
        disabledColor: const Color.fromARGB(255, 193, 29, 29),
      ),
      home: const SplashViewPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pageOptions = <Widget>[
    const ConnectionPage(),
    const CurrentScanPage(),
    const ScanListPage()
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConnectionStatusAppBar(),
      body: _pageOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Scanner.svg),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Your Scans',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 36, 161, 157),
        onTap: _onItemTapped,
      ),
    );
  }
}
