import '../../core/config/app_config.dart';

enum SocialKind { linkedin, github, x, instagram, facebook, youtube, website }

class SocialLink {
  const SocialLink(this.kind, this.url);

  final SocialKind kind;
  final String url;

  /// Classifies by host rather than by the API key, because some profiles
  /// store e.g. an Instagram URL in the "twitter" field.
  static SocialLink? tryParse(String? raw) {
    if (raw == null) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http') || uri.host.isEmpty) {
      return null;
    }
    final host = uri.host.toLowerCase();
    final hasPath = uri.pathSegments.where((s) => s.isNotEmpty).isNotEmpty;
    SocialKind kind;
    if (host.contains('linkedin.com')) {
      kind = SocialKind.linkedin;
    } else if (host.contains('github.com')) {
      kind = SocialKind.github;
    } else if (host == 'x.com' || host.endsWith('.x.com') || host.contains('twitter.com')) {
      kind = SocialKind.x;
    } else if (host.contains('instagram.com')) {
      kind = SocialKind.instagram;
    } else if (host.contains('facebook.com')) {
      kind = SocialKind.facebook;
    } else if (host.contains('youtube.com')) {
      kind = SocialKind.youtube;
    } else {
      kind = SocialKind.website;
    }
    // Bare social-network home pages ("https://x.com/") are placeholders.
    if (kind != SocialKind.website && !hasPath) return null;
    return SocialLink(kind, uri.toString());
  }
}

/// A community speaker, mapped from `GET /api/speakers`.
class Speaker {
  const Speaker({
    required this.id,
    required this.name,
    this.slug,
    this.title = '',
    this.bio,
    this.avatarUrl,
    this.links = const [],
  });

  final String id;
  final String? slug;
  final String name;
  final String title;
  final String? bio;
  final String? avatarUrl;
  final List<SocialLink> links;

  /// Bundled photo used when offline (only for the founding team).
  String? get localAvatar =>
      slug != null && _bundledAvatars.contains(slug) ? 'assets/images/speakers/${slug!.replaceAll('-', '_')}.jpg' : null;

  static const _bundledAvatars = {
    'anas-belabbes',
    'hassan-fadili',
    'mohssine-masaaf',
    'outman-bazzaz',
    'said-wahid',
    'youssef-chigane',
  };

  /// "Hassan Fadili", "Said WAHID" → "Said Wahid".
  String get displayName => name
      .trim()
      .split(RegExp(r'\s+'))
      .map((w) => w.length > 1 && w == w.toUpperCase()
          ? '${w[0]}${w.substring(1).toLowerCase()}'
          : w)
      .join(' ');

  String get initials {
    final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// Title split on "|" for display as tags.
  List<String> get roles => title
      .split('|')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);

  bool get isMvp => title.toLowerCase().contains('mvp');

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        title.toLowerCase().contains(q) ||
        (bio?.toLowerCase().contains(q) ?? false);
  }

  factory Speaker.fromApi(Map<String, dynamic> json) {
    final links = <SocialLink>[];
    final seen = <String>{};
    final social = json['social'];
    if (social is Map) {
      for (final value in social.values) {
        final link = SocialLink.tryParse(value is String ? value : null);
        if (link != null && seen.add(link.url)) links.add(link);
      }
    }
    final avatar = (json['avatar'] as String?)?.trim();
    return Speaker(
      id: '${json['id']}',
      slug: json['slug'] as String?,
      name: (json['name'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      bio: (json['bio'] as String?)?.trim(),
      avatarUrl: _absolute(avatar),
      links: links,
    );
  }
}

String? _absolute(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http')) return url;
  if (url.startsWith('/')) return '${AppConfig.websiteUrl}$url';
  return null;
}
