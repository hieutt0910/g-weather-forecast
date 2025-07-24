import 'package:flutter/material.dart';

class CitySearchInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const CitySearchInput({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white24,
        hintText: 'Searching for city...',
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon:
            controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: onClear,
                )
                : null,
      ),
    );
  }
}
