import 'package:flutter/material.dart';

import '../features/community/community_screen.dart';
import '../features/events/event_details_screen.dart';
import '../features/programs/program_details_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/speakers/speaker_details_screen.dart';
import '../features/splash/splash_screen.dart';
import 'shell.dart';

/// Central route table. Detail routes carry their id in the path,
/// e.g. `/events/gaib-2024-tanger`.
class AppRouter {
  const AppRouter._();

  static const splash = '/splash';
  static const home = '/';
  static const community = '/community';
  static const settings = '/settings';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? home);
    final segments = uri.pathSegments;

    Widget page;
    if (uri.path == splash) {
      page = const SplashScreen();
    } else if (uri.path == home || segments.isEmpty) {
      page = const HomeShell();
    } else if (uri.path == community) {
      page = const CommunityScreen();
    } else if (uri.path == AppRouter.settings) {
      page = const SettingsScreen();
    } else if (segments.length == 2 && segments[0] == 'events') {
      page = EventDetailsScreen(eventId: segments[1]);
    } else if (segments.length == 2 && segments[0] == 'speakers') {
      page = SpeakerDetailsScreen(speakerId: segments[1]);
    } else if (segments.length == 2 && segments[0] == 'programs') {
      page = ProgramDetailsScreen(programId: segments[1]);
    } else {
      // Unknown paths (also skipped when building deep-link stacks).
      return null;
    }
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      MaterialPageRoute<void>(builder: (_) => const NotFoundScreen(), settings: settings);

  static Future<void> openEvent(BuildContext context, String id) =>
      Navigator.of(context).pushNamed('/events/${Uri.encodeComponent(id)}');

  static Future<void> openSpeaker(BuildContext context, String id) =>
      Navigator.of(context).pushNamed('/speakers/${Uri.encodeComponent(id)}');

  static Future<void> openProgram(BuildContext context, String id) =>
      Navigator.of(context).pushNamed('/programs/${Uri.encodeComponent(id)}');

  static Future<void> openCommunity(BuildContext context) =>
      Navigator.of(context).pushNamed(community);

  static Future<void> openSettings(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRouter.settings);
}
