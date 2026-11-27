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

/// A filter preset another tab can hand to the Events tab
/// (e.g. tapping a topic chip on Home).
class EventsFilterRequest {
  const EventsFilterRequest({this.topic, this.time});

  final String? topic;
  final EventTimeFilter? time;
}

/// Pure filtering logic, unit-tested separately from the UI.
/// All criteria combine (AND).
List<MmcEvent> filterEvents(
  List<MmcEvent> events, {
  required DateTime now,
  String query = '',
  EventTimeFilter time = EventTimeFilter.all,
  String? topic,
  String? city,
  String? programId,
}) {
  final result = events.where((e) {
    if (time == EventTimeFilter.upcoming && !e.isUpcoming(now)) return false;
    if (time == EventTimeFilter.past && e.isUpcoming(now)) return false;
    if (topic != null && !e.topics.contains(topic)) return false;
    if (city != null) {
      if (city == 'Online') {
        if (!e.isOnline) return false;
      } else if (e.city != city) {
        return false;
      }
    }
    if (programId != null && e.programId != programId) return false;
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
  String? _city;
  String? _programId;
  ValueNotifier<EventsFilterRequest?>? _request;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = HomeShell.filterRequestOf(context);
    if (request != _request) {
      _request?.removeListener(_onRequest);
      _request = request?..addListener(_onRequest);
      _onRequest();
    }
  }

  void _onRequest() {
    final req = _request?.value;
    if (req == null) return;
    _request!.value = null;
    // Listener may fire during a build of the shell: defer setState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _topic = req.topic;
        _time = req.time ?? EventTimeFilter.all;
        _city = null;
        _programId = null;
        _searchController.clear();
      });
    });
  }

  @override
  void dispose() {
    _request?.removeListener(_onRequest);
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount =>
      (_topic != null ? 1 : 0) +
      (_city != null ? 1 : 0) +
      (_programId != null ? 1 : 0) +
      (_time != EventTimeFilter.all ? 1 : 0) +
      (_searchController.text.trim().isNotEmpty ? 1 : 0);

  void _clear() => setState(() {
        _searchController.clear();
        _topic = null;
        _city = null;
        _programId = null;
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
      city: _city,
      programId: _programId,
    );
    final cities = ['Online', ...data.cities.toList()..sort()];
    final double scale =
        (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.8).toDouble();

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(MmcSpacing.l, MmcSpacing.m, MmcSpacing.l, 0),
              child: Row(
                children: [
                  Expanded(
                    child: FilterDropdown(
                      label: s.filterCity,
                      value: _city,
                      allLabel: s.filterAll,
                      items: [for (final c in cities) (c, c)],
                      onChanged: (v) => setState(() => _city = v),
                    ),
                  ),
                  const SizedBox(width: MmcSpacing.s),
                  Expanded(
                    child: FilterDropdown(
                      label: s.filterProgram,
                      value: _programId,
                      allLabel: s.filterAll,
                      items: [
                        for (final p in data.allProgramsByActivity) (p.id, p.title),
                      ],
                      onChanged: (v) => setState(() => _programId = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56 * scale,
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _activeFilterCount > 0
                          ? '${s.eventsCount(events.length)} · ${s.activeFilters(_activeFilterCount)}'
                          : s.eventsCount(events.length),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                  if (_activeFilterCount > 0)
                    TextButton.icon(
                      onPressed: _clear,
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: Text(s.clearFilters),
                    ),
                ],
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
                title: _time == EventTimeFilter.upcoming && _activeFilterCount <= 1
                    ? s.noUpcomingTitle
                    : s.noEventsMatch,
                body: _time == EventTimeFilter.upcoming && _activeFilterCount <= 1
                    ? s.noUpcomingBody
                    : null,
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

/// Compact dropdown used for the city and program filters.
class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.allLabel,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final String allLabel;

  /// (value, display) pairs.
  final List<(String, String)> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        filled: true,
        fillColor: AppTheme.cardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MmcRadius.button),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MmcRadius.button),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(MmcRadius.button),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(allLabel)),
            for (final (v, text) in items)
              DropdownMenuItem<String?>(
                value: v,
                child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
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
