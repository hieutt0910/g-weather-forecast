import 'package:flutter/material.dart';

class CitySuggestionsDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Offset position;
  final Size size;
  final void Function(String cityName) onSelect;

  const CitySuggestionsDropdown({
    super.key,
    required this.suggestions,
    required this.position,
    required this.size,
    required this.onSelect,
  });

  String _buildDisplayText(Map<String, dynamic> suggestion) {
    final String name = suggestion['name'] ?? '';
    final String region = suggestion['region'] ?? '';
    final String country = suggestion['country'] ?? '';

    List<String> parts = [];
    if (name.isNotEmpty) parts.add(name);
    if (region.isNotEmpty && region != name) parts.add(region);
    if (country.isNotEmpty && country != region && country != name) {
      parts.add(country);
    }

    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.dy + size.height + 4,
      left: position.dx,
      width: size.width,
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
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              final displayText = _buildDisplayText(suggestion);

              return ListTile(
                title: Text(
                  displayText,
                  style: const TextStyle(color: Colors.black87),
                ),
                onTap: () => onSelect(suggestion['name'] ?? ''),
              );
            },
          ),
        ),
      ),
    );
  }
}
