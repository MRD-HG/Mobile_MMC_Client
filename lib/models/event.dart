// models/event.dart
class Event {
  final String id;
  final String title;
  final String address;
  final String description;
  final String imagePath;
  final DateTime startDate;
  final DateTime endDate;
  final String programId;
  final Program program;
  final List<Session> sessions;

  Event({
    required this.id,
    required this.title,
    required this.address,
    required this.description,
    required this.imagePath,
    required this.startDate,
    required this.endDate,
    required this.programId,
    required this.program,
    required this.sessions,
  });
}

class Program {
  final String id;
  final String title;
  final List<Event> events;

  Program({
    required this.id,
    required this.title,
    required this.events,
  });
}

class Session {
  final String id;
  final String name;
  final int numPlace;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  Session({
    required this.id,
    required this.name,
    required this.numPlace,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}