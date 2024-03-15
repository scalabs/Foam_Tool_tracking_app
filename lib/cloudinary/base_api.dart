import 'dart:typed_data';

abstract class CloudinaryBaseApi {
  final String baseUrl;

  CloudinaryBaseApi() : baseUrl = "https://api.cloudinary.com/v1_1/";

  Future<Map<String, dynamic>> uploadFromBytes(
    Uint8List file,
    String filename, {
    String? folder,
    bool? useFilename,
    bool? uniqueFilename,
  });
}
