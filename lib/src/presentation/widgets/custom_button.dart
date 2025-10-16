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
  final AlignmentGeometry childAlign;
  final TextAlign textAlign;
  final double? radius;
  final bool isLoading;
  final List<BoxShadow>? boxShadow;

  const CustomButton({
    Key? key,
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
    this.childAlign = Alignment.center,
    this.textAlign = TextAlign.center,
    this.boxShadow,
  }) : super(key: key);

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
            gradient: LinearGradient(
                colors:
                    gradient ?? const [Color(0xFF667EEA), Color(0xFF764BA2)]),
            boxShadow: boxShadow ??
                [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
          ),
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
                  alignment: childAlign,
                  child: Text(
                    text!,
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: textSize ?? 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: textAlign,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
