import 'package:flutter/material.dart';
import 'package:g_weather_forecast/views/widgets/hourly_weather.dart';
import 'package:g_weather_forecast/views/widgets/weekly_forecast_section.dart';

class HourlyForecastSection extends StatefulWidget {
  final List<dynamic> forecastDays;
  final ScrollController hourlyScrollController;
  final bool Function(String date, String time) isCurrentHour;

  const HourlyForecastSection({
    super.key,
    required this.forecastDays,
    required this.hourlyScrollController,
    required this.isCurrentHour,
  });

  @override
  State<HourlyForecastSection> createState() => _HourlyForecastSectionState();
}

class _HourlyForecastSectionState extends State<HourlyForecastSection>
    with TickerProviderStateMixin {
  late TabController _internalTabController;

  @override
  void initState() {
    super.initState();
    _internalTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _internalTabController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forecastDays.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: const Center(
          child: Text(
            'Không có dữ liệu dự báo',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final todayData = widget.forecastDays[0];
    final todayHours = todayData['hour'] as List;
    final forecastDateToday = DateTime.parse(todayData['date']);
    final now = DateTime.now();

    final List<dynamic> filteredTodayHours =
        _isSameDay(forecastDateToday, now)
            ? todayHours.where((hour) {
              final hourDateTime = DateTime.parse(hour['time']);
              return hourDateTime.hour >= now.hour;
            }).toList()
            : todayHours;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _internalTabController,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              tabs: const [Tab(text: 'Today'), Tab(text: 'Weekly')],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _internalTabController,
                children: [
                  Scrollbar(
                    controller: widget.hourlyScrollController,
                    child: ListView.separated(
                      controller: widget.hourlyScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredTodayHours.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, hourIndex) {
                        final hour = filteredTodayHours[hourIndex];
                        return SizedBox(
                          width: 85,
                          child: HourlyWeatherItem(
                            hourData: hour,
                            isCurrentHour: widget.isCurrentHour(
                              todayData['date'],
                              hour['time'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  WeeklyForecastSection(forecastDays: widget.forecastDays),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
