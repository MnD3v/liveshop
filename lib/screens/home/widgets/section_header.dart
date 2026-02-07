import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liveshop/config/theme_config.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showAll;
  final VoidCallback? onShowAll;

  const SectionHeader({
    Key? key,
    required this.title,
    this.showAll = false,
    this.onShowAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (showAll)
            InkWell(
              onTap: onShowAll,
              child: Text(
                'Voir Tout',
                style: GoogleFonts.sora(
                  color: ThemeConfig.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
