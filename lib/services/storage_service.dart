import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Profil fotoğrafı yükle
  Future<String> uploadProfilePhoto(File file, String userId) async {
    try {
      // Benzersiz dosya adı oluştur
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_photos/$fileName');

      // Dosyayı yükle
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        ),
      );

      // Yükleme tamamlanana kadar bekle
      final TaskSnapshot snapshot = await uploadTask;

      // İndirme URL'sini al
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Fotoğraf yüklenirken hata oluştu: $e';
    }
  }

  // Profil fotoğrafını sil
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_photos/$fileName');
      await ref.delete();
    } catch (e) {
      // Dosya zaten yoksa sessizce devam et
      if (!e.toString().contains('object-not-found')) {
        throw 'Fotoğraf silinirken hata oluştu: $e';
      }
    }
  }

  // Görev için dosya yükle (opsiyonel - gelecekte eklenebilir)
  Future<String> uploadTaskAttachment(File file, String taskId) async {
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${taskId}_$timestamp';
      final Reference ref = _storage.ref().child('task_attachments/$fileName');

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Dosya yüklenirken hata oluştu: $e';
    }
  }

  // Dosyayı sil (opsiyonel)
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw 'Dosya silinirken hata oluştu: $e';
    }
  }
}
