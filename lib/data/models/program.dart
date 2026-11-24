/// An event series, mapped from `GET /api/programs`.
class Program {
  const Program({
    required this.id,
    required this.title,
    this.summary = '',
    this.imageUrl,
    this.isCommunityProgram = false,
  });

  final String id;
  final String title;
  final String summary;
  final String? imageUrl;
  final bool isCommunityProgram;

  factory Program.fromApi(Map<String, dynamic> json) => Program(
        id: '${json['id']}',
        title: (json['name'] as String? ?? json['title'] as String? ?? '').trim(),
        summary: (json['description'] as String? ?? '').trim(),
        imageUrl: json['image'] as String?,
        isCommunityProgram: json['isCommunityProgram'] == true,
      );
}
