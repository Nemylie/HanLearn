class WordModel {
  final String id;
  final String character;
  final String pinyin;
  final String meaning;
  final String category;
  final bool isDefault;

  WordModel({
    required this.id,
    required this.character,
    required this.pinyin,
    required this.meaning,
    required this.category,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character': character,
      'pinyin': pinyin,
      'meaning': meaning,
      'category': category,
      'isDefault': isDefault,
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: (map['id'] ?? '') as String,
      character: (map['character'] ?? '') as String,
      pinyin: (map['pinyin'] ?? '') as String,
      meaning: (map['meaning'] ?? '') as String,
      category: (map['category'] ?? 'Uncategorized') as String,
      isDefault: (map['isDefault'] ?? false) as bool,
    );
  }
}