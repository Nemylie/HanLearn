class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int level;
  final int totalScore;
  final int wordsLearned;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.level = 1,
    this.totalScore = 0,
    this.wordsLearned = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
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
      level: map['level']?.toInt() ?? 1,
      totalScore: map['totalScore']?.toInt() ?? 0,
      wordsLearned: map['wordsLearned']?.toInt() ?? 0,
    );
  }
}
