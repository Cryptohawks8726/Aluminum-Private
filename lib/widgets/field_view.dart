import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_size_getter/file_input.dart' show FileInput;
import 'package:image_size_getter/image_size_getter.dart'
    show ImageSizeGetter, SizeResult;
import '../ntreferences.dart';
import '../ntcore/values.dart';
import 'dart:math' as math;

// Constants to update per game.
// Double check coordinates please! Make sure there's actually an origin in the bottom left
// and adjust the code if there isn't.
// FRC Field dimensions in meters
const double fieldLengthMeters = 16.54;
const double fieldWidthMeters = 8.21;
// Path to the field image file.
const String fieldImagePath = "images/2026-field.png";
// Position of the origin and size of the field, in pixels
const double fieldOriginX = 255, fieldOriginY = 1920;
const double fieldSizeX = 2938, fieldSizeY = 1469;

// Calculated values from the constants to save time later.
// Manually inputed field size (4000x1927)
const Size fieldImageSize = Size(4196, 2035);

// Same as the other constants just divided by image size
final double fieldOriginRatioX = fieldOriginX / fieldImageSize.width;
final double fieldOriginRatioY = fieldOriginY / fieldImageSize.height;
final double fieldSizeRatioX = fieldSizeX / fieldImageSize.width;
final double fieldSizeRatioY = fieldSizeY / fieldImageSize.height;

class FieldViewWidget extends StatefulWidget {
  const FieldViewWidget({super.key});

  @override
  State<FieldViewWidget> createState() => _FieldViewWidgetState();
}

class _FieldViewWidgetState extends State<FieldViewWidget> {
  List<double> robotPosition = [0, 0, 0]; // x, y, rotation

  @override
  void initState() {
    super.initState();

    // Listen to robot position updates from NetworkTables
    robotPosNotifier.addListener(_updateRobotPosition);
  }

  @override
  void dispose() {
    robotPosNotifier.removeListener(_updateRobotPosition);
    super.dispose();
  }

  void _updateRobotPosition() {
    setState(() {
      final currentVal = robotPosNotifier.currentValue;
      if (currentVal is NTDoubleArrayValue) {
        final posArray = currentVal.value;
        robotPosition = [
          posArray.isNotEmpty ? posArray[0] : 0.0,
          posArray.length > 1 ? posArray[1] : 0.0,
          posArray.length > 2 ? posArray[2] : 0.0,
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Theme.of(context).colorScheme.onPrimary;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Field View',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'X: ${robotPosition[0].toStringAsFixed(2)}m  Y: ${robotPosition[1].toStringAsFixed(2)}m  θ: ${robotPosition[2].toStringAsFixed(1)}°',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          // The actual field - stack of the image and everything that needs to be drawn on it.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double scaleX =
                    constraints.maxWidth / fieldImageSize.width;
                final double scaleY =
                    constraints.maxHeight / fieldImageSize.height;
                // image scale factor to fit within the box
                final double scale = math.min(scaleX, scaleY);
                final Size scaledSize = Size(
                  fieldImageSize.width * scale,
                  fieldImageSize.height * scale,
                );
                return Align(
                  alignment: .center,
                  child: Stack(
                    children: [
                      Image.asset(
                        fieldImagePath,
                        width: scaledSize.width,
                        height: scaledSize.height,
                      ),
                      CustomPaint(
                        size: scaledSize,
                        painter: FieldPainter(robotPosition: robotPosition),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FieldPainter extends CustomPainter {
  final List<double> robotPosition;

  FieldPainter({required this.robotPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final x =
        (fieldOriginRatioX +
            robotPosition[0] / fieldLengthMeters * fieldSizeRatioX) *
        size.width;
    // note that Y is flipped since in FRC origin is usually bottom left
    final y =
        (fieldOriginRatioY -
            robotPosition[1] / fieldWidthMeters * fieldSizeRatioY) *
        size.height;

    _drawRobot(canvas, x, y, robotPosition[2]);
  }

  void _drawRobot(Canvas canvas, double x, double y, double rotation) {
    final double robotWidth = 30;
    final double robotHeight = 30;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-rotation * math.pi / 180);

    final robotPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: robotWidth,
        height: robotHeight,
      ),
      robotPaint,
    );

    final robotBorderPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: robotWidth,
        height: robotHeight,
      ),
      robotBorderPaint,
    );

    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(0, -robotHeight / 2);
    arrowPath.lineTo(robotWidth / 4, -robotHeight / 3);
    arrowPath.lineTo(-robotWidth / 4, -robotHeight / 3);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);

    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, 3, centerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(FieldPainter oldDelegate) {
    return oldDelegate.robotPosition != robotPosition;
  }
}
