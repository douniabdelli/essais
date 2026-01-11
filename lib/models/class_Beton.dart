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
    final dynamic raw = json['value'];
    final intVal = raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;
    return ClasseBeton(
      value: intVal,
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}
