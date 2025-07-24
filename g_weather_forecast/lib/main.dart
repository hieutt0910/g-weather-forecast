// File: main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_weather_forecast/views/bloc/weather_history_bloc.dart';
import 'package:g_weather_forecast/views/pages/home_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm import này

void main() async {
  // Đảm bảo Flutter framework đã được khởi tạo trước khi gọi bất kỳ code native nào
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dữ liệu định dạng ngày giờ cho tất cả các locale có sẵn.
  // Điều này phải được gọi một lần duy nhất trước khi sử dụng bất kỳ DateFormat nào.
  await initializeDateFormatting();

  // Lấy một instance của SharedPreferences
  final SharedPreferences prefs =
      await SharedPreferences.getInstance(); // Dòng MỚI

  runApp(
    MyApp(prefs: prefs), // Truyền instance prefs vào MyApp
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs; // Khai báo biến prefs

  const MyApp({
    super.key,
    required this.prefs,
  }); // Yêu cầu prefs trong constructor

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Tạo WeatherHistoryBloc và truyền instance prefs vào đây
      create: (context) => WeatherHistoryBloc(prefs: prefs), // Dòng ĐÃ SỬA
      child: MaterialApp(
        title: 'G-Weather Forecast',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
