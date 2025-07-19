import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../model/jadwal.model.dart';
import '../viewmodel/jadwal.viewmodel.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JadwalViewModel>().loadCurrentYearHolidays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: Text(
          'Jadwal & Kalender',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          Consumer<JadwalViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                onPressed:
                    viewModel.isLoading
                        ? null
                        : () {
                          viewModel.refreshHolidays();
                        },
                icon:
                    viewModel.isLoading
                        ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.refresh, color: Colors.white),
              );
            },
          ),
        ],
      ),
      body: Consumer<JadwalViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.hasError) {
            return _buildErrorState(viewModel);
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshHolidays(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildCalendar(viewModel),
                  _buildSelectedDayEvents(viewModel),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(JadwalViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => viewModel.refreshHolidays(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(JadwalViewModel viewModel) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<CalendarEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: viewModel.focusedDay,
        selectedDayPredicate: (day) => isSameDay(viewModel.selectedDay, day),
        eventLoader: viewModel.getEventsForDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: 'id_ID',
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Colors.blue[600],
            size: 28.r,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Colors.blue[600],
            size: 28.r,
          ),
          headerPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
          weekendStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.red[400],
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: Colors.red[400],
            fontWeight: FontWeight.w500,
          ),
          holidayTextStyle: TextStyle(
            color: Colors.red[600],
            fontWeight: FontWeight.w600,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue[600],
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Colors.blue[600],
            fontWeight: FontWeight.w600,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.red[500],
            shape: BoxShape.circle,
          ),
          markersMaxCount: 2,
          markerMargin: EdgeInsets.only(top: 5.h),
          cellMargin: EdgeInsets.all(4.w),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          viewModel.onDaySelected(selectedDay, focusedDay);
        },
        onPageChanged: (focusedDay) {
          viewModel.onMonthChanged(focusedDay);
        },
        holidayPredicate: (day) => viewModel.isHoliday(day),
      ),
    );
  }

  Widget _buildSelectedDayEvents(JadwalViewModel viewModel) {
    final events = viewModel.getEventsForDay(viewModel.selectedDay);
    final holiday = viewModel.getHolidayForDay(viewModel.selectedDay);
    final selectedDate = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(viewModel.selectedDay);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[600], size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'Tanggal Terpilih',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            selectedDate,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 16.h),
          if (events.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.event, color: Colors.red[400], size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  'Hari Libur',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...events.map((event) => _buildEventItem(event)),
          ] else if (holiday == null) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.work, color: Colors.green[600], size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'Hari Kerja',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventItem(CalendarEvent event) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: event.isNationalHoliday ? Colors.red[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              event.isNationalHoliday ? Colors.red[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                event.isNationalHoliday ? Icons.flag : Icons.event,
                size: 16.r,
                color:
                    event.isNationalHoliday
                        ? Colors.red[600]
                        : Colors.orange[600],
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        event.isNationalHoliday
                            ? Colors.red[700]
                            : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          if (event.description != null && event.description!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              event.description!,
              style: TextStyle(
                fontSize: 12.sp,
                color:
                    event.isNationalHoliday
                        ? Colors.red[600]
                        : Colors.orange[600],
              ),
            ),
          ],
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color:
                  event.isNationalHoliday
                      ? Colors.red[100]
                      : Colors.orange[100],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              event.isNationalHoliday ? 'Nasional' : 'Regional',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color:
                    event.isNationalHoliday
                        ? Colors.red[800]
                        : Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
