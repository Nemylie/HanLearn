import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/auth_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userLevel = authProvider.userModel?.level ?? 1;
      Provider.of<QuizProvider>(context, listen: false).generateQuiz(vocabProvider, userLevel: userLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/HanLearnLogo.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 12),
            const Text('Quiz Challenge'),
          ],
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Not enough vocabulary to generate quiz!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (quizProvider.isQuizFinished) {
            return _buildResultScreen(context, quizProvider);
          }

          return _buildQuestionScreen(context, quizProvider);
        },
      ),
    );
  }

  Widget _buildQuestionScreen(BuildContext context, QuizProvider quizProvider) {
    final question = quizProvider.questions[quizProvider.currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (quizProvider.currentQuestionIndex + 1) / quizProvider.questions.length,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.questions.length}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                question.questionText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final option = question.options[index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onPressed: () {
                    quizProvider.answerQuestion(option);
                  },
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, QuizProvider quizProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Save score only once when this screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assuming 5 words learned for completing a quiz (simplification)
      authProvider.updateProgress(quizProvider.score, 5);
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            ),
            const SizedBox(height: 32),
            const Text(
              'Quiz Completed!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF800000)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Score',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${quizProvider.score} / ${quizProvider.questions.length * 10}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final userLevel = authProvider.userModel?.level ?? 1;
                  quizProvider.generateQuiz(vocabProvider, userLevel: userLevel);
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Try Again', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF800000)),
                  foregroundColor: const Color(0xFF800000),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
