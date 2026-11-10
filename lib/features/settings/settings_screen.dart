import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/content_repository.dart';
import '../events/event_details_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const appVersion = '2.0.0';

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scope = AppScope.of(context);
    final settings = scope.settings;
    final content = scope.content;

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListenableBuilder(
        listenable: Listenable.merge([settings, content]),
        builder: (context, _) {
          final theme = Theme.of(context);
          final data = content.data;
          final topics = data?.allTopics ?? const <String>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(MmcSpacing.l, 0, MmcSpacing.l, MmcSpacing.xl),
            children: [
              SectionTitle(s.appearance),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_outlined),
                      label: Text(s.themeSystem)),
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(s.themeLight)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(s.themeDark)),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (v) => settings.setThemeMode(v.first),
              ),
              SectionTitle(s.language),
              MmcCard(
                child: Column(
                  children: [
                    for (final option in <(String?, String)>[
                      (null, s.languageSystem),
                      ('fr', 'Français'),
                      ('en', 'English'),
                    ])
                      ListTile(
                        title: Text(option.$2),
                        trailing: settings.localeCode == option.$1
                            ? Icon(Icons.check, color: theme.colorScheme.primary)
                            : null,
                        selected: settings.localeCode == option.$1,
                        onTap: () => settings.setLocaleCode(option.$1),
                      ),
                  ],
                ),
              ),
              if (topics.isNotEmpty) ...[
                SectionTitle(s.favoriteTopics),
                Text(s.favoriteTopicsHint,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: MmcSpacing.s),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final t in topics)
                      TopicChip(
                        t,
                        selected: settings.favoriteTopics.contains(t),
                        onTap: () => settings.toggleTopic(t),
                      ),
                  ],
                ),
              ],
              SectionTitle(s.dataSource),
              MmcCard(
                child: ListTile(
                  leading: Icon(data?.origin == ContentOrigin.live
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined),
                  title: Text(data?.origin == ContentOrigin.live ? s.liveMode : s.offlineMode),
                  subtitle: data?.updatedAt == null
                      ? null
                      : Text(s.updatedOn(Formatters.longDate(
                          data!.updatedAt!.toLocal(), s.languageCode))),
                  trailing: content.refreshing
                      ? const SizedBox.square(
                          dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          tooltip: s.refreshNow,
                          icon: const Icon(Icons.refresh),
                          onPressed: content.refresh,
                        ),
                ),
              ),
              const SizedBox(height: MmcSpacing.s),
              Text(s.dataNotice,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              SectionTitle(s.about),
              MmcCard(
                child: ListTile(
                  leading: Image.asset('assets/images/brand/mmc_mark.png', width: 36),
                  title: Text(s.appName),
                  subtitle: Text('${s.version} $appVersion'),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'MMC',
                    applicationVersion: appVersion,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
