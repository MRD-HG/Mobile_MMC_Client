import 'package:flutter/widgets.dart';

/// Lightweight, compile-checked EN/FR strings (no code generation needed).
/// Add a language by extending [_t] and [supportedLocales].
class S {
  const S._(this.languageCode);

  final String languageCode;

  static const supportedLocales = [Locale('en'), Locale('fr')];

  static S of(BuildContext context) {
    final code = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    return S._(code == 'fr' ? 'fr' : 'en');
  }

  bool get isFrench => languageCode == 'fr';

  String _t(String en, String fr) => isFrench ? fr : en;

  // Navigation
  String get navHome => _t('Home', 'Accueil');
  String get navEvents => _t('Events', 'Événements');
  String get navPrograms => _t('Programs', 'Programmes');
  String get navSpeakers => _t('Speakers', 'Intervenants');
  String get navSaved => _t('Saved', 'Favoris');

  // Common
  String get appName => 'Morocco Microsoft Community';
  String get retry => _t('Retry', 'Réessayer');
  String get loading => _t('Loading…', 'Chargement…');
  String get seeAll => _t('See all', 'Tout voir');
  String get search => _t('Search', 'Rechercher');
  String get errorTitle => _t('Something went wrong', 'Une erreur est survenue');
  String get errorBody => _t('We couldn\'t load the community content.',
      'Impossible de charger le contenu de la communauté.');
  String get linkError => _t('Couldn\'t open the link.', 'Impossible d\'ouvrir le lien.');
  String get notFound => _t('This page no longer exists.', 'Cette page n\'existe plus.');
  String get back => _t('Back', 'Retour');
  String get online => _t('Online', 'En ligne');
  String offlineBanner(String date) => _t(
      'Offline — showing data saved on $date.',
      'Hors ligne — données enregistrées le $date.');
  String get refreshing => _t('Updating…', 'Mise à jour…');
  String updatedOn(String date) => _t('Updated $date', 'Mis à jour le $date');

  // Home
  String get greeting => _t('Learn, share and grow with Microsoft technologies',
      'Apprendre, partager et progresser avec les technologies Microsoft');
  String get nextEvent => _t('Next event', 'Prochain événement');
  String get upcomingEvents => _t('Upcoming events', 'Événements à venir');
  String get latestEvents => _t('Latest events', 'Derniers événements');
  String get exploreTopics => _t('Explore by topic', 'Explorer par thème');
  String get meetSpeakers => _t('Meet the speakers', 'Les intervenants');
  String get ourPrograms => _t('Our programs', 'Nos programmes');
  String get noUpcomingTitle =>
      _t('No upcoming event announced yet', 'Aucun événement annoncé pour le moment');
  String get noUpcomingBody => _t(
      'New dates are published by MMC on its website. Meanwhile, browse past editions.',
      'Les nouvelles dates sont publiées par MMC sur son site. En attendant, parcourez les éditions passées.');
  String get visitWebsite => _t('Visit website', 'Visiter le site');
  String get statsEvents => _t('events', 'événements');
  String get statsCities => _t('cities', 'villes');
  String get statsSpeakers => _t('speakers', 'intervenants');

  // Events
  String get searchEvents => _t('Search events, cities, topics',
      'Rechercher événements, villes, thèmes');
  String get filterAll => _t('All', 'Tous');
  String get filterUpcoming => _t('Upcoming', 'À venir');
  String get filterPast => _t('Past', 'Passés');
  String get noEventsMatch =>
      _t('No event matches your search.', 'Aucun événement ne correspond à votre recherche.');
  String get clearFilters => _t('Clear filters', 'Effacer les filtres');
  String get upcomingBadge => _t('Upcoming', 'À venir');
  String get pastBadge => _t('Past', 'Terminé');
  String eventsCount(int n) => isFrench
      ? '$n événement${n > 1 ? 's' : ''}'
      : '$n event${n == 1 ? '' : 's'}';

