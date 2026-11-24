class CommunityLink {
  const CommunityLink({required this.type, required this.label, required this.url});

  final String type;
  final String label;
  final String url;

  factory CommunityLink.fromJson(Map<String, dynamic> json) => CommunityLink(
        type: json['type'] as String? ?? 'website',
        label: json['label'] as String? ?? '',
        url: json['url'] as String,
      );
}

class Partner {
  const Partner({required this.name, this.url});

  final String name;
  final String? url;

  factory Partner.fromJson(Map<String, dynamic> json) =>
      Partner(name: json['name'] as String, url: json['url'] as String?);
}

/// Static community information (assets/data/community.json).
class CommunityInfo {
  const CommunityInfo({
    required this.name,
    required this.shortName,
    required this.about,
    this.motto,
    this.focus = const [],
    this.email,
    this.links = const [],
    this.partners = const [],
    this.gallery = const [],
    this.source,
  });

  final String name;
  final String shortName;

  /// Language code → text.
  final Map<String, String> about;
  final String? motto;
  final List<String> focus;
  final String? email;
  final List<CommunityLink> links;
  final List<Partner> partners;
  final List<String> gallery;
  final String? source;

  String aboutFor(String languageCode) =>
      about[languageCode] ?? about['en'] ?? (about.isEmpty ? '' : about.values.first);

  factory CommunityInfo.fromJson(Map<String, dynamic> json) {
    final about = <String, String>{};
    final rawAbout = json['about'];
    if (rawAbout is Map) {
      rawAbout.forEach((k, v) {
        if (v is String) about['$k'] = v;
      });
    } else if (rawAbout is String) {
      about['en'] = rawAbout;
    }
    List<Map<String, dynamic>> maps(Object? v) =>
        (v as List? ?? const []).whereType<Map<String, dynamic>>().toList();
    return CommunityInfo(
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? 'MMC',
      about: about,
      motto: json['motto'] as String?,
      focus: (json['focus'] as List? ?? const []).whereType<String>().toList(),
      email: json['email'] as String?,
      links: maps(json['links']).map(CommunityLink.fromJson).toList(),
      partners: maps(json['partners']).map(Partner.fromJson).toList(),
      gallery: (json['gallery'] as List? ?? const []).whereType<String>().toList(),
      source: json['source'] as String?,
    );
  }
}
