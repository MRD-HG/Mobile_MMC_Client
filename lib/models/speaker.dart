// models/speaker.dart
class Speaker {
  final String id;
  final String name;
  final String role;
  final String image;
  final SocialLinks social;

  Speaker({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
    required this.social,
  });
}

class SocialLinks {
  final String? facebook;
  final String? linkedin;
  final String? instagram;

  SocialLinks({this.facebook, this.linkedin, this.instagram});
}