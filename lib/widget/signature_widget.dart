import 'dart:io';

import 'package:flutter/material.dart';

class SignatureWidget extends StatefulWidget {
  final String signatureImagePath;
  final double initialX;
  final double initialY;
  final Function(double x, double y, double width, double height) onUpdate;

  const SignatureWidget({
    Key? key,
    required this.signatureImagePath,
    required this.initialX,
    required this.initialY,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _SignatureWidgetState createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends State<SignatureWidget> {
  double x = 0;
  double y = 0;
  double width = 100;
  double height = 50;
  double rotation = 0;

  @override
  void initState() {
    super.initState();
    x = widget.initialX;
    y = widget.initialY;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            x += details.delta.dx;
            y += details.delta.dy;
          });
          widget.onUpdate(x, y, width, height);
        },
        onScaleUpdate: (details) {
          setState(() {
            width *= details.scale;
            height *= details.scale;
          });
          widget.onUpdate(x, y, width, height);
        },
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                File(widget.signatureImagePath),
                width: width,
                height: height,
              ),
              // Optional: Add rotation controls
              Positioned(
                top: -20,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      rotation += details.delta.dx * 0.01;
                    });
                  },
                  child: const Icon(Icons.rotate_right, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
