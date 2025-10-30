import 'package:flutter/material.dart';

class ConstituentCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(int) onDelete;
  final List<Widget> Function(Map<String, dynamic> item, int index) buildFields;

  const ConstituentCard({
    Key? key,
    required this.title,
    required this.items,
    required this.onDelete,
    required this.buildFields,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ...buildFields(item, i),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(i),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
