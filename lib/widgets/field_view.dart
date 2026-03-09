import 'dart:math' as math;

import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:flutter/material.dart';

// --- CONSTANTS ---
const double fieldLengthMeters = 16.54;
const double fieldWidthMeters = 8.21;
const String fieldImagePath = "images/2026-field.png";

// Same as the constants in the robot - 180 points forward.
// In degrees.
const double robotLeftTurretExtent = 90;
const double robotRightTurretExtent = 270;

// Field Image & Coordinates
const double fieldOriginX = 255, fieldOriginY = 1920;
const double fieldSizeX = 3672, fieldSizeY = 1781;
const Size fieldImageSize = Size(4196, 2035);

final double fieldOriginRatioX = fieldOriginX / fieldImageSize.width;
final double fieldOriginRatioY = fieldOriginY / fieldImageSize.height;
final double fieldSizeRatioX = fieldSizeX / fieldImageSize.width;
final double fieldSizeRatioY = fieldSizeY / fieldImageSize.height;

// Paint objects used for painting the things on the field.
final pointPaint = Paint()
  ..color = Colors.cyanAccent
  ..style = PaintingStyle.fill;
final selectedPaint = Paint()
  ..color = Colors.orangeAccent
  ..style = PaintingStyle.fill;
final pathPaint = Paint()
  ..color = Colors.cyan.withValues(alpha: 0.0)
  ..strokeWidth = 2
  ..style = PaintingStyle.stroke;
final displayPointPaint = Paint()
  ..color = Colors.green
  ..style = PaintingStyle.fill;

class FieldViewWidget extends StatefulWidget {
  const FieldViewWidget({super.key});

  @override
  State<FieldViewWidget> createState() => _FieldViewWidgetState();
}

class _FieldViewWidgetState extends State<FieldViewWidget> {
  List<double> robotPosition = [0, 0, -math.pi / 2.0];
  List<Offset> customWaypoints = [];
  List<Offset> displayPoints = [];
  int? _draggedPointIndex;

  @override
  void initState() {
    super.initState();
    robotPosNotifier.addListener(_updateRobotPosition);
    waypointsEntry.addListener(_updateWaypointsFromNT);
    displayPointsEntry.addListener(_updateDisplayPointsFromNT);
    _updateWaypointsFromNT();
    _updateRobotPosition();
  }

  @override
  void dispose() {
    robotPosNotifier.removeListener(_updateRobotPosition);
    waypointsEntry.removeListener(_updateWaypointsFromNT);
    displayPointsEntry.removeListener(_updateDisplayPointsFromNT);
    super.dispose();
  }

  // --- NT READ (Robot -> Dashboard) ---
  void _updateRobotPosition() {
    setState(() {
      final currentVal = robotPosNotifier.currentValue;
      if (currentVal is NTDoubleArrayValue) {
        final posArray = currentVal.value;
        robotPosition = [
          posArray.isNotEmpty ? posArray[0] : 0.0,
          posArray.isNotEmpty ? posArray[1] : 0.0,
          posArray.length >= 2 ? posArray[2] - math.pi / 2.0 : -math.pi / 2.0,
        ];
      }
    });
  }

  // copy-paste of waypoint updater, too lazy to clean this up.
  void _updateDisplayPointsFromNT() {
    final currentVal = displayPointsEntry.currentValue;
    if (currentVal is NTDoubleArrayValue) {
      final arr = currentVal.value;
      List<Offset> newPoints = [];
      // Parse [x, y, x, y...]
      for (int i = 0; i < arr.length; i += 2) {
        if (i + 1 < arr.length) {
          newPoints.add(Offset(arr[i], arr[i + 1]));
        }
      }
      setState(() {
        displayPoints = newPoints;
      });
    }
  }

  void _updateWaypointsFromNT() {
    // If user is dragging, ignore NT updates to prevent fighting
    if (_draggedPointIndex != null) return;

    final currentVal = waypointsEntry.currentValue;
    if (currentVal is NTDoubleArrayValue) {
      final arr = currentVal.value;
      List<Offset> newPoints = [];
      // Parse [x, y, x, y...]
      for (int i = 0; i < arr.length; i += 2) {
        if (i + 1 < arr.length) {
          newPoints.add(Offset(arr[i], arr[i + 1]));
        }
      }
      setState(() {
        customWaypoints = newPoints;
      });
    }
  }

  // --- NT WRITE (Dashboard -> Robot) ---
  void _sendWaypointsToNT() {
    List<double> flatList = [];
    for (var point in customWaypoints) {
      flatList.add(point.dx);
      flatList.add(point.dy);
    }
    // Sync dragged position back to robot
    inst.setEntryDoubleArray(waypointsPath, flatList);
  }

  // --- COORDINATE MATH ---
  Offset _pixelsToMeters(Offset pixelPos, Size scaledSize) {
    double clickRatioX = pixelPos.dx / scaledSize.width;
    double clickRatioY = pixelPos.dy / scaledSize.height;
    double metersX =
        ((clickRatioX - fieldOriginRatioX) / fieldSizeRatioX) *
        fieldLengthMeters;
    double metersY =
        ((fieldOriginRatioY - clickRatioY) / fieldSizeRatioY) *
        fieldWidthMeters;
    return Offset(metersX, metersY);
  }

