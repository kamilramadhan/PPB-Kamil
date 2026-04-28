import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImagePlatform(ImageSource source,
    {int? maxWidth, int? maxHeight, int? imageQuality}) {
  final picker = ImagePicker();
  return picker.pickImage(
    source: source,
    maxWidth: maxWidth?.toDouble(),
    maxHeight: maxHeight?.toDouble(),
    imageQuality: imageQuality,
  );
}
