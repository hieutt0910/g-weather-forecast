import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyWeatherItem extends StatelessWidget {
  final Map<String, dynamic> dayData;

  const WeeklyWeatherItem({super.key, required this.dayData});

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(dayData['date']);
    final String formattedDate = DateFormat('EEEE, dd/MM').format(date);

    final int maxTempC = dayData['day']['maxtemp_c']?.toInt() ?? 0;
    final int minTempC = dayData['day']['mintemp_c']?.toInt() ?? 0;
    final String conditionText =
        dayData['day']['condition']['text'] ?? 'Không rõ';
    final String iconUrl = dayData['day']['condition']['icon'] ?? '';
    final int dailyChanceOfRain =
        dayData['day']['daily_chance_of_rain']?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  conditionText,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                if (dailyChanceOfRain > 0)
                  Text(
                    'Chance of rain: $dailyChanceOfRain%',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                if (iconUrl.isNotEmpty)
                  Image.network(
                    'https:$iconUrl',
                    width: 50,
                    height: 50,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.cloud,
                          color: Colors.white,
                          size: 50,
                        ),
                  ),
                Text(
                  '$maxTempC°/$minTempC°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
