import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return null;
    return File(picked.path);
  }
}