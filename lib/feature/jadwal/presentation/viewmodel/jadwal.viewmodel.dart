import 'package:flutter/foundation.dart';
import '../../model/jadwal.model.dart';
import '../../repository/jadwal.repo.dart';

enum JadwalViewState { initial, loading, loaded, error }

class JadwalViewModel extends ChangeNotifier {
  final JadwalRepository _repository;

  JadwalViewModel({required JadwalRepository repository})
    : _repository = repository;

  JadwalViewState _state = JadwalViewState.initial;
  List<Holiday> _holidays = [];
  List<CalendarEvent> _calendarEvents = [];
  String _errorMessage = '';
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<CalendarEvent>> nevents = {};

  JadwalViewState get state => _state;
  List<Holiday> get holidays => List.unmodifiable(_holidays);
  List<CalendarEvent> get calendarEvents => List.unmodifiable(_calendarEvents);
  String get errorMessage => _errorMessage;
  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  Map<DateTime, List<CalendarEvent>> get events => Map.unmodifiable(nevents);

  bool get isLoading => _state == JadwalViewState.loading;
  bool get hasError => _state == JadwalViewState.error;
  bool get hasData => _state == JadwalViewState.loaded && _holidays.isNotEmpty;

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  List<CalendarEvent> getEventsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return nevents[dayKey] ?? [];
  }

  bool isHoliday(DateTime day) {
    return getEventsForDay(day).any((event) => event.isHoliday);
  }

  Future<void> loadCurrentYearHolidays() async {
    await _loadHolidays(() => _repository.getCurrentYearHolidays());
  }

  Future<void> loadMonthHolidays(int month, {int? year}) async {
    await _loadHolidays(() => _repository.getMonthHolidays(month, year: year));
  }

  Future<void> loadHolidaysForDateRange(DateTime start, DateTime end) async {
    await _loadHolidays(() => _repository.getHolidaysForDateRange(start, end));
  }

  Future<void> refreshHolidays() async {
    await loadCurrentYearHolidays();
  }

  Future<void> loadHolidaysForMonth(DateTime month) async {
    await loadMonthHolidays(month.month, year: month.year);
  }

  Future<void> _loadHolidays(
    Future<List<Holiday>> Function() loadFunction,
  ) async {
    try {
      _setState(JadwalViewState.loading);

      final holidays = await loadFunction();
      _holidays = holidays;
      _calendarEvents =
          holidays.map((h) => CalendarEvent.fromHoliday(h)).toList();

      _buildEventsMap();

      _setState(JadwalViewState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(JadwalViewState.error);

      if (kDebugMode) {
        print('Error loading holidays: $e');
      }
    }
  }

  void _buildEventsMap() {
    nevents.clear();

    for (final event in _calendarEvents) {
      final dayKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (nevents.containsKey(dayKey)) {
        nevents[dayKey]!.add(event);
      } else {
        nevents[dayKey] = [event];
      }
    }
  }

  void _setState(JadwalViewState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void clearError() {
    if (_state == JadwalViewState.error) {
      _setState(JadwalViewState.initial);
      _errorMessage = '';
    }
  }

  Future<void> onMonthChanged(DateTime month) async {
    _focusedDay = month;

    final monthEvents = _calendarEvents.where(
      (event) =>
          event.date.year == month.year && event.date.month == month.month,
    );

    if (monthEvents.isEmpty) {
      await loadMonthHolidays(month.month, year: month.year);
    }

    notifyListeners();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setSelectedDay(selectedDay);
    setFocusedDay(focusedDay);
  }

  Holiday? getHolidayForDay(DateTime day) {
    return _holidays.where((holiday) {
      final holidayDate = holiday.dateTime;
      return holidayDate.year == day.year &&
          holidayDate.month == day.month &&
          holidayDate.day == day.day;
    }).firstOrNull;
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
