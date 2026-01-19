

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/vocabulary_provider.dart';
// import '../models/word_model.dart';

// class VocabularyScreen extends StatefulWidget {
//   final int initialTab;
//   const VocabularyScreen({super.key, this.initialTab = 0});

//   @override
//   State<VocabularyScreen> createState() => _VocabularyScreenState();
// }

// class _VocabularyScreenState extends State<VocabularyScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   final TextEditingController _translationController = TextEditingController();
//   Map<String, String>? _translationResult;
//   bool _isTranslating = false;

//   // ✅ Filter state
//   String _selectedCategory = 'All';

//   @override
//   void initState() {
//     super.initState();
//     _tabController =
//         TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<VocabularyProvider>(context, listen: false).fetchWords();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _translationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Vocabulary & Translation'),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: const [
//             Tab(text: 'Vocabulary Bank', icon: Icon(Icons.menu_book)),
//             Tab(text: 'Translation', icon: Icon(Icons.translate)),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildVocabularyList(theme),
//           _buildTranslationTab(theme),
//         ],
//       ),
//     );
//   }

//   Widget _buildVocabularyList(ThemeData theme) {
//     return Consumer<VocabularyProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // Group by category
//         final Map<String, List<WordModel>> grouped = {};
//         for (final word in provider.words) {
//           grouped.putIfAbsent(word.category, () => []);
//           grouped[word.category]!.add(word);
//         }

//         // Categories (sorted for nice UX)
//         final List<String> categories = grouped.keys.toList()..sort();

//         // Keep selected category valid (e.g., after data refresh)
//         if (_selectedCategory != 'All' &&
//             !grouped.containsKey(_selectedCategory)) {
//           _selectedCategory = 'All';
//         }

//         // Apply filter
//         final List<String> visibleCategories = _selectedCategory == 'All'
//             ? categories
//             : <String>[_selectedCategory];

//         // ListView with header (filter) at index 0
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: visibleCategories.length + 1,
//           itemBuilder: (context, index) {
//             // ✅ Filter UI header
//             if (index == 0) {
//               return _buildCategoryFilter(theme, categories);
//             }

//             final String category = visibleCategories[index - 1];
//             final List<WordModel> words = grouped[category] ?? const [];

//             return _buildCategorySection(theme, category, words);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildCategoryFilter(ThemeData theme, List<String> categories) {
//     final List<String> dropdownItems = <String>['All', ...categories];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Card(
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.filter_list,
//                   color: theme.brightness == Brightness.dark
//                       ? Colors.white70
//                       : theme.colorScheme.primary,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     initialValue: _selectedCategory,
//                     decoration: const InputDecoration(
//                       labelText: 'Filter by category',
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     items: dropdownItems
//                         .map(
//                           (c) => DropdownMenuItem<String>(
//                             value: c,
//                             child: Text(c),
//                           ),
//                         )
//                         .toList(),
//                     onChanged: (value) {
//                       if (value == null) return;
//                       setState(() => _selectedCategory = value);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 if (_selectedCategory != 'All')
//                   IconButton(
//                     tooltip: 'Clear filter',
//                     icon: const Icon(Icons.clear),
//                     onPressed: () => setState(() => _selectedCategory = 'All'),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildCategorySection(
//     ThemeData theme,
//     String category,
//     List<WordModel> words,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           decoration: BoxDecoration(
//             color: theme.brightness == Brightness.dark
//                 ? Colors.white10
//                 : theme.colorScheme.primary.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: theme.brightness == Brightness.dark
//                   ? Colors.white24
//                   : theme.colorScheme.primary.withValues(alpha: 0.3),
//             ),
//           ),
//           child: Text(
//             category,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: theme.brightness == Brightness.dark
//                   ? Colors.white
//                   : theme.colorScheme.primary,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...words.map(
//           (word) => Card(
//             elevation: 2,
//             margin: const EdgeInsets.only(bottom: 12),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 60,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       word.character,
//                       style: const TextStyle(
//                         fontSize: 28,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           word.pinyin,
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: Colors.grey[600],
//                             color: theme.brightness == Brightness.dark
//                                 ? Colors.white70
//                                 : Colors.grey[600],

