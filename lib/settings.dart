import 'dart:convert';
import 'dart:io';

import 'package:driver_dashboard/ntreferences.dart';

class Settings {
  /// Global instance of settings containing all of the values.
  /// Initially attempts to load a stored config or uses default values.
  static Settings _instance = Settings();

  Settings();

  // this is C++ syntax they ported to dart <3
  /// Use this to get a copy of the current settings. When you're finished
  /// making changes, set it using Settings.overwriteSettings
  Settings.copyInstance()
    : useNamedServer = _instance.useNamedServer,
      serverName = _instance.serverName,
      teamNumber = _instance.teamNumber,
      port = _instance.port,
      cameraURLs = List.from(_instance.cameraURLs);

  static void overwriteSettings(Settings newSettings) {
    _instance = newSettings;
    // reload things that may need to change
    if (_instance.useNamedServer) {
      inst.updateServerNamePort(_instance.serverName, _instance.port);
    } else {
      inst.updateConnectionSettings(_instance.teamNumber, _instance.port);
    }
  }

  // Getters for all of the settings values so you can check settings
  // values
  /// If the instance should use a server name instead of port and team number.
  static bool get getUseNamedServer => _instance.useNamedServer;

  /// The name of the server to connect to. Only used if useNamedServer is true.
  static String get getServerName => _instance.serverName;

  static int get getTeamNumber => _instance.teamNumber;
  static int get getPort => _instance.port;

  /// List of URLs to all camera streams.
  static List<String> get getCameraURLs => _instance.cameraURLs;

  // RIO connection settings
  bool useNamedServer = true;
  String serverName = 'localhost';
  int teamNumber = 8726;
  int port = 5810;
  // Camera URLs (check if these defaults are sane)
  List<String> cameraURLs = const <String>[
    'http://10.87.26.11:5801',
    'http://10.87.26.10:5801',
  ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'useNamedServer': useNamedServer,
      'serverName': serverName,
      'teamNumber': teamNumber,
      'port': port,
      'cameraURLs': cameraURLs,
    };
  }

  static Settings? fromJson(Map<String, dynamic> json) {
    try {
      var settings = Settings();
      settings.useNamedServer = json['useNamedServer'];
      settings.teamNumber = json['teamNumber'];
      settings.port = json['port'];
      settings.serverName = json['serverName'];
      settings.cameraURLs = List<String>.from(json['cameraURLs']);
      return settings;
    } catch (_) {
      return null;
    }
  }

  static void exportJSONSettings(String filePath) {
    var s = jsonEncode(_instance.toJson());
    File(filePath).writeAsString(s, flush: true);
  }

  static bool tryLoadSettingsFromJSON(String filePath) {
    try {
      var maybeSettings = Settings.fromJson(
        jsonDecode(File(filePath).readAsStringSync()),
      );
      if (maybeSettings != null) {
        overwriteSettings(maybeSettings);
      } else {
        print('bad decode');
        return false;
      }
      return true;
    } catch (_) {
      print('bad file');
      return false;
    }
  }
}
