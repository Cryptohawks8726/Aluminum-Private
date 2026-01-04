import 'package:flutter/material.dart';
import '../ntreferences.dart';
import '../ntcore/values.dart';
import 'dart:math' as math;

// FRC Field dimensions in meters
const double fieldLengthMeters = 16.54;
const double fieldWidthMeters = 8.21;

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
          posArray.length > 0 ? posArray[0] : 0.0,
          posArray.length > 1 ? posArray[1] : 0.0,
          posArray.length > 2 ? posArray[2] : 0.0,
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'X: ${robotPosition[0].toStringAsFixed(2)}m  Y: ${robotPosition[1].toStringAsFixed(2)}m  θ: ${robotPosition[2].toStringAsFixed(1)}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: FieldPainter(
                    robotPosition: robotPosition,
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
    final double scaleX = size.width / fieldLengthMeters;
    final double scaleY = size.height / fieldWidthMeters;
    final double scale = math.min(scaleX, scaleY) * 0.95;

    final double offsetX = (size.width - (fieldLengthMeters * scale)) / 2;
    final double offsetY = (size.height - (fieldWidthMeters * scale)) / 2;

    final fieldPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        offsetX,
        offsetY,
        fieldLengthMeters * scale,
        fieldWidthMeters * scale,
      ),
      fieldPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(
        offsetX,
        offsetY,
        fieldLengthMeters * scale,
        fieldWidthMeters * scale,
      ),
      borderPaint,
    );

    final centerLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(offsetX + (fieldLengthMeters * scale / 2), offsetY),
      Offset(offsetX + (fieldLengthMeters * scale / 2), offsetY + (fieldWidthMeters * scale)),
      centerLinePaint,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i < fieldLengthMeters.toInt(); i++) {
      canvas.drawLine(
        Offset(offsetX + (i * scale), offsetY),
        Offset(offsetX + (i * scale), offsetY + (fieldWidthMeters * scale)),
        gridPaint,
      );
    }

    for (int i = 1; i < fieldWidthMeters.toInt(); i++) {
      canvas.drawLine(
        Offset(offsetX, offsetY + (i * scale)),
        Offset(offsetX + (fieldLengthMeters * scale), offsetY + (i * scale)),
        gridPaint,
      );
    }

    final blueAlliancePaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final redAlliancePaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        offsetX,
        offsetY,
        fieldLengthMeters * scale * 0.25,
        fieldWidthMeters * scale,
      ),
      blueAlliancePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        offsetX + (fieldLengthMeters * scale * 0.75),
        offsetY,
        fieldLengthMeters * scale * 0.25,
        fieldWidthMeters * scale,
      ),
      redAlliancePaint,
    );

    _drawRobot(canvas, robotPosition, scale, offsetX, offsetY);
  }

  void _drawRobot(Canvas canvas, List<double> position, double scale, double offsetX, double offsetY) {
    final double x = position[0];
    final double y = position[1];
    final double rotation = position[2];

    final double canvasX = offsetX + (x * scale);
    final double canvasY = offsetY + ((fieldWidthMeters - y) * scale);

    final double robotWidth = 0.9 * scale;
    final double robotHeight = 0.9 * scale;

    canvas.save();
    canvas.translate(canvasX, canvasY);
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