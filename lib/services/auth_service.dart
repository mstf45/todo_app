import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);

      if (credential.user != null) {
        await _createUserInFirestore(credential.user!, displayName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  Future<void> _createUserInFirestore(User user, String displayName) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'email-already-in-use':
        return 'Bu email adresi zaten kullanımda';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Yanlış şifre';
      case 'invalid-email':
        return 'Geçersiz email adresi';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakıldı';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda izin verilmiyor';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}
