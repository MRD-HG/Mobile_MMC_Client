import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/utils/links.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/content_builder.dart';
import '../events/event_details_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  static IconData _iconFor(String type) {
    switch (type) {
      case 'linkedin':
        return Icons.work_outline;
      case 'facebook':
        return Icons.facebook;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'instagram':
        return Icons.photo_camera_outlined;
      default:
        return Icons.language;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.community)),
      body: ContentBuilder(builder: (context, data) {
        final info = data.community;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return ListView(
          padding: const EdgeInsets.fromLTRB(MmcSpacing.l, 0, MmcSpacing.l, MmcSpacing.xl),
          children: [
            Center(
              child: Image.asset(
                isDark
                    ? 'assets/images/brand/mmc_logo_dark.png'
                    : 'assets/images/brand/mmc_logo.png',
                height: 96,
                semanticLabel: info.name,
              ),
            ),
            const SizedBox(height: MmcSpacing.l),
            const LogoStripe(),
            SectionTitle(s.aboutMmc),
            Text(info.aboutFor(s.languageCode),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
            if (info.motto != null) ...[
              const SizedBox(height: MmcSpacing.m),
              Text(
                '“${info.motto}”',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: MmcSpacing.l),
            Row(
              children: [
                _Stat(value: '${data.events.length}', label: s.statsEvents),
                _Stat(value: '${data.cities.length}', label: s.statsCities),
                _Stat(value: '${data.speakers.length}', label: s.statsSpeakers),
              ],
            ),
            if (info.focus.isNotEmpty) ...[
              SectionTitle(s.focusAreas),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [for (final f in info.focus) TopicChip(f)],
              ),
            ],
            SectionTitle(s.officialLinks),
            MmcCard(
              child: Column(
                children: [
                  for (final link in info.links)
                    ListTile(
                      leading: Icon(_iconFor(link.type)),
                      title: Text(link.label),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => Links.open(context, link.url),
                    ),
                  if (info.email != null)
                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: Text(info.email!),
                      subtitle: Text(s.contact),
                      onTap: () => Links.open(context, 'mailto:${info.email}'),
                    ),
                ],
              ),
            ),
            if (info.partners.isNotEmpty) ...[
              SectionTitle(s.ourPartners),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in info.partners)
                    ActionChip(
                      avatar: const Icon(Icons.handshake_outlined, size: 18),
                      label: Text(p.name),
                      onPressed: p.url == null ? null : () => Links.open(context, p.url!),
                    ),
                ],
              ),
            ],
            if (info.gallery.isNotEmpty) ...[
              SectionTitle(s.moments),
              for (final img in info.gallery)
                Padding(
                  padding: const EdgeInsets.only(bottom: MmcSpacing.m),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(MmcRadius.card),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: AppImage(source: img, cacheWidth: 1000),
                    ),
                  ),
                ),
            ],
          ],
        );
      }),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: MmcCard(
        padding: const EdgeInsets.all(MmcSpacing.m),
        child: Column(
          children: [
            Text(value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: theme.colorScheme.primary)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
