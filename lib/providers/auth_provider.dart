// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user_model.dart';

// class AuthProvider extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   User? user;
//   UserModel? userModel;

//   AuthProvider() {
//     _auth.authStateChanges().listen((User? firebaseUser) async {
//       user = firebaseUser;
//       if (user != null) {
//         await _fetchUserData();
//       } else {
//         userModel = null;
//       }
//       notifyListeners();
//     });
//   }

//   bool get isAuthenticated => user != null;

//   Future<void> login(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> register(String email, String password, String name) async {
//     try {
//       UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//       user = cred.user;

//       if (user != null) {
//         userModel = UserModel(
//           uid: user!.uid,
//           email: email,
//           displayName: name,
//         );

//         await _firestore.collection('users').doc(user!.uid).set(userModel!.toMap());
//       }
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> logout() async {
//     await _auth.signOut();
//   }

//   Future<void> _fetchUserData() async {
//     if (user != null) {
//       DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();
//       if (doc.exists) {
//         userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
//         notifyListeners();
//       }
//     }
//   }

//   Future<void> updateProgress(int scoreToAdd, int wordsToAdd) async {
//     if (userModel == null) return;

//     int newScore = userModel!.totalScore + scoreToAdd;
//     int newWords = userModel!.wordsLearned + wordsToAdd;
//     int newLevel = (newScore / 100).floor() + 1;

//     await _firestore.collection('users').doc(user!.uid).update({
//       'totalScore': newScore,
//       'wordsLearned': newWords,
//       'level': newLevel,
//     });

//     await _fetchUserData();
//   }
// }

// import 'package:flutter/foundation.dart';
// //import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// import '../models/user_model.dart';

// class AuthProvider extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Use the NEW-style singleton (as in your other project)
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

//   bool _isGoogleInitialized = false;

//   User? user;
//   UserModel? userModel;

//   AuthProvider() {
//     _auth.authStateChanges().listen((User? firebaseUser) async {
//       user = firebaseUser;
//       if (user != null) {
//         await _fetchUserData();
//       } else {
//         userModel = null;
//       }
//       notifyListeners();
//     });
//   }

//   bool get isAuthenticated => user != null;

//   Future<void> login(String email, String password) async {
//     await _auth.signInWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );
//   }

//   Future<void> register(String email, String password, String name) async {
//     final UserCredential cred = await _auth.createUserWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );

//     user = cred.user;

//     if (user != null) {
//       await user!.updateDisplayName(name.trim());

//       userModel = UserModel(
//         uid: user!.uid,
//         email: email.trim(),
//         displayName: name.trim(),
//       );

//       await _firestore.collection('users').doc(user!.uid).set(
//             userModel!.toMap(),
//             SetOptions(merge: true),
//           );
//     }

//     notifyListeners();
//   }

//   // ---------- GOOGLE SIGN-IN (YOUR REFERENCE STYLE) ----------

//   Future<void> _ensureGoogleInitialized() async {
//     if (_isGoogleInitialized) return;
//     try {
//       await _googleSignIn.initialize();
//       _isGoogleInitialized = true;
//     } catch (e) {
//       // If initialize fails, still allow attempt (some platforms may not require it)
//       debugPrint('GoogleSignIn initialize failed: $e');
//     }
//   }

//   Future<String> _getAccessToken(List<String> scopes) async {
//     final authClient = _googleSignIn.authorizationClient;

//     // Try to reuse existing auth first, then request
//     var authorization = await authClient.authorizationForScopes(scopes);
//     authorization ??= await authClient.authorizeScopes(scopes);

//     final token = authorization.accessToken;
//     if (token.isEmpty) throw Exception('Failed to obtain Google access token');

//     return token;
//   }

//   /// Google sign-in (login OR register)
//   /// - uses authenticate() + authorizationClient to get access token
//   Future<void> signInWithGoogle() async {
//     await _ensureGoogleInitialized();

//     // Your reference project: special handling for web
//     if (!_googleSignIn.supportsAuthenticate() && kIsWeb) {
//       throw UnsupportedError('Web requires Google Sign-In button UI flow.');
//     }

//     // Your reference project: authenticate() with scopeHint
//     final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
//       scopeHint: const ['email', 'profile', 'openid'],
//     );

//     // Get access token via authorizationClient (NOT gAuth.accessToken)
//     final accessToken =
//         await _getAccessToken(const ['email', 'profile', 'openid']);

//     final OAuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: accessToken,
//     );

//     final UserCredential userCred =
//         await _auth.signInWithCredential(credential);

//     user = userCred.user;
//     if (user == null) throw Exception('Google sign-in failed');

//     // Ensure Firestore user doc exists
//     final docRef = _firestore.collection('users').doc(user!.uid);
//     final snap = await docRef.get();

//     if (!snap.exists) {
//       userModel = UserModel(
//         uid: user!.uid,
//         email: user!.email ?? googleUser.email,
//         displayName: user!.displayName ?? googleUser.displayName ?? 'Learner',
//       );
//       await docRef.set(userModel!.toMap(), SetOptions(merge: true));
//     } else {
//       userModel = UserModel.fromMap(snap.data() as Map<String, dynamic>);
//     }

//     notifyListeners();
//   }

//   // -----------------------------------------------------------

//   Future<void> logout() async {
//     try {
//       await _googleSignIn.signOut();
//     } catch (_) {}
//     await _auth.signOut();
//   }

//   Future<void> _fetchUserData() async {
//     if (user == null) return;

//     final doc = await _firestore.collection('users').doc(user!.uid).get();

//     if (doc.exists) {
//       userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
//     } else {
//       userModel = UserModel(
//         uid: user!.uid,
//         email: user!.email ?? '',
//         displayName: user!.displayName ?? 'Learner',
//       );
//       await _firestore.collection('users').doc(user!.uid).set(
//             userModel!.toMap(),
//             SetOptions(merge: true),
//           );
//     }

//     notifyListeners();
//   }

//   Future<void> updateProgress(int scoreToAdd, int wordsToAdd) async {
//     if (userModel == null || user == null) return;

//     final int newScore = userModel!.totalScore + scoreToAdd;
//     final int newWords = userModel!.wordsLearned + wordsToAdd;
//     final int newLevel = (newScore / 100).floor() + 1;

//     await _firestore.collection('users').doc(user!.uid).update({
//       'totalScore': newScore,
//       'wordsLearned': newWords,
//       'level': newLevel,
//     });

//     await _fetchUserData();
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

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

  bool get isAuthenticated => user != null;

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

    final googleAuth = await googleUser.authentication;

    final accessToken =
        await _getAccessToken(const ['email', 'profile', 'openid']);

    final OAuthCredential credential = GoogleAuthProvider.credential(
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
}
