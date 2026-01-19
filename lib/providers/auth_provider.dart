

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

enum EmailUpdateResult {
  authAndProfileUpdated,
  profileOnlyUpdated,
}

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  User? user;
  UserModel? userModel;

  AppAuthProvider() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      user = firebaseUser;
      if (user != null) {
        await _fetchUserData();
      } else {
        userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> sendPasswordReset(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('Please enter a valid email.');
    }
    await _auth.sendPasswordResetEmail(email: cleanEmail);
  }

  bool get isAuthenticated => user != null;

  bool get isGoogleUser =>
      user?.providerData.any((p) => p.providerId == 'google.com') ?? false;

  bool get isPasswordUser =>
      user?.providerData.any((p) => p.providerId == 'password') ?? false;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String email, String password, String name) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    user = cred.user;

    if (user != null) {
      await user!.updateDisplayName(name.trim());

      userModel = UserModel(
        uid: user!.uid,
        email: email.trim(),
        displayName: name.trim(),
        photoUrl: user!.photoURL,
      );

      await _firestore.collection('users').doc(user!.uid).set(
            userModel!.toMap(),
            SetOptions(merge: true),
          );
    }

    notifyListeners();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;
    try {
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
    } catch (e) {
      debugPrint('GoogleSignIn initialize failed: $e');
    }
  }

  Future<String> _getAccessToken(List<String> scopes) async {
    final authClient = _googleSignIn.authorizationClient;

    var authorization = await authClient.authorizationForScopes(scopes);
    authorization ??= await authClient.authorizeScopes(scopes);

    final token = authorization.accessToken;
    if (token.isEmpty) throw Exception('Failed to obtain Google access token');
    return token;
  }

  Future<void> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    if (!_googleSignIn.supportsAuthenticate() && kIsWeb) {
      throw UnsupportedError('Web requires Google Sign-In button UI flow.');
    }

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
      scopeHint: const ['email', 'profile', 'openid'],
    );

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;
    final String accessToken =
        await _getAccessToken(const ['email', 'profile', 'openid']);

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCred =
        await _auth.signInWithCredential(credential);

    user = userCred.user;
    if (user == null) throw Exception('Google sign-in failed');

    final docRef = _firestore.collection('users').doc(user!.uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      userModel = UserModel(
        uid: user!.uid,
        email: user!.email ?? googleUser.email,
        displayName: user!.displayName ?? googleUser.displayName ?? 'Learner',
        photoUrl: user!.photoURL,
      );
      await docRef.set(userModel!.toMap(), SetOptions(merge: true));
    } else {
      userModel = UserModel.fromMap(snap.data() as Map<String, dynamic>);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user!.uid).get();

    if (doc.exists) {
      userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      userModel = UserModel(
        uid: user!.uid,
        email: user!.email ?? '',
        displayName: user!.displayName ?? 'Learner',
        photoUrl: user!.photoURL,
      );

      await _firestore.collection('users').doc(user!.uid).set(
            userModel!.toMap(),
            SetOptions(merge: true),
          );
    }

    notifyListeners();
  }

  Future<void> updateProgress(int scoreToAdd, int wordsToAdd) async {
    if (userModel == null || user == null) return;

    final int newScore = userModel!.totalScore + scoreToAdd;
    final int newWords = userModel!.wordsLearned + wordsToAdd;
    final int newLevel = (newScore / 100).floor() + 1;

    await _firestore.collection('users').doc(user!.uid).update({
      'totalScore': newScore,
      'wordsLearned': newWords,
      'level': newLevel,
    });

    await _fetchUserData();
  }

  // -------------------- Sensitive actions helpers --------------------

  Future<void> reauthenticate({String? password}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user session found.');

    if (isPasswordUser) {
      final email = currentUser.email;
      if (email == null || email.isEmpty) {
        throw Exception('No email found for this account.');
      }
      if (password == null || password.isEmpty) {
        throw Exception('Current password is required.');
      }

      final cred = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await currentUser.reauthenticateWithCredential(cred);
      return;
    }

    if (isGoogleUser) {
      await _ensureGoogleInitialized();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile', 'openid'],
      );

      final googleAuth = googleUser.authentication;
      final accessToken =
          await _getAccessToken(const ['email', 'profile', 'openid']);

      final OAuthCredential cred = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      await currentUser.reauthenticateWithCredential(cred);
      return;
    }

    throw Exception('Unsupported provider. Please log in again.');
  }

  // -------------------- Email update (balanced) --------------------

  Future<void> updateProfileEmailOnly(String newEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user session found.');

    final cleanEmail = newEmail.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('Please enter a valid email.');
    }

    await _firestore.collection('users').doc(currentUser.uid).set(
      {'email': cleanEmail},
      SetOptions(merge: true),
    );

    await _fetchUserData();
  }

  /// Best overall: try to update Auth email, but if Firebase blocks it
  /// (common when verification is required), still update Firestore profile email.
  Future<EmailUpdateResult> updateEmailBalanced(String newEmail,
      {String? password}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user session found.');

    final cleanEmail = newEmail.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('Please enter a valid email.');
    }

    await reauthenticate(password: password);

    try {
      await currentUser.verifyBeforeUpdateEmail(cleanEmail);

      await _firestore.collection('users').doc(currentUser.uid).set(
        {'email': cleanEmail},
        SetOptions(merge: true),
      );

      await _fetchUserData();
      return EmailUpdateResult.authAndProfileUpdated;
    } on FirebaseAuthException catch (e) {
      // Your screenshot error comes here
      if (e.code == 'operation-not-allowed' ||
          (e.message?.toLowerCase().contains('verify') ?? false)) {
        await updateProfileEmailOnly(cleanEmail);
        return EmailUpdateResult.profileOnlyUpdated;
      }
      rethrow;
    }
  }

  // -------------------- Update Display Name --------------------

  Future<void> updateDisplayName(String newName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user session found.');

    final cleanName = newName.trim();
    if (cleanName.isEmpty) throw Exception('Name cannot be empty.');

    await currentUser.updateDisplayName(cleanName);

    await _firestore.collection('users').doc(currentUser.uid).set(
      {'displayName': cleanName},
      SetOptions(merge: true),
    );

    await _fetchUserData();
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user session found.');

    await currentUser.updatePhotoURL(photoUrl);

    await _firestore.collection('users').doc(currentUser.uid).set(
      {'photoUrl': photoUrl},
      SetOptions(merge: true),
    );

    await _fetchUserData();
  }
}
