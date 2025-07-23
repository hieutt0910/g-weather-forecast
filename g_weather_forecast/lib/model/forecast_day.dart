import 'package:g_weather_forecast/model/hourly_forecast.dart';

class ForecastDayModel {
  final String date;
  final List<HourlyWeather> hours;

  ForecastDayModel({required this.date, required this.hours});

  factory ForecastDayModel.fromJson(Map<String, dynamic> json) {
    List<HourlyWeather> hourList =
        (json['hour'] as List)
            .map((hourJson) => HourlyWeather.fromJson(hourJson))
            .toList();

    return ForecastDayModel(date: json['date'], hours: hourList);
  }
}
