<img src="images/logo.png" style="width:30%; height:auto;"></img>
# 8726 DriverDashboard

Dashboard for 8726 drivers. Can communicate with the robot to send and receive info.

## Repo Structure

A basic template and any utilities which should be shared across different games should be kept on the main branch.
Separate branches are created for the specific configurations used for each game.
A checkout of allwpilib is also in the repo as a submodule - this should be updated from time to time.
This is used to build ntcore from source, the WPILib library which can run a NetworkTables client.
The FFI bindings used can be found in lib/ntcore and you can find the C api's documentation
[here](https://github.wpilib.org/allwpilib/docs/release/cpp/ntcore__c_8h.html).

## Building and Running

You can either compile the ntcore library from source using the submodule checkout in this repository
or use precompiled ntcoreffi binaries which can be found in [wpilib's maven releases](https://frcmaven.wpi.edu/ui/native/release/).
If using those binaries, place them in the repository's root. Setting the environment variable COMPILE_NTCORE will cause
the library to be build from source. You need the protobuf C++ library installed somewhere cmake will be able to find it
as a dependency.

Building from source is currently not supported on macos.

`flutter run` will run the project in debug mode and `flutter build {platform}`
will build and places a bundle in build/{platform}/{architecture}/{debug or release}/bundle
containing the executable and all project assets/libraries.
On macos, you'll need to install the [cocoapods](https://cocoapods.org/) package manager for xcode. To do this, you can use the [homebrew package manager](https://brew.sh/) (download it through github or through the terminal as shown on the website). Run `brew install cocoapods` in the terminal to install cocoapods, then run `pod setup` to complete the setup. You may need to restart your IDE and manually type `flutter run` after initially installing.

Other than that this is a normal flutter project and can run/hot reload/add packages as usual. Note that the dashboard will most likely be ran on windows; the linux and macos versions are mainly for development purposes.

## Getting Started

TODO
