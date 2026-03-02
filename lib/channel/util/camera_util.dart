import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraUtil {
  static final _picker = ImagePicker();

  static Future<File?> cameraPhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    return x == null ? null : File(x.path);
  }

  static Future<File?> galleryPhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return x == null ? null : File(x.path);
  }

  static Future<File?> cameraVideo() async {
    final x = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 30), // ⛔ HARD LIMIT
    );
    return x == null ? null : File(x.path);
  }

  static Future<File?> galleryVideo() async {
    final x = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    return x == null ? null : File(x.path);
  }
}