import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/auth_provider.dart';
import '../models/word_model.dart';

class VocabularyScreen extends StatefulWidget {
  final int initialIndex;
  const VocabularyScreen({super.key, this.initialIndex = 0});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final _translationController = TextEditingController();
  WordModel? _translatedWord;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      Provider.of<VocabularyProvider>(context, listen: false)
          .fetchMyVocabulary(auth.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialIndex,
      child: Scaffold(
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
              const Text('Vocabulary & Translation'),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.library_books), text: 'Bank'),
              Tab(icon: Icon(Icons.bookmark), text: 'My Vocab'),
              Tab(icon: Icon(Icons.translate), text: 'Translate'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _buildWordBankTab(),
            _buildMyVocabularyTab(),
            _buildTranslationTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildWordBankTab() {
    final vocabProvider = Provider.of<VocabularyProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Get words filtered by user's level
    final userLevel = authProvider.userModel?.level ?? 1;
    final filteredWordBank = vocabProvider.getWordsByLevel(userLevel);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredWordBank.keys.length,
      itemBuilder: (context, index) {
        String category = filteredWordBank.keys.elementAt(index);
        List<WordModel> words = filteredWordBank[category]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(Icons.category, color: Theme.of(context).primaryColor),
              title: Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              children: words.map((word) {
                return ListTile(
                  title: Text(
                    word.character,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${word.pinyin} - ${word.meaning}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getLevelColor(word.level).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Level ${word.level}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getLevelColor(word.level),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (authProvider.user != null) {
                        vocabProvider.addToMyVocabulary(authProvider.user!.uid, word);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${word.character} to My Vocabulary')),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Color _getLevelColor(int level) {
    if (level <= 2) return Colors.green;
    if (level <= 5) return Colors.orange;
    if (level <= 8) return Colors.red;
    return Colors.purple;
  }

  Widget _buildMyVocabularyTab() {
    final vocabProvider = Provider.of<VocabularyProvider>(context);
    
    if (vocabProvider.myVocabulary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No words saved yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vocabProvider.myVocabulary.length,
      itemBuilder: (context, index) {
        WordModel word = vocabProvider.myVocabulary[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              word.character,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  word.pinyin,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  word.meaning,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranslationTab() {
    final vocabProvider = Provider.of<VocabularyProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _translationController,
            decoration: const InputDecoration(
              labelText: 'Enter text to translate',
              hintText: 'e.g., Hello',
              prefixIcon: Icon(Icons.translate),
              suffixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : () async {
              if (_translationController.text.isNotEmpty) {
                setState(() => _isLoading = true);
                try {
                  final result = await vocabProvider.translate(_translationController.text);
                  setState(() {
                    _translatedWord = result;
                    _isLoading = false;
                  });
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Translation failed: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)) 
              : const Text('Translate to Chinese', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 32),
          if (_translatedWord != null) ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text(
                      _translatedWord!.character,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _translatedWord!.pinyin,
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _translatedWord!.meaning,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                         if (authProvider.user != null) {
                          vocabProvider.addToMyVocabulary(authProvider.user!.uid, _translatedWord!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved to My Vocabulary')),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save to My Vocabulary'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