  Offset _metersToPixels(Offset metersPos, Size scaledSize) {
    double px =
        (fieldOriginRatioX +
            metersPos.dx / fieldLengthMeters * fieldSizeRatioX) *
        scaledSize.width;
    double py =
        (fieldOriginRatioY -
            metersPos.dy / fieldWidthMeters * fieldSizeRatioY) *
        scaledSize.height;
    return Offset(px, py);
  }

  // --- INTERACTION ---
  int? _getPointIndexAt(Offset touchPixels, Size scaledSize) {
    const double hitRadius = 30.0;
    for (int i = 0; i < customWaypoints.length; i++) {
      Offset pointPixels = _metersToPixels(customWaypoints[i], scaledSize);
      if ((pointPixels - touchPixels).distance < hitRadius) {
        return i;
      }
    }
    return null;
  }

  void _onPanStart(DragStartDetails details, Size scaledSize) {
    int? index = _getPointIndexAt(details.localPosition, scaledSize);
    if (index != null) {
      setState(() {
        _draggedPointIndex = index;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size scaledSize) {
    if (_draggedPointIndex != null) {
      setState(() {
        customWaypoints[_draggedPointIndex!] = _pixelsToMeters(
          details.localPosition,
          scaledSize,
        );
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggedPointIndex != null) {
      _sendWaypointsToNT(); // Sync only on release
      setState(() {
        _draggedPointIndex = null;
      });
    }
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
                  'X: ${robotPosition[0].toStringAsFixed(2)}m  Y: ${robotPosition[1].toStringAsFixed(2)}m',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                FilledButton(
                  onPressed: () {
                    inst.setEntryBool(setZeroGyroPath, true);
                  },
                  child: Text(
                    'Reset Gyro',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double scaleX =
                    constraints.maxWidth / fieldImageSize.width;
                final double scaleY =
                    constraints.maxHeight / fieldImageSize.height;
                final double scale = math.min(scaleX, scaleY);
                final Size scaledSize = Size(
                  fieldImageSize.width * scale,
                  fieldImageSize.height * scale,
                );

                return Align(
                  alignment: .center,
                  child: GestureDetector(
                    // Only Pan (Drag) logic remains
                    onPanStart: (details) => _onPanStart(details, scaledSize),
                    onPanUpdate: (details) => _onPanUpdate(details, scaledSize),
                    onPanEnd: (details) => _onPanEnd(details),
                    child: Stack(
                      children: [
                        Image.asset(
                          fieldImagePath,
                          width: scaledSize.width,
                          height: scaledSize.height,
                        ),
                        CustomPaint(
                          size: scaledSize,
                          painter: FieldPainter(
                            robotPosition: robotPosition,
                            waypoints: customWaypoints,
                            displayPoints: displayPoints,
                            draggedIndex: _draggedPointIndex,
                          ),
                        ),
                      ],
                    ),
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
  final List<Offset> waypoints;
  final List<Offset> displayPoints;
  final int? draggedIndex;

  FieldPainter({
    required this.robotPosition,
    required this.waypoints,
    required this.displayPoints,
    this.draggedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw path
    if (waypoints.length > 1) {
      Path path = Path();
      for (int i = 0; i < waypoints.length; i++) {
        Offset px = _toScreen(waypoints[i], size);
        (i == 0) ? path.moveTo(px.dx, px.dy) : path.lineTo(px.dx, px.dy);
      }
      canvas.drawPath(path, pathPaint);
    }

    // Draw points
    for (int i = 0; i < waypoints.length; i++) {
      Offset px = _toScreen(waypoints[i], size);
      double radius = (i == draggedIndex) ? 8.0 : 6.0;
      canvas.drawCircle(
        px,
        radius,
        (i == draggedIndex) ? selectedPaint : pointPaint,
      );
    }

    // Draw display points
    for (int i = 0; i < displayPoints.length; i++) {
      Offset px = _toScreen(displayPoints[i], size);
      double radius = (i == draggedIndex) ? 8.0 : 6.0;
      canvas.drawCircle(px, radius, displayPointPaint);
    }

    // Draw Robot
    Offset robotPx = _toScreen(
      Offset(robotPosition[0], robotPosition[1]),
      size,
    );
    _drawRobot(canvas, robotPx.dx, robotPx.dy, robotPosition[2]);
  }

  Offset _toScreen(Offset meters, Size size) {
    final px =
        (fieldOriginRatioX + meters.dx / fieldLengthMeters * fieldSizeRatioX) *
        size.width;
    final py =
        (fieldOriginRatioY - meters.dy / fieldWidthMeters * fieldSizeRatioY) *
        size.height;
    return Offset(px, py);
  }

  void _drawRobot(Canvas canvas, double x, double y, double rotation) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-rotation);

    

    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 30, height: 30),
      Paint()..color = Colors.green,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 30, height: 30),
      Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, -15)
        ..lineTo(7.5, -10)
        ..lineTo(-7.5, -10)
        ..close(),
      Paint()..color = Colors.yellow,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(FieldPainter old) =>
      old.robotPosition != robotPosition ||
      old.waypoints != waypoints ||
      old.draggedIndex != draggedIndex;
}
