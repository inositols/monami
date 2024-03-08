import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;
  final Color? color;
  final double? width;
  final double? height;
  final double? textSize;
  final Color? textColor;
  final List<Color>? gradient;
  final BorderSide? borderSide;
  final AlignmentGeometry textAlign;
  final double? radius;
  final bool isLoading;

  const CustomButton(
      {Key? key,
      this.onPressed,
      this.textColor,
      this.text,
      this.color,
      this.child,
      this.width = double.infinity,
      this.height,
      this.gradient = const [Colors.transparent, Colors.transparent],
      this.borderSide,
      this.radius = 50,
      this.isLoading = false,
      this.textSize,
      this.textAlign = Alignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLoading ? true : false,
      child: SizedBox(
        height: height ?? 54,
        width: width,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 650),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius!),
              gradient: LinearGradient(colors: gradient!)),
          child: MaterialButton(
            elevation: 0,
            highlightElevation: 0,
            onPressed: onPressed ?? () {},
            color: isLoading ? Colors.blueGrey.shade300 : color,
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius!),
                borderSide: borderSide ?? BorderSide.none),
            child: child ??
                Align(
                  alignment: textAlign,
                  child: Text(text!,
                      style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: textSize ?? 16,
                          fontWeight: FontWeight.w600)),
                ),
          ),
        ),
      ),
    );
  }
}
