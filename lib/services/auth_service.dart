import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Firebase Auth 實例
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 取得目前的使用者
  User? get currentUser => _auth.currentUser;

  // 監聽使用者狀態
  Stream<User?> get userStream => _auth.authStateChanges();

  // 註冊新使用者
  Future<UserCredential> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      // 創建使用者
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 發送電子郵件驗證
      await userCredential.user?.sendEmailVerification();
      
      // 建立使用者資料
      await _createUserDocument(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // 電子郵件密碼登入
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Google 登入
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 開始 Google 登入流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // 使用者取消登入
      }
      
      // 獲取身份驗證詳細信息
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
          
      // 建立 Firebase 憑證
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // 使用 Google 憑證登入 Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // 如果是新用戶，建立用戶資料
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // 登出
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 密碼重設
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // 建立使用者文檔
  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'emailVerified': user.emailVerified,
    });
  }

  // 更新使用者資料
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 更新 Auth 中的資料
    if (displayName != null || photoURL != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }

    // 更新 Firestore 中的資料
    final updateData = <String, dynamic>{};
    if (displayName != null) updateData['displayName'] = displayName;
    if (photoURL != null) updateData['photoURL'] = photoURL;

    if (updateData.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updateData);
    }
  }
}
