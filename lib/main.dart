import 'dart:ui' show Size;

import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:aluminum/screens/gallery_screen.dart';
import 'package:aluminum/screens/main_dashboard.dart';
import 'package:aluminum/screens/debug_screen.dart';
import 'package:aluminum/screens/motor_testing.dart';
import 'package:aluminum/screens/settings_screen.dart';
import 'package:aluminum/screens/soundboard.dart';
import 'package:aluminum/settings.dart';
import 'package:aluminum/util.dart';
import 'package:aluminum/widgets/auto_chooser.dart';
import 'package:flutter/material.dart' hide Size;
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

bool appIsExpanded = false;
String versionString = '';

void main() async {
  JustAudioMediaKit.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  // await windowManager.setFullScreen(true);
  windowManager.setTitle('Aluminum');
  Settings.tryLoadUserSettings();

  // Get version string (slapped here since it was convenient)
  final pkgInfo = await PackageInfo.fromPlatform();
  versionString = pkgInfo.version;

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
final pageList = <PageDestination>[
  PageDestination(
    name: 'Dashboard',
    icon: Icon(Icons.dashboard),
    page: MainDashboard(),
  ),
  PageDestination(
    name: 'Debug Panel',
    icon: Icon(Icons.construction),
    page: DebugScreen(),
  ),
  PageDestination(
    name: 'Test Motors',
    icon: Icon(Icons.sports_esports),
    page: MotorTestingScreen(),
  ),
  PageDestination(
    name: 'Soundboard',
    icon: Icon(Icons.audio_file),
    page: SoundboardScreen(),
  ),
  PageDestination(
    name: 'Settings',
    icon: Icon(Icons.settings),
    page: SettingsScreen(),
  ),
  PageDestination(
    name: 'Image Gallery',
    icon: Icon(Icons.image),
    page: GalleryScreen(),
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
            floatingActionButton: Column(
              mainAxisSize: .min,
              spacing: 5.0,
              children: [
                FloatingActionButton.small(
                  onPressed: () async {
                    if (appIsExpanded) {
                      windowManager.setTitleBarStyle(TitleBarStyle.normal);
                    } else {
                      await windowManager.setTitleBarStyle(
                        TitleBarStyle.hidden,
                      );
                      // maximizing for some reasons sets the position correctly, idfk windows
                      // await windowManager.maximize(vertically: false);

                      // mysterious await to get it to stop breaking
                      // await windowManager.getSize();

                      Size size = getDockedWindowSize();
                      double scale = windowManager.getDevicePixelRatio();
                      size = Size(size.width / scale, size.height / scale);
                      await windowManager.setSize(size);
                      await windowManager.setPosition(Offset.zero);
                    }
                    appIsExpanded = !appIsExpanded;
                  },
                  child: Icon(Icons.expand),
                ),
                FloatingActionButton.small(
                  onPressed: () {
                    scaffoldKey.currentState?.openEndDrawer();
                  },
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(4.0),
                    child: Image.asset("images/logo.png"),
                  ),
                ),
              ],
            ),

            // drawer
            endDrawer: NavigationDrawer(
              selectedIndex: selectedIndex,
              footer: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    AutoChooser(),
                    const Divider(),
                    Text('Aluminum Version: $versionString'),
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
      },
    );
  }
}
