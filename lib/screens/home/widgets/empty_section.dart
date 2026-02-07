import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liveshop/widgets/app_icons.dart';

class EmptySection extends StatelessWidget {
  final String message;
  const EmptySection({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcons.icon(
              AppIcons.inbox,
              size: 48,
              color: Colors.grey.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.sora(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
