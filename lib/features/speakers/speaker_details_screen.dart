import 'package:flutter/material.dart';

import '../../app/shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/utils/links.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/content_builder.dart';
import '../../data/models/speaker.dart';
import '../events/event_details_screen.dart';
import '../events/widgets/event_card.dart';

class SpeakerDetailsScreen extends StatelessWidget {
  const SpeakerDetailsScreen({super.key, required this.speakerId});

  final String speakerId;

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(builder: (context, data) {
      final speaker = data.speakerById(speakerId);
      if (speaker == null) return const NotFoundScreen();
      final s = context.s;
      final theme = Theme.of(context);
      final events = data.eventsForSpeaker(speaker.id);

      return Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(MmcSpacing.l, 0, MmcSpacing.l, MmcSpacing.xl),
          children: [
            Center(
              child: AvatarImage(
                url: speaker.avatarUrl,
                localAsset: speaker.localAvatar,
                initials: speaker.initials,
                size: 132,
              ),
            ),
            const SizedBox(height: MmcSpacing.l),
            Semantics(
              header: true,
              child: Text(
                speaker.displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: MmcSpacing.m),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final role in speaker.roles)
                  Chip(
                    label: Text(role),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: role.toLowerCase().contains('mvp')
                        ? MmcColors.brand.withAlpha(30)
                        : null,
                  ),
              ],
            ),
            if (speaker.links.isNotEmpty) ...[
              const SizedBox(height: MmcSpacing.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final link in speaker.links)
                    IconButton.filledTonal(
                      tooltip: socialLabel(link.kind),
                      icon: Icon(socialIcon(link.kind)),
                      onPressed: () => Links.open(context, link.url),
                    ),
                ],
              ),
            ],
            const SizedBox(height: MmcSpacing.l),
            const LogoStripe(),
            if (speaker.bio != null && speaker.bio!.isNotEmpty) ...[
              SectionTitle(s.about),
              SelectableText(speaker.bio!, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
            ],
            if (events.isNotEmpty) ...[
              SectionTitle('${s.spokeAt} (${events.length})'),
              for (final e in events) ...[
                EventCard(event: e),
                const SizedBox(height: MmcSpacing.l),
              ],
            ],
          ],
        ),
      );
    });
  }
}

IconData socialIcon(SocialKind kind) {
  switch (kind) {
    case SocialKind.linkedin:
      return Icons.work_outline;
    case SocialKind.github:
      return Icons.code;
    case SocialKind.x:
      return Icons.alternate_email;
    case SocialKind.instagram:
      return Icons.photo_camera_outlined;
    case SocialKind.facebook:
      return Icons.facebook;
    case SocialKind.youtube:
      return Icons.play_circle_outline;
    case SocialKind.website:
      return Icons.language;
  }
}

String socialLabel(SocialKind kind) {
  switch (kind) {
    case SocialKind.linkedin:
      return 'LinkedIn';
    case SocialKind.github:
      return 'GitHub';
    case SocialKind.x:
      return 'X';
    case SocialKind.instagram:
      return 'Instagram';
    case SocialKind.facebook:
      return 'Facebook';
    case SocialKind.youtube:
      return 'YouTube';
    case SocialKind.website:
      return 'Website';
  }
}
