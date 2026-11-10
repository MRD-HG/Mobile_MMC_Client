import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/strings.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/content_builder.dart';
import '../../data/models/event.dart';
import '../../data/repositories/content_repository.dart';
import 'widgets/event_card.dart';

enum EventTimeFilter { all, upcoming, past }

/// Pure filtering logic, unit-tested separately from the UI.
List<MmcEvent> filterEvents(
  List<MmcEvent> events, {
  required DateTime now,
  String query = '',
  EventTimeFilter time = EventTimeFilter.all,
  String? topic,
}) {
  final result = events.where((e) {
    if (time == EventTimeFilter.upcoming && !e.isUpcoming(now)) return false;
    if (time == EventTimeFilter.past && e.isUpcoming(now)) return false;
    if (topic != null && !e.topics.contains(topic)) return false;
    return e.matches(query);
  }).toList();
  if (time == EventTimeFilter.upcoming) {
    result.sort((a, b) => a.start.compareTo(b.start));
  }
  return result;
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _searchController = TextEditingController();
  EventTimeFilter _time = EventTimeFilter.all;
  String? _topic;
  ValueNotifier<String?>? _topicRequest;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = HomeShell.topicRequestOf(context);
    if (request != _topicRequest) {
      _topicRequest?.removeListener(_onTopicRequest);
      _topicRequest = request?..addListener(_onTopicRequest);
      _onTopicRequest();
    }
  }

  void _onTopicRequest() {
    final topic = _topicRequest?.value;
    if (topic == null) return;
    _topicRequest!.value = null;
    // Listener may fire during a build of the shell: defer setState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _topic = topic;
        _time = EventTimeFilter.all;
        _searchController.clear();
      });
    });
  }

  @override
  void dispose() {
    _topicRequest?.removeListener(_onTopicRequest);
    _searchController.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
        _searchController.clear();
        _topic = null;
        _time = EventTimeFilter.all;
      });

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.navEvents)),
      body: ContentBuilder(builder: (context, data) => _buildBody(context, data)),
    );
  }

  Widget _buildBody(BuildContext context, ContentBundle data) {
    final s = context.s;
    final scope = AppScope.of(context);
    final now = scope.clock();
    final events = filterEvents(
      data.events,
      now: now,
      query: _searchController.text,
      time: _time,
      topic: _topic,
    );

    return RefreshIndicator(
      onRefresh: scope.content.refresh,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(MmcSpacing.l, MmcSpacing.s, MmcSpacing.l, 0),
            child: SearchField(
              controller: _searchController,
              hint: s.searchEvents,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(MmcSpacing.l, MmcSpacing.m, MmcSpacing.l, 0),
            child: SegmentedButton<EventTimeFilter>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: EventTimeFilter.all, label: Text(s.filterAll)),
                ButtonSegment(value: EventTimeFilter.upcoming, label: Text(s.filterUpcoming)),
                ButtonSegment(value: EventTimeFilter.past, label: Text(s.filterPast)),
              ],
              selected: {_time},
              onSelectionChanged: (v) => setState(() => _time = v.first),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: MmcSpacing.l, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: data.allTopics.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final t = data.allTopics[i];
                return TopicChip(
                  t,
                  selected: _topic == t,
                  onTap: () => setState(() => _topic = _topic == t ? null : t),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(MmcSpacing.l, 0, MmcSpacing.l, MmcSpacing.s),
            child: Text(
              s.eventsCount(events.length),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        if (events.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: MessageView(
              icon: _time == EventTimeFilter.upcoming
                  ? Icons.event_available_outlined
                  : Icons.search_off,
              title: _time == EventTimeFilter.upcoming &&
                      _searchController.text.isEmpty &&
                      _topic == null
                  ? s.noUpcomingTitle
                  : s.noEventsMatch,
              body: _time == EventTimeFilter.upcoming ? s.noUpcomingBody : null,
              actionLabel: s.clearFilters,
              onAction: _clear,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                MmcSpacing.l, 0, MmcSpacing.l, MmcSpacing.xl),
            sliver: SliverList.separated(
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: MmcSpacing.l),
              itemBuilder: (context, i) => EventCard(event: events[i]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded search box shared by Events and Speakers.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(MmcRadius.button),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
        filled: true,
        fillColor: AppTheme.cardColor(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}
