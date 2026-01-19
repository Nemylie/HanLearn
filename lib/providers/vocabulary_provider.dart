
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:translator/translator.dart';
// import 'package:lpinyin/lpinyin.dart';
// import '../models/word_model.dart';

// class VocabularyProvider extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleTranslator _translator = GoogleTranslator();

//   List<WordModel> _words = [];
//   List<WordModel> get words => _words;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<void> fetchWords() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       QuerySnapshot snapshot = await _firestore.collection('vocabulary').get();
//       if (snapshot.docs.isNotEmpty) {
//         _words = snapshot.docs.map((doc) => WordModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
//       } else {
//         // Fallback dummy data if Firestore is empty
//         _words = [
//           WordModel(id: '1', character: '你好', pinyin: 'nǐ hǎo', meaning: 'Hello', category: 'Daily Conversation'),
//           WordModel(id: '2', character: '谢谢', pinyin: 'xiè xie', meaning: 'Thank you', category: 'Daily Conversation'),
//           WordModel(id: '3', character: '再见', pinyin: 'zài jiàn', meaning: 'Goodbye', category: 'Daily Conversation'),
//           WordModel(id: '4', character: '猫', pinyin: 'māo', meaning: 'Cat', category: 'Animals'),
//           WordModel(id: '5', character: '狗', pinyin: 'gǒu', meaning: 'Dog', category: 'Animals'),
//           WordModel(id: '6', character: '水', pinyin: 'shuǐ', meaning: 'Water', category: 'Food'),
//           WordModel(id: '7', character: '饭', pinyin: 'fàn', meaning: 'Rice/Meal', category: 'Food'),
//         ];
//       }
//     } catch (e) {
//       debugPrint('Error fetching words: $e');
//     }
//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<Map<String, String>> translateText(String text) async {
//     try {
//       var translation = await _translator.translate(text, to: 'zh-cn');
//       String chineseText = translation.text;
//       String pinyin = PinyinHelper.getPinyin(chineseText, separator: ' ', format: PinyinFormat.WITH_TONE_MARK);

//       return {
//         'character': chineseText,
//         'pinyin': pinyin,
//       };
//     } catch (e) {
//       return {
//         'character': 'Error',
//         'pinyin': '',
//       };
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';
import 'package:lpinyin/lpinyin.dart';

import '../models/word_model.dart';

class VocabularyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleTranslator _translator = GoogleTranslator();

  List<WordModel> _words = [];
  List<WordModel> get words => _words;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Existing categories from current words (for dropdown)
  List<String> get categories {
    final set = <String>{};
    for (final w in _words) {
      final c = w.category.trim();
      if (c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> fetchWords() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('vocabulary').get();

      if (snapshot.docs.isNotEmpty) {
        _words = snapshot.docs.map((doc) {
          final data = doc.data();

          // If Firestore doc doesn't contain "id", use doc.id
          data['id'] = (data['id'] ?? doc.id);
          return WordModel.fromMap(data);
        }).toList();
      } else {
        // Fallback dummy data if Firestore is empty
        _words = [
          WordModel(
            id: '1',
            character: '你好',
            pinyin: 'nǐ hǎo',
            meaning: 'Hello',
            category: 'Daily Conversation',
          ),
          WordModel(
            id: '2',
            character: '谢谢',
            pinyin: 'xiè xie',
            meaning: 'Thank you',
            category: 'Daily Conversation',
          ),
          WordModel(
            id: '3',
            character: '再见',
            pinyin: 'zài jiàn',
            meaning: 'Goodbye',
            category: 'Daily Conversation',
          ),
          WordModel(
            id: '4',
            character: '猫',
            pinyin: 'māo',
            meaning: 'Cat',
            category: 'Animals',
          ),
          WordModel(
            id: '5',
            character: '狗',
            pinyin: 'gǒu',
            meaning: 'Dog',
            category: 'Animals',
          ),
          WordModel(
            id: '6',
            character: '水',
            pinyin: 'shuǐ',
            meaning: 'Water',
            category: 'Food',
          ),
          WordModel(
            id: '7',
            character: '饭',
            pinyin: 'fàn',
            meaning: 'Rice/Meal',
            category: 'Food',
          ),
        ];
      }
    } catch (e) {
      debugPrint('Error fetching words: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, String>> translateText(String text) async {
    try {
      final translation = await _translator.translate(text, to: 'zh-cn');
      final chineseText = translation.text;

      final pinyin = PinyinHelper.getPinyin(
        chineseText,
        separator: ' ',
        format: PinyinFormat.WITH_TONE_MARK,
      );

      return {
        'character': chineseText,
        'pinyin': pinyin,
      };
    } catch (_) {
      return {
        'character': 'Error',
        'pinyin': '',
      };
    }
  }

  /// ✅ Add translated word/sentence into Firestore vocabulary collection
  Future<void> addWordToBank({
    required String character,
    required String pinyin,
    required String meaning,
    required String category,
  }) async {
    final cleanCategory =
        category.trim().isEmpty ? 'Uncategorized' : category.trim();

    final docRef = _firestore.collection('vocabulary').doc();

    final newWord = WordModel(
      id: docRef.id,
      character: character.trim(),
      pinyin: pinyin.trim(),
      meaning: meaning.trim(),
      category: cleanCategory,
    );

    await docRef.set(newWord.toMap());

    // Update local list immediately (so it appears without needing refresh)
    _words.insert(0, newWord);
    notifyListeners();
  }
}