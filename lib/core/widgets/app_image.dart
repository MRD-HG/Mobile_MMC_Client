import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Displays an asset or network image with a branded fallback, so a missing
/// file or no connectivity never shows a broken image.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.fallbackLabel,
    this.fallbackIcon = Icons.event_outlined,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.semanticLabel,
  });

  final String? source;
  final BoxFit fit;
  final String? fallbackLabel;
  final IconData fallbackIcon;
  final Alignment alignment;

  /// Decode width in physical pixels (saves memory for thumbnails).
  final int? cacheWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final src = source;
    final placeholder = BrandPlaceholder(label: fallbackLabel, icon: fallbackIcon);
    if (src == null || src.isEmpty) return placeholder;

    if (src.startsWith('http')) {
      return Image.network(
        src,
        fit: fit,
        alignment: alignment,
        cacheWidth: cacheWidth,
        semanticLabel: semanticLabel,
        errorBuilder: (_, __, ___) => placeholder,
        frameBuilder: (context, child, frame, wasSyncLoaded) {
          if (wasSyncLoaded || frame != null) return child;
          return const ShimmerBox();
        },
      );
    }
    return Image.asset(
      src,
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

/// Neutral box shown while a network image loads.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const SizedBox.expand(),
    );
  }
}

/// Gradient tile with the MMC colours, used when an event has no picture.
class BrandPlaceholder extends StatelessWidget {
  const BrandPlaceholder({super.key, this.label, this.icon = Icons.event_outlined});

  final String? label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final seed = (label ?? '').codeUnits.fold<int>(0, (a, b) => a + b);
    final accent = MmcColors.logoColors[seed % MmcColors.logoColors.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MmcColors.brandDark, MmcColors.brand, accent],
          stops: const [0, 0.6, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 140, color: Colors.white.withAlpha(30)),
          ),
          if (label != null)
            Padding(
              padding: const EdgeInsets.all(MmcSpacing.l),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  label!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Circular avatar: network photo → bundled photo → initials.
class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    required this.url,
    required this.initials,
    this.localAsset,
    this.size = 56,
  });

  final String? url;
  final String? localAsset;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final decode = (size * dpr).round();
    final initialsWidget = Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );
    Widget local() => localAsset == null
        ? initialsWidget
        : Image.asset(
            localAsset!,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.6),
            cacheWidth: decode,
            errorBuilder: (_, __, ___) => initialsWidget,
          );

    final remote = url;
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: remote == null
            ? local()
            : Image.network(
                remote,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.6),
                cacheWidth: decode,
                errorBuilder: (_, __, ___) => local(),
                frameBuilder: (context, child, frame, sync) =>
                    (sync || frame != null) ? child : local(),
              ),
      ),
    );
  }
}
