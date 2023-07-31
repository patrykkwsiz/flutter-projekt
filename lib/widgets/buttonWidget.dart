import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final Color color;
  final Color textColor;
  final Color boxColor;

ButtonWidget({
  required this.title,
  required this.textColor,
  this.onTap,
  required this.color,
  required this.boxColor,
  
});


@override
Widget build(BuildContext context) {
    return Material(
      color: color,
      child: Ink(
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 60,
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                 ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}