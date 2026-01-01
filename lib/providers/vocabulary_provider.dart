import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';
import 'package:lpinyin/lpinyin.dart';
import '../models/word_model.dart';

class VocabularyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleTranslator _translator = GoogleTranslator();

  List<WordModel> _myVocabulary = [];
  List<WordModel> get myVocabulary => _myVocabulary;

  Map<String, List<WordModel>> _wordBank = {};
  bool _isLoading = false;
  bool _isInitialized = false;
  bool get isLoading => _isLoading;

  // Fallback hardcoded vocabulary (used if Firebase fails or is empty)
  // Expanded vocabulary bank organized by categories and difficulty levels
  // Level 1-2: Beginner (simple, common words)
  // Level 3-5: Intermediate (more complex words)
  // Level 6-8: Advanced (complex words and phrases)
  // Level 9-10: Expert (very complex, specialized vocabulary)
  static final Map<String, List<WordModel>> _hardcodedWordBank = {
    'Daily Conversation': [
      // Level 1 - Beginner
      WordModel(id: '1', character: '你好', pinyin: 'nǐ hǎo', meaning: 'Hello', category: 'Daily Conversation', level: 1),
      WordModel(id: '2', character: '谢谢', pinyin: 'xiè xie', meaning: 'Thank you', category: 'Daily Conversation', level: 1),
      WordModel(id: '3', character: '再见', pinyin: 'zài jiàn', meaning: 'Goodbye', category: 'Daily Conversation', level: 1),
      WordModel(id: '13', character: '请', pinyin: 'qǐng', meaning: 'Please', category: 'Daily Conversation', level: 1),
      WordModel(id: '14', character: '对不起', pinyin: 'duì bu qǐ', meaning: 'Sorry', category: 'Daily Conversation', level: 1),
      WordModel(id: '15', character: '是的', pinyin: 'shì de', meaning: 'Yes', category: 'Daily Conversation', level: 1),
      WordModel(id: '16', character: '不', pinyin: 'bù', meaning: 'No', category: 'Daily Conversation', level: 1),
      // Level 2
      WordModel(id: '17', character: '早上好', pinyin: 'zǎo shang hǎo', meaning: 'Good morning', category: 'Daily Conversation', level: 2),
      WordModel(id: '18', character: '晚上好', pinyin: 'wǎn shang hǎo', meaning: 'Good evening', category: 'Daily Conversation', level: 2),
      WordModel(id: '19', character: '请问', pinyin: 'qǐng wèn', meaning: 'Excuse me / May I ask', category: 'Daily Conversation', level: 2),
      WordModel(id: '20', character: '没关系', pinyin: 'méi guān xi', meaning: "It's okay / No problem", category: 'Daily Conversation', level: 2),
      // Level 3
      WordModel(id: '21', character: '很高兴认识你', pinyin: 'hěn gāo xìng rèn shi nǐ', meaning: 'Nice to meet you', category: 'Daily Conversation', level: 3),
      WordModel(id: '22', character: '你怎么样', pinyin: 'nǐ zěn me yàng', meaning: 'How are you', category: 'Daily Conversation', level: 3),
    ],
    'Education': [
      // Level 1
      WordModel(id: '4', character: '学校', pinyin: 'xué xiào', meaning: 'School', category: 'Education', level: 1),
      WordModel(id: '5', character: '老师', pinyin: 'lǎo shī', meaning: 'Teacher', category: 'Education', level: 1),
      WordModel(id: '6', character: '学生', pinyin: 'xué shēng', meaning: 'Student', category: 'Education', level: 1),
      WordModel(id: '23', character: '书', pinyin: 'shū', meaning: 'Book', category: 'Education', level: 1),
      WordModel(id: '24', character: '笔', pinyin: 'bǐ', meaning: 'Pen', category: 'Education', level: 1),
      // Level 2
      WordModel(id: '25', character: '教室', pinyin: 'jiào shì', meaning: 'Classroom', category: 'Education', level: 2),
      WordModel(id: '26', character: '学习', pinyin: 'xué xí', meaning: 'To study', category: 'Education', level: 2),
      WordModel(id: '27', character: '考试', pinyin: 'kǎo shì', meaning: 'Exam', category: 'Education', level: 2),
      // Level 3-4
      WordModel(id: '28', character: '作业', pinyin: 'zuò yè', meaning: 'Homework', category: 'Education', level: 3),
      WordModel(id: '29', character: '大学', pinyin: 'dà xué', meaning: 'University', category: 'Education', level: 3),
      WordModel(id: '30', character: '知识', pinyin: 'zhī shi', meaning: 'Knowledge', category: 'Education', level: 4),
      WordModel(id: '31', character: '教育', pinyin: 'jiào yù', meaning: 'Education', category: 'Education', level: 4),
    ],
    'Travel': [
      // Level 1
      WordModel(id: '7', character: '飞机', pinyin: 'fēi jī', meaning: 'Airplane', category: 'Travel', level: 1),
      WordModel(id: '8', character: '酒店', pinyin: 'jiǔ diàn', meaning: 'Hotel', category: 'Travel', level: 1),
      WordModel(id: '9', character: '地图', pinyin: 'dì tú', meaning: 'Map', category: 'Travel', level: 1),
      WordModel(id: '32', character: '车', pinyin: 'chē', meaning: 'Car', category: 'Travel', level: 1),
      // Level 2
      WordModel(id: '33', character: '火车', pinyin: 'huǒ chē', meaning: 'Train', category: 'Travel', level: 2),
      WordModel(id: '34', character: '票', pinyin: 'piào', meaning: 'Ticket', category: 'Travel', level: 2),
      WordModel(id: '35', character: '旅行', pinyin: 'lǚ xíng', meaning: 'Travel', category: 'Travel', level: 2),
      // Level 3-4
      WordModel(id: '36', character: '护照', pinyin: 'hù zhào', meaning: 'Passport', category: 'Travel', level: 3),
      WordModel(id: '37', character: '行李', pinyin: 'xíng li', meaning: 'Luggage', category: 'Travel', level: 3),
      WordModel(id: '38', character: '机场', pinyin: 'jī chǎng', meaning: 'Airport', category: 'Travel', level: 3),
      WordModel(id: '39', character: '签证', pinyin: 'qiān zhèng', meaning: 'Visa', category: 'Travel', level: 4),
    ],
    'Food': [
      // Level 1
      WordModel(id: '10', character: '米饭', pinyin: 'mǐ fàn', meaning: 'Rice', category: 'Food', level: 1),
      WordModel(id: '11', character: '面条', pinyin: 'miàn tiáo', meaning: 'Noodles', category: 'Food', level: 1),
      WordModel(id: '12', character: '水', pinyin: 'shuǐ', meaning: 'Water', category: 'Food', level: 1),
      WordModel(id: '40', character: '茶', pinyin: 'chá', meaning: 'Tea', category: 'Food', level: 1),
      WordModel(id: '41', character: '苹果', pinyin: 'píng guǒ', meaning: 'Apple', category: 'Food', level: 1),
      // Level 2
      WordModel(id: '42', character: '菜', pinyin: 'cài', meaning: 'Vegetable / Dish', category: 'Food', level: 2),
      WordModel(id: '43', character: '肉', pinyin: 'ròu', meaning: 'Meat', category: 'Food', level: 2),
      WordModel(id: '44', character: '吃', pinyin: 'chī', meaning: 'To eat', category: 'Food', level: 2),
      WordModel(id: '45', character: '餐厅', pinyin: 'cān tīng', meaning: 'Restaurant', category: 'Food', level: 2),
      // Level 3-4
      WordModel(id: '46', character: '菜单', pinyin: 'cài dān', meaning: 'Menu', category: 'Food', level: 3),
      WordModel(id: '47', character: '饺子', pinyin: 'jiǎo zi', meaning: 'Dumpling', category: 'Food', level: 3),
      WordModel(id: '48', character: '火锅', pinyin: 'huǒ guō', meaning: 'Hot pot', category: 'Food', level: 4),
      WordModel(id: '49', character: '筷子', pinyin: 'kuài zi', meaning: 'Chopsticks', category: 'Food', level: 3),
    ],
    'Numbers': [
      // Level 1
      WordModel(id: '50', character: '一', pinyin: 'yī', meaning: 'One', category: 'Numbers', level: 1),
      WordModel(id: '51', character: '二', pinyin: 'èr', meaning: 'Two', category: 'Numbers', level: 1),
      WordModel(id: '52', character: '三', pinyin: 'sān', meaning: 'Three', category: 'Numbers', level: 1),
      WordModel(id: '53', character: '四', pinyin: 'sì', meaning: 'Four', category: 'Numbers', level: 1),
      WordModel(id: '54', character: '五', pinyin: 'wǔ', meaning: 'Five', category: 'Numbers', level: 1),
      // Level 2
      WordModel(id: '55', character: '十', pinyin: 'shí', meaning: 'Ten', category: 'Numbers', level: 2),
      WordModel(id: '56', character: '百', pinyin: 'bǎi', meaning: 'Hundred', category: 'Numbers', level: 2),
      WordModel(id: '57', character: '千', pinyin: 'qiān', meaning: 'Thousand', category: 'Numbers', level: 3),
    ],
    'Family': [
      // Level 1-2
      WordModel(id: '58', character: '家', pinyin: 'jiā', meaning: 'Home / Family', category: 'Family', level: 1),
      WordModel(id: '59', character: '爸爸', pinyin: 'bà ba', meaning: 'Father', category: 'Family', level: 1),
      WordModel(id: '60', character: '妈妈', pinyin: 'mā ma', meaning: 'Mother', category: 'Family', level: 1),
      WordModel(id: '61', character: '朋友', pinyin: 'péng you', meaning: 'Friend', category: 'Family', level: 2),
      // Level 3
      WordModel(id: '62', character: '哥哥', pinyin: 'gē ge', meaning: 'Older brother', category: 'Family', level: 3),
      WordModel(id: '63', character: '姐姐', pinyin: 'jiě jie', meaning: 'Older sister', category: 'Family', level: 3),
      WordModel(id: '64', character: '弟弟', pinyin: 'dì di', meaning: 'Younger brother', category: 'Family', level: 3),
    ],
    'Time & Dates': [
      // Level 1-2
      WordModel(id: '65', character: '今天', pinyin: 'jīn tiān', meaning: 'Today', category: 'Time & Dates', level: 1),
      WordModel(id: '66', character: '明天', pinyin: 'míng tiān', meaning: 'Tomorrow', category: 'Time & Dates', level: 1),
      WordModel(id: '67', character: '昨天', pinyin: 'zuó tiān', meaning: 'Yesterday', category: 'Time & Dates', level: 2),
      WordModel(id: '68', character: '现在', pinyin: 'xiàn zài', meaning: 'Now', category: 'Time & Dates', level: 2),
      // Level 3-4
      WordModel(id: '69', character: '小时', pinyin: 'xiǎo shí', meaning: 'Hour', category: 'Time & Dates', level: 3),
      WordModel(id: '70', character: '分钟', pinyin: 'fēn zhōng', meaning: 'Minute', category: 'Time & Dates', level: 3),
      WordModel(id: '71', character: '星期', pinyin: 'xīng qī', meaning: 'Week', category: 'Time & Dates', level: 3),
    ],
    'Business': [
      // Level 4-5
      WordModel(id: '72', character: '公司', pinyin: 'gōng sī', meaning: 'Company', category: 'Business', level: 4),
      WordModel(id: '73', character: '工作', pinyin: 'gōng zuò', meaning: 'Work / Job', category: 'Business', level: 4),
      WordModel(id: '74', character: '会议', pinyin: 'huì yì', meaning: 'Meeting', category: 'Business', level: 4),
      WordModel(id: '75', character: '合同', pinyin: 'hé tong', meaning: 'Contract', category: 'Business', level: 5),
      WordModel(id: '76', character: '客户', pinyin: 'kè hù', meaning: 'Client', category: 'Business', level: 5),
    ],
    'Advanced': [
      // Level 6-8
      WordModel(id: '77', character: '文化', pinyin: 'wén huà', meaning: 'Culture', category: 'Advanced', level: 6),
      WordModel(id: '78', character: '历史', pinyin: 'lì shǐ', meaning: 'History', category: 'Advanced', level: 6),
      WordModel(id: '79', character: '经济', pinyin: 'jīng jì', meaning: 'Economy', category: 'Advanced', level: 7),
      WordModel(id: '80', character: '政治', pinyin: 'zhèng zhì', meaning: 'Politics', category: 'Advanced', level: 8),
      WordModel(id: '81', character: '哲学', pinyin: 'zhé xué', meaning: 'Philosophy', category: 'Advanced', level: 8),
    ],
  };

  Map<String, List<WordModel>> get wordBank {
    if (_wordBank.isEmpty && !_isLoading) {
      // If wordBank is empty and not loading, use fallback
      return _fallbackWordBank;
    }
    return _wordBank;
  }

  // Initialize vocabulary from Firebase (call this on app start)
  Future<void> initializeVocabulary() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await fetchVocabularyFromFirebase();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing vocabulary from Firebase: $e');
      // Fallback to hardcoded words
      _wordBank = _fallbackWordBank;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch vocabulary from Firebase Firestore
  Future<void> fetchVocabularyFromFirebase() async {
    try {
      final snapshot = await _firestore
          .collection('vocabulary')
          .get();
      
      if (snapshot.docs.isEmpty) {
        // If no words in Firebase, use fallback and optionally seed Firebase
        _wordBank = _fallbackWordBank;
        return;
      }

      // Group words by category
      Map<String, List<WordModel>> fetchedBank = {};
      
      for (var doc in snapshot.docs) {
        final word = WordModel.fromMap(doc.data());
        if (!fetchedBank.containsKey(word.category)) {
          fetchedBank[word.category] = [];
        }
        fetchedBank[word.category]!.add(word);
      }

      _wordBank = fetchedBank;
      notifyListeners();
    } catch (e) {
      print('Error fetching vocabulary from Firebase: $e');
      // Fallback to hardcoded words
      _wordBank = _fallbackWordBank;
      rethrow;
    }
  }

  // Seed Firebase with initial vocabulary (call this once to populate Firebase)
  Future<void> seedFirebaseWithVocabulary() async {
    try {
      final batch = _firestore.batch();
      int batchCount = 0;
      const maxBatchSize = 500; // Firestore batch limit

      for (var category in _hardcodedWordBank.keys) {
        for (var word in _hardcodedWordBank[category]!) {
          final docRef = _firestore
              .collection('vocabulary')
              .doc(word.id);
          
          batch.set(docRef, word.toMap());
          batchCount++;

          // Firestore has a limit of 500 operations per batch
          if (batchCount >= maxBatchSize) {
            await batch.commit();
            batchCount = 0;
          }
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      print('Successfully seeded Firebase with ${_hardcodedWordBank.values.fold(0, (sum, words) => sum + words.length)} words');
      
      // Refresh the word bank from Firebase
      await fetchVocabularyFromFirebase();
    } catch (e) {
      print('Error seeding Firebase: $e');
      rethrow;
    }
  }

  // Add a new word to Firebase vocabulary bank
  Future<void> addWordToFirebase(WordModel word) async {
    try {
      await _firestore
          .collection('vocabulary')
          .doc(word.id)
          .set(word.toMap());
      
      // Update local word bank
      if (!_wordBank.containsKey(word.category)) {
        _wordBank[word.category] = [];
      }
      if (!_wordBank[word.category]!.any((w) => w.id == word.id)) {
        _wordBank[word.category]!.add(word);
      }
      notifyListeners();
    } catch (e) {
      print('Error adding word to Firebase: $e');
      rethrow;
    }
  }

  // Fallback hardcoded vocabulary (used if Firebase fails or is empty)
  Map<String, List<WordModel>> get _fallbackWordBank {
    return _hardcodedWordBank;
  }

  // Get words filtered by user's level (shows words up to user's level)
  Map<String, List<WordModel>> getWordsByLevel(int userLevel) {
    Map<String, List<WordModel>> filteredBank = {};
    
    wordBank.forEach((category, words) {
      List<WordModel> filteredWords = words.where((word) => word.level <= userLevel).toList();
      if (filteredWords.isNotEmpty) {
        filteredBank[category] = filteredWords;
      }
    });
    
    return filteredBank;
  }

  // Get all words up to user's level (flattened list)
  List<WordModel> getAllWordsByLevel(int userLevel) {
    List<WordModel> allWords = [];
    wordBank.forEach((category, words) {
      allWords.addAll(words.where((word) => word.level <= userLevel));
    });
    return allWords;
  }

  Future<void> fetchMyVocabulary(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_vocabulary')
          .get();
      
      _myVocabulary = snapshot.docs
          .map((doc) => WordModel.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching vocabulary: $e');
    }
  }

  Future<void> addToMyVocabulary(String userId, WordModel word) async {
    try {
      // Check if already exists
      if (_myVocabulary.any((w) => w.character == word.character)) {
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_vocabulary')
          .doc(word.character) // Use character as ID to prevent duplicates
          .set(word.toMap());
      
      _myVocabulary.add(word);
      notifyListeners();
    } catch (e) {
      print('Error adding word: $e');
      rethrow;
    }
  }

  Future<WordModel> translate(String text, {bool toChinese = true}) async {
    var from = toChinese ? 'en' : 'zh-cn';
    var to = toChinese ? 'zh-cn' : 'en';

    var translation = await _translator.translate(text, from: from, to: to);
    
    String character = toChinese ? translation.text : text;
    String meaning = toChinese ? text : translation.text;
    String pinyinStr = PinyinHelper.getPinyin(character, separator: ' ', format: PinyinFormat.WITH_TONE_MARK);

    return WordModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      character: character,
      pinyin: pinyinStr,
      meaning: meaning,
      category: 'Translated',
      level: 1, // Default to level 1 for translated words
    );
  }
}
