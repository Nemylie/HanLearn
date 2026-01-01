class WordModel {
  final String id;
  final String character;
  final String pinyin;
  final String meaning;
  final String category;
  final int level; // Difficulty level (1-10, where 1 is beginner, 10 is advanced)

  WordModel({
    required this.id,
    required this.character,
    required this.pinyin,
    required this.meaning,
    this.category = 'General',
    this.level = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character': character,
      'pinyin': pinyin,
      'meaning': meaning,
      'category': category,
      'level': level,
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] ?? '',
      character: map['character'] ?? '',
      pinyin: map['pinyin'] ?? '',
      meaning: map['meaning'] ?? '',
      category: map['category'] ?? 'General',
      level: map['level']?.toInt() ?? 1,
    );
  }
}
