import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/content_builder.dart';
import '../events/widgets/event_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.navSaved)),
      body: ContentBuilder(
        builder: (context, data) => ListenableBuilder(
          listenable: scope.bookmarks,
          builder: (context, _) {
            final now = scope.clock();
            final saved = data.events.where((e) => scope.bookmarks.isSaved(e.id)).toList()
              // Upcoming first (soonest), then past (most recent).
              ..sort((a, b) {
                final au = a.isUpcoming(now), bu = b.isUpcoming(now);
                if (au != bu) return au ? -1 : 1;
                return au ? a.start.compareTo(b.start) : b.start.compareTo(a.start);
              });
            // Bookmarks whose event is no longer in the current dataset:
            // keep them visible instead of silently dropping them (MMC-014).
            final knownIds = data.events.map((e) => e.id).toSet();
            final orphans =
                scope.bookmarks.ids.where((id) => !knownIds.contains(id)).toList();
            if (saved.isEmpty && orphans.isEmpty) {
              return MessageView(
                icon: Icons.bookmark_border,
                title: s.savedEmptyTitle,
                body: s.savedEmptyBody,
                actionLabel: s.browseEvents,
                onAction: () => HomeShell.goTo(context, ShellTab.events),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(MmcSpacing.l, 0, MmcSpacing.l, MmcSpacing.xl),
              children: [
                for (final e in saved) ...[
                  EventCard(event: e),
                  const SizedBox(height: MmcSpacing.l),
                ],
                for (final id in orphans)
                  MmcCard(
                    child: ListTile(
                      leading: const Icon(Icons.event_busy_outlined),
                      title: Text(s.savedUnavailable),
                      subtitle: Text(id, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        tooltip: s.removeLabel,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => scope.bookmarks.toggle(id),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
