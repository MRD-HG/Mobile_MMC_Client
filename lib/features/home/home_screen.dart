import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/utils/links.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/content_builder.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/event.dart';
import '../../data/repositories/content_repository.dart';
import '../events/widgets/event_card.dart';
import '../programs/programs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return ContentBuilder(
      builder: (context, data) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) => _HomeBody(data: data),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.data});

  final ContentBundle data;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scope = AppScope.of(context);
    final now = scope.clock();
    final upcoming = data.upcoming(now);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: scope.content.refresh,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            titleSpacing: MmcSpacing.l,
            title: Image.asset(
              isDark
                  ? 'assets/images/brand/mmc_logo_dark.png'
                  : 'assets/images/brand/mmc_logo.png',
              height: 36,
              semanticLabel: s.appName,
            ),
            actions: [
              IconButton(
                tooltip: s.community,
                icon: const Icon(Icons.groups_outlined),
                onPressed: () => AppRouter.openCommunity(context),
              ),
              IconButton(
                tooltip: s.settings,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => AppRouter.openSettings(context),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _HeroHeader(data: data)),
          const SliverToBoxAdapter(child: DataStatusBanner()),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: upcoming.length > 1 ? s.upcomingEvents : s.nextEvent,
              actionLabel: s.seeAll,
              onAction: () => HomeShell.goTo(context, ShellTab.events),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: MmcSpacing.l),
            sliver: SliverToBoxAdapter(
              child: upcoming.isNotEmpty
                  ? Column(
                      children: [
                        for (final e in upcoming.take(3)) ...[
                          EventCard(event: e),
                          const SizedBox(height: MmcSpacing.m),
                        ],
                      ],
                    )
                  : MmcCard(
                      child: MessageView(
                        compact: true,
                        icon: Icons.event_available_outlined,
                        title: s.noUpcomingTitle,
                        body: s.noUpcomingBody,
                        actionLabel: s.visitWebsite,
                        onAction: () => Links.open(context, AppConfig.websiteUrl),
                      ),
                    ),
            ),
          ),
          ..._forYou(context, data),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: s.latestEvents,
              actionLabel: s.seeAll,
              onAction: () => HomeShell.goTo(context, ShellTab.events),
            ),
          ),
          SliverToBoxAdapter(child: _EventCarousel(events: data.past(now).take(6).toList())),
          SliverToBoxAdapter(child: SectionHeader(title: s.exploreTopics)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: MmcSpacing.l),
            sliver: SliverToBoxAdapter(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final t in data.allTopics)
                    TopicChip(
                      t,
                      onTap: () => HomeShell.goTo(context, ShellTab.events, topic: t),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: s.ourPrograms,
              actionLabel: s.seeAll,
              onAction: () => HomeShell.goTo(context, ShellTab.programs),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: MmcSpacing.l),
                scrollDirection: Axis.horizontal,
                itemCount: data.activePrograms.length,
                separatorBuilder: (_, __) => const SizedBox(width: MmcSpacing.m),
                itemBuilder: (context, i) {
                  final program = data.activePrograms[i];
                  return SizedBox(
                    width: 240,
                    child: ProgramCard(
                      program: program,
                      eventCount: data.eventsForProgram(program.id).length,
                      compact: true,
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: s.meetSpeakers,
              actionLabel: s.seeAll,
              onAction: () => HomeShell.goTo(context, ShellTab.speakers),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 128,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: MmcSpacing.l),
                scrollDirection: Axis.horizontal,
                itemCount: data.speakers.length,
                separatorBuilder: (_, __) => const SizedBox(width: MmcSpacing.m),
                itemBuilder: (context, i) {
                  final sp = data.speakers[i];
                  return Semantics(
                    button: true,
                    label: sp.displayName,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => AppRouter.openSpeaker(context, sp.id),
                      child: SizedBox(
                        width: 84,
                        child: Column(
                          children: [
                            AvatarImage(
                              url: sp.avatarUrl,
                              localAsset: sp.localAvatar,
                              initials: sp.initials,
                              size: 72,
                            ),
                            const SizedBox(height: 6),
                            ExcludeSemantics(
                              child: Text(
                                sp.displayName.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                MmcSpacing.l, MmcSpacing.xl, MmcSpacing.l, MmcSpacing.xl),
            sliver: SliverToBoxAdapter(child: _CommunityTeaser(data: data)),
          ),
        ],
      ),
    );
  }

  List<Widget> _forYou(BuildContext context, ContentBundle data) {
    final topics = AppScope.of(context).settings.favoriteTopics;
    if (topics.isEmpty) return const [];
    final picks =
        data.events.where((e) => e.topics.any(topics.contains)).take(6).toList();
    if (picks.isEmpty) return const [];
    return [
      SliverToBoxAdapter(
        child: SectionHeader(
          title: context.s.isFrench ? 'Pour vous' : 'Picked for you',
        ),
      ),
      SliverToBoxAdapter(child: _EventCarousel(events: picks)),
    ];
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.data});

  final ContentBundle data;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final cities = data.cities.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(MmcSpacing.l, MmcSpacing.s, MmcSpacing.l, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MmcRadius.card),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/brand/team_banner.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                cacheWidth: 1200,
                errorBuilder: (_, __, ___) => const BrandPlaceholder(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      MmcColors.brandDark.withAlpha(60),
                      MmcColors.brandDark.withAlpha(235),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  MmcSpacing.l, 110, MmcSpacing.l, MmcSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.greeting,
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: MmcSpacing.m),
                  const LogoStripe(),
                  const SizedBox(height: MmcSpacing.m),
                  Row(
                    children: [
                      _Stat(value: data.events.length, label: s.statsEvents),
                      _Stat(value: cities, label: s.statsCities),
                      _Stat(value: data.speakers.length, label: s.statsSpeakers),
                    ],
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

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Semantics(
        label: '$value $label',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value',
                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
            Text(label,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _EventCarousel extends StatelessWidget {
  const _EventCarousel({required this.events});

  final List<MmcEvent> events;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: MmcSpacing.l),
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: MmcSpacing.m),
        itemBuilder: (context, i) => EventTile(event: events[i]),
      ),
    );
  }
}

