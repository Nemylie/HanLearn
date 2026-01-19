class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final int level;
  final int totalScore;
  final int wordsLearned;
//This model represents the User Profile and their Learning Progress . It is used to store and retrieve user data from Firestore.
//keep track sape yg login, display user progress, etc
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.level = 1,
    this.totalScore = 0,
    this.wordsLearned = 0,
  });


//toMap store, fromMap retrieve from firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'level': level,
      'totalScore': totalScore,
      'wordsLearned': wordsLearned,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] as String?,
      level: map['level']?.toInt() ?? 1,
      totalScore: map['totalScore']?.toInt() ?? 0,
      wordsLearned: map['wordsLearned']?.toInt() ?? 0,
    );
  }
}
