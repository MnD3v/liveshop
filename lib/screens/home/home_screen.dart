import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:liveshop/providers/live_event_provider.dart';
import 'package:liveshop/models/live_event.dart';
import 'package:liveshop/config/theme_config.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:liveshop/widgets/cart/cart_view.dart';
import 'package:liveshop/screens/profile/profile_screen.dart';
import 'package:liveshop/models/category.dart';

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_filled,
              color: ThemeConfig.primaryColor,
            ),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(
              Icons.shopping_bag,
              color: ThemeConfig.primaryColor,
            ),
            label: 'Commandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: ThemeConfig.primaryColor),
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

        // Filter events by category if selected
        var filteredEvents = provider.events;
        if (selectedCategoryId != null) {
          filteredEvents = provider.events.where((event) {
            // Check if event has products in the selected category
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
                        child: const Icon(Icons.search),
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
                        child: const Icon(Icons.notifications_none),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _PromoBanner(),
                  ),
                ),

                // Categories Section
                if (provider.categories.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
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
                    child: _CategoriesList(
                      categories: provider.categories,
                      selectedCategoryId: selectedCategoryId,
                      onCategorySelected: onCategorySelected,
                    ),
                  ),
                ],

                // Live Events Section - Always show
                SliverToBoxAdapter(
                  child: _SectionHeader(title: "En Direct 🔥", showAll: true),
                ),
                if (liveEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _HorizontalPulseList(events: liveEvents),
                  )
                else
                  SliverToBoxAdapter(
                    child: _EmptySection(message: "Aucun événement en direct"),
                  ),

                // Scheduled Events Section - Always show
                SliverToBoxAdapter(child: _SectionHeader(title: "À Venir 📅")),
                if (scheduledEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _HorizontalEventList(
                      events: scheduledEvents,
                      isSmall: true,
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: _EmptySection(message: "Aucun événement à venir"),
                  ),

                // Ended Events Section - Always show
                SliverToBoxAdapter(child: _SectionHeader(title: "Replays ⏪")),
                if (endedEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _HorizontalPulseList(events: endedEvents),
                  )
                else
                  SliverToBoxAdapter(
                    child: _EmptySection(message: "Aucun replay disponible"),
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

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({Key? key, required this.message}) : super(key: key);

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
            Icon(
              Icons.inbox_outlined,
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

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: ThemeConfig.primaryColor,
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
          ),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NOUVEAUTÉS',
                    style: GoogleFonts.sora(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Soldes d\'Été\nCollection 2024',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showAll;
  final VoidCallback? onShowAll;

  const _SectionHeader({
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

class _HorizontalPulseList extends StatelessWidget {
  final List<LiveEvent> events;
  const _HorizontalPulseList({Key? key, required this.events})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _LiveEventCardBig(event: event);
        },
      ),
    );
  }
}

class _HorizontalEventList extends StatelessWidget {
  final List<LiveEvent> events;
  final bool isSmall;
  const _HorizontalEventList({
    Key? key,
    required this.events,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isSmall ? 200 : 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 160,
              child: _EventCardVertical(event: event, isSmall: isSmall),
            ),
          );
        },
      ),
    );
  }
}

class _LiveEventCardBig extends StatelessWidget {
  final LiveEvent event;
  const _LiveEventCardBig({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLive = event.status == LiveEventStatus.live;
    final isReplay = event.status == LiveEventStatus.ended;

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.read<LiveEventProvider>().joinEvent(event.id);
          context.push('/live/${event.id}');
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Image.network(event.thumbnailUrl, fit: BoxFit.cover),
                  ),
                  if (isReplay)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? ThemeConfig.primaryColor
                            : Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLive) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            isLive
                                ? 'EN DIRECT'
                                : (isReplay ? 'REPLAY' : 'À VENIR'),
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${event.viewerCount}',
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(event.seller.logoUrl),
                        radius: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.seller.name,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final void Function(String?) onCategorySelected;

  const _CategoriesList({
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
                // Toggle selection: if already selected, deselect
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
                    Text(category.icon, style: const TextStyle(fontSize: 28)),
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

class _EventCardVertical extends StatelessWidget {
  final LiveEvent event;
  final bool isSmall;
  const _EventCardVertical({
    Key? key,
    required this.event,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Can also go to live logic if replays are supported similarly
          context.read<LiveEventProvider>().joinEvent(event.id);
          context.push('/live/${event.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(event.thumbnailUrl, fit: BoxFit.cover),
                  if (event.status == LiveEventStatus.scheduled)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\u00C0 Venir',
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (!isSmall) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.seller.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
