import 'package:flutter/material.dart';
import 'dart:math';
import '../models/quiz_model.dart';
import '../models/word_model.dart';

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  List<QuizQuestion> get questions => _questions;

  int _currentScore = 0;
  int get currentScore => _currentScore;

  void generateQuiz(List<WordModel> words) {
    _questions = [];
    _currentScore = 0;
    if (words.isEmpty) return;

    final random = Random();
    // Generate 5 questions
    for (int i = 0; i < 5; i++) {
      WordModel target = words[random.nextInt(words.length)];
      List<String> options = [];
      options.add(target.meaning);
      
      while (options.length < 4) {
        String option = words[random.nextInt(words.length)].meaning;
        if (!options.contains(option)) {
          options.add(option);
        }
      }
      options.shuffle();

      _questions.add(QuizQuestion(
        question: 'What is the meaning of ${target.character} (${target.pinyin})?',
        options: options,
        correctIndex: options.indexOf(target.meaning),
      ));
    }
    notifyListeners();
  }

  void updateScore(bool isCorrect) {
    if (isCorrect) _currentScore += 10;
    notifyListeners();
  }
}
