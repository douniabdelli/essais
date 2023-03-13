class User {
  String name;
  String email;
  String photo;

  User({required this.name, required this.email, required this.photo});

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        photo = json['photo'];
}