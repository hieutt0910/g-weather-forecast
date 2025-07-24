
import 'package:flutter/material.dart';
import 'package:g_weather_forecast/views/widgets/weekly_weather_item.dart';

class WeeklyForecastSection extends StatelessWidget {
  final List<dynamic> forecastDays;

  const WeeklyForecastSection({
    super.key,
    required this.forecastDays,
  });

  @override
  Widget build(BuildContext context) {
    if (forecastDays.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu dự báo hàng tuần',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: ListView.separated(
        itemCount: forecastDays.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final day = forecastDays[index];
      
          return WeeklyWeatherItem(dayData: day);
        },
      ),
    );
  }
}