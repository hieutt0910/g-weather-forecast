import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherInformation extends StatelessWidget {
  final String cityName;
  final String country;
  final String localtime;
  final double temperature;
  final String condition;
  final double windSpeed;
  final int humidity;

  const WeatherInformation({
    super.key,
    required this.cityName,
    required this.country,
    required this.localtime,
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(localtime);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              '$cityName, $country',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '$temperature°C',
            style: const TextStyle(
              fontSize: 52,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            condition,
            style: const TextStyle(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.air, color: Colors.white70, size: 30),
              const SizedBox(width: 4),
              Text(
                '$windSpeed km/h',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.water_drop, color: Colors.white70, size: 30),
              const SizedBox(width: 4),
              Text('$humidity%', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
