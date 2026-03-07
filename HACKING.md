# Hacking
Guide for making code changes to the dashboard.

## How to use NTCore (or change it)
- The app should make a single instance of NTInstance (ntcore/instance.dart)
- Use updateConnectionSettings or updateServerNamePort to connect to a specific NT server.
- You can either connect to the rio via team number and port 5810, or to a sim using localhost:5810.
- The full auto-generated FFI bindings are in ntcore/ntcore.g.dart. However, you should not use these directly from the main dashbaord code - instead use or implement wrapper methods in NTInstance which handle things like native memory/pointers.
- The NTInstance keeps track of any entry handles in use to publish/subscribe to avoid memory leaks and keep publishers alive.
- The NetworkTablesValue class is a sealed class with subclasses for each value type in NT. You can use a switch statement to check what type a value is or use an if statement to check if it matches a certain type. Also, the toString method will return an appropriate string representation of the value, whatever type it is.
- The NTValueNotifier class is used to provide a ChangeNotifierProvider object which notifies listeners any time the value at a certain path in NetworkTables changes. Internally, NTInstance polls listeners and updates them in a loop, and this is how these updates are handed out.
- The easiest way to create new NTValueNotifiers is to use the .fromName factory, which either creates a new one or returns an existing listener for that entry.
- We keep most of the paths and notifiers (and the NTInstance) used as global variables in one file (lib/ntreferences.dart).
- NTCore uses pointers to the WPI_String struct for strings. You can convert to/from dart strings using toWpiString and wpiToDartString methods. If you don't have a pointer to a WPI_String struct you can also cast the str field to a Utf8 pointer and then call toDartString() with the length from the len field.
- There is also an NTPrefixNotifier class which tracks a map of all the values under a certain prefix.

## Where to find stuff
- lib/screens contains files for each one of the screens on the dashboard - the main dash, settings, motor tester panel, etc. Each just has a class extending Widget which contains all the logic for that screen.
- lib/widgets contains some specific widgets used such as the field view widget and the auto chooser widget.
- main.dart is the entry point and has the main app and scaffold as well as the side drawer. It also maintains a list of all the screens, labels, and icons for each one - if you're adding a new screen make sure to add it to that list.
- util.dart contains some random things
- settings.dart contains the logic for saving, loading, and accessing settings to/from json files.

## Specific guides
### Displaying custom values on the dashboard
- The NTValuesDisplay widget (lib/widgets/nt_values_display.dart) is used to display different widgets that show things like numbers or booleans in NT.
- There are some useful widgets already added, such as ones which show a number, boolean, string, or a number and change color depending on the value.
- These widgets are passed as a list in the constructor. This is called in lib/screens/main_dashboard.dart. You can search for NTValuesDisplay. The code from the general branch should have good examples.
### Displaying custom status lights on the dashboard
- Status lights are displayed on the right side of the dashboard screen.
- Right now, they're all set up in lib/screens/main_dashboard.dart. This might get moved out to another widget later if it gets complex enough.
- For now just add more widgets to the list of children (should be labeled with a comment saying "Status icons" or something like that)
### Adding to the soundboard
- add the desired sound to the sounds/ directory
- add the name and path to the sound to the list at the top of lib/screens/soundboard.dart
### Adding to the image gallery
- upload image/gif files into images/gallery
- add the file name to the list in the top of widgets/image_gallery.dart
