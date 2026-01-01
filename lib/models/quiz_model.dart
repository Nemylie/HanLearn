enum QuizType { multipleChoice, trueFalse }

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final QuizType type;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.type = QuizType.multipleChoice,
  });
}
