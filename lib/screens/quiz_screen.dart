import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/vocabulary_provider.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _answered = false;
  int? _selectedOptionIndex;
  final List<int> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vocabProvider =
          Provider.of<VocabularyProvider>(context, listen: false);
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      if (vocabProvider.words.isEmpty) {
        vocabProvider.fetchWords().then((_) {
          quizProvider.generateQuiz(vocabProvider.words);
        });
      } else {
        quizProvider.generateQuiz(vocabProvider.words);
      }
    });
  }

  void _handleAnswer(int selectedIndex, int correctIndex) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedOptionIndex = selectedIndex;
      _userAnswers.add(selectedIndex);
    });

    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    bool isCorrect = selectedIndex == correctIndex;
    quizProvider.updateScore(isCorrect);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentIndex < quizProvider.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedOptionIndex = null;
        });
      } else {
        _navigateToResult();
      }
    });
  }

  void _navigateToResult() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          score: quizProvider.currentScore,
          totalQuestions: quizProvider.questions.length,
          questions: quizProvider.questions,
          userAnswers: _userAnswers,
          onRetake: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const QuizScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Challenge'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final question = provider.questions[_currentIndex];
          final progress = (_currentIndex + 1) / provider.questions.length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: theme.colorScheme.primary,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Question ${_currentIndex + 1} of ${provider.questions.length}',
                  // style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[600],
                    fontSize: 16,
                  ),

                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        question.question,
                        // style: TextStyle(
                        //   fontSize: 24,
                        //   fontWeight: FontWeight.bold,
                        //   color: theme.colorScheme.primary,
                        // ),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),

                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                    itemBuilder: (ctx, index) {
                      final option = question.options[index];
                      Color btnColor = Colors.white;
                      Color textColor = theme.colorScheme.primary;
                      BorderSide borderSide =
                          BorderSide(color: theme.colorScheme.primary);

                      if (_answered) {
                        if (index == question.correctIndex) {
                          btnColor = Colors.green;
                          textColor = Colors.white;
                          borderSide = BorderSide.none;
                        } else if (index == _selectedOptionIndex) {
                          btnColor = Colors.red;
                          textColor = Colors.white;
                          borderSide = BorderSide.none;
                        }
                      }

                      return SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleAnswer(index, question.correctIndex),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: btnColor,
                            foregroundColor: textColor,
                            elevation: _answered ? 0 : 2,
                            side: borderSide,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
