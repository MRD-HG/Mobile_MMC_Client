import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/links.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/content_builder.dart';
import '../../data/models/event.dart';
import '../../data/repositories/content_repository.dart';
import 'widgets/event_card.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(builder: (context, data) {
      final event = data.eventById(eventId);
      if (event == null) return const NotFoundScreen();
      return _EventDetailsView(event: event, data: data);
    });
  }
}

class _EventDetailsView extends StatelessWidget {
  const _EventDetailsView({required this.event, required this.data});

  final MmcEvent event;
  final ContentBundle data;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final locale = s.languageCode;
    final upcoming = event.isUpcoming(AppScope.of(context).clock());
    final program = data.programById(event.programId);
    final gallery = event.galleryImages.skip(1).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            actions: [BookmarkButton(eventId: event.id)],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    source: event.image,
                    fallbackLabel: event.title,
                    alignment: Alignment.topCenter,
                    semanticLabel: event.title,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Color(0x99000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(MmcSpacing.l),
            sliver: SliverList.list(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Pill(
                      upcoming ? s.upcomingBadge : s.pastBadge,
                      color: upcoming ? MmcColors.green : theme.colorScheme.outline,
                    ),
                    if (event.isOnline)
                      Pill(s.online, color: MmcColors.blue, icon: Icons.videocam_outlined),
                    if (program != null)
                      ActionChip(
                        label: Text(program.title),
                        avatar: const Icon(Icons.school_outlined, size: 18),
                        onPressed: () => AppRouter.openProgram(context, program.id),
                      ),
                  ],
                ),
                const SizedBox(height: MmcSpacing.m),
                Semantics(
                  header: true,
                  child: Text(event.title, style: theme.textTheme.headlineSmall),
                ),
                const SizedBox(height: MmcSpacing.l),
                MmcCard(
                  padding: const EdgeInsets.symmetric(vertical: MmcSpacing.s),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        title: Formatters.longDate(event.start, locale),
                        subtitle: Formatters.timeRange(event, locale),
                      ),
                      if (event.isOnline)
                        _InfoRow(icon: Icons.videocam_outlined, title: s.online)
                      else if (event.location.isNotEmpty)
                        _InfoRow(
                          icon: Icons.place_outlined,
                          title: event.venue ?? event.city ?? '',
                          subtitle: event.venue != null ? event.city : null,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: MmcSpacing.l),
                _ActionsPanel(event: event, upcoming: upcoming),
                if (event.description.isNotEmpty) ...[
                  SectionTitle(s.aboutEvent),
                  SelectableText(
                    event.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
                if (event.topics.isNotEmpty) ...[
                  SectionTitle(s.topics),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [for (final t in event.topics) TopicChip(t)],
                  ),
                ],
                if (event.sessions.isNotEmpty) ...[
                  SectionTitle(s.sessions),
                  for (final session in event.sessions)
                    _SessionTile(session: session, data: data),
                ],
                if (event.partners.isNotEmpty || event.club != null) ...[
                  SectionTitle(s.partners),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (event.club != null)
                        Chip(
                          avatar: const Icon(Icons.groups_outlined, size: 18),
                          label: Text('${s.organizedWith} ${event.club}'),
                        ),
                      for (final p in event.partners)
                        Chip(
                          avatar: const Icon(Icons.apartment_outlined, size: 18),
                          label: Text(p),
                        ),
                    ],
                  ),
                ],
                if (gallery.isNotEmpty) ...[
                  SectionTitle(s.gallery),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: MmcSpacing.s),
                      itemBuilder: (context, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(MmcRadius.card),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: AppImage(source: gallery[i], cacheWidth: 600),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: MmcSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.data});

  final EventSession session;
  final ContentBundle data;

  @override
  Widget build(BuildContext context) {
    final speaker = data.speakerById(session.speakerId);
    if (speaker == null) return const SizedBox.shrink();
    final s = context.s;
    final theme = Theme.of(context);
    final subtitle = [
      if (session.cleanTitle != null) session.cleanTitle!,
      if (session.durationMinutes != null) s.minutes(session.durationMinutes!),
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AvatarImage(
        url: speaker.avatarUrl,
        localAsset: speaker.localAvatar,
        initials: speaker.initials,
        size: 48,
      ),
      title: Text(speaker.displayName, style: theme.textTheme.titleSmall),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => AppRouter.openSpeaker(context, speaker.id),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(icon, color: scheme.onPrimaryContainer, size: 20),
      ),
      title: Text(title),
      subtitle: subtitle == null || subtitle!.isEmpty ? null : Text(subtitle!),
    );
  }
}

/// Register (official website), add to calendar, open the event page.
class _ActionsPanel extends StatelessWidget {
  const _ActionsPanel({required this.event, required this.upcoming});

  final MmcEvent event;
  final bool upcoming;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final web = event.webUrl;

    if (!upcoming) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MmcCard(
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(MmcSpacing.m),
            child: Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: MmcSpacing.m),
                Expanded(child: Text(s.eventEnded)),
              ],
            ),
          ),
          if (web != null) ...[
            const SizedBox(height: MmcSpacing.m),
            OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: Text(s.viewOnWebsite),
              onPressed: () => Links.open(context, web),
            ),
          ],
        ],
      );
    }

    final registration = event.registrationUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (registration != null) ...[
          FilledButton.icon(
            icon: const Icon(Icons.how_to_reg_outlined),
            label: Text(s.register),
            onPressed: () => Links.open(context, registration),
          ),
          const SizedBox(height: MmcSpacing.xs),
          Text(
            s.registerHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: MmcSpacing.s),
        ],
        OutlinedButton.icon(
          icon: const Icon(Icons.event_outlined),
          label: Text(s.addToCalendar),
          onPressed: () => Links.open(context, Links.calendarUri(event).toString()),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: MmcSpacing.xl, bottom: MmcSpacing.s),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
