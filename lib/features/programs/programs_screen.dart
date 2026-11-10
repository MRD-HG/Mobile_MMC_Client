import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/content_builder.dart';
import '../../data/models/program.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.navPrograms)),
      body: ContentBuilder(builder: (context, data) {
        final programs = data.activePrograms;
        return ListView(
          padding: const EdgeInsets.fromLTRB(MmcSpacing.l, 0, MmcSpacing.l, MmcSpacing.xl),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: MmcSpacing.l),
              child: Text(
                s.programsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            for (final p in programs) ...[
              ProgramCard(program: p, eventCount: data.eventsForProgram(p.id).length),
              const SizedBox(height: MmcSpacing.m),
            ],
          ],
        );
      }),
    );
  }
}

class ProgramCard extends StatelessWidget {
  const ProgramCard({
    super.key,
    required this.program,
    required this.eventCount,
    this.compact = false,
  });

  final Program program;
  final int eventCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final seed = program.title.codeUnits.fold<int>(0, (a, b) => a + b);
    final accent = MmcColors.logoColors[seed % MmcColors.logoColors.length];

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          program.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          s.eventsCount(eventCount),
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
        ),
        if (!compact && program.summary.isNotEmpty) ...[
          const SizedBox(height: MmcSpacing.s),
          Text(
            program.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );

    return MmcCard(
      semanticLabel: '${program.title}, ${s.eventsCount(eventCount)}',
      onTap: () => AppRouter.openProgram(context, program.id),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: accent),
            SizedBox(
              width: compact ? 72 : 96,
              child: AppImage(
                source: program.imageUrl,
                fallbackIcon: Icons.school_outlined,
                cacheWidth: 300,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(MmcSpacing.m),
                child: compact ? Center(child: info) : info,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
