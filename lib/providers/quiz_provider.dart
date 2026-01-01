import 'dart:math';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../models/word_model.dart';
import 'vocabulary_provider.dart';

class QuizProvider extends ChangeNotifier {
  List<Question> _questions = [];
  List<Question> get questions => _questions;
  
  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;
  
  int _score = 0;
  int get score => _score;
  
  bool _isQuizFinished = false;
  bool get isQuizFinished => _isQuizFinished;

  // Generate a quiz from the vocabulary bank, filtered by user level
  void generateQuiz(VocabularyProvider vocabProvider, {int? userLevel}) {
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizFinished = false;

    // Get words filtered by user level, or all words if level not provided
    List<WordModel> allWords = userLevel != null
        ? vocabProvider.getAllWordsByLevel(userLevel)
        : vocabProvider.wordBank.values.expand((words) => words).toList();

    if (allWords.length < 4) return; // Not enough words

    final random = Random();
    
    // Create 5 questions
    for (int i = 0; i < 5; i++) {
      WordModel targetWord = allWords[random.nextInt(allWords.length)];
      
      // Create options (1 correct, 3 wrong) from words at similar level
      List<String> options = [targetWord.meaning];
      List<WordModel> similarLevelWords = allWords.where((w) => 
        (w.level - targetWord.level).abs() <= 1 && w.character != targetWord.character
      ).toList();
      
      if (similarLevelWords.length < 3) {
        similarLevelWords = allWords.where((w) => w.character != targetWord.character).toList();
      }
      
      while (options.length < 4 && similarLevelWords.isNotEmpty) {
        String randomMeaning = similarLevelWords[random.nextInt(similarLevelWords.length)].meaning;
        if (!options.contains(randomMeaning)) {
          options.add(randomMeaning);
        }
      }
      
      // If still not enough options, fill with any words
      while (options.length < 4) {
        String randomMeaning = allWords[random.nextInt(allWords.length)].meaning;
        if (!options.contains(randomMeaning)) {
          options.add(randomMeaning);
        }
      }
      
      options.shuffle();

      _questions.add(Question(
        id: i.toString(),
        questionText: 'What is the meaning of "${targetWord.character}" (${targetWord.pinyin})?',
        options: options,
        correctAnswer: targetWord.meaning,
      ));
    }
    notifyListeners();
  }

  void answerQuestion(String answer) {
    if (_questions[_currentQuestionIndex].correctAnswer == answer) {
      _score += 10;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _isQuizFinished = true;
    }
    notifyListeners();
  }

  void resetQuiz() {
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizFinished = false;
    notifyListeners();
  }
}
