import '../../core/config/app_config.dart';

/// A speaker slot inside an event.
class EventSession {
  const EventSession({required this.speakerId, this.title, this.durationMinutes});

  final String speakerId;
  final String? title;
  final int? durationMinutes;

  /// The API sometimes prefixes titles with "Session Title:".
  String? get cleanTitle {
    final t = title?.replaceFirst(RegExp(r'^\s*session title\s*:\s*', caseSensitive: false), '').trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

class EventMedia {
  const EventMedia({required this.url, this.thumbnail, this.isVideo = false});

  final String url;
  final String? thumbnail;
  final bool isVideo;

  /// Best URL to show as a still image.
  String? get imageUrl => isVideo ? thumbnail : (thumbnail ?? url);
}

/// A community event, mapped from `GET /api/events` of moroccomicrosoftcommunity.com.
class MmcEvent {
  const MmcEvent({
    required this.id,
    required this.title,
    required this.start,
    this.slug,
    this.end,
    this.timeLabel,
    this.programId,
    this.city,
    this.venue,
    this.isOnline = false,
    this.description = '',
    this.media = const [],
    this.sessions = const [],
    this.partners = const [],
    this.club,
    this.externalRegistrationUrl,
    this.isFeatured = false,
    this.topics = const [],
  });

  final String id;
  final String? slug;
  final String title;
  final DateTime start;
  final DateTime? end;

  /// Time exactly as published (e.g. "09:00 AM - 05:00 PM").
  final String? timeLabel;
  final String? programId;
  final String? city;
  final String? venue;
  final bool isOnline;
  final String description;
  final List<EventMedia> media;
  final List<EventSession> sessions;
  final List<String> partners;

  /// Student club co-organising the event, if any.
  final String? club;
  final String? externalRegistrationUrl;
  final bool isFeatured;

  /// Keywords detected in the title/description (AI, Azure, GitHub...).
  final List<String> topics;

  List<String> get speakerIds => sessions.map((s) => s.speakerId).toList();

  /// First still image, used as the cover.
  String? get image {
    for (final m in media) {
      final url = m.imageUrl;
      if (url != null) return url;
    }
    return null;
  }

  List<String> get galleryImages =>
      media.map((m) => m.imageUrl).whereType<String>().toList(growable: false);

  /// Official page of the event on the MMC website.
  String? get webUrl =>
      slug == null ? null : '${AppConfig.websiteUrl}/events/${Uri.encodeComponent(slug!)}';

  /// Where to register: external page if the organiser uses one, otherwise
  /// the MMC website (which handles registration itself).
  String? get registrationUrl => externalRegistrationUrl ?? webUrl;

  DateTime get effectiveEnd {
    final e = end;
    if (e != null && e.isAfter(start)) return e;
    return start.add(const Duration(hours: 8));
  }

  bool isUpcoming(DateTime now) => effectiveEnd.isAfter(now);

  String get displayCity => isOnline ? 'Online' : (city ?? '');

  String get location {
    if (isOnline) return 'Online';
    return [venue, city]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.toLowerCase() != 'online event')
        .toSet()
        .join(', ');
  }

  bool matches(String query) {
    final q = _fold(query.trim());
    if (q.isEmpty) return true;
    return _fold(title).contains(q) ||
        _fold(city ?? '').contains(q) ||
        _fold(venue ?? '').contains(q) ||
        topics.any((t) => _fold(t).contains(q));
  }

  factory MmcEvent.fromApi(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime(1970);
    final endDate = DateTime.tryParse(json['endDate'] as String? ?? '');
    final timeLabel = (json['time'] as String?)?.trim();
    final times = parseTimeRange(timeLabel);
    final start = _at(date, times.$1 ?? const (9, 0));
    DateTime? end;
    if (times.$2 != null) {
      end = _at(endDate ?? date, times.$2!);
    } else if (endDate != null && endDate.isAfter(date)) {
      end = _at(endDate, const (18, 0));
    }

    final title = (json['title'] as String? ?? '').trim();
    final description = stripHtml(json['description'] as String? ?? '');
    final isOnline = json['isOnline'] == true ||
        (json['city'] as String? ?? '').trim().toLowerCase() == 'online';

    final media = <EventMedia>[];
    for (final m in (json['media'] as List? ?? const [])) {
      if (m is! Map) continue;
      final url = m['url'];
      if (url is! String || url.isEmpty) continue;
      media.add(EventMedia(
        url: url,
        thumbnail: m['thumbnail'] as String?,
        isVideo: m['type'] == 'video',
      ));
    }

    final sessions = <EventSession>[];
    for (final s in (json['speakers'] as List? ?? const [])) {
      if (s is! Map || s['id'] == null) continue;
      sessions.add(EventSession(
        speakerId: '${s['id']}',
        title: s['sessionTitle'] as String?,
        durationMinutes: (s['sessionDuration'] as num?)?.toInt(),
      ));
    }

    final partners = <String>[];
    for (final p in (json['partners'] as List? ?? const [])) {
      if (p is String) partners.add(p);
      if (p is Map && p['name'] is String) partners.add(p['name'] as String);
    }

    final club = json['club'];
    final external = json['externalRegistrationUrl'] as String?;

    return MmcEvent(
      id: '${json['id']}',
      slug: json['slug'] as String?,
      title: title,
      start: start,
      end: end,
      timeLabel: (timeLabel == null || timeLabel.isEmpty) ? null : timeLabel,
      programId: json['programId'] as String?,
      city: isOnline ? null : _clean(json['city'] as String?),
      venue: _clean(json['location'] as String?),
      isOnline: isOnline,
      description: description,
      media: media,
      sessions: sessions,
      partners: partners,
      club: club is Map ? club['name'] as String? : null,
      externalRegistrationUrl: json['registrationMode'] == 'external' &&
              external != null &&
              external.startsWith('http')
          ? external
          : null,
      isFeatured: json['isFeatured'] == true,
      topics: detectTopics('$title\n$description'),
    );
  }
}

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

DateTime _at(DateTime day, (int, int) hm) =>
    DateTime(day.year, day.month, day.day, hm.$1, hm.$2);

/// Parses free-text times such as "9:30", "09:00 - 17:00",
/// "09:00 AM - 05:00 PM", "9:00am - 4:00pm", "20h00".
((int, int)?, (int, int)?) parseTimeRange(String? input) {
  if (input == null || input.trim().isEmpty) return (null, null);
  final re = RegExp(r'(\d{1,2})\s*(?:([:h.])\s*(\d{2})?)?\s*([ap])?\.?\s*m?\.?',
      caseSensitive: false);
  final found = <(int, int)>[];
  for (final m in re.allMatches(input)) {
    var h = int.parse(m.group(1)!);
    final min = m.group(3) == null ? 0 : int.parse(m.group(3)!);
    final ap = m.group(4)?.toLowerCase();
    // A bare number without separator or am/pm is probably not a time.
    if (m.group(2) == null && ap == null) continue;
    if (ap == 'p' && h < 12) h += 12;
    if (ap == 'a' && h == 12) h = 0;
    if (h > 23 || min > 59) continue;
    found.add((h, min));
    if (found.length == 2) break;
  }
  return (found.isNotEmpty ? found[0] : null, found.length > 1 ? found[1] : null);
}

String stripHtml(String input) => input
    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'</(p|li|h\d)>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&#39;', "'")
    .replaceAll('&quot;', '"')
    .replaceAll(RegExp(r'[ \t]+\n'), '\n')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

/// Keyword → label. Only words that literally appear in the event text.
const _topicRules = <String, String>{
  r'copilot': 'Copilot',
  r'github': 'GitHub',
  r'azure': 'Azure',
  r'devops': 'DevOps',
  r'\b(ai|ia|ml|genai)\b|intelligence artificielle|artificial intelligence|machine learning|\bagent': 'AI',
  r'\bdata\b|données|fabric|power ?bi|sql': 'Data',
  r'\.net\b|dotnet|c#': '.NET',
  r'power (platform|apps|automate)': 'Power Platform',
  r'secur|sécurité|cyber': 'Security',
  r'cloud': 'Cloud',
  r'microsoft 365|m365|office 365': 'Microsoft 365',
};

List<String> detectTopics(String text) {
  final lower = text.toLowerCase();
  return [
    for (final entry in _topicRules.entries)
      if (RegExp(entry.key, caseSensitive: false).hasMatch(lower)) entry.value,
  ];
}

/// Case/accent-insensitive comparison helper for search.
String _fold(String s) {
  const from = 'àâäáãéèêëíìîïóòôöõúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final buf = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    buf.write(i >= 0 ? to[i] : ch);
  }
  return buf.toString();
}
