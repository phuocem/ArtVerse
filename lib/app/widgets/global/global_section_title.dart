import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';

class GlobalSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final LayoutController lc;

  const GlobalSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle.toUpperCase(), style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w900, color: lc.primaryColor, letterSpacing: 2.5)),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.w400, color: lc.textColor, letterSpacing: 1)),
      ],
    );
  }
}
