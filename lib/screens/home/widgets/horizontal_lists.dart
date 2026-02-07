import 'package:flutter/material.dart';
import 'package:liveshop/models/live_event.dart';
import 'package:liveshop/screens/home/widgets/live_event_card_big.dart';
import 'package:liveshop/screens/home/widgets/event_card_vertical.dart';

class HorizontalPulseList extends StatelessWidget {
  final List<LiveEvent> events;
  const HorizontalPulseList({Key? key, required this.events}) : super(key: key);

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
          return LiveEventCardBig(event: event);
        },
      ),
    );
  }
}

class HorizontalEventList extends StatelessWidget {
  final List<LiveEvent> events;
  final bool isSmall;
  const HorizontalEventList({
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
              child: EventCardVertical(event: event, isSmall: isSmall),
            ),
          );
        },
      ),
    );
  }
}
