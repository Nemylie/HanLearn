import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? user;
  UserModel? userModel;

  AuthProvider() {
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
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = cred.user;
      await _fetchUserData();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = cred.user;
      
      if (user != null) {
        userModel = UserModel(
          uid: user!.uid,
          email: email,
          displayName: name,
        );
        
        await _firestore.collection('users').doc(user!.uid).set(userModel!.toMap());
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    userModel = null;
    notifyListeners();
  }

  // Update progress
  Future<void> updateProgress(int scoreToAdd, int wordsToAdd) async {
    if (userModel == null) return;

    int newScore = userModel!.totalScore + scoreToAdd;
    int newWords = userModel!.wordsLearned + wordsToAdd;
    
    // Simple level up logic: every 100 points
    int newLevel = (newScore / 100).floor() + 1;

    await _firestore.collection('users').doc(user!.uid).update({
      'totalScore': newScore,
      'wordsLearned': newWords,
      'level': newLevel,
    });

    // Refresh local model
    await _fetchUserData();
    notifyListeners();
  }
}
