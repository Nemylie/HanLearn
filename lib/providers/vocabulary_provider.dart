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

  /// Realtime stream (recommended for vocab list page)
  /// i didnt add timestamp in firebase.
  Stream<List<WordModel>> vocabularyStream() {
    return _firestore
        .collection('vocabulary')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => WordModel.fromFirestore(d)).toList());
  }

  /// One-time fetch (kept for compatibility with your current UI)
  Future<void> fetchWords() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('vocabulary')
          .orderBy('createdAt', descending: true)
          .get();

      _words = snapshot.docs.map((d) => WordModel.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('Error fetching words: $e');
      _words = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Manual add (recommended for your use case)
  /// - character and meaning required
  /// - pinyin optional (auto-generate if empty)
  Future<void> addWordManual({
    required String character,
    required String meaning,
    required String category,
    String? pinyin,
  }) async {
    final cleanChar = character.trim();
    final cleanMeaning = meaning.trim();
    final cleanCategory = category.trim();

    if (cleanChar.isEmpty || cleanMeaning.isEmpty || cleanCategory.isEmpty) {
      throw Exception('Character, meaning, and category cannot be empty.');
    }

    // If user didn't provide pinyin, auto-generate from chinese characters
    final finalPinyin = (pinyin == null || pinyin.trim().isEmpty)
        ? PinyinHelper.getPinyin(
            cleanChar,
            separator: ' ',
            format: PinyinFormat.WITH_TONE_MARK,
          )
        : pinyin.trim();

    final word = WordModel(
      id: '', // Firestore will generate doc id
      character: cleanChar,
      pinyin: finalPinyin,
      meaning: cleanMeaning,
      category: cleanCategory,
    );

    await _firestore.collection('vocabulary').add(word.toMap());

    // Optional: refresh local cache if your UI uses `words` list
    await fetchWords();
  }

  /// Delete a vocab word by Firestore doc id
  Future<void> deleteWord(String docId) async {
    await _firestore.collection('vocabulary').doc(docId).delete();
    await fetchWords();
  }

  /// Optional helper:
  /// Translate an English/Malay word/phrase to Chinese and generate Pinyin.
  /// NOTE: This does NOT "add vocab". It only helps generate chinese + pinyin.
  Future<Map<String, String>> translateToChineseAndPinyin(String text) async {
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
    } catch (e) {
      debugPrint('translateToChineseAndPinyin error: $e');
      return {
        'character': 'Error',
        'pinyin': '',
      };
    }
  }
}


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
//        // adjusted words here to replace firestore if code cannot sync
//         _words = [
        //   // Daily Conversation (10)
        //   WordModel(id: '1', character: '你好', pinyin: 'nǐ hǎo', meaning: 'Hello', category: 'Daily Conversation'),
        //   WordModel(id: '2', character: '谢谢', pinyin: 'xiè xie', meaning: 'Thank you', category: 'Daily Conversation'),
        //   WordModel(id: '3', character: '不客气', pinyin: 'bú kè qi', meaning: 'You’re welcome', category: 'Daily Conversation'),
        //   WordModel(id: '4', character: '对不起', pinyin: 'duì bù qǐ', meaning: 'Sorry', category: 'Daily Conversation'),
        //   WordModel(id: '5', character: '没关系', pinyin: 'méi guān xi', meaning: 'It’s okay', category: 'Daily Conversation'),
        //   WordModel(id: '6', character: '请问', pinyin: 'qǐng wèn', meaning: 'Excuse me / May I ask', category: 'Daily Conversation'),
        //   WordModel(id: '7', character: '再见', pinyin: 'zài jiàn', meaning: 'Goodbye', category: 'Daily Conversation'),
        //   WordModel(id: '8', character: '好的', pinyin: 'hǎo de', meaning: 'Okay', category: 'Daily Conversation'),
        //   WordModel(id: '9', character: '是', pinyin: 'shì', meaning: 'Yes', category: 'Daily Conversation'),
        //   WordModel(id: '10', character: '不是', pinyin: 'bú shì', meaning: 'No', category: 'Daily Conversation'),

        //   // Animals (10)
        //   WordModel(id: '11', character: '狗', pinyin: 'gǒu', meaning: 'Dog', category: 'Animals'),
        //   WordModel(id: '12', character: '猫', pinyin: 'māo', meaning: 'Cat', category: 'Animals'),
        //   WordModel(id: '13', character: '鸟', pinyin: 'niǎo', meaning: 'Bird', category: 'Animals'),
        //   WordModel(id: '14', character: '鱼', pinyin: 'yú', meaning: 'Fish', category: 'Animals'),
        //   WordModel(id: '15', character: '马', pinyin: 'mǎ', meaning: 'Horse', category: 'Animals'),
        //   WordModel(id: '16', character: '牛', pinyin: 'niú', meaning: 'Cow', category: 'Animals'),
        //   WordModel(id: '17', character: '虎', pinyin: 'hǔ', meaning: 'Tiger', category: 'Animals'),
        //   WordModel(id: '18', character: '熊', pinyin: 'xióng', meaning: 'Bear', category: 'Animals'),
        //   WordModel(id: '19', character: '猴子', pinyin: 'hóu zi', meaning: 'Monkey', category: 'Animals'),
        //   WordModel(id: '20', character: '乌龟', pinyin: 'wū guī', meaning: 'Turtle', category: 'Animals'),

        //   // Food (10)
        //   WordModel(id: '21', character: '米饭', pinyin: 'mǐ fàn', meaning: 'Rice', category: 'Food'),
        //   WordModel(id: '22', character: '面条', pinyin: 'miàn tiáo', meaning: 'Noodles', category: 'Food'),
        //   WordModel(id: '23', character: '水', pinyin: 'shuǐ', meaning: 'Water', category: 'Food'),
        //   WordModel(id: '24', character: '鸡肉', pinyin: 'jī ròu', meaning: 'Chicken', category: 'Food'),
        //   WordModel(id: '25', character: '牛肉', pinyin: 'niú ròu', meaning: 'Beef', category: 'Food'),
        //   WordModel(id: '26', character: '面包', pinyin: 'miàn bāo', meaning: 'Bread', category: 'Food'),
        //   WordModel(id: '27', character: '蛋', pinyin: 'dàn', meaning: 'Egg', category: 'Food'),
        //   WordModel(id: '28', character: '苹果', pinyin: 'píng guǒ', meaning: 'Apple', category: 'Food'),
        //   WordModel(id: '29', character: '茶', pinyin: 'chá', meaning: 'Tea', category: 'Food'),
        //   WordModel(id: '30', character: '咖啡', pinyin: 'kā fēi', meaning: 'Coffee', category: 'Food'),

        //   // Travel (10)
        //   WordModel(id: '31', character: '飞机', pinyin: 'fēi jī', meaning: 'Airplane', category: 'Travel'),
        //   WordModel(id: '32', character: '火车', pinyin: 'huǒ chē', meaning: 'Train', category: 'Travel'),
        //   WordModel(id: '33', character: '出发', pinyin: 'chū fā', meaning: 'Depart', category: 'Travel'),
        //   WordModel(id: '34', character: '到达', pinyin: 'dào dá', meaning: 'Arrive', category: 'Travel'),
        //   WordModel(id: '35', character: '机场', pinyin: 'jī chǎng', meaning: 'Airport', category: 'Travel'),
        //   WordModel(id: '36', character: '酒店', pinyin: 'jiǔ diàn', meaning: 'Hotel', category: 'Travel'),
        //   WordModel(id: '37', character: '护照', pinyin: 'hù zhào', meaning: 'Passport', category: 'Travel'),
        //   WordModel(id: '38', character: '行李', pinyin: 'xíng lǐ', meaning: 'Luggage', category: 'Travel'),
        //   WordModel(id: '39', character: '地图', pinyin: 'dì tú', meaning: 'Map', category: 'Travel'),
        //   WordModel(id: '40', character: '旅游', pinyin: 'lǚ yóu', meaning: 'Travel/Tourism', category: 'Travel'),
        // ];

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
