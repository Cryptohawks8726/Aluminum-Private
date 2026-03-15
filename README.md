<img src="images/logo.png" style="width:30%; height:auto;"></img>

# Aluminum

Dashboard for 8726 drivers. Can communicate with the robot to send and receive info.

## Features

- Main dashboard screen with cameras, a view of the field, and widgets to display custom values
- Motor test panel designed to work with MotorTesting code
  - Set custom motor voltages for multiple different motors to test prototypes
  - Read built in encoder position/velocity values
  - Can also play sounds on TalonFX devices via uploading a .chrp file
- Soundboard to tank team productivity
- Image Gallery for fun :3
- Debug panel to view and edit values for each subsystem

## Repo Structure

A basic template and any utilities which should be shared across different games should be kept on the main branch.
Separate branches are created for the specific configurations used for each game.
A checkout of allwpilib is also in the repo as a submodule - this should be updated from time to time.
This is used to build ntcore from source, the WPILib library which can run a NetworkTables client.
The FFI bindings used can be found in lib/ntcore and you can find the C api's documentation
[here](https://github.wpilib.org/allwpilib/docs/release/cpp/ntcore__c_8h.html).

## NTCore Bindings & Running FFIGen

This project uses dart FFI bindings to interface with the NTCore library, part of WPILib. This library has a C API
which can easily be called from other languages, like dart. Dart bindings were automatically generated using the ffigen
package, creating lib/ntcore/ntcore.g.dart. The main app code shouldn't directly use these bindings - instead,
go through the classes provided in lib/ntcore/instance.dart, which have all been documented and have methods which can
safely and easily be called from dart without interacting with native memory. You can easily add extra methods to NTInstance
or create another class if you need to access other parts of the C library which do not currently have safe dart bindings written
for them.

In order to regenerate the bindings, run tool/ffigen.dart (`dart run tool/ffigen.dart`). You may need to provide the location
of the C standard library headers, which it for some reason can't find sometimes (linux error, no clue if this happens on windows :P ),
so locate wherever those headers are on your
system and set your CPATH environment variable to that or temporarily add it to the compiler arguments in tool/ffigen.dart.

You may need to update the bindings if WPILib changes or adds to the NTCore C API. To do this, download the headers (the easiest
place to get them is [wpilib's maven releases](https://frcmaven.wpi.edu/ui/native/release). Go to the ntcoreffi releases, where there
is a .zip file containing all the headers. Unzip all the NTCore headers into ntcore_headers/include, replacing the old files. Then,
follow the above instructions to regenerate the bindings, and make sure there are no new errors and implement any new functionality.

## Building & Running

This project relies on the ntcoreffi binaries published by WPILib to interface with the ntcore library.
These binaries can be downloaded from [wpilib's maven releases](https://frcmaven.wpi.edu/ui/native/release), however, there is also
a script in this project to automatically download them for you. It's in tool/download_ntcore.dart - run it using `dart run tool/download_ntcore.dart`.

`flutter run` will run the project in debug mode and `flutter build {platform}`
will build and places a bundle in build/{platform}/{architecture}/{debug or release}/bundle
containing the executable and all project assets/libraries.
On macos, you'll need to install the [cocoapods](https://cocoapods.org/) package manager for xcode. To do this, you can use the [homebrew package manager](https://brew.sh/) (download it through github or through the terminal as shown on the website). Run `brew install cocoapods` in the terminal to install cocoapods, then run `pod setup` to complete the setup. You may need to restart your IDE and manually type `flutter run` after initially installing.

Windows additionally requires enabling developer mode to allow flutter to create symlinks. Thanks, Microslop.

Other than that this is a normal flutter project and can run/hot reload/add packages as usual. Note that the dashboard will most likely be ran on windows; the linux and macos versions are mainly for development purposes.

## Building installers

Building installers and publishing them to GitHub releases is an easy way
to get the app onto different laptops and will create start menu shortcuts automatically.

First, build the project normally (`flutter build windows --release`).
Installers are built using NSIS and the setup.nsi script in the repository root.
The fastest way to downloaded NSIS is using winget: `winget install NSIS.NSIS`.
Then, run the installed NSIS app and select "Compile NSI scripts", then open
the setup.nsi file in this repository. An installer will be produced in the build directory.

Please remember to update the version number when publishing new releases -
all you need to do is change the number at the top of pubspec.yaml!

## Maintenance and Adding Features

- If the NTCore C API ever changes or gets new features, you may need to regenerate the FFI bindings.
- You should update the version of NTCore used by the downloader script (tool/download_ntcore.dart) and delete/redownload the new binaries when a new version of WPILib releases.
- See HACKING.md at the root of this repo for more info on making code edits.

## TODO:
- Screen record during matches
- Support reading NT logs
- Make logo.png a square so it doesn't look squished on windows
- Improve performance? Seems to lag sometimes
