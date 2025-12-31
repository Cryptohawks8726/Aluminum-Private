import 'package:driver_dashboard/screens/dash_2cam_default.dart';
import 'package:flutter/material.dart';

void main() {
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
    page: Text('TODO'),
  ),
  PageDestination(
    name: 'Settings',
    icon: Icon(Icons.settings),
    page: Text('TODO'),
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
    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        // TODO: add navigation buttons and stuff surrounding the main dashboard widget
        body: Container(
          padding: EdgeInsets.all(30),

          child: pageList[selectedIndex].page,
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            scaffoldKey.currentState?.openEndDrawer();
          },
          child: Icon(Icons.settings),
        ),
        endDrawer: NavigationDrawer(
          selectedIndex: selectedIndex,
          children: pageList
              .map((var page) {
                return NavigationDrawerDestination(
                  label: Text(page.name),
                  icon: page.icon,
                );
              })
              .toList(growable: false),
          onDestinationSelected: (int idx) {
            setState(() {
              selectedIndex = idx;
            });
          },
        ),
      ),
    );
  }
}
