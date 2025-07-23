class HourlyWeather {
  final String time;
  final double tempC;
  final String conditionText;
  final String conditionIcon;
  final double windKph;
  final int humidity;

  HourlyWeather({
    required this.time,
    required this.tempC,
    required this.conditionText,
    required this.conditionIcon,
    required this.windKph,
    required this.humidity,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: json['time'],
      tempC: (json['temp_c'] as num).toDouble(),
      conditionText: json['condition']['text'],
      conditionIcon: "https:${json['condition']['icon']}",
      windKph: (json['wind_kph'] as num).toDouble(),
      humidity: json['humidity'],
    );
  }
}
