import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liveshop/providers/live_event_provider.dart';
import 'package:liveshop/models/live_event.dart';
import 'package:liveshop/config/theme_config.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:liveshop/widgets/cart/cart_view.dart';
import 'package:liveshop/screens/profile/profile_screen.dart';
import 'package:liveshop/models/category.dart';
import 'package:liveshop/widgets/app_icons.dart';

// Widgets
import 'package:liveshop/screens/home/widgets/section_header.dart';
import 'package:liveshop/screens/home/widgets/categories_list.dart';
import 'package:liveshop/screens/home/widgets/horizontal_lists.dart';
import 'package:liveshop/screens/home/widgets/empty_section.dart';
import 'package:liveshop/screens/home/widgets/promo_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveEventProvider>().loadEvents();
    });
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? _HomeContent(
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: _onCategorySelected,
            )
          : _selectedIndex == 1
          ? const CartView()
          : const ProfileScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: AppIcons.icon(AppIcons.home, color: Colors.white),
            selectedIcon: AppIcons.icon(
              AppIcons.homeFilled,
              color: ThemeConfig.primaryColor,
            ),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: AppIcons.icon(AppIcons.bag, color: Colors.white),
            selectedIcon: AppIcons.icon(
              AppIcons.bagFilled,
              color: ThemeConfig.primaryColor,
            ),
            label: 'Commandes',
          ),
          NavigationDestination(
            icon: AppIcons.icon(AppIcons.person, color: Colors.white),
            selectedIcon: AppIcons.icon(
              AppIcons.personFilled,
              color: ThemeConfig.primaryColor,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String? selectedCategoryId;
  final void Function(String?) onCategorySelected;

  const _HomeContent({
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  String _getCategoryName(String categoryId, List<Category> categories) {
    try {
      return categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveEventProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ThemeConfig.primaryColor),
          );
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        // Filtrer les événements par catégorie si sélectionné
        var filteredEvents = provider.events;
        if (selectedCategoryId != null) {
          filteredEvents = provider.events.where((event) {
            // Vérifier si l'événement a des produits dans la catégorie sélectionnée
            return event.productsList.any(
              (product) =>
                  product.category ==
                  _getCategoryName(selectedCategoryId!, provider.categories),
            );
          }).toList();
        }

        final liveEvents = filteredEvents
            .where((e) => e.status == LiveEventStatus.live)
            .toList();
        final scheduledEvents = filteredEvents
            .where((e) => e.status == LiveEventStatus.scheduled)
            .toList();
        final endedEvents = filteredEvents
            .where((e) => e.status == LiveEventStatus.ended)
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: true,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    expandedTitleScale: 1.2,
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    title: Text(
                      'Découvrir',
                      style: GoogleFonts.sora(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: AppIcons.icon(
                          AppIcons.search,
                          size: 20,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: AppIcons.icon(
                          AppIcons.bell,
                          size: 20,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PromoBanner(),
                  ),
                ),

                // Section Catégories
                if (provider.categories.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: selectedCategoryId == null
                          ? "Catégories"
                          : "Catégories (${_getCategoryName(selectedCategoryId!, provider.categories)})",
                      showAll: selectedCategoryId != null,
                      onShowAll: selectedCategoryId != null
                          ? () => onCategorySelected(null)
                          : null,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: CategoriesList(
                      categories: provider.categories,
                      selectedCategoryId: selectedCategoryId,
                      onCategorySelected: onCategorySelected,
                    ),
                  ),
                ],

                // Section Événements en Direct - Toujours afficher
                SliverToBoxAdapter(
                  child: SectionHeader(title: "En Direct", showAll: true),
                ),
                if (liveEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: HorizontalPulseList(events: liveEvents),
                  )
                else
                  SliverToBoxAdapter(
                    child: EmptySection(message: "Aucun événement en direct"),
                  ),

                // Section Événements à Venir - Toujours afficher
                SliverToBoxAdapter(child: SectionHeader(title: "À Venir")),
                if (scheduledEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: HorizontalEventList(
                      events: scheduledEvents,
                      isSmall: true,
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: EmptySection(message: "Aucun événement à venir"),
                  ),

                // Section Événements Terminés - Toujours afficher
                SliverToBoxAdapter(child: SectionHeader(title: "Replays")),
                if (endedEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: HorizontalPulseList(events: endedEvents),
                  )
                else
                  SliverToBoxAdapter(
                    child: EmptySection(message: "Aucun replay disponible"),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        );
      },
    );
  }
}
