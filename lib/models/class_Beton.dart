class Beton {
  final List<ClasseBeton> classeBeton;

  Beton({
    required this.classeBeton,
  });

  factory Beton.fromJson(Map<String, dynamic> json) {
    return Beton(
      classeBeton: (json['beton'] as List? ?? [])
          .map((e) => ClasseBeton.fromJson(e))
          .toList(),
    );
  }
}

class ClasseBeton {
  final int value;
  final String label;

  ClasseBeton({required this.value, required this.label});

  factory ClasseBeton.fromJson(Map<String, dynamic> json) {
    return ClasseBeton(
      value: json['value'] ?? 0,
      label: json['label']?.toString() ?? '',
    );
  }
}
