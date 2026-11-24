import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../l10n/strings.dart';

/// Rounded surface used for every card in the app.
class MmcCard extends StatelessWidget {
  const MmcCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(MmcRadius.card);
    final card = Material(
      color: color ?? AppTheme.cardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant.withAlpha(110)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
    if (semanticLabel == null) return card;
    return Semantics(button: onTap != null, label: semanticLabel, child: card);
  }
}

/// The four MMC logo colours as a thin decorative stripe.
class LogoStripe extends StatelessWidget {
  const LogoStripe({super.key, this.height = 4, this.radius = 2});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              for (final c in MmcColors.logoColors) Expanded(child: ColoredBox(color: c)),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(MmcSpacing.l, MmcSpacing.xl, MmcSpacing.s, MmcSpacing.s),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class TopicChip extends StatelessWidget {
  const TopicChip(this.label, {super.key, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = MmcColors.forTopic(label);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? color : color.withAlpha(isDark ? 50 : 30),
        borderRadius: BorderRadius.circular(MmcRadius.chip),
        border: Border.all(color: color.withAlpha(selected ? 255 : 90)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : (isDark ? Colors.white : _darken(color)),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
    if (onTap == null) return chip;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(MmcRadius.chip),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Center(widthFactor: 1, child: chip),
        ),
      ),
    );
  }

  static Color _darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor();
  }
}

/// Small pill, e.g. "Upcoming", "Microsoft MVP".
class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(MmcRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: context.s.loading,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: EdgeInsets.all(compact ? MmcSpacing.l : MmcSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: compact ? 24 : 36,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(icon,
                size: compact ? 24 : 36, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: MmcSpacing.l),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          if (body != null) ...[
            const SizedBox(height: MmcSpacing.s),
            Text(body!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: MmcSpacing.l),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
    return compact ? content : Center(child: SingleChildScrollView(child: content));
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return MessageView(
      icon: Icons.cloud_off_outlined,
      title: s.errorTitle,
      body: s.errorBody,
      actionLabel: s.retry,
      onAction: onRetry,
    );
  }
}
