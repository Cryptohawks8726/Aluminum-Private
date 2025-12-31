import 'package:driver_dashboard/ntcore/values.dart';
import 'package:driver_dashboard/ntreferences.dart';
import 'package:driver_dashboard/util.dart';
import 'package:flutter/material.dart';

class Default2CamDashboard extends StatefulWidget {
  const Default2CamDashboard({super.key});

  @override
  State<Default2CamDashboard> createState() => _Default2CamDashboardState();
}

class _Default2CamDashboardState extends State<Default2CamDashboard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        Column(
          spacing: 30,
          mainAxisAlignment: .center,
          children: [
            // these black containers are temporary
            // they will be replaced by mjpeg streams
            Container(
              color: Colors.black,
              width: 480,
              height: 360,
              padding: EdgeInsets.all(10),
              child: Text(
                "Cam 1",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Container(
              color: Colors.black,
              width: 480,
              height: 360,
              padding: EdgeInsets.all(10),
              child: Text(
                "Cam 2",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),

        SizedBox(width: 200),

        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          spacing: 30,
          children: [
            // timer
            Container(
              width: 300,
              height: 150,
              alignment: .center,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              child: ListenableBuilder(
                listenable: gameTimeNotifier,
                builder: (BuildContext context, Widget? child) {
                  var s = switch (gameTimeNotifier.currentValue) {
                    NTDoubleValue(:final value) => formatTime(
                      timeInSeconds: value.toInt(),
                    ),
                    _ => '-:--',
                  };
                  return Text(
                    s,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: .bold,
                    ),
                  );
                },
              ),
            ),

            // labels
            Row(
              spacing: 10,
              children: [
                LabelContainer(label: "label", data: "data"),
                LabelContainer(label: "longerlabel", data: "longerdata"),
                LabelContainer(label: "longestlabel!", data: "evenlongerdata"),
              ],
            ),

            // field view
            Container(
              color: Colors.blueGrey,
              width: 623,
              height: 350,
              child: Text("fled viw"),
            ),
          ],
        ),
      ],
    );
  }
}
