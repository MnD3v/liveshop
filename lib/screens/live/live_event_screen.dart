import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liveshop/providers/live_event_provider.dart';
import 'package:liveshop/widgets/live/video_player_widget.dart';
import 'package:liveshop/widgets/live/chat_widget.dart';
import 'package:liveshop/widgets/live/product_list_widget.dart';
import 'package:liveshop/models/live_event.dart'; // Explicit import

class LiveEventScreen extends StatefulWidget {
  final String eventId;
  const LiveEventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<LiveEventScreen> createState() => _LiveEventScreenState();
}

class _LiveEventScreenState extends State<LiveEventScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Offset _fabPosition = const Offset(20, 200);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveEventProvider>().joinEvent(widget.eventId);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LiveEventProvider>();
    final LiveEvent? event = provider.currentEvent;

    if (event == null || event.id != widget.eventId) {
      LiveEvent? placeholder;
      try {
        placeholder = provider.events.firstWhere((e) => e.id == widget.eventId);
      } catch (_) {}

      if (placeholder != null &&
          placeholder.status == LiveEventStatus.scheduled) {
        return _buildScheduledView(context, placeholder);
      }

      if (placeholder != null) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                placeholder.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              ),
              Container(color: Colors.black.withOpacity(0.5)),
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ),
        );
      }
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (event.status == LiveEventStatus.scheduled) {
      return _buildScheduledView(context, event);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout(context, event);
        }
        return _buildMobileLayout(context, event);
      },
    );
  }

  Widget _buildScheduledView(BuildContext context, LiveEvent event) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            event.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black),
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'À Venir',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DateFormat('d MMMM y, HH:mm').format(event.startTime),
                  style: GoogleFonts.sora(
                    color: const Color(0xFFFF2600),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  event.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  // Change dynamic to LiveEvent
  Widget _buildDesktopLayout(BuildContext context, LiveEvent event) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: VideoPlayerWidget(
              streamUrl: event.streamUrl,
              replayUrl: event.replayUrl,
              thumbnailUrl: event.thumbnailUrl,
              isLive: event.status == LiveEventStatus.live,
            ),
          ),
          Container(
            width: 400,
            color: Colors.white10,
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: ClipOval(
                      child: Image.network(
                        event.seller.logoUrl,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            event.seller.name.isNotEmpty
                                ? event.seller.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    event.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    event.seller.name,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                const Divider(color: Colors.white24),
                Expanded(flex: 1, child: const ProductListWidget()),
                const Divider(color: Colors.white24),
                Expanded(
                  flex: 1,
                  child: ChatWidget(
                    isReadOnly: event.status == LiveEventStatus.ended,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, LiveEvent event) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: VideoPlayerWidget(
                streamUrl: event.streamUrl,
                replayUrl: event.replayUrl,
                thumbnailUrl: event.thumbnailUrl,
                isLive: event.status == LiveEventStatus.live,
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.black54,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.4, 0.9],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      context.read<LiveEventProvider>().leaveEvent();
                      context.pop();
                    },
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white10,
                    child: ClipOval(
                      child: Image.network(
                        event.seller.logoUrl,
                        fit: BoxFit.cover,
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            event.seller.name.isNotEmpty
                                ? event.seller.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                        Row(
                          children: [
                            if (event.status == LiveEventStatus.live) ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '${event.viewerCount} Spectateurs',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.0, 0.2],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ChatWidget(
                  isReadOnly: event.status == LiveEventStatus.ended,
                ),
              ),
            ),

            Positioned(
              left: _fabPosition.dx,
              top: _fabPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _fabPosition += details.delta;
                  });
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFFFF2600),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.6,
                          minChildSize: 0.3,
                          maxChildSize: 0.8,
                          builder: (context, scrollController) {
                            return ProductListWidget(
                              scrollController: scrollController,
                            );
                          },
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
