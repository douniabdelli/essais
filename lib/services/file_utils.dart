import 'dart:io';
import 'dart:typed_data';

class FileUtils {
  // ► Convertir des bytes en fichier temporaire (pour l'UI)
  static Future<File> saveBytesToTempFile(
    List<int> bytes, {
    required String filename,
  }) async {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$filename');
    return await file.writeAsBytes(bytes);
  }

  // ► Charger un fichier depuis un chemin
  static Future<List<int>> loadImageBytes(String imagePath) async {
    return await File(imagePath).readAsBytes();
  }
}