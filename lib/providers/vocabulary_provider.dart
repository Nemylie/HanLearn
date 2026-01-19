import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translator/translator.dart';
import 'package:lpinyin/lpinyin.dart';

import '../models/word_model.dart';

class VocabularyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleTranslator _translator = GoogleTranslator();

  static const Map<String, String> supportedLanguages = {
    'auto': 'Detect Language',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'vi': 'Vietnamese',
    'th': 'Thai',
    'id': 'Indonesian',
    'ms': 'Malay',
    'hi': 'Hindi',
    'bn': 'Bengali',
    'ar': 'Arabic',
    'tr': 'Turkish',
    'pl': 'Polish',
    'nl': 'Dutch',
    'tl': 'Tagalog',
    'uk': 'Ukrainian',
    'sv': 'Swedish',
    'no': 'Norwegian',
    'da': 'Danish',
    'fi': 'Finnish',
    'el': 'Greek',
    'cs': 'Czech',
    'ro': 'Romanian',
    'hu': 'Hungarian',
    'sk': 'Slovak',
    'bg': 'Bulgarian',
    'hr': 'Croatian',
    'sr': 'Serbian',
    'sl': 'Slovenian',
    'et': 'Estonian',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'he': 'Hebrew',
    'fa': 'Persian',
    'ur': 'Urdu',
    'sw': 'Swahili',
    'zh-cn': 'Chinese (Simplified)',
    'zh-tw': 'Chinese (Traditional)',
  };

  static final List<WordModel> _defaultWords = [
    // 1. Daily Conversation
    WordModel(id: 'def_1', character: '你好', pinyin: 'nǐ hǎo', meaning: 'Hello', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_2', character: '谢谢', pinyin: 'xiè xie', meaning: 'Thank you', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_3', character: '再见', pinyin: 'zài jiàn', meaning: 'Goodbye', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_4', character: '对不起', pinyin: 'duì bu qǐ', meaning: 'Sorry', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_5', character: '没关系', pinyin: 'méi guān xi', meaning: 'It\'s okay', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_6', character: '早上好', pinyin: 'zǎo shang hǎo', meaning: 'Good morning', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_7', character: '晚安', pinyin: 'wǎn ān', meaning: 'Good night', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_8', character: '是', pinyin: 'shì', meaning: 'Yes', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_9', character: '不', pinyin: 'bù', meaning: 'No', category: 'Daily Conversation', isDefault: true),
    WordModel(id: 'def_10', character: '请', pinyin: 'qǐng', meaning: 'Please', category: 'Daily Conversation', isDefault: true),

    // 2. Numbers
    WordModel(id: 'def_11', character: '一', pinyin: 'yī', meaning: 'One', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_12', character: '二', pinyin: 'èr', meaning: 'Two', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_13', character: '三', pinyin: 'sān', meaning: 'Three', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_14', character: '四', pinyin: 'sì', meaning: 'Four', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_15', character: '五', pinyin: 'wǔ', meaning: 'Five', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_16', character: '六', pinyin: 'liù', meaning: 'Six', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_17', character: '七', pinyin: 'qī', meaning: 'Seven', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_18', character: '八', pinyin: 'bā', meaning: 'Eight', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_19', character: '九', pinyin: 'jiǔ', meaning: 'Nine', category: 'Numbers', isDefault: true),
    WordModel(id: 'def_20', character: '十', pinyin: 'shí', meaning: 'Ten', category: 'Numbers', isDefault: true),

    // 3. Food
    WordModel(id: 'def_21', character: '水', pinyin: 'shuǐ', meaning: 'Water', category: 'Food', isDefault: true),
    WordModel(id: 'def_22', character: '饭', pinyin: 'fàn', meaning: 'Rice/Meal', category: 'Food', isDefault: true),
    WordModel(id: 'def_23', character: '面条', pinyin: 'miàn tiáo', meaning: 'Noodles', category: 'Food', isDefault: true),
    WordModel(id: 'def_24', character: '面包', pinyin: 'miàn bāo', meaning: 'Bread', category: 'Food', isDefault: true),
    WordModel(id: 'def_25', character: '牛奶', pinyin: 'niú nǎi', meaning: 'Milk', category: 'Food', isDefault: true),
    WordModel(id: 'def_26', character: '茶', pinyin: 'chá', meaning: 'Tea', category: 'Food', isDefault: true),
    WordModel(id: 'def_27', character: '咖啡', pinyin: 'kā fēi', meaning: 'Coffee', category: 'Food', isDefault: true),
    WordModel(id: 'def_28', character: '水果', pinyin: 'shuǐ guǒ', meaning: 'Fruit', category: 'Food', isDefault: true),
    WordModel(id: 'def_29', character: '蔬菜', pinyin: 'shū cài', meaning: 'Vegetables', category: 'Food', isDefault: true),
    WordModel(id: 'def_30', character: '鸡蛋', pinyin: 'jī dàn', meaning: 'Egg', category: 'Food', isDefault: true),

    // 4. Animals
    WordModel(id: 'def_31', character: '猫', pinyin: 'māo', meaning: 'Cat', category: 'Animals', isDefault: true),
    WordModel(id: 'def_32', character: '狗', pinyin: 'gǒu', meaning: 'Dog', category: 'Animals', isDefault: true),
    WordModel(id: 'def_33', character: '鸟', pinyin: 'niǎo', meaning: 'Bird', category: 'Animals', isDefault: true),
    WordModel(id: 'def_34', character: '鱼', pinyin: 'yú', meaning: 'Fish', category: 'Animals', isDefault: true),
    WordModel(id: 'def_35', character: '马', pinyin: 'mǎ', meaning: 'Horse', category: 'Animals', isDefault: true),
    WordModel(id: 'def_36', character: '牛', pinyin: 'niú', meaning: 'Cow', category: 'Animals', isDefault: true),
    WordModel(id: 'def_37', character: '羊', pinyin: 'yáng', meaning: 'Sheep', category: 'Animals', isDefault: true),
    WordModel(id: 'def_38', character: '猪', pinyin: 'zhū', meaning: 'Pig', category: 'Animals', isDefault: true),
    WordModel(id: 'def_39', character: '熊猫', pinyin: 'xióng māo', meaning: 'Panda', category: 'Animals', isDefault: true),
    WordModel(id: 'def_40', character: '龙', pinyin: 'lóng', meaning: 'Dragon', category: 'Animals', isDefault: true),

    // 5. Family
    WordModel(id: 'def_41', character: '爸爸', pinyin: 'bà ba', meaning: 'Father', category: 'Family', isDefault: true),
    WordModel(id: 'def_42', character: '妈妈', pinyin: 'mā ma', meaning: 'Mother', category: 'Family', isDefault: true),
    WordModel(id: 'def_43', character: '哥哥', pinyin: 'gē ge', meaning: 'Older Brother', category: 'Family', isDefault: true),
    WordModel(id: 'def_44', character: '弟弟', pinyin: 'dì di', meaning: 'Younger Brother', category: 'Family', isDefault: true),
    WordModel(id: 'def_45', character: '姐姐', pinyin: 'jiě jie', meaning: 'Older Sister', category: 'Family', isDefault: true),
    WordModel(id: 'def_46', character: '妹妹', pinyin: 'mèi mei', meaning: 'Younger Sister', category: 'Family', isDefault: true),
    WordModel(id: 'def_47', character: '爷爷', pinyin: 'yé ye', meaning: 'Grandfather (Paternal)', category: 'Family', isDefault: true),
    WordModel(id: 'def_48', character: '奶奶', pinyin: 'nǎi nai', meaning: 'Grandmother (Paternal)', category: 'Family', isDefault: true),
    WordModel(id: 'def_49', character: '儿子', pinyin: 'ér zi', meaning: 'Son', category: 'Family', isDefault: true),
    WordModel(id: 'def_50', character: '女儿', pinyin: 'nǚ ér', meaning: 'Daughter', category: 'Family', isDefault: true),

    // 6. Colors
    WordModel(id: 'def_51', character: '红色', pinyin: 'hóng sè', meaning: 'Red', category: 'Colors', isDefault: true),
    WordModel(id: 'def_52', character: '蓝色', pinyin: 'lán sè', meaning: 'Blue', category: 'Colors', isDefault: true),
    WordModel(id: 'def_53', character: '绿色', pinyin: 'lǜ sè', meaning: 'Green', category: 'Colors', isDefault: true),
    WordModel(id: 'def_54', character: '黄色', pinyin: 'huáng sè', meaning: 'Yellow', category: 'Colors', isDefault: true),
    WordModel(id: 'def_55', character: '黑色', pinyin: 'hēi sè', meaning: 'Black', category: 'Colors', isDefault: true),
    WordModel(id: 'def_56', character: '白色', pinyin: 'bái sè', meaning: 'White', category: 'Colors', isDefault: true),
    WordModel(id: 'def_57', character: '橙色', pinyin: 'chéng sè', meaning: 'Orange', category: 'Colors', isDefault: true),
    WordModel(id: 'def_58', character: '紫色', pinyin: 'zǐ sè', meaning: 'Purple', category: 'Colors', isDefault: true),
    WordModel(id: 'def_59', character: '粉色', pinyin: 'fěn sè', meaning: 'Pink', category: 'Colors', isDefault: true),
    WordModel(id: 'def_60', character: '灰色', pinyin: 'huī sè', meaning: 'Grey', category: 'Colors', isDefault: true),

    // 7. Travel
    WordModel(id: 'def_61', character: '飞机', pinyin: 'fēi jī', meaning: 'Airplane', category: 'Travel', isDefault: true),
    WordModel(id: 'def_62', character: '火车', pinyin: 'huǒ chē', meaning: 'Train', category: 'Travel', isDefault: true),
    WordModel(id: 'def_63', character: '出租车', pinyin: 'chū zū chē', meaning: 'Taxi', category: 'Travel', isDefault: true),
    WordModel(id: 'def_64', character: '公共汽车', pinyin: 'gōng gòng qì chē', meaning: 'Bus', category: 'Travel', isDefault: true),
    WordModel(id: 'def_65', character: '机场', pinyin: 'jī chǎng', meaning: 'Airport', category: 'Travel', isDefault: true),
    WordModel(id: 'def_66', character: '车站', pinyin: 'chē zhàn', meaning: 'Station', category: 'Travel', isDefault: true),
    WordModel(id: 'def_67', character: '酒店', pinyin: 'jiǔ diàn', meaning: 'Hotel', category: 'Travel', isDefault: true),
    WordModel(id: 'def_68', character: '护照', pinyin: 'hù zhào', meaning: 'Passport', category: 'Travel', isDefault: true),
    WordModel(id: 'def_69', character: '行李', pinyin: 'xíng li', meaning: 'Luggage', category: 'Travel', isDefault: true),
    WordModel(id: 'def_70', character: '地图', pinyin: 'dì tú', meaning: 'Map', category: 'Travel', isDefault: true),

    // 8. Jobs
    WordModel(id: 'def_71', character: '老师', pinyin: 'lǎo shī', meaning: 'Teacher', category: 'Job', isDefault: true),
    WordModel(id: 'def_72', character: '学生', pinyin: 'xué shēng', meaning: 'Student', category: 'Job', isDefault: true),
    WordModel(id: 'def_73', character: '医生', pinyin: 'yī shēng', meaning: 'Doctor', category: 'Job', isDefault: true),
    WordModel(id: 'def_74', character: '护士', pinyin: 'hù shi', meaning: 'Nurse', category: 'Job', isDefault: true),
    WordModel(id: 'def_75', character: '工程师', pinyin: 'gōng chéng shī', meaning: 'Engineer', category: 'Job', isDefault: true),
    WordModel(id: 'def_76', character: '警察', pinyin: 'jǐng chá', meaning: 'Police', category: 'Job', isDefault: true),
    WordModel(id: 'def_77', character: '商人', pinyin: 'shāng rén', meaning: 'Businessperson', category: 'Job', isDefault: true),
    WordModel(id: 'def_78', character: '厨师', pinyin: 'chú shī', meaning: 'Chef', category: 'Job', isDefault: true),
    WordModel(id: 'def_79', character: '司机', pinyin: 'sī jī', meaning: 'Driver', category: 'Job', isDefault: true),
    WordModel(id: 'def_80', character: '律师', pinyin: 'lǜ shī', meaning: 'Lawyer', category: 'Job', isDefault: true),

    // 9. Countries
    WordModel(id: 'def_81', character: '中国', pinyin: 'zhōng guó', meaning: 'China', category: 'Countries', isDefault: true),
    WordModel(id: 'def_82', character: '美国', pinyin: 'měi guó', meaning: 'USA', category: 'Countries', isDefault: true),
    WordModel(id: 'def_83', character: '英国', pinyin: 'yīng guó', meaning: 'UK', category: 'Countries', isDefault: true),
    WordModel(id: 'def_84', character: '法国', pinyin: 'fǎ guó', meaning: 'France', category: 'Countries', isDefault: true),
    WordModel(id: 'def_85', character: '日本', pinyin: 'rì běn', meaning: 'Japan', category: 'Countries', isDefault: true),
    WordModel(id: 'def_86', character: '韩国', pinyin: 'hán guó', meaning: 'Korea', category: 'Countries', isDefault: true),
    WordModel(id: 'def_87', character: '德国', pinyin: 'dé guó', meaning: 'Germany', category: 'Countries', isDefault: true),
    WordModel(id: 'def_88', character: '加拿大', pinyin: 'jiā ná dà', meaning: 'Canada', category: 'Countries', isDefault: true),
    WordModel(id: 'def_89', character: '澳大利亚', pinyin: 'ào dà lì yà', meaning: 'Australia', category: 'Countries', isDefault: true),
    WordModel(id: 'def_90', character: '印度', pinyin: 'yìn dù', meaning: 'India', category: 'Countries', isDefault: true),

    // 10. Time
    WordModel(id: 'def_91', character: '今天', pinyin: 'jīn tiān', meaning: 'Today', category: 'Time', isDefault: true),
    WordModel(id: 'def_92', character: '明天', pinyin: 'míng tiān', meaning: 'Tomorrow', category: 'Time', isDefault: true),
    WordModel(id: 'def_93', character: '昨天', pinyin: 'zuó tiān', meaning: 'Yesterday', category: 'Time', isDefault: true),
    WordModel(id: 'def_94', character: '现在', pinyin: 'xiàn zài', meaning: 'Now', category: 'Time', isDefault: true),
    WordModel(id: 'def_95', character: '时间', pinyin: 'shí jiān', meaning: 'Time', category: 'Time', isDefault: true),
    WordModel(id: 'def_96', character: '年', pinyin: 'nián', meaning: 'Year', category: 'Time', isDefault: true),
    WordModel(id: 'def_97', character: '月', pinyin: 'yuè', meaning: 'Month', category: 'Time', isDefault: true),
    WordModel(id: 'def_98', character: '日', pinyin: 'rì', meaning: 'Day', category: 'Time', isDefault: true),
    WordModel(id: 'def_99', character: '星期', pinyin: 'xīng qī', meaning: 'Week', category: 'Time', isDefault: true),
    WordModel(id: 'def_100', character: '小时', pinyin: 'xiǎo shí', meaning: 'Hour', category: 'Time', isDefault: true),
  ];

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
      // Always start with default words
      List<WordModel> allWords = List.from(_defaultWords);

      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('vocabulary')
            .get();

        if (snapshot.docs.isNotEmpty) {
          final userWords = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = (data['id'] ?? doc.id);
            // Ensure isDefault is false for user words
            data['isDefault'] = false;
            return WordModel.fromMap(data);
          }).toList();

          // Add user words to the beginning or end? 
          // Let's add them to the beginning so users see their saved words first
          allWords.insertAll(0, userWords);
        }
      }
      
      _words = allWords;
    } catch (e) {
      debugPrint('Error fetching words: $e');
      // On error, at least show default words
      _words = List.from(_defaultWords);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, String>> translateText(String text, {String from = 'auto'}) async {
    try {
      final translation = await _translator.translate(text, from: from, to: 'zh-cn');
      final chineseText = translation.text;

      final pinyin = PinyinHelper.getPinyin(
        chineseText,
        separator: ' ',
        format: PinyinFormat.WITH_TONE_MARK,
      );

      // Try to fetch an example sentence if the source language is likely English
      String exampleOriginal = '';
      String exampleTranslated = '';

      if (from == 'auto' || from == 'en') {
        try {
          final example = await _fetchExampleSentence(text);
          if (example.isNotEmpty) {
             exampleOriginal = example;
             final exampleTrans = await _translator.translate(example, from: 'en', to: 'zh-cn');
             exampleTranslated = exampleTrans.text;
          }
        } catch (e) {
          debugPrint('Error fetching example: $e');
        }
      }

      return {
        'character': chineseText,
        'pinyin': pinyin,
        'example_original': exampleOriginal,
        'example_translated': exampleTranslated,
      };
    } catch (_) {
      return {
        'character': 'Error',
        'pinyin': '',
        'example_original': '',
        'example_translated': '',
      };
    }
  }

  Future<String> _fetchExampleSentence(String word) async {
    try {
      // Use DictionaryAPI to get meanings and examples
      final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final meanings = data[0]['meanings'] as List<dynamic>;
          for (final meaning in meanings) {
            final definitions = meaning['definitions'] as List<dynamic>;
            for (final def in definitions) {
              if (def['example'] != null) {
                return def['example'].toString();
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('DictionaryAPI error: $e');
    }
    return '';
  }

  /// ✅ Add translated word/sentence into Firestore vocabulary collection
  Future<void> addWordToBank({
    required String character,
    required String pinyin,
    required String meaning,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to save words');
    }

    final cleanCategory =
        category.trim().isEmpty ? 'Uncategorized' : category.trim();

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('vocabulary')
        .doc();

    final newWord = WordModel(
      id: docRef.id,
      character: character.trim(),
      pinyin: pinyin.trim(),
      meaning: meaning.trim(),
      category: cleanCategory,
      isDefault: false,
    );

    await docRef.set(newWord.toMap());

    // Update local list immediately (so it appears without needing refresh)
    _words.insert(0, newWord);
    notifyListeners();
  }
}