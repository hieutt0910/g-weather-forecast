abstract class WeatherHistoryEvent {}

class LoadWeatherHistory extends WeatherHistoryEvent {}

class AddWeatherToHistory extends WeatherHistoryEvent {
  final Map<String, dynamic>
  weatherData; 

  AddWeatherToHistory({required this.weatherData});
}

class RemoveWeatherFromHistory extends WeatherHistoryEvent {
  final String cityName;

  RemoveWeatherFromHistory({required this.cityName});
}
