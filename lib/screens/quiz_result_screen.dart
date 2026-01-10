import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import 'home_screen.dart'; // For navigation back to home

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<QuizQuestion> questions;
  final List<int> userAnswers;
  final VoidCallback onRetake;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.userAnswers,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = score / (totalQuestions * 10); // Assuming 10 points per question

    String titleText;
    String imagePath;
    String message;

    if (percentage >= 1.0) {
      titleText = 'Amazing!';
      imagePath = 'assets/images/HappyHan.png';
      message = 'Perfect score! You are a master!';
    } else if (percentage == 0.0) {
      titleText = 'Study more!';
      imagePath = 'assets/images/SadHan.png';
      message = 'Don\'t give up! Keep practicing.';
    } else {
      titleText = 'Keep it up!';
      imagePath = 'assets/images/DecentHan.png';
      message = 'Good job! You\'re making progress.';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Quiz Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Result Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(
                    imagePath,
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '$score / ${totalQuestions * 10}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Summary Section
            Row(
              children: [
                Icon(Icons.summarize, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Quiz Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Questions List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final question = questions[index];
                final userAnswerIndex = userAnswers[index];
                final isCorrect = userAnswerIndex == question.correctIndex;
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCorrect ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCorrect ? Icons.check : Icons.close,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Your Answer
                      _buildAnswerRow(
                        context, 
                        'Your Answer:', 
                        question.options[userAnswerIndex], 
                        isCorrect ? Colors.green : Colors.red
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 4),
                        // Correct Answer (only if wrong)
                        _buildAnswerRow(
                          context, 
                          'Correct Answer:', 
                          question.options[question.correctIndex], 
                          Colors.green
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const QuizScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(BuildContext context, String label, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
