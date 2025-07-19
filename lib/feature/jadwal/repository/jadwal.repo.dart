import '../model/jadwal.model.dart';
import '../service/jadwal.service.dart';

abstract class JadwalRepository {
  Future<List<Holiday>> getHolidays({int? month, int? year});
  Future<List<Holiday>> getCurrentYearHolidays();
  Future<List<Holiday>> getMonthHolidays(int month, {int? year});
  Future<List<CalendarEvent>> getCalendarEvents({int? month, int? year});
  Future<List<Holiday>> getHolidaysForDateRange(DateTime start, DateTime end);
}

class JadwalRepositoryImpl implements JadwalRepository {
  final JadwalService _service;

  JadwalRepositoryImpl({required JadwalService service}) : _service = service;

  @override
  Future<List<Holiday>> getHolidays({int? month, int? year}) async {
    try {
      final response = await _service.getHolidays(month: month, year: year);
      return response.holidays;
    } catch (e) {
      throw Exception('Failed to get holidays: $e');
    }
  }

  @override
  Future<List<Holiday>> getCurrentYearHolidays() async {
    try {
      final response = await _service.getCurrentYearHolidays();
      return response.holidays;
    } catch (e) {
      throw Exception('Failed to get current year holidays: $e');
    }
  }

  @override
  Future<List<Holiday>> getMonthHolidays(int month, {int? year}) async {
    try {
      final response = await _service.getMonthHolidays(month, year: year);
      return response.holidays;
    } catch (e) {
      throw Exception('Failed to get month holidays: $e');
    }
  }

  @override
  Future<List<CalendarEvent>> getCalendarEvents({int? month, int? year}) async {
    try {
      final holidays = await getHolidays(month: month, year: year);
      return holidays
          .map((holiday) => CalendarEvent.fromHoliday(holiday))
          .toList();
    } catch (e) {
      throw Exception('Failed to get calendar events: $e');
    }
  }

  @override
  Future<List<Holiday>> getHolidaysForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      Set<Holiday> allHolidays = {};

      DateTime current = DateTime(start.year, start.month, 1);
      DateTime endMonth = DateTime(end.year, end.month, 1);

      while (current.isBefore(endMonth) || current.isAtSameMomentAs(endMonth)) {
        final monthHolidays = await getMonthHolidays(
          current.month,
          year: current.year,
        );

        final filteredHolidays = monthHolidays.where((holiday) {
          final holidayDate = holiday.dateTime;
          return (holidayDate.isAfter(start) ||
                  holidayDate.isAtSameMomentAs(start)) &&
              (holidayDate.isBefore(end) || holidayDate.isAtSameMomentAs(end));
        });

        allHolidays.addAll(filteredHolidays);

        if (current.month == 12) {
          current = DateTime(current.year + 1, 1, 1);
        } else {
          current = DateTime(current.year, current.month + 1, 1);
        }
      }

      return allHolidays.toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      throw Exception('Failed to get holidays for date range: $e');
    }
  }
}