  // Event details
  String get aboutEvent => _t('About the event', 'À propos');
  String get dateAndTime => _t('Date & time', 'Date et heure');
  String get location => _t('Location', 'Lieu');
  String get topics => _t('Topics', 'Thèmes');
  String get speakers => _t('Speakers', 'Intervenants');
  String get partners => _t('Hosts & partners', 'Hôtes et partenaires');
  String get gallery => _t('Gallery', 'Galerie');
  String get register => _t('Register', 'S\'inscrire');
  String get registerHint => _t(
      'Registration happens on the official MMC website.',
      'L\'inscription se fait sur le site officiel de MMC.');
  String get viewOnWebsite => _t('View on website', 'Voir sur le site');
  String get sessions => _t('Sessions', 'Sessions');
  String minutes(int n) => '$n min';
  String get organizedWith => _t('Co-organised with', 'Co-organisé avec');
  String get moreInfo => _t('More info', 'Plus d\'infos');
  String get addToCalendar => _t('Add to calendar', 'Ajouter au calendrier');
  String get save => _t('Save', 'Enregistrer');
  String get saved => _t('Saved', 'Enregistré');
  String get eventEnded => _t('This event has ended', 'Cet événement est terminé');
  String get addedToSaved => _t('Added to Saved', 'Ajouté aux favoris');
  String get removedFromSaved => _t('Removed from Saved', 'Retiré des favoris');

  // Programs
  String get programsSubtitle => _t('Event series run by the community',
      'Les séries d\'événements de la communauté');
  String get programEvents => _t('Editions', 'Éditions');
  String get communityProgram => _t('Community program', 'Programme communautaire');

  // Speakers
  String get searchSpeakers => _t('Search by name or expertise',
      'Rechercher par nom ou expertise');
  String get expertise => _t('Expertise', 'Expertise');
  String get spokeAt => _t('Spoke at', 'Est intervenu·e à');
  String get connect => _t('Connect', 'Réseaux');
  String get noSpeakersMatch =>
      _t('No speaker matches your search.', 'Aucun intervenant ne correspond.');

  // Saved
  String get savedEmptyTitle => _t('No saved events yet', 'Aucun événement enregistré');
  String get savedEmptyBody => _t('Tap the bookmark icon on an event to keep it here.',
      'Touchez l\'icône signet d\'un événement pour le retrouver ici.');
  String get browseEvents => _t('Browse events', 'Parcourir les événements');

  // Community
  String get community => _t('Community', 'Communauté');
  String get aboutMmc => _t('About MMC', 'À propos de MMC');
  String get focusAreas => _t('Focus areas', 'Domaines');
  String get officialLinks => _t('Official links', 'Liens officiels');
  String get moments => _t('Community moments', 'Moments de la communauté');
  String get contact => _t('Contact', 'Contact');
  String get ourPartners => _t('Partners', 'Partenaires');
  String get requestEvent => _t('Request an event', 'Demander un événement');

  // Settings
  String get settings => _t('Settings', 'Paramètres');
  String get appearance => _t('Appearance', 'Apparence');
  String get themeSystem => _t('System', 'Système');
  String get themeLight => _t('Light', 'Clair');
  String get themeDark => _t('Dark', 'Sombre');
  String get language => _t('Language', 'Langue');
  String get languageSystem => _t('Device language', 'Langue de l\'appareil');
  String get favoriteTopics => _t('Favourite topics', 'Thèmes favoris');
  String get favoriteTopicsHint => _t('Events on these topics are highlighted on Home.',
      'Les événements sur ces thèmes sont mis en avant sur l\'accueil.');
  String get about => _t('About', 'À propos');
  String get dataNotice => _t(
      'Events, speakers and programs come from the official MMC website '
          '(moroccomicrosoftcommunity.com). A copy is bundled for offline use.',
      'Les événements, intervenants et programmes proviennent du site officiel '
          'de MMC (moroccomicrosoftcommunity.com). Une copie est incluse pour un usage hors ligne.');
  String get dataSource => _t('Data source', 'Source des données');
  String get offlineMode => _t('Offline copy', 'Copie hors ligne');
  String get liveMode => _t('Live — MMC website', 'En direct — site MMC');
  String get refreshNow => _t('Refresh now', 'Actualiser');
  String get version => _t('Version', 'Version');
}

extension StringsX on BuildContext {
  S get s => S.of(this);
}
