import 'dart:io';

import 'package:archive/archive.dart';
import 'package:internet_file/internet_file.dart';

// CHANGE THIS WHEN SWITCHING TO NEW VERSIONS!
const versionString = '2026.2.1';

const libName = 'ntcoreffi';
const baseDlLink =
    'https://frcmaven.wpi.edu/artifactory/release/edu/wpi/first/ntcoreffi/ntcoreffi-cpp/$versionString';

void main(List<String> args) async {
  String fileName;
  if (Platform.isWindows) {
    fileName = '$libName.dll';
  } else if (Platform.isMacOS) {
    fileName = 'lib$libName.dylib';
  } else {
    fileName = 'lib$libName.so';
  }

  // File which should have the binary.
  File f;
  if (Platform.isMacOS) {
    File f = File(Platform.script.resolve("../macos/Runner/$fileName").toFilePath());
  } else {
    File f = File(Platform.script.resolve("../$fileName").toFilePath());
  }
  // download for current platform if needed.
  if (!f.existsSync()) {
    print(
      'NTCoreFFI library not found, downloading for this platform to ${f.path}',
    );
    String downloadLink;
    if (Platform.isWindows) {
      downloadLink =
          '$baseDlLink/ntcoreffi-cpp-$versionString-windowsx86-64.zip';
    } else if (Platform.isMacOS) {
      downloadLink =
          '$baseDlLink/ntcoreffi-cpp-$versionString-osxuniversal.zip';
    } else {
      downloadLink = '$baseDlLink/ntcoreffi-cpp-$versionString-linuxx86-64.zip';
    }

    final bytes = await InternetFile.get(downloadLink);
    final archive = ZipDecoder().decodeBytes(bytes);
    final foundFile = archive.firstWhere((ArchiveFile f) {
      return f.name.endsWith(fileName);
    });

    f.createSync();
    f.writeAsBytesSync(foundFile.readBytes()!);
  } else {
    print('NTCoreFFI library already found at ${f.path}, nothing to do.');
  }
}
