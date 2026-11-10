import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models/event.dart';

/// Full-width event card used in lists.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final MmcEvent event;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final scope = AppScope.of(context);
    final upcoming = event.isUpcoming(scope.clock());
    final locale = s.languageCode;

    return MmcCard(
      semanticLabel: '${event.title}, ${Formatters.longDate(event.start, locale)}',
      onTap: () => AppRouter.openEvent(context, event.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  source: event.image,
                  fallbackLabel: event.title,
                  alignment: Alignment.topCenter,
                  cacheWidth: 900,
                ),
                Positioned(
                  left: MmcSpacing.m,
                  top: MmcSpacing.m,
                  child: Pill(
                    upcoming ? s.upcomingBadge : s.pastBadge,
                    color: upcoming ? MmcColors.green : Colors.black.withAlpha(150),
                  ),
                ),
                Positioned(
                  right: MmcSpacing.xs,
                  top: MmcSpacing.xs,
                  child: BookmarkButton(eventId: event.id, onImage: true),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(MmcSpacing.l),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateBadge(date: event.start),
                const SizedBox(width: MmcSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (event.location.isNotEmpty) ...[
                        const SizedBox(height: MmcSpacing.xs),
                        Row(
                          children: [
                            Icon(event.isOnline ? Icons.videocam_outlined : Icons.place_outlined,
                                size: 16, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.isOnline ? s.online : event.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (event.topics.isNotEmpty) ...[
                        const SizedBox(height: MmcSpacing.s),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [for (final t in event.topics.take(3)) TopicChip(t)],
                        ),
                      ],
                    ],
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

/// Narrow card for horizontal carousels.
class EventTile extends StatelessWidget {
  const EventTile({super.key, required this.event, this.width = 260});

  final MmcEvent event;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.s.languageCode;
    return SizedBox(
      width: width,
      child: MmcCard(
        semanticLabel: event.title,
        onTap: () => AppRouter.openEvent(context, event.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: AppImage(
                source: event.image,
                fallbackLabel: event.title,
                alignment: Alignment.topCenter,
                cacheWidth: 600,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(MmcSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.longDate(event.start, locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (event.displayCity.isNotEmpty)
                      Text(
                        event.isOnline ? context.s.online : event.displayCity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateBadge extends StatelessWidget {
  const DateBadge({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (day, month, year) = Formatters.dateBadge(date, context.s.languageCode);
    return ExcludeSemantics(
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(month,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700)),
            Text(day,
                style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer, height: 1.1)),
            Text(year,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({super.key, required this.eventId, this.onImage = false});

  final String eventId;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final bookmarks = AppScope.of(context).bookmarks;
    final s = context.s;
    return ListenableBuilder(
      listenable: bookmarks,
      builder: (context, _) {
        final saved = bookmarks.isSaved(eventId);
        final button = IconButton(
          tooltip: saved ? s.saved : s.save,
          isSelected: saved,
          icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          color: onImage ? Colors.white : null,
          onPressed: () {
            bookmarks.toggle(eventId);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(saved ? s.removedFromSaved : s.addedToSaved),
                duration: const Duration(seconds: 2),
              ));
          },
        );
        if (!onImage) return button;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(90),
            shape: BoxShape.circle,
          ),
          child: button,
        );
      },
    );
  }
}
