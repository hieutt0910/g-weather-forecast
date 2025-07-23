abstract class WeatherHistoryState {
  final List<Map<String, dynamic>> history; 

  const WeatherHistoryState(this.history);
}

class WeatherHistoryInitial extends WeatherHistoryState {
  const WeatherHistoryInitial() : super(const []);
}

class WeatherHistoryLoading extends WeatherHistoryState {
  const WeatherHistoryLoading(super.history);
}

class WeatherHistoryLoaded extends WeatherHistoryState {
  const WeatherHistoryLoaded(super.history);
}

class WeatherHistoryError extends WeatherHistoryState {
  final String message;
  const WeatherHistoryError(this.message, List<Map<String, dynamic>> history)
    : super(history);
}
