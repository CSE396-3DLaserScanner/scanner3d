import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:scanner3d/src/presentation/icons/scanner_icons.dart';
import 'package:scanner3d/src/presentation/pages/connection_page.dart';
import 'package:scanner3d/src/presentation/pages/current_scan_page.dart';
import 'package:scanner3d/src/presentation/pages/scan_list_page.dart';
import 'package:scanner3d/src/presentation/pages/splash_view_page.dart';
import 'package:scanner3d/src/presentation/widgets/connection_status_app_bar.dart';
import 'package:scanner3d/src/services/notification_service.dart';
import 'package:scanner3d/src/services/scan_provider.dart';
import 'package:scanner3d/src/services/socket_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

main() {
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

  @override
  void initState() {
    super.initState();
    NotificationService.initialize(flutterLocalNotificationsPlugin);
  }

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
        iconSize: 28,
        useLegacyColorScheme: false,
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
