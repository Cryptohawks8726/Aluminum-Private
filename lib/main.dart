import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:aluminum/screens/dash_2cam_default.dart';
import 'package:aluminum/screens/debug_screen.dart';
import 'package:aluminum/screens/motor_testing.dart';
import 'package:aluminum/screens/settings_screen.dart';
import 'package:aluminum/settings.dart';
import 'package:aluminum/util.dart';
import 'package:aluminum/widgets/auto_chooser.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setTitle('Aluminum');
  Settings.tryLoadUserSettings();
  runApp(const DriverDashboard());
}

class PageDestination {
  final String name;
  final Widget icon;
  final Widget page;

  const PageDestination({
    required this.name,
    required this.icon,
    required this.page,
  });
}

// More convenient place to edit all the pages in the app.
const pageList = <PageDestination>[
  PageDestination(
    name: 'Dashboard',
    icon: Icon(Icons.dashboard),
    page: Default2CamDashboard(),
  ),
  PageDestination(
    name: 'Debug Panel',
    icon: Icon(Icons.construction),
    page: DebugScreen(),
  ),
  PageDestination(
    name: 'Test Motors',
    icon: Icon(Icons.construction),
    page: MotorTestingScreen(),
  ),
  PageDestination(
    name: 'Settings',
    icon: Icon(Icons.settings),
    page: SettingsScreen(),
  ),
];

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: isRedAllianceNotifier,
      builder: (context, child) {
        bool isRed = switch (isRedAllianceNotifier.currentValue) {
          NTBooleanValue(:final value) => value,
          _ => false,
        };
        return MaterialApp(
          theme: isRed ? appRedTheme : appBlueTheme,
          debugShowCheckedModeBanner: false, // removes red debug banner
          home: Scaffold(
            key: scaffoldKey,
            // TODO: add navigation buttons and stuff surrounding the main dashboard widget
            body: Container(
              // container for screens
              // padding: EdgeInsets.all(30),
              child: pageList[selectedIndex].page,
            ),

            // drawer button (has since been moved to dashbaord)
            floatingActionButton: FloatingActionButton.small(
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
              child: Padding(
                padding: EdgeInsetsGeometry.all(4.0),
                child: Image.asset("images/logo.png"),
              ),
            ),

            // drawer
            endDrawer: NavigationDrawer(
              selectedIndex: selectedIndex,
              footer: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: AutoChooser(),
              ),

              onDestinationSelected: (int idx) {
                setState(() {
                  selectedIndex = idx;
                });
              },
              children: pageList
                  .map<Widget>((var page) {
                    return NavigationDrawerDestination(
                      label: Text(page.name),
                      icon: page.icon,
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
  }
}
