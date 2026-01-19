class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String type; // 'meaning', 'pinyin', 'character'
//This model represents a Single Question within a quiz session. Unlike the others, 
//this is typically generated dynamically rather than stored in a database.
  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.type = 'meaning',
  });
}
