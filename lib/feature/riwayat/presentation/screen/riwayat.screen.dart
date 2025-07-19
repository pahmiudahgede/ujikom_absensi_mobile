import 'package:absensi_mobile/feature/riwayat/model/riwayatabsen.model.dart';
import 'package:flutter/material.dart';

class RiwayatAbsenScreen extends StatefulWidget {
  const RiwayatAbsenScreen({super.key});

  @override
  State<RiwayatAbsenScreen> createState() => _RiwayatAbsenScreenState();
}

class _RiwayatAbsenScreenState extends State<RiwayatAbsenScreen>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _weekDayTabController;
  late TabController _semesterTabController;

  List<RiwayatAbsenModel> currentSemesterData = [];
  List<WeekInfo> semesterWeeks = [];
  SemesterInfo currentSemester = RiwayatAbsenModel.getCurrentSemester();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _weekDayTabController = TabController(length: 6, vsync: this);

    _semesterTabController = TabController(length: 1, vsync: this);

    _loadDataForCurrentSemester();
  }

  Future<void> _loadDataForCurrentSemester() async {
    setState(() => isLoading = true);

    try {
      currentSemesterData = await RiwayatAbsenModel.getDataForSemester(
        currentSemester,
      );

      semesterWeeks = RiwayatAbsenModel.generateSemesterWeeks(currentSemester);

      _semesterTabController.dispose();
      _semesterTabController = TabController(
        length: semesterWeeks.length,
        vsync: this,
      );

      _weekDayTabController.addListener(() {
        if (mounted) setState(() {});
      });
      _semesterTabController.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _weekDayTabController.dispose();
    _semesterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildSemesterInfo(),
          const SizedBox(height: 8),
          _buildMainTabs(),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [_buildWeeklyView(), _buildSemesterView()],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D47A1),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Riwayat Absensi',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            _showSemesterPicker();
          },
          tooltip: 'Pilih Semester',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSemesterInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentSemester.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${semesterWeeks.length} minggu pembelajaran',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _mainTabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        tabs: const [Tab(text: 'Harian'), Tab(text: 'Mingguan')],
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildWeekDayTabs(),
        const SizedBox(height: 16),
        _buildCurrentWeekStatsCard(),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _weekDayTabController,
            children: _buildWeekDayViews(),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterView() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildSemesterTabs(),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _semesterTabController,
            children:
                semesterWeeks.map((week) {
                  final weekData = RiwayatAbsenModel.filterByWeek(
                    currentSemesterData,
                    week,
                  );
                  return Column(
                    children: [
                      _buildWeekStatsCard(weekData, week),
                      const SizedBox(height: 16),
                      Expanded(child: _buildAbsensiList(weekData)),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDayTabs() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: RiwayatAbsenModel.weekDays.length,
        itemBuilder: (context, index) {
          final isSelected = _weekDayTabController.index == index;
          return GestureDetector(
            onTap: () => _weekDayTabController.animateTo(index),
            child: Container(
              margin: EdgeInsets.only(
                right: index == RiwayatAbsenModel.weekDays.length - 1 ? 0 : 12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        )
                        : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isSelected
                            ? const Color(0xFF0D47A1).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.03),
                    blurRadius: isSelected ? 8 : 4,
                    offset: Offset(0, isSelected ? 3 : 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  RiwayatAbsenModel.weekDays[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSemesterTabs() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: semesterWeeks.length,
        itemBuilder: (context, index) {
          final week = semesterWeeks[index];
          final isSelected = _semesterTabController.index == index;

          return GestureDetector(
            onTap: () => _semesterTabController.animateTo(index),
            child: Container(
              margin: EdgeInsets.only(
                right: index == semesterWeeks.length - 1 ? 0 : 12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        )
                        : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isSelected
                            ? const Color(0xFF0D47A1).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.03),
                    blurRadius: isSelected ? 8 : 4,
                    offset: Offset(0, isSelected ? 3 : 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  week.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildWeekDayViews() {
    return RiwayatAbsenModel.weekDays.asMap().entries.map((entry) {
      final dayIndex = entry.key + 1;
      final dayData = RiwayatAbsenModel.filterByWeekday(
        currentSemesterData,
        dayIndex,
      );
      return _buildAbsensiList(dayData);
    }).toList();
  }

  Widget _buildCurrentWeekStatsCard() {
    final now = DateTime.now();
    final currentWeek = semesterWeeks.firstWhere(
      (week) =>
          now.isAfter(week.startDate.subtract(const Duration(days: 1))) &&
          now.isBefore(week.endDate.add(const Duration(days: 1))),
      orElse:
          () =>
              semesterWeeks.isNotEmpty
                  ? semesterWeeks.first
                  : WeekInfo(
                    weekNumber: 1,
                    startDate: now,
                    endDate: now,
                    label: 'Minggu ini',
                  ),
    );

    final weekData = RiwayatAbsenModel.filterByWeek(
      currentSemesterData,
      currentWeek,
    );

    return _buildStatsCard(
      title: 'Statistik ${currentWeek.label}',
      data: weekData,
      isGradient: true,
    );
  }

  Widget _buildWeekStatsCard(List<RiwayatAbsenModel> weekData, WeekInfo week) {
    return _buildStatsCard(
      title: 'Statistik ${week.label}',
      data: weekData,
      isGradient: false,
    );
  }

  Widget _buildStatsCard({
    required String title,
    required List<RiwayatAbsenModel> data,
    required bool isGradient,
  }) {
    final int totalHadir = data.where((d) => d.status == 'Hadir').length;
    final int totalTerlambat =
        data.where((d) => d.status == 'Terlambat').length;
    final int totalAlpha = data.where((d) => d.status == 'Alpha').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            isGradient
                ? const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                )
                : null,
        color: isGradient ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isGradient ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color:
                isGradient
                    ? const Color(0xFF0D47A1).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isGradient ? Colors.white : const Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                label: 'Hadir',
                value: '$totalHadir',
                color:
                    isGradient
                        ? Colors.green.shade300
                        : const Color(0xFF059669),
                isWhiteBackground: isGradient,
              ),
              _buildStatItem(
                icon: Icons.schedule,
                label: 'Terlambat',
                value: '$totalTerlambat',
                color:
                    isGradient
                        ? Colors.orange.shade300
                        : const Color(0xFFEAB308),
                isWhiteBackground: isGradient,
              ),
              _buildStatItem(
                icon: Icons.cancel,
                label: 'Alpha',
                value: '$totalAlpha',
                color:
                    isGradient ? Colors.red.shade300 : const Color(0xFFDC2626),
                isWhiteBackground: isGradient,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isWhiteBackground = false,
  }) {
    return Flexible(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isWhiteBackground
                      ? Colors.white.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isWhiteBackground ? Colors.white : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isWhiteBackground ? Colors.white70 : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isWhiteBackground ? Colors.white : const Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiList(List<RiwayatAbsenModel> data) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.event_busy,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data absensi',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data absensi akan muncul setelah melakukan absensi',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: data.length,
      itemBuilder: (context, index) => _buildAbsensiCard(data[index]),
    );
  }

  Widget _buildAbsensiCard(RiwayatAbsenModel data) {
    Color statusColor;
    IconData statusIcon;

    switch (data.status) {
      case 'Hadir':
        statusColor = const Color(0xFF059669);
        statusIcon = Icons.check_circle;
        break;
      case 'Terlambat':
        statusColor = const Color(0xFFEAB308);
        statusIcon = Icons.schedule;
        break;
      case 'Alpha':
        statusColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatDate(data.tanggal),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (data.keterangan.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      data.keterangan,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (data.status != 'Alpha') ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTimeChip(
                          icon: Icons.login,
                          time: data.jamMasuk,
                          color: const Color(0xFF059669),
                        ),
                        const SizedBox(width: 8),
                        _buildTimeChip(
                          icon: Icons.logout,
                          time: data.jamPulang,
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip({
    required IconData icon,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${RiwayatAbsenModel.dayNames[date.weekday % 7]}, ${date.day} ${RiwayatAbsenModel.monthNames[date.month - 1]} ${date.year}';
  }

  Future<void> _showSemesterPicker() async {
    final availableSemesters = RiwayatAbsenModel.getAvailableSemesters();

    final selected = await showDialog<SemesterInfo>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pilih Semester'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableSemesters.length,
                itemBuilder: (context, index) {
                  final semester = availableSemesters[index];
                  final isSelected = semester.name == currentSemester.name;

                  return ListTile(
                    title: Text(semester.name),
                    trailing:
                        isSelected
                            ? const Icon(Icons.check, color: Color(0xFF0D47A1))
                            : null,
                    onTap: () => Navigator.pop(context, semester),
                  );
                },
              ),
            ),
          ),
    );

    if (selected != null && selected.name != currentSemester.name) {
      currentSemester = selected;
      await _loadDataForCurrentSemester();
    }
  }
}
