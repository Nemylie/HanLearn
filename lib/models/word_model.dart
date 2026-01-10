class WordModel {
  final String id;
  final String character;
  final String pinyin;
  final String meaning;
  final String category;

  WordModel({
    required this.id,
    required this.character,
    required this.pinyin,
    required this.meaning,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character': character,
      'pinyin': pinyin,
      'meaning': meaning,
      'category': category,
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] ?? '',
      character: map['character'] ?? '',
      pinyin: map['pinyin'] ?? '',
      meaning: map['meaning'] ?? '',
      category: map['category'] ?? '',
    );
  }
}
