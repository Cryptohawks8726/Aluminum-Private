import 'package:driver_dashboard/ntcore/values.dart';
import 'package:driver_dashboard/ntreferences.dart';
import 'package:mjpeg_view/mjpeg_view.dart';
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
      mainAxisAlignment: .start,
      crossAxisAlignment: .center,
      children: [
        Column(
          spacing: 30,
          mainAxisAlignment: .center,
          children: [
            // limelight cameras are 4:3 aspect ratio
            MjpegView(
                width: 480,
                height: 360,
                errorWidget: cameraErrorWidget,
                uri: llCamUrls[0] ?? 'http://webcam01.ecn.purdue.edu/mjpg/video.mjpg',
              ),

            MjpegView(
              width: 480,
              height: 360,
              errorWidget: cameraErrorWidget,
              uri: llCamUrls[1] ?? 'http://webcam01.ecn.purdue.edu/mjpg/video.mjpg',
            ),
          ],
        ),

        SizedBox(width: 50),

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
              
              // timer text
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
