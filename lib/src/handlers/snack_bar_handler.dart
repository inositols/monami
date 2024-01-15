import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class SnackbarHandler {
  GlobalKey<ScaffoldMessengerState> get key;
  void showErrorSnackbar(String message);
  void showSnackbar(String message);
}

class SnackbarHandlerImpl implements SnackbarHandler {
  late final GlobalKey<ScaffoldMessengerState> _key;

  SnackbarHandlerImpl({GlobalKey<ScaffoldMessengerState>? state}) {
    _key = state ?? GlobalKey<ScaffoldMessengerState>();
  }

  @override
  void showErrorSnackbar(String message) {
    _key.currentState!.hideCurrentSnackBar();
    _key.currentState!.showSnackBar(
      SnackBar(
        backgroundColor: Colors.amber.shade900,
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  void showSnackbar(String message) {
    _key.currentState!.hideCurrentSnackBar();
    _key.currentState!.showSnackBar(
      SnackBar(
        backgroundColor: Colors.amber.shade900,
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  GlobalKey<ScaffoldMessengerState> get key => _key;
}
