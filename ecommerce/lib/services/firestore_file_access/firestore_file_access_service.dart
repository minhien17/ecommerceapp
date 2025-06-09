import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirestoreFilesAccess {
  FirestoreFilesAccess._privateConstructor();

  static final FirestoreFilesAccess _instance =
      FirestoreFilesAccess._privateConstructor();
  factory FirestoreFilesAccess() {
    return _instance;
  }
  FirebaseFirestore? _firebaseFirestore;
  FirebaseFirestore get firestore {
    if (_firebaseFirestore == null) {
      _firebaseFirestore = FirebaseFirestore.instance;
    }
    return _firebaseFirestore!;
  }

  Future<String> uploadFileToPath(File file, String path) async {
    final supabase = Supabase.instance.client;
    const bucketName = 'ecommerce';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = 'user/display_picture/$timestamp.jpg';

    try {
      final response = await supabase.storage.from(bucketName).upload(
            path, // thay đổi từ path
            file,
          );

      if (response.isNotEmpty) {
        final publicUrl = supabase.storage.from(bucketName).getPublicUrl(path);
        return publicUrl;
      } else {
        throw Exception('Upload failed: empty response');
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  Future<String> getDeveloperImage() async {
    const filename = "about_developer/developer";
    List<String> extensions = <String>["jpg", "jpeg", "jpe", "jfif"];
    final Reference firestorageRef = FirebaseStorage.instance.ref();
    for (final ext in extensions) {
      try {
        final url =
            await firestorageRef.child("$filename.$ext").getDownloadURL();
        return url;
      } catch (_) {
        continue;
      }
    }
    throw FirebaseException(
        message: "No JPEG Image found for Developer",
        plugin: 'Firebase Storage');
  }
}
