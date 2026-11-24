import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/content_builder.dart';
import '../../data/models/speaker.dart';
import '../events/events_screen.dart';

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({super.key});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.navSpeakers)),
      body: ContentBuilder(builder: (context, data) {
        final speakers = data.speakers.where((sp) => sp.matches(_search.text)).toList()
          ..sort((a, b) =>
              data.eventsForSpeaker(b.id).length.compareTo(data.eventsForSpeaker(a.id).length));
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(MmcSpacing.l, MmcSpacing.s, MmcSpacing.l, MmcSpacing.l),
              sliver: SliverToBoxAdapter(
                child: SearchField(
                  controller: _search,
                  hint: s.searchSpeakers,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            if (speakers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: MessageView(icon: Icons.person_search_outlined, title: s.noSpeakersMatch),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(MmcSpacing.l, 0, MmcSpacing.l, MmcSpacing.xl),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: MmcSpacing.m,
                    crossAxisSpacing: MmcSpacing.m,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: speakers.length,
                  itemBuilder: (context, i) => SpeakerCard(
                    speaker: speakers[i],
                    eventCount: data.eventsForSpeaker(speakers[i].id).length,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class SpeakerCard extends StatelessWidget {
  const SpeakerCard({super.key, required this.speaker, required this.eventCount});

  final Speaker speaker;
  final int eventCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    return MmcCard(
      semanticLabel: '${speaker.displayName}, ${speaker.title}',
      onTap: () => AppRouter.openSpeaker(context, speaker.id),
      padding: const EdgeInsets.all(MmcSpacing.m),
      child: Column(
        children: [
          const SizedBox(height: MmcSpacing.s),
          Stack(
            clipBehavior: Clip.none,
            children: [
              AvatarImage(
                url: speaker.avatarUrl,
                localAsset: speaker.localAvatar,
                initials: speaker.initials,
                size: 88,
              ),
              if (speaker.isMvp)
                const Positioned(
                  right: -6,
                  bottom: 0,
                  child: Pill('MVP', color: MmcColors.brand),
                ),
            ],
          ),
          const SizedBox(height: MmcSpacing.m),
          Text(
            speaker.displayName,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              speaker.roles.isEmpty ? '' : speaker.roles.first,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Text(
            s.eventsCount(eventCount),
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
