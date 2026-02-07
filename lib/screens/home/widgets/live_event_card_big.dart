import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:liveshop/providers/live_event_provider.dart';
import 'package:liveshop/models/live_event.dart';
import 'package:liveshop/config/theme_config.dart';
import 'package:liveshop/widgets/app_icons.dart';

class LiveEventCardBig extends StatelessWidget {
  final LiveEvent event;
  const LiveEventCardBig({Key? key, required this.event}) : super(key: key);

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
                        child: AppIcons.icon(
                          AppIcons.play,
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
                            AppIcons.icon(
                              AppIcons.flash,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
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
                          AppIcons.icon(
                            AppIcons.eye,
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
