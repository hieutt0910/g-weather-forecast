import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_bloc.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_event.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_state.dart';

class WeatherHistoryListView extends StatelessWidget {
  final Function(Map<String, dynamic>) onTapHistoryItem;

  const WeatherHistoryListView({super.key, required this.onTapHistoryItem});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherHistoryBloc, WeatherHistoryState>(
      builder: (context, state) {
        if (state is WeatherHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is WeatherHistoryError) {
          return Center(child: Text('Failed to load history:${state.message}'));
        }
        if (state.history.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No cities have been searched today.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: state.history.length,
          itemBuilder: (context, index) {
            final historyItem = state.history[index];
            final cityName = historyItem['location']['name'] ?? 'Unknown City';
            final temp = historyItem['current']['temp_c']?.toInt() ?? 'N/A';
            final condition =
                historyItem['current']['condition']['text'] ?? 'N/A';
            final conditionIcon = historyItem['current']['condition']['icon'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blue.shade50.withOpacity(0.9),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading:
                    conditionIcon != null
                        ? Image.network(
                          'https:$conditionIcon',
                          width: 40,
                          height: 40,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.cloud, color: Colors.blue),
                        )
                        : const Icon(Icons.cloud, color: Colors.blue),
                title: Text(
                  cityName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$temp°C',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      condition,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                onTap: () => onTapHistoryItem(historyItem),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () {
                    context.read<WeatherHistoryBloc>().add(
                      RemoveWeatherFromHistory(cityName: cityName),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed "$cityName" from history.'),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
