class ImageData {
  final int? id;
  final String name;
  final String path;
  final List<int> imageBytes; 

  ImageData({this.id, required this.name, required this.path,required this.imageBytes});


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'imageByte': imageBytes,
    };
  }

  
  static ImageData fromMap(Map<String, dynamic> map) {
    return ImageData(
      id: map['id'],
      name: map['name'],
      path: map['path'],
      imageBytes: List<int>.from(map['imageByte']),
    );
  }
}
