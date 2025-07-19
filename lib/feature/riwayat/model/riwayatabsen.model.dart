class RiwayatAbsenModel {
  final DateTime tanggal;
  final String jamMasuk;
  final String jamPulang;
  final String status;
  final String keterangan;

  RiwayatAbsenModel({
    required this.tanggal,
    required this.jamMasuk,
    required this.jamPulang,
    required this.status,
    required this.keterangan,
  });

  // Convert from JSON
  factory RiwayatAbsenModel.fromJson(Map<String, dynamic> json) {
    return RiwayatAbsenModel(
      tanggal: DateTime.parse(json['tanggal']),
      jamMasuk: json['jam_masuk'] ?? '',
      jamPulang: json['jam_pulang'] ?? '',
      status: json['status'] ?? '',
      keterangan: json['keterangan'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal.toIso8601String(),
      'jam_masuk': jamMasuk,
      'jam_pulang': jamPulang,
      'status': status,
      'keterangan': keterangan,
    };
  }

  // Copy with method for updating data
  RiwayatAbsenModel copyWith({
    DateTime? tanggal,
    String? jamMasuk,
    String? jamPulang,
    String? status,
    String? keterangan,
  }) {
    return RiwayatAbsenModel(
      tanggal: tanggal ?? this.tanggal,
      jamMasuk: jamMasuk ?? this.jamMasuk,
      jamPulang: jamPulang ?? this.jamPulang,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
    );
  }

  @override
  String toString() {
    return 'RiwayatAbsenModel(tanggal: $tanggal, jamMasuk: $jamMasuk, jamPulang: $jamPulang, status: $status, keterangan: $keterangan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RiwayatAbsenModel &&
        other.tanggal == tanggal &&
        other.jamMasuk == jamMasuk &&
        other.jamPulang == jamPulang &&
        other.status == status &&
        other.keterangan == keterangan;
  }

  @override
  int get hashCode {
    return tanggal.hashCode ^
        jamMasuk.hashCode ^
        jamPulang.hashCode ^
        status.hashCode ^
        keterangan.hashCode;
  }

  // Static data untuk nama hari dan bulan
  static const List<String> weekDays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static const List<String> dayNames = [
    'Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'
  ];

  // Konfigurasi semester akademik
  static const Map<String, SemesterConfig> semesterConfig = {
    'ganjil': SemesterConfig(
      startMonth: 7,  // Juli
      endMonth: 12,   // Desember
      name: 'Ganjil',
    ),
    'genap': SemesterConfig(
      startMonth: 1,  // Januari
      endMonth: 6,    // Juni  
      name: 'Genap',
    ),
  };

  // Get current semester berdasarkan tanggal
  static SemesterInfo getCurrentSemester([DateTime? date]) {
    final now = date ?? DateTime.now();
    final month = now.month;
    
    if (month >= 7 && month <= 12) {
      // Semester Ganjil (Juli - Desember)
      return SemesterInfo(
        type: 'ganjil',
        year: now.year,
        startDate: DateTime(now.year, 7, 1),
        endDate: DateTime(now.year, 12, 31),
        name: 'Semester Ganjil ${now.year}/${now.year + 1}',
      );
    } else {
      // Semester Genap (Januari - Juni)
      return SemesterInfo(
        type: 'genap', 
        year: now.year,
        startDate: DateTime(now.year, 1, 1),
        endDate: DateTime(now.year, 6, 30),
        name: 'Semester Genap ${now.year - 1}/${now.year}',
      );
    }
  }

  // Generate semua minggu dalam semester (Senin-Sabtu)
  static List<WeekInfo> generateSemesterWeeks(SemesterInfo semester) {
    final List<WeekInfo> weeks = [];
    DateTime currentMonday = _findFirstMondayOfSemester(semester.startDate);
    int weekNumber = 1;

    while (currentMonday.isBefore(semester.endDate) || 
           currentMonday.isAtSameMomentAs(semester.endDate)) {
      
      final saturday = currentMonday.add(const Duration(days: 5)); // Sabtu
      
      // Jika minggu ini masih dalam semester
      if (currentMonday.isBefore(semester.endDate.add(const Duration(days: 1)))) {
        weeks.add(WeekInfo(
          weekNumber: weekNumber,
          startDate: currentMonday,
          endDate: saturday.isAfter(semester.endDate) ? semester.endDate : saturday,
          label: _formatWeekLabel(weekNumber, currentMonday, saturday),
        ));
        weekNumber++;
      }
      
      currentMonday = currentMonday.add(const Duration(days: 7));
    }

    return weeks;
  }

  // Helper: Cari Senin pertama dalam semester
  static DateTime _findFirstMondayOfSemester(DateTime semesterStart) {
    DateTime date = semesterStart;
    
    // Cari Senin pertama
    while (date.weekday != DateTime.monday) {
      date = date.add(const Duration(days: 1));
    }
    
    return date;
  }

  // Helper: Format label minggu
  static String _formatWeekLabel(int weekNumber, DateTime start, DateTime end) {
    final startStr = '${start.day} ${monthNames[start.month - 1]}';
    final endStr = start.month == end.month 
        ? '${end.day}' 
        : '${end.day} ${monthNames[end.month - 1]}';
    
    return 'Minggu $weekNumber ($startStr-$endStr)';
  }

  // Filter data berdasarkan minggu
  static List<RiwayatAbsenModel> filterByWeek(
    List<RiwayatAbsenModel> data, 
    WeekInfo week
  ) {
    return data.where((item) {
      final itemDate = DateTime(item.tanggal.year, item.tanggal.month, item.tanggal.day);
      final start = DateTime(week.startDate.year, week.startDate.month, week.startDate.day);
      final end = DateTime(week.endDate.year, week.endDate.month, week.endDate.day);
      
      return (itemDate.isAfter(start) || itemDate.isAtSameMomentAs(start)) &&
             (itemDate.isBefore(end) || itemDate.isAtSameMomentAs(end));
    }).toList();
  }

  // Filter data berdasarkan hari dalam seminggu
  static List<RiwayatAbsenModel> filterByWeekday(
    List<RiwayatAbsenModel> data, 
    int weekday // 1 = Monday, 6 = Saturday
  ) {
    return data.where((item) => item.tanggal.weekday == weekday).toList();
  }

  // API Methods - untuk integrasi dengan backend
  static Future<List<RiwayatAbsenModel>> getDataForSemester(SemesterInfo semester) async {
    // TODO: Implement actual API call
    // Example: 
    // final response = await ApiService.getAbsensiData(
    //   startDate: semester.startDate,
    //   endDate: semester.endDate,
    // );
    // return response.data.map((json) => RiwayatAbsenModel.fromJson(json)).toList();
    
    // Untuk sekarang return sample data
    return _generateSampleDataForSemester(semester);
  }

  static Future<List<RiwayatAbsenModel>> getDataForWeek(WeekInfo week) async {
    // TODO: Implement actual API call
    // Example:
    // final response = await ApiService.getAbsensiData(
    //   startDate: week.startDate,
    //   endDate: week.endDate,
    // );
    
    final semesterData = await getDataForSemester(getCurrentSemester());
    return filterByWeek(semesterData, week);
  }

  // Generate sample data untuk testing
  static List<RiwayatAbsenModel> _generateSampleDataForSemester(SemesterInfo semester) {
    final List<RiwayatAbsenModel> data = [];
    final statuses = ['Hadir', 'Terlambat', 'Alpha'];
    final keterangans = {
      'Hadir': ['Tepat waktu', 'Lebih awal', 'Baik'],
      'Terlambat': ['Terlambat 5 menit', 'Terlambat 10 menit', 'Macet'],
      'Alpha': ['Sakit', 'Tidak hadir tanpa keterangan', 'Keperluan keluarga'],
    };

    DateTime currentDate = semester.startDate;
    int dayCounter = 0;

    while (currentDate.isBefore(semester.endDate.add(const Duration(days: 1)))) {
      // Skip hari Minggu (weekday 7)
      if (currentDate.weekday != DateTime.sunday) {
        // Generate data untuk beberapa hari (tidak semua hari)
        if (dayCounter % 3 == 0 || dayCounter % 5 == 0) {
          final statusIndex = dayCounter % statuses.length;
          final status = statuses[statusIndex];
          final keterangan = keterangans[status]![dayCounter % keterangans[status]!.length];
          
          data.add(RiwayatAbsenModel(
            tanggal: currentDate,
            jamMasuk: status == 'Alpha' ? '-' : '07:${20 + (dayCounter % 30)}',
            jamPulang: status == 'Alpha' ? '-' : '15:${30 + (dayCounter % 30)}',
            status: status,
            keterangan: keterangan,
          ));
        }
        dayCounter++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return data;
  }

  // Utility: Get available semesters
  static List<SemesterInfo> getAvailableSemesters() {
    final List<SemesterInfo> semesters = [];
    final currentYear = DateTime.now().year;
    
    // Generate 3 tahun terakhir
    for (int year = currentYear - 2; year <= currentYear; year++) {
      // Semester Ganjil
      semesters.add(SemesterInfo(
        type: 'ganjil',
        year: year,
        startDate: DateTime(year, 7, 1),
        endDate: DateTime(year, 12, 31),
        name: 'Semester Ganjil $year/${year + 1}',
      ));
      
      // Semester Genap
      semesters.add(SemesterInfo(
        type: 'genap',
        year: year + 1,
        startDate: DateTime(year + 1, 1, 1),
        endDate: DateTime(year + 1, 6, 30),
        name: 'Semester Genap $year/${year + 1}',
      ));
    }
    
    return semesters;
  }
}

// Helper classes
class SemesterConfig {
  final int startMonth;
  final int endMonth;
  final String name;

  const SemesterConfig({
    required this.startMonth,
    required this.endMonth,
    required this.name,
  });
}

class SemesterInfo {
  final String type;
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final String name;

  SemesterInfo({
    required this.type,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.name,
  });

  @override
  String toString() => name;
}

class WeekInfo {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String label;

  WeekInfo({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.label,
  });

  @override
  String toString() => label;
}