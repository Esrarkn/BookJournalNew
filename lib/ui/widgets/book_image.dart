import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

Future<String?> pickAndUploadImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  File file = File(pickedFile.path);
  String fileName = basename(file.path);

  try {
    final ref = FirebaseStorage.instance.ref().child('images/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  } catch (e) {
    print('Firebase upload error: $e');
    return null;
  }
}
