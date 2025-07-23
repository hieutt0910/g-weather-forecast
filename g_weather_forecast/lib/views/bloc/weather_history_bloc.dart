import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_event.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WeatherHistoryBloc
    extends Bloc<WeatherHistoryEvent, WeatherHistoryState> {
  final SharedPreferences _prefs;

  WeatherHistoryBloc({required SharedPreferences prefs})
    : _prefs = prefs,
      super(const WeatherHistoryInitial()) {
    on<LoadWeatherHistory>(_onLoadWeatherHistory);
    on<AddWeatherToHistory>(_onAddWeatherToHistory);
    on<RemoveWeatherFromHistory>(_onRemoveWeatherFromHistory);
  }

  String _getHistoryKey() {
    return 'weather_history_${DateFormat('yyyyMMdd').format(DateTime.now())}';
  }

  Future<void> _onLoadWeatherHistory(
    LoadWeatherHistory event,
    Emitter<WeatherHistoryState> emit,
  ) async {
    emit(WeatherHistoryLoading(state.history));
    try {
      final String? historyJson = _prefs.getString(_getHistoryKey());
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(historyJson);
        final List<Map<String, dynamic>> history =
            decodedList.map((item) => item as Map<String, dynamic>).toList();
        emit(WeatherHistoryLoaded(history));
      } else {
        emit(const WeatherHistoryLoaded([]));
      }
    } catch (e) {
      emit(WeatherHistoryError('Failed to load history: $e', state.history));
    }
  }

  Future<void> _onAddWeatherToHistory(
    AddWeatherToHistory event,
    Emitter<WeatherHistoryState> emit,
  ) async {
    final List<Map<String, dynamic>> currentHistory = List.from(state.history);
    final String newCityName = event.weatherData['location']['name'];

    final int existingIndex = currentHistory.indexWhere(
      (item) => item['location']['name'] == newCityName,
    );

    if (existingIndex != -1) {
      currentHistory.removeAt(existingIndex);
    }

    currentHistory.insert(0, event.weatherData);

    try {
      final String historyJson = json.encode(currentHistory);
      await _prefs.setString(_getHistoryKey(), historyJson);
      emit(WeatherHistoryLoaded(currentHistory));
    } catch (e) {
      emit(WeatherHistoryError('Failed to save history: $e', state.history));
    }
  }

  Future<void> _onRemoveWeatherFromHistory(
    RemoveWeatherFromHistory event,
    Emitter<WeatherHistoryState> emit,
  ) async {
    final List<Map<String, dynamic>> currentHistory = List.from(state.history);
    currentHistory.removeWhere(
      (item) => item['location']['name'] == event.cityName,
    );

    try {
      final String historyJson = json.encode(currentHistory);
      await _prefs.setString(_getHistoryKey(), historyJson);
      emit(WeatherHistoryLoaded(currentHistory));
    } catch (e) {
      emit(
        WeatherHistoryError('Failed to remove from history: $e', state.history),
      );
    }
  }
}
