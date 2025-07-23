import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:g_weather_forecast/views/bloc/weather_history_bloc.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_event.dart';
import 'package:g_weather_forecast/views/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              WeatherHistoryBloc(prefs: prefs)..add(LoadWeatherHistory()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather Forecast',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashPage(),
      ),
    );
  }
}
