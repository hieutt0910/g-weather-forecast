import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailSubscriptionPage extends StatefulWidget {
  const EmailSubscriptionPage({super.key});

  @override
  State<EmailSubscriptionPage> createState() => _EmailSubscriptionPageState();
}

class _EmailSubscriptionPageState extends State<EmailSubscriptionPage> {
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  String? _message;

  Future<void> _subscribe() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    const String baseUrl =
        'https://g-weather-forecast-production.up.railway.app/api';

    final response = await http.post(
      Uri.parse('$baseUrl/subscribe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailController.text.trim(),
        'location': _locationController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = "Đã đăng ký. Vui lòng kiểm tra email để xác nhận.";
      });
    } else {
      setState(() {
        _message = "Lỗi: ${response.statusCode}\n${response.body}";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký nhận dự báo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Nhập thông tin để nhận dự báo thời tiết hằng ngày:'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Địa điểm (VD: Ho Chi Minh)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _subscribe,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Đăng ký'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 20),
              Text(_message!),
            ],
          ],
        ),
      ),
    );
  }
}
