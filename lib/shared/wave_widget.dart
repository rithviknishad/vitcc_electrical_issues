import 'dart:math' as Math;

import 'package:flutter/material.dart';

class ClipperWidget extends CustomClipper<Path> {
  ClipperWidget({
    required this.waveList,
  });

  final List<Offset> waveList;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addPolygon(waveList, false);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}

class WaveWidget extends StatefulWidget {
  final Size size;
  final double yOffset;
  final Color color;

  const WaveWidget({
    required this.size,
    required this.yOffset,
    required this.color,
  });

  @override
  _WaveWidgetState createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with TickerProviderStateMixin {
  late AnimationController animationController;
  final wavePoints = <Offset>[];

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
    )..addListener(() {
        wavePoints.clear();

        final waveSpeed = animationController.value * 1080;
        final fullSphere = animationController.value * Math.pi * 2;
        final normalizer = Math.cos(fullSphere);
        final waveWidth = Math.pi / 270;
        final waveHeight = 20.0;

        for (var i = 0; i <= widget.size.width.toInt(); ++i) {
          final calc = Math.sin((waveSpeed - i) * waveWidth);

          final dx = i.toDouble();
          final dy = calc * waveHeight * normalizer + widget.yOffset;

          wavePoints.add(Offset(dx, dy));
        }
      });

    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        return ClipPath(
          clipper: ClipperWidget(waveList: wavePoints),
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            color: widget.color,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
