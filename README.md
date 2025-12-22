# DriverDashboard

Dashboard for 8726 drivers. Can communicate with the robot to send and receive info.

## Repo Structure

A basic template and any utilities which should be shared across different games should be kept on the main branch.
Separate branches are created for the specific configurations used for each game.
A checkout of allwpilib is also in the repo as a submodule - this should be updated from time to time.
This is used to build ntcore from source, the WPILib library which can run a NetworkTables client.
The FFI bindings used can be found in lib/ntcore and you can find the C api's documentation
[here](https://github.wpilib.org/allwpilib/docs/release/cpp/ntcore__c_8h.html).

## Getting Started

TODO

## Building and Running

On windows and linux, `flutter run` will run the project in debug mode and `flutter build`
will build and places a bundle in build/{platform}/{architecture}/{debug or release}/bundle
containing the executable and all project assets/libraries.

This builds the ntcore library from source along with the flutter project, so it make take a
minute the first time you run it.

On macos you must first download the ntcoreffi binary from [wpilib's maven releases](https://frcmaven.wpi.edu/ui/native/release/)
and place them in the build bundle - unless someone wants to fiddle with xcode to get it to build from source correctly
(should be doable).

Other than that this is a normal flutter project and can run/hot reload/add packages as usual.
