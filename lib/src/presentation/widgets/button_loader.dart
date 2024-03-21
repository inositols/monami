import 'package:flutter/material.dart';

class ButtonLoader extends StatelessWidget {
  final bool isLoading;
  final String? text;
  final Color? textColor;
  final double textSize;
  final Color? spinnerColor;
  const ButtonLoader(
      {Key? key,
      required this.isLoading,
      required this.text,
      this.textColor = Colors.white,
      this.spinnerColor,
      this.textSize = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Text(
            text!,
            style: TextStyle(color: textColor, fontSize: textSize),
          )
        : Center(
            child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: spinnerColor ?? Colors.white,
                  strokeWidth: 2,
                )),
          );
  }
}
