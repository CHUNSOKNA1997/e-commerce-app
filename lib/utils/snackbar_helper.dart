import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final mediaQuery = MediaQuery.of(context);
  final bottomOffset =
      mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 24;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomOffset),
        backgroundColor:
            isError ? const Color(0xFF3A2E2A) : const Color(0xFF2F6F43),
      ),
    );
}
