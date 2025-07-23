import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_weather_forecast/service/api_service.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_bloc.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_event.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_state.dart';
import 'package:g_weather_forecast/views/widgets/hourly_weather.dart';
import 'package:g_weather_forecast/views/widgets/weather_infomation.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _citySuggestions = [];

  final GlobalKey _textFieldKey = GlobalKey();

  late TabController _tabController;
  final int _numberOfForecastDays = 3;
  final ScrollController _hourlyScrollController = ScrollController();

  static const String _lastWeatherDataKey = 'last_weather_data';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _numberOfForecastDays, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadInitialWeather();
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  Future<void> _loadInitialWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? lastWeatherDataJson = prefs.getString(_lastWeatherDataKey);

      Map<String, dynamic>? data;

      if (lastWeatherDataJson != null && lastWeatherDataJson.isNotEmpty) {
        print('DEBUG: Found saved weather data. Attempting to load...');
        try {
          data = json.decode(lastWeatherDataJson) as Map<String, dynamic>;
          print(
            'DEBUG: Successfully loaded last weather data from SharedPreferences: ${data['location']['name']}',
          );
        } catch (e) {
          print('ERROR: Failed to decode last weather data JSON: $e');
          await prefs.remove(_lastWeatherDataKey);
          print(
            'DEBUG: Corrupted data cleared. Falling back to default city (Ho Chi Minh).',
          );
          data = await _weatherService.fetchWeather('Ho Chi Minh');
        }
      } else {
        print(
          'DEBUG: No last weather data found in SharedPreferences. Loading default city (Ho Chi Minh).',
        );
        data = await _weatherService.fetchWeather('Ho Chi Minh');
      }

      if (mounted) {
        setState(() {
          _weatherData = data;
          _cityController.text = _weatherData!['location']['name'];
          final newLength =
              (_weatherData!['forecast']['forecastday'] as List).length;
          if (_tabController.length != newLength) {
            _tabController.dispose();
            _tabController = TabController(length: newLength, vsync: this);
            _tabController.addListener(_handleTabSelection);
          }
        });
        _tabController.animateTo(0);

        await _saveWeatherData(_weatherData!);

        context.read<WeatherHistoryBloc>().add(
          AddWeatherToHistory(weatherData: _weatherData!),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Không thể tải dữ liệu thời tiết ban đầu. Vui lòng thử lại. Lỗi: ${e.toString().split(':')[0]}';
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
      print(
        'DEBUG: Weather data for "${data['location']['name']}" saved to SharedPreferences.',
      );
    } catch (e) {
      print('ERROR: Failed to save weather data to SharedPreferences: $e');
    }
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
        final newLength = (data['forecast']['forecastday'] as List).length;
        if (_tabController.length != newLength) {
          _tabController.dispose();
          _tabController = TabController(length: newLength, vsync: this);
          _tabController.addListener(_handleTabSelection);
        }
      });
      _tabController.animateTo(0);

      if (mounted && _weatherData != null) {
        await _saveWeatherData(_weatherData!);
        context.read<WeatherHistoryBloc>().add(
          AddWeatherToHistory(weatherData: _weatherData!),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Không thể tải dữ liệu thời tiết. Vui lòng thử lại. Lỗi: ${e.toString().split(':')[0]}';
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

  Future<void> _fetchCurrentLocationWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
        setState(() {
          _isLoading = false;
          _errorMessage = 'Dịch vụ định vị chưa được bật.';
        });
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
          setState(() {
            _isLoading = false;
            _errorMessage = 'Quyền truy cập vị trí đã bị từ chối.';
          });
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
        setState(() {
          _isLoading = false;
          _errorMessage = 'Quyền truy cập vị trí đã bị từ chối vĩnh viễn.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print(
        'DEBUG: Vị trí hiện tại: ${position.latitude}, ${position.longitude}',
      );

      final data = await _weatherService.fetchWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _weatherData = data;
        _cityController.text = data['location']['name'];
        final newLength = (data['forecast']['forecastday'] as List).length;
        if (_tabController.length != newLength) {
          _tabController.dispose();
          _tabController = TabController(length: newLength, vsync: this);
          _tabController.addListener(_handleTabSelection);
        }
      });
      _tabController.animateTo(0);

      if (mounted && _weatherData != null) {
        await _saveWeatherData(_weatherData!);
        context.read<WeatherHistoryBloc>().add(
          AddWeatherToHistory(weatherData: _weatherData!),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Không thể lấy vị trí hiện tại hoặc tải dữ liệu thời tiết. Lỗi: ${e.toString().split(':')[0]}';
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

  void _loadWeatherFromHistory(Map<String, dynamic> historicalData) async {
    setState(() {
      _weatherData = historicalData;
      _cityController.text = historicalData['location']['name'];
      _isLoading = false;
      _errorMessage = null;
      _citySuggestions = [];
    });
    _tabController.animateTo(0);
    Navigator.of(context).pop();

    if (_weatherData != null) {
      await _saveWeatherData(_weatherData!);
    }
  }

  Future<void> _fetchCitySuggestions(String query) async {
    print('DEBUG: _fetchCitySuggestions called with query: "$query"');
    if (query.isEmpty) {
      setState(() {
        _citySuggestions = [];
      });
      print('DEBUG: Query is empty, clearing suggestions.');
      return;
    }
    try {
      final suggestions = await _weatherService.searchCity(query);
      setState(() {
        _citySuggestions = suggestions;
      });
      print('DEBUG: Received ${suggestions.length} suggestions.');
      if (suggestions.isNotEmpty) {
        print('DEBUG: First suggestion: ${suggestions[0]['name']}');
      }
    } catch (e) {
      print('DEBUG: Error fetching city suggestions: $e');
      setState(() {
        _citySuggestions = [];
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _hourlyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 15),
                    Text(
                      'Đang tải dữ liệu thời tiết...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _fetchWeatherForCity(_cityController.text),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
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

    print('DEBUG: _citySuggestions.isNotEmpty: ${_citySuggestions.isNotEmpty}');
    print(
      'DEBUG: textFieldPosition: $textFieldPosition, textFieldSize: $textFieldSize',
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Center(
                child: Text(
                  'Lịch sử tìm kiếm',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<WeatherHistoryBloc, WeatherHistoryState>(
                builder: (context, state) {
                  if (state is WeatherHistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is WeatherHistoryError) {
                    return Center(
                      child: Text('Lỗi tải lịch sử: ${state.message}'),
                    );
                  }
                  if (state.history.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Chưa có thành phố nào được tìm kiếm trong hôm nay.',
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
                      final cityName =
                          historyItem['location']['name'] ?? 'Unknown City';
                      final temp =
                          historyItem['current']['temp_c']?.toInt() ?? 'N/A';
                      final condition =
                          historyItem['current']['condition']['text'] ?? 'N/A';
                      final conditionIcon =
                          historyItem['current']['condition']['icon'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                                            const Icon(
                                              Icons.cloud,
                                              color: Colors.blue,
                                            ),
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
                          onTap: () {
                            _loadWeatherFromHistory(historyItem);
                          },
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              context.read<WeatherHistoryBloc>().add(
                                RemoveWeatherFromHistory(cityName: cityName),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã xóa "$cityName" khỏi lịch sử.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
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
                        builder:
                            (context) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _cityController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Nhập tên thành phố...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              suffixIcon:
                                  _cityController.text.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _cityController.clear();
                                            _errorMessage = null;
                                            _citySuggestions = [];
                                          });
                                        },
                                      )
                                      : null,
                            ),
                            onChanged: (query) {
                              setState(() {});
                              _fetchCitySuggestions(query);
                            },
                            onSubmitted: (_) => _searchCity(),
                          ),
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
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Padding(
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
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                controller: _tabController,
                                indicatorColor: Colors.blueAccent,
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                tabs:
                                    forecastDays.map((dayData) {
                                      final forecastDate = DateTime.parse(
                                        dayData['date'],
                                      );
                                      final today = DateTime.now();
                                      final tomorrow = today.add(
                                        const Duration(days: 1),
                                      );

                                      String dayText;
                                      if (forecastDate.year == today.year &&
                                          forecastDate.month == today.month &&
                                          forecastDate.day == today.day) {
                                        dayText = 'Today';
                                      } else if (forecastDate.year ==
                                              tomorrow.year &&
                                          forecastDate.month ==
                                              tomorrow.month &&
                                          forecastDate.day == tomorrow.day) {
                                        dayText = 'Tomorrow';
                                      } else {
                                        dayText = DateFormat(
                                          'EEE, MMM d',
                                        ).format(forecastDate);
                                      }
                                      return Tab(text: dayText);
                                    }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children:
                                      forecastDays.map((dayData) {
                                        final currentDayHours =
                                            dayData['hour'] as List;

                                        final DateTime forecastDate =
                                            DateTime.parse(dayData['date']);
                                        final DateTime now = DateTime.now();

                                        final List<dynamic> filteredHours;
                                        if (forecastDate.year == now.year &&
                                            forecastDate.month == now.month &&
                                            forecastDate.day == now.day) {
                                          filteredHours =
                                              currentDayHours.where((hour) {
                                                final DateTime hourDateTime =
                                                    DateTime.parse(
                                                      hour['time'],
                                                    );
                                                return hourDateTime.hour >=
                                                    now.hour;
                                              }).toList();
                                        } else {
                                          filteredHours = currentDayHours;
                                        }

                                        return Scrollbar(
                                          controller: _hourlyScrollController,
                                          child: ListView.separated(
                                            controller: _hourlyScrollController,
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount: filteredHours.length,
                                            separatorBuilder:
                                                (_, __) =>
                                                    const SizedBox(width: 12),
                                            itemBuilder: (context, hourIndex) {
                                              final hour =
                                                  filteredHours[hourIndex];
                                              return SizedBox(
                                                width: 120,
                                                child: HourlyWeatherItem(
                                                  hourData: hour,
                                                  isCurrentHour: _isCurrentHour(
                                                    dayData['date'],
                                                    hour['time'],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_citySuggestions.isNotEmpty &&
              textFieldPosition != null &&
              textFieldSize != null)
            Positioned(
              top: textFieldPosition.dy + textFieldSize.height + 4,
              left: textFieldPosition.dx,
              width: textFieldSize.width,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _citySuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _citySuggestions[index];
                      final String name = suggestion['name'] ?? '';
                      final String country = suggestion['country'] ?? '';
                      final String region = suggestion['region'] ?? '';

                      String displayText = name;
                      if (region.isNotEmpty && region != name) {
                        displayText += ', $region';
                      }
                      if (country.isNotEmpty &&
                          country != name &&
                          country != region) {
                        displayText += ', $country';
                      }

                      return ListTile(
                        title: Text(
                          displayText,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        onTap: () {
                          _cityController.text = name;
                          _searchCity();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
}
