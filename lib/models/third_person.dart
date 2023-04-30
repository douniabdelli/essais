import 'dart:convert';
import 'dart:convert' show utf8;

class ThirdPerson {
  final String thirdPerson;
  final String fullName;


  const ThirdPerson({
    required this.thirdPerson,
    required this.fullName,
  });

  Map toJson() => {
    'thirdPerson': thirdPerson,
    'fullName': fullName,
  };

  factory ThirdPerson.fromJson(Map<String, dynamic> json) {
    return ThirdPerson(
      thirdPerson: json['thirdPerson'] == null ? '' : json['thirdPerson'],
      fullName: json['fullName'] == null ? '' : json['fullName'],
    );
  }

  static Map<String, dynamic> toMap(ThirdPerson model) =>
      <String, dynamic> {
        'thirdPerson': model.thirdPerson,
        'fullName': model.fullName,
      };

  static String serialize(ThirdPerson model) => json.encode(ThirdPerson.toMap(model));

  static List<ThirdPerson> deserialize(String data) => (json.decode(data) as List).map((i) => ThirdPerson.fromJson(i)).toList();

}