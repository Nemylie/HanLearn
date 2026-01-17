import 'package:cloud_firestore/cloud_firestore.dart';

class WordModel {
  final String id; // Firestore doc id
  final String character;
  final String pinyin;
  final String meaning;
  final String category;

  WordModel({
    required this.id,
    required this.character,
    required this.pinyin,
    required this.meaning,
    required this.category,
  });

  /// For saving to Firestore (do NOT store id inside the document)
  Map<String, dynamic> toMap() {
    return {
      'character': character,
      'pinyin': pinyin,
      'meaning': meaning,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Read from Firestore DocumentSnapshot (id comes from doc.id)
  factory WordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return WordModel(
      id: doc.id,
      character: (data?['character'] ?? '') as String,
      pinyin: (data?['pinyin'] ?? '') as String,
      meaning: (data?['meaning'] ?? '') as String,
      category: (data?['category'] ?? '') as String,
    );
  }

  /// Backward compatible: if you still have maps with 'id' field in old data
  factory WordModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return WordModel(
      id: (docId ?? map['id'] ?? '') as String,
      character: (map['character'] ?? '') as String,
      pinyin: (map['pinyin'] ?? '') as String,
      meaning: (map['meaning'] ?? '') as String,
      category: (map['category'] ?? '') as String,
    );
  }
}

// class WordModel {
//   final String id;
//   final String character;
//   final String pinyin;
//   final String meaning;
//   final String category;

//   WordModel({
//     required this.id,
//     required this.character,
//     required this.pinyin,
//     required this.meaning,
//     required this.category,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'character': character,
//       'pinyin': pinyin,
//       'meaning': meaning,
//       'category': category,
//     };
//   }

//   factory WordModel.fromMap(Map<String, dynamic> map) {
//     return WordModel(
//       id: map['id'] ?? '',
//       character: map['character'] ?? '',
//       pinyin: map['pinyin'] ?? '',
//       meaning: map['meaning'] ?? '',
//       category: map['category'] ?? '',
//     );
//   }
// }
