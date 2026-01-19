import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../providers/vocabulary_provider.dart';
import '../models/word_model.dart';

class VocabularyScreen extends StatefulWidget {
  final int initialTab;
  const VocabularyScreen({super.key, this.initialTab = 0});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FlutterTts _flutterTts = FlutterTts();

  final TextEditingController _translationController = TextEditingController();
  Map<String, String>? _translationResult;
  bool _isTranslating = false;

  // Filter state
  String _selectedCategory = 'All';

  // Translation Language State
  String _sourceLanguageCode = 'auto';
  String _sourceLanguageName = 'Detect Language';

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

    _initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VocabularyProvider>(context, listen: false).fetchWords();
    });
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("zh-CN");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // iOS specific configuration
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );

      await _flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      debugPrint("TTS Init Error: $e");
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      try {
        await _flutterTts.stop(); // Stop any previous speech
        await _flutterTts.speak(text);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing audio: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _translationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const headerHeight = 240.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Curved Header Background
          ClipPath(
            clipper: _VocabularyHeaderClipper(),
            child: Container(
              height: headerHeight,
              width: double.infinity,
              color: theme.colorScheme.primary,
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Header Content (Title + TabBar)
                SizedBox(
                  height: headerHeight - MediaQuery.of(context).padding.top - 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Vocabulary',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Balance back button
                        ],
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: Colors.white,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'Word Bank'),
                            Tab(text: 'Translator'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Content View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVocabularyList(theme),
                      _buildTranslationTab(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyList(ThemeData theme) {
    return Consumer<VocabularyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Group by category
        final Map<String, List<WordModel>> grouped = {};
        for (final word in provider.words) {
          grouped.putIfAbsent(word.category, () => []);
          grouped[word.category]!.add(word);
        }

        final List<String> categories = grouped.keys.toList()..sort();

        if (_selectedCategory != 'All' &&
            !grouped.containsKey(_selectedCategory)) {
          _selectedCategory = 'All';
        }

        final List<String> visibleCategories = _selectedCategory == 'All'
            ? categories
            : <String>[_selectedCategory];
        
        // Show message if empty
        if (visibleCategories.isEmpty) {
          return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
                 const SizedBox(height: 16),
                 Text(
                   'No vocabulary found',
                   style: TextStyle(color: Colors.grey[600], fontSize: 16),
                 ),
               ],
             ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: visibleCategories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildCategoryFilter(theme, categories);
            }

            final String category = visibleCategories[index - 1];
            final List<WordModel> words = grouped[category] ?? const [];
            return _buildCategorySection(theme, category, words);
          },
        );
      },
    );
  }

  Widget _buildCategoryFilter(ThemeData theme, List<String> categories) {
    final List<String> dropdownItems = <String>['All', ...categories];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Filter by category',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: dropdownItems
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedCategory = value);
                    },
                  ),
                ),
                if (_selectedCategory != 'All')
                  IconButton(
                    tooltip: 'Clear filter',
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => setState(() => _selectedCategory = 'All'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategorySection(
    ThemeData theme,
    String category,
    List<WordModel> words,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final isFiltered = _selectedCategory == category;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isFiltered,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          collapsedBackgroundColor: isDark ? Colors.grey[900] : Colors.white,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category),
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : theme.colorScheme.primary,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: words.map((word) => _buildWordCard(theme, word, category)).toList(),
        ),
      ),
    );
  }

  Widget _buildWordCard(ThemeData theme, WordModel word, String category) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        onTap: () => _speak(word.character),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  word.character.substring(0, 1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          word.character,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            word.pinyin,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.meaning,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.volume_up_rounded,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => _speak(word.character),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Daily Conversation':
        return Icons.chat_bubble_outline;
      case 'Animals':
        return Icons.pets;
      case 'Food':
        return Icons.restaurant;
      case 'Numbers':
        return Icons.looks_one;
      case 'Family':
        return Icons.family_restroom;
      case 'Colors':
        return Icons.palette;
      case 'Travel':
        return Icons.flight_takeoff;
      default:
        return Icons.category_outlined;
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            String searchQuery = '';
            const allLanguages = VocabularyProvider.supportedLanguages;

            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: StatefulBuilder(
                builder: (context, setSheetState) {
                  final filteredLanguages = allLanguages.entries.where((entry) {
                    final name = entry.value.toLowerCase();
                    final query = searchQuery.toLowerCase();
                    return name.contains(query);
                  }).toList();

                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select Language',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search language...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white10
                                : Colors.grey[100],
                          ),
                          onChanged: (value) {
                            setSheetState(() => searchQuery = value);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filteredLanguages.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final entry = filteredLanguages[index];
                            final isSelected = entry.key == _sourceLanguageCode;
                            return ListTile(
                              title: Text(
                                entry.value,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check,
                                      color: Theme.of(context).colorScheme.primary)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _sourceLanguageCode = entry.key;
                                  _sourceLanguageName = entry.value;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTranslationTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: _showLanguageSelector,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _sourceLanguageName,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                      const Spacer(),
                      Text(
                        'Mandarin',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _translationController,
                    decoration: InputDecoration(
                      hintText: 'Type text here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark ? Colors.black12 : Colors.grey[50],
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isTranslating
                          ? null
                          : () async {
                              final input = _translationController.text.trim();
                              if (input.isEmpty) return;

                              setState(() => _isTranslating = true);
                              try {
                                final provider = Provider.of<VocabularyProvider>(
                                  context,
                                  listen: false,
                                );
                                final result = await provider.translateText(
                                  input,
                                  from: _sourceLanguageCode,
                                );
                                setState(() => _translationResult = result);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isTranslating = false);
                              }
                            },
                      icon: _isTranslating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.translate),
                      label: const Text('TRANSLATE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_translationResult != null) _buildTranslationResultCard(theme),
        ],
      ),
    );
  }

  Widget _buildTranslationResultCard(ThemeData theme) {
    final character = _translationResult!['character'] ?? '';
    final pinyin = _translationResult!['pinyin'] ?? '';
    final exampleOriginal = _translationResult!['example_original'] ?? '';
    final exampleTranslated = _translationResult!['example_translated'] ?? '';

    return Card(
      color: theme.colorScheme.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Translation Result',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              character,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              pinyin,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (exampleOriginal.isNotEmpty && exampleTranslated.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Example Sentence',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exampleTranslated,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exampleOriginal,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                       icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                       onPressed: () => _speak(exampleTranslated),
                       tooltip: 'Play Example',
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.volume_up_rounded,
                  label: 'Listen',
                  onTap: () => _speak(character),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.copy,
                  label: 'Copy',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: character));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.bookmark_add_outlined,
                  label: 'Save',
                  onTap: () => _showAddToBankSheet(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onTap,
            tooltip: label,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Future<void> _showAddToBankSheet() async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);

    final character = _translationResult?['character'] ?? '';
    final pinyin = _translationResult?['pinyin'] ?? '';
    final meaning = _translationController.text.trim();

    final existingCategories = provider.categories;
    String selectedCategory = existingCategories.isNotEmpty
        ? existingCategories.first
        : 'Daily Conversation';

    bool useCustom = false;
    final customCategoryController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add to Vocabulary Bank',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chinese: $character', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        if (pinyin.trim().isNotEmpty) Text('Pinyin: $pinyin'),
                        const SizedBox(height: 4),
                        Text('Meaning: $meaning'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    key: ValueKey(useCustom ? 'custom' : selectedCategory),
                    initialValue: useCustom ? null : selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      ...existingCategories.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                      const DropdownMenuItem(
                        value: '__custom__',
                        child: Text('Create new category...'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == '__custom__') {
                        setSheetState(() => useCustom = true);
                      } else if (val != null) {
                        setSheetState(() {
                          useCustom = false;
                          selectedCategory = val;
                        });
                      }
                    },
                  ),
                  if (useCustom) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: customCategoryController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'New Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('SAVE WORD'),
                    onPressed: () async {
                      final category = useCustom
                          ? customCategoryController.text.trim()
                          : selectedCategory.trim();

                      if (category.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a category')),
                        );
                        return;
                      }

                      try {
                        await provider.addWordToBank(
                          character: character,
                          pinyin: pinyin,
                          meaning: meaning,
                          category: category,
                        );
                        if (!ctx.mounted) return;

                        Navigator.pop(ctx);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved to Vocabulary Bank')),
                        );

                        // Jump to Vocabulary Bank tab
                        _tabController.animateTo(0);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _VocabularyHeaderClipper extends CustomClipper<Path> {
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
