class TypeIntervention {
  final String label;
  final String value;
  final bool inactive;

  TypeIntervention({
    required this.label,
    required this.value,
    required this.inactive,
  });

  factory TypeIntervention.fromJson(Map<String, dynamic> json) {
    return TypeIntervention(
      label: json['label'],
      value: json['value'],
      inactive: json['inactive'],
    );
  }
  
}