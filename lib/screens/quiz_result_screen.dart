import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quiz_model.dart';
import 'home_screen.dart'; // For navigation back to home

class QuizResultScreen extends StatefulWidget {
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
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playSound();
  }

  Future<void> _playSound() async {
    try {
      // Ensure the file 'assets/sounds/quiz_complete.wav' exists
      await _audioPlayer.play(AssetSource('sounds/quiz_complete.wav'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final percentage =
        widget.score / (widget.totalQuestions * 10); // Assuming 10 points per question

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
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Quiz Results', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Curved Header Background
          ClipPath(
            clipper: _ResultHeaderClipper(),
            child: Container(
              height: size.height * 0.35,
              width: double.infinity,
              color: theme.colorScheme.primary,
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Result Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? theme.cardTheme.color
                          : Colors.white,
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
                          height: 170,
                          width: 170,
                          fit: BoxFit.contain,
                        ),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: Text(
                            titleText,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            '${widget.score} / ${widget.totalQuestions * 10}',
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
                      const SizedBox(width: 8),
                      Text(
                        'Quiz Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Questions List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.questions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final question = widget.questions[index];
                      final userAnswerIndex = widget.userAnswers[index];
                      final isCorrect = userAnswerIndex == question.correctIndex;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? theme.cardTheme.color
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCorrect
                                ? Colors.green.withValues(alpha: 0.5)
                                : Colors.red.withValues(alpha: 0.5),
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
                                    color: isCorrect
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        question.question,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: theme.brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Your answer: ${question.options[userAnswerIndex]}',
                                        style: TextStyle(
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (!isCorrect)
                                        Text(
                                          'Correct answer: ${question.options[question.correctIndex]}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onRetake,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retake Quiz'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
