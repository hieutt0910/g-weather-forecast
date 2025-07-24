import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HourlyWeatherItem extends StatelessWidget {
  final Map<String, dynamic> hourData;
  final bool isCurrentHour;

  const HourlyWeatherItem({
    super.key,
    required this.hourData,
    this.isCurrentHour = false,
  });

  @override
  Widget build(BuildContext context) {
    final String fullDateTimeString = hourData['time'];
    final DateTime dateTime = DateTime.parse(fullDateTimeString);
    final String formattedTime = DateFormat('h a').format(dateTime);

    final double temperature = hourData['temp_c']?.toDouble() ?? 0.0;
    final String iconUrl = 'https:${hourData['condition']['icon']}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCurrentHour
                ? Colors.blueAccent.withOpacity(0.3)
                : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(36),
        border:
            isCurrentHour
                ? Border.all(color: Colors.blueAccent, width: 2)
                : null, 
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isCurrentHour ? 'Now' : formattedTime,
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Image.network(iconUrl, width: 50, height: 50, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(
            '${temperature.toInt()}°C',
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
