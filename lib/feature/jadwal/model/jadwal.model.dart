class HolidayResponse {
  final List<Holiday> holidays;

  HolidayResponse({
    required this.holidays,
  });

  factory HolidayResponse.fromJsonList(List<dynamic> jsonList) {
    return HolidayResponse(
      holidays: jsonList
          .map((item) => Holiday.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Holiday {
  final String name;
  final String date;
  final bool isNationalHoliday;

  Holiday({
    required this.name,
    required this.date,
    required this.isNationalHoliday,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      name: json['holiday_name'] ?? '',
      date: json['holiday_date'] ?? '',
      isNationalHoliday: json['is_national_holiday'] ?? false,
    );
  }

  DateTime get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Holiday &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          name == other.name;

  @override
  int get hashCode => date.hashCode ^ name.hashCode;
}

class CalendarEvent {
  final String title;
  final String? description;
  final DateTime date;
  final bool isHoliday;
  final bool isNationalHoliday;

  CalendarEvent({
    required this.title,
    this.description,
    required this.date,
    required this.isHoliday,
    required this.isNationalHoliday,
  });

  factory CalendarEvent.fromHoliday(Holiday holiday) {
    return CalendarEvent(
      title: holiday.name,
      description: holiday.isNationalHoliday ? 'Hari Libur Nasional' : 'Hari Libur',
      date: holiday.dateTime,
      isHoliday: true,
      isNationalHoliday: holiday.isNationalHoliday,
    );
  }
}