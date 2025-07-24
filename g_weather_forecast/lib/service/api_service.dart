import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  WeatherService();

  final String _baseUrl = 'http://api.weatherapi.com/v1';
  final String _apiKey = '16b3992992cf467c88363403252207';

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final response = await http
        .get(
          Uri.parse(
            '$_baseUrl/forecast.json?key=$_apiKey&q=$city&days=7&aqi=no&alerts=no',
          ),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      final errorMessage =
          errorData['error']['message'] ?? 'Không thể tải dữ liệu thời tiết';
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> fetchWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '$_baseUrl/forecast.json?key=$_apiKey&q=$lat,$lon&days=7&aqi=no&alerts=no',
          ),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      final errorMessage =
          errorData['error']['message'] ?? 'Không thể tải dữ liệu thời tiết';
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> searchCity(String query) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/search.json?key=$_apiKey&q=$query'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Không thể tìm kiếm thành phố');
    }
  }
}
