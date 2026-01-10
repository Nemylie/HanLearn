class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String type; // 'meaning', 'pinyin', 'character'

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.type = 'meaning',
  });
}
