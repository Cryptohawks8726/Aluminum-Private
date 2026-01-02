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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          // TODO: get correct team color and make a scheme out of it
          // seedColor: Color.fromARGB(0, 0, 0, 0),
          seedColor: Colors.indigo,
          brightness: .dark,
        ),

        textTheme: TextTheme(),
      ),
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

        // drawer
        endDrawer: NavigationDrawer(
          selectedIndex: selectedIndex,
          footer: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text('Selected Auto:'),
                // TODO: Swap for proper auto chooser widget
                DropdownButton(
                  onChanged: (val) {},
                  items: [
                    DropdownMenuItem(
                      value: 'SomeReallyLongAutoName',
                      child: Text('SomeReallyLongAutoName'),
                    ),
                    DropdownMenuItem(
                      value: 'OtherReallyLongAutoName',
                      child: Text('OtherReallyLongAutoName'),
                    ),
                  ],
                  value: 'SomeReallyLongAutoName',
                ),
              ],
            ),
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
  }
}