//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           word.meaning,
//                           // style: const TextStyle(
//                           //   fontSize: 18,
//                           //   fontWeight: FontWeight.w500,
//                           // ),
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                             color: theme.brightness == Brightness.dark
//                                 ? Colors.white
//                                 : null,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.volume_up_rounded,
//                       color: theme.brightness == Brightness.dark
//                           ? Colors.white70
//                           : theme.colorScheme.primary,
//                     ),
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Audio playing...'),
//                           duration: Duration(seconds: 1),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildTranslationTab(ThemeData theme) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Card(
//             elevation: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'English to Mandarin',
//                     style: TextStyle(
//                       color: theme.brightness == Brightness.dark
//                           ? Colors.white
//                           : theme.colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _translationController,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter English text...',
//                       border: OutlineInputBorder(),
//                     ),
//                     maxLines: 3,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _isTranslating
//                 ? null
//                 : () async {
//                     if (_translationController.text.isEmpty) return;
//                     setState(() => _isTranslating = true);
//                     try {
//                       final provider = Provider.of<VocabularyProvider>(
//                         context,
//                         listen: false,
//                       );
//                       final result = await provider
//                           .translateText(_translationController.text);
//                       setState(() => _translationResult = result);
//                     } catch (e) {
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error: $e')),
//                         );
//                       }
//                     } finally {
//                       if (mounted) setState(() => _isTranslating = false);
//                     }
//                   },
//             icon: _isTranslating
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : const Icon(Icons.translate),
//             label: const Text('TRANSLATE'),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//           ),
//           const SizedBox(height: 24),
//           if (_translationResult != null)
//             Card(
//               color: theme.colorScheme.primary,
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Translation Result',
//                       style: TextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       _translationResult!['character'] ?? '',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _translationResult!['pinyin'] ?? '',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontStyle: FontStyle.italic,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     IconButton(
//                       icon: const Icon(Icons.copy, color: Colors.white),
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Copied to clipboard')),
//                         );
//                       },
//                     )
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final TextEditingController _translationController = TextEditingController();
  Map<String, String>? _translationResult;
  bool _isTranslating = false;

  // ✅ Filter state
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VocabularyProvider>(context, listen: false).fetchWords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary & Translation'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Vocabulary Bank', icon: Icon(Icons.menu_book)),
            Tab(text: 'Translation', icon: Icon(Icons.translate)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVocabularyList(theme),
          _buildTranslationTab(theme),
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                      border: OutlineInputBorder(),
                      isDense: true,
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
                const SizedBox(width: 12),
                if (_selectedCategory != 'All')
                  IconButton(
                    tooltip: 'Clear filter',
                    icon: const Icon(Icons.clear),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.white10
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.white24
                  : theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...words.map(
          (word) => Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      word.character,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.pinyin,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.meaning,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.volume_up_rounded,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Audio playing...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTranslationTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'English to Mandarin',
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _translationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter English text...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
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
                      final result = await provider.translateText(input);
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

    return Card(
      color: theme.colorScheme.primary,
      elevation: 4,
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
            const SizedBox(height: 16),

            // ✅ Copy + Add to Bank buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: character));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined,
                      color: Colors.white),
                  onPressed: () => _showAddToBankSheet(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showAddToBankSheet() async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);

    final character = _translationResult?['character'] ?? '';
    final pinyin = _translationResult?['pinyin'] ?? '';
    final meaning = _translationController.text
        .trim(); // store original English text as meaning

    final existingCategories = provider.categories;
    String selectedCategory = existingCategories.isNotEmpty
        ? existingCategories.first
        : 'Daily Conversation';

    bool useCustom = false;
    final customCategoryController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add to Vocabulary Bank',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Chinese: $character'),
                  const SizedBox(height: 4),
                  if (pinyin.trim().isNotEmpty) Text('Pinyin: $pinyin'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: useCustom ? null : selectedCategory,
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
                        child: Text('Custom category...'),
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
                      decoration: const InputDecoration(
                        labelText: 'Custom Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('ADD TO BANK'),
                    onPressed: () async {
                      final category = useCustom
                          ? customCategoryController.text.trim()
                          : selectedCategory.trim();

                      if (category.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a category')),
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

                        if (!mounted) return;
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Saved to Vocabulary Bank')),
                        );

                        // optional: jump to Vocabulary Bank tab
                        _tabController.animateTo(0);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    },
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