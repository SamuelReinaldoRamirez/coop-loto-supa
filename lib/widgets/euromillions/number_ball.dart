import 'package:flutter/material.dart';

class NumberBall extends StatelessWidget {
  final dynamic number;
  final Color color;
  final Color numberColor;
  final Color? borderColor;
  final double radius;
  final double fontSize;

  const NumberBall({
    super.key,
    required this.number,
    required this.color,
    this.numberColor = Colors.white,
    this.borderColor,
    this.radius = 13,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(
                color: borderColor!,
                width: 2.5,
              ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color,
        child: Text(
          '$number',
          style: TextStyle(
            color: numberColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}