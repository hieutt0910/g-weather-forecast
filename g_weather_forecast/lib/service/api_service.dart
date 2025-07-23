import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '16b3992992cf467c88363403252207';
  final String baseUrl = 'http://api.weatherapi.com/v1';

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final encodedCity = Uri.encodeComponent(city);
    final String apiUrl =
        '$baseUrl/forecast.json?key=$apiKey&q=$encodedCity&days=3&aqi=no&alerts=no';

    print('Calling API URL: $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        if (errorBody['error'] != null && errorBody['error']['code'] == 1006) {
          throw Exception('City not found. Please check the city name.');
        }
        throw Exception(
          'API Error: ${errorBody['error']['message'] ?? 'Bad Request'}',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Authentication Error: Invalid API key or access denied.',
        );
      } else {
        throw Exception(
          'Failed to load weather data: Status Code ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Network Error: Could not connect to the weather server. ${e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    final String apiUrl =
        '$baseUrl/forecast.json?key=$apiKey&q=$lat,$lon&days=3&aqi=no&alerts=no';

    print('Calling API URL (Coordinates): $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        if (errorBody['error'] != null && errorBody['error']['code'] == 1006) {
          throw Exception('Location not found for coordinates. Please check.');
        }
        throw Exception(
          'API Error (Coordinates): ${errorBody['error']['message'] ?? 'Bad Request'}',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Authentication Error (Coordinates): Invalid API key or access denied.',
        );
      } else {
        throw Exception(
          'Failed to load weather data for coordinates: Status Code ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Network Error (Coordinates): Could not connect to the weather server. ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'An unexpected error occurred (Coordinates): ${e.toString()}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> searchCity(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final encodedQuery = Uri.encodeComponent(query);
    final String apiUrl = '$baseUrl/search.json?key=$apiKey&q=$encodedQuery';

    print('Calling City Search API URL: $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        print(
          'City Search API Error: ${errorData['error']['message'] ?? 'Unknown error'}',
        );
        return [];
      }
    } on http.ClientException catch (e) {
      print('City Search Network Error: ${e.message}');
      return [];
    } catch (e) {
      print('Unexpected error in city search: $e');
      return [];
    }
  }
}
