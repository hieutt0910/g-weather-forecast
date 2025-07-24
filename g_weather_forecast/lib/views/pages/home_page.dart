import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_weather_forecast/service/api_service.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_bloc.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_event.dart';
import 'package:g_weather_forecast/views/pages/email_registration_page.dart';
import 'package:g_weather_forecast/views/pages/error_messege_page.dart';
import 'package:g_weather_forecast/views/pages/loading_page.dart';
import 'package:g_weather_forecast/views/widgets/city_search_input.dart';
import 'package:g_weather_forecast/views/widgets/city_suggestions_dropdown.dart';
import 'package:g_weather_forecast/views/widgets/hourly_forecast_section.dart';
import 'package:g_weather_forecast/views/widgets/weather_history_list_view.dart';
import 'package:g_weather_forecast/views/widgets/weather_infomation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _citySuggestions = [];

  final GlobalKey _textFieldKey = GlobalKey();

  final ScrollController _hourlyScrollController = ScrollController();

  static const String _lastWeatherDataKey = 'last_weather_data';

  @override
  void initState() {
    super.initState();
    _loadInitialWeatherRobust();
  }

  bool _isCurrentHour(String date, String hourTime) {
    final DateTime now = DateTime.now();
    final DateTime forecastDateTime = DateTime.parse(hourTime);

    final bool isToday =
        forecastDateTime.year == now.year &&
        forecastDateTime.month == now.month &&
        forecastDateTime.day == now.day;

    final bool isCurrentHour = forecastDateTime.hour == now.hour;

    return isToday && isCurrentHour;
  }

  Future<void> _loadInitialWeatherRobust() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? lastWeatherDataJson = prefs.getString(_lastWeatherDataKey);

      Map<String, dynamic>? data;

      if (lastWeatherDataJson != null && lastWeatherDataJson.isNotEmpty) {
        try {
          data = json.decode(lastWeatherDataJson) as Map<String, dynamic>;
        } catch (e) {
          await prefs.remove(_lastWeatherDataKey);
        }
      }

      if (data == null) {
        try {
          await _fetchCurrentLocationWeather(isInitialLoad: true);
          data = _weatherData;
        } catch (e) {}
      }

      if (data == null) {
        data = await _weatherService.fetchWeather('Ho Chi Minh');
      }

      if (mounted) {
        setState(() {
          _weatherData = data;
          if (_weatherData != null) {
            _cityController.text = _weatherData!['location']['name'];
          }
        });

        if (_weatherData != null) {
          await _saveWeatherData(_weatherData!);
          context.read<WeatherHistoryBloc>().add(
                AddWeatherToHistory(weatherData: _weatherData!),
              );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Không thể tải dữ liệu thời tiết ban đầu. Vui lòng kiểm tra kết nối mạng hoặc cấp quyền vị trí. Lỗi: ${e.toString().split(':')[0]}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveWeatherData(Map<String, dynamic> data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(data);
      await prefs.setString(_lastWeatherDataKey, jsonString);
    } catch (e) {}
  }

  Future<void> _fetchWeatherForCity(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherData = null;
      _citySuggestions = [];
    });

    try {
      final data = await _weatherService.fetchWeather(city);
      setState(() {
        _weatherData = data;
        _cityController.text = data['location']['name'];
      });

      if (mounted && _weatherData != null) {
        await _saveWeatherData(_weatherData!);
        context.read<WeatherHistoryBloc>().add(
              AddWeatherToHistory(weatherData: _weatherData!),
            );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Không thể tải dữ liệu thời tiết. Vui lòng kiểm tra lại tên thành phố hoặc kết nối mạng. Lỗi: ${e.toString().split(':')[0]}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchCity() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên thành phố!')),
        );
      }
      return;
    }
    await _fetchWeatherForCity(city);
  }

  Future<void> _fetchCurrentLocationWeather({
    bool isInitialLoad = false,
  }) async {
    if (!isInitialLoad) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Dịch vụ định vị chưa được bật. Vui lòng bật để sử dụng tính năng này.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        String msg = 'Dịch vụ định vị chưa được bật.';
        if (!isInitialLoad) {
          setState(() {
            _errorMessage = msg;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quyền truy cập vị trí đã bị từ chối.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          String msg = 'Quyền truy cập vị trí đã bị từ chối.';
          if (!isInitialLoad) {
            setState(() {
              _errorMessage = msg;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Quyền truy cập vị trí đã bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt ứng dụng.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        String msg = 'Quyền truy cập vị trí đã bị từ chối vĩnh viễn.';
        if (!isInitialLoad) {
          setState(() {
            _errorMessage = msg;
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      final data = await _weatherService.fetchWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _weatherData = data;
          _cityController.text = data['location']['name'];
        });

        if (_weatherData != null) {
          await _saveWeatherData(_weatherData!);
          context.read<WeatherHistoryBloc>().add(
                AddWeatherToHistory(weatherData: _weatherData!),
              );
        }
      }
    } catch (e) {
      String errorMsg =
          'Không thể lấy vị trí hiện tại hoặc tải dữ liệu thời tiết. Lỗi: ${e.toString().split(':')[0]}';

      if (!isInitialLoad) {
        setState(() {
          _errorMessage = errorMsg;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (!isInitialLoad && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadWeatherFromHistory(Map<String, dynamic> historicalData) async {
    setState(() {
      _weatherData = historicalData;
      _cityController.text = historicalData['location']['name'];
      _isLoading = false;
      _errorMessage = null;
      _citySuggestions = [];
    });
    Navigator.of(context).pop();

    if (_weatherData != null) {
      await _saveWeatherData(_weatherData!);
    }
  }

  Future<void> _fetchCitySuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _citySuggestions = [];
      });
      return;
    }
    try {
      final suggestions = await _weatherService.searchCity(query);
      setState(() {
        _citySuggestions = suggestions;
      });
    } catch (e) {
      setState(() {
        _citySuggestions = [];
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _hourlyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingPage();
    }

    if (_errorMessage != null) {
      return ErrorMessegePage(
        message: _errorMessage!,
        onRetry: () {
          _loadInitialWeatherRobust();
        },
      );
    }

    if (_weatherData == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Không có dữ liệu thời tiết',
            style: TextStyle(fontSize: 20),
          ),
        ),
        backgroundColor: Colors.white,
      );
    }

    final location = _weatherData!['location'];
    final current = _weatherData!['current'];
    final forecastDays = _weatherData!['forecast']['forecastday'] as List;

    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset? textFieldPosition = renderBox?.localToGlobal(Offset.zero);
    final Size? textFieldSize = renderBox?.size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade700,
                    Colors.blue.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch sử tìm kiếm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Các thành phố bạn đã tìm kiếm gần đây',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: WeatherHistoryListView(
                onTapHistoryItem: _loadWeatherFromHistory,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blueAccent),
              title: const Text(
                'Đăng ký nhận email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EmailSubscriptionPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    key: _textFieldKey,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CitySearchInput(
                          controller: _cityController,
                          onClear: () {
                            setState(() {
                              _cityController.clear();
                              _errorMessage = null;
                              _citySuggestions = [];
                            });
                          },
                          onChanged: (query) {
                            setState(() {});
                            _fetchCitySuggestions(query);
                          },
                          onSubmitted: (query) => _searchCity(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _fetchCurrentLocationWeather,
                          icon: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WeatherInformation(
                    cityName: location['name'],
                    country: location['country'],
                    localtime: location['localtime'],
                    temperature: current['temp_c']?.toDouble() ?? 0.0,
                    condition: current['condition']['text'],
                    windSpeed: current['wind_kph']?.toDouble() ?? 0.0,
                    humidity: current['humidity']?.toInt() ?? 0,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: HourlyForecastSection(
                    forecastDays: forecastDays,
                    hourlyScrollController: _hourlyScrollController,
                    isCurrentHour: _isCurrentHour,
                  ),
                ),
              ],
            ),
          ),
          if (_citySuggestions.isNotEmpty &&
              textFieldPosition != null &&
              textFieldSize != null)
            CitySuggestionsDropdown(
              suggestions: _citySuggestions,
              position: textFieldPosition,
              size: textFieldSize,
              onSelect: (cityName) {
                _cityController.text = cityName;
                _searchCity();
              },
            ),
        ],
      ),
    );
  }
}