class _CommunityTeaser extends StatelessWidget {
  const _CommunityTeaser({required this.data});

  final ContentBundle data;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return MmcCard(
      onTap: () => AppRouter.openCommunity(context),
      padding: const EdgeInsets.all(MmcSpacing.l),
      child: Row(
        children: [
          Image.asset('assets/images/brand/mmc_mark.png', width: 48, height: 48),
          const SizedBox(width: MmcSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.aboutMmc, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  data.community.aboutFor(s.languageCode),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

/// Tells the user whether they see live data or the offline copy.
class DataStatusBanner extends StatelessWidget {
  const DataStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).content;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final data = controller.data;
        if (data == null) return const SizedBox.shrink();
        final s = context.s;
        final theme = Theme.of(context);
        String? text;
        IconData icon = Icons.cloud_off_outlined;
        if (controller.refreshing && data.origin == ContentOrigin.snapshot) {
          text = s.refreshing;
          icon = Icons.sync;
        } else if (data.origin == ContentOrigin.snapshot && controller.refreshFailed) {
          final date = data.updatedAt == null
              ? '—'
              : Formatters.longDate(data.updatedAt!.toLocal(), s.languageCode);
          text = s.offlineBanner(date);
        }
        if (text == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(MmcSpacing.l, MmcSpacing.m, MmcSpacing.l, 0),
          child: MmcCard(
            color: theme.colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: MmcSpacing.m, vertical: 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.onSecondaryContainer),
                const SizedBox(width: MmcSpacing.s),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ),
                if (!controller.refreshing)
                  TextButton(onPressed: controller.refresh, child: Text(s.retry)),
              ],
            ),
          ),
        );
      },
    );
  }
}
