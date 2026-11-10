import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/content_builder.dart';
import '../events/event_details_screen.dart';
import '../events/widgets/event_card.dart';

class ProgramDetailsScreen extends StatelessWidget {
  const ProgramDetailsScreen({super.key, required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(builder: (context, data) {
      final program = data.programById(programId);
      if (program == null) return const NotFoundScreen();
      final s = context.s;
      final theme = Theme.of(context);
      final now = AppScope.of(context).clock();
      final events = data.eventsForProgram(program.id);
      final upcoming = events.where((e) => e.isUpcoming(now)).toList();
      final past = events.where((e) => !e.isUpcoming(now)).toList();

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  program.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      source: program.imageUrl,
                      fallbackIcon: Icons.school_outlined,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xCC000000)],
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
                  if (program.summary.isNotEmpty)
                    Text(program.summary,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                  if (upcoming.isNotEmpty) ...[
                    SectionTitle(s.upcomingEvents),
                    for (final e in upcoming) ...[
                      EventCard(event: e),
                      const SizedBox(height: MmcSpacing.l),
                    ],
                  ],
                  SectionTitle('${s.programEvents} (${past.length})'),
                  for (final e in past) ...[
                    EventCard(event: e),
                    const SizedBox(height: MmcSpacing.l),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
