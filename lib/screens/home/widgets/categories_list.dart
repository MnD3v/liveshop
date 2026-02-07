import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liveshop/config/theme_config.dart';
import 'package:liveshop/models/category.dart';
import 'package:liveshop/widgets/app_icons.dart';

class CategoriesList extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final void Function(String?) onCategorySelected;

  const CategoriesList({
    Key? key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryId == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                // Basculer la sélection : si déjà sélectionné, désélectionner
                if (isSelected) {
                  onCategorySelected(null);
                } else {
                  onCategorySelected(category.id);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ThemeConfig.primaryColor.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? ThemeConfig.primaryColor
                        : Colors.grey.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcons.icon(
                      AppIcons.getCategoryIcon(category.slug),
                      size: 28,
                      color: isSelected
                          ? ThemeConfig.primaryColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected ? ThemeConfig.primaryColor : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
