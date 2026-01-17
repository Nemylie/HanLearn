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

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
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
            Tab(text: 'Vocabulary List', icon: Icon(Icons.menu_book)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // If user is on Vocabulary tab -> manual add
          if (_tabController.index == 0) {
            await _showManualAddDialog();
          } else {
            // If on Translation tab -> focus input
            FocusScope.of(context).requestFocus(FocusNode());
          }
        },
        child: Icon(_tabController.index == 0 ? Icons.add : Icons.edit),
      ),
    );
  }

  // =========================
  // TAB 1: VOCAB LIST (Firestore)
  // =========================
  Widget _buildVocabularyList(ThemeData theme) {
    final provider = context.read<VocabularyProvider>();

    return StreamBuilder<List<WordModel>>(
      stream: provider.vocabularyStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final words = snapshot.data!;
        if (words.isEmpty) {
          return const Center(
            child: Text('No vocabulary yet. Tap + to add.'),
          );
        }

        // Group by category
        final Map<String, List<WordModel>> grouped = {};
        for (final word in words) {
          grouped.putIfAbsent(word.category, () => []);
          grouped[word.category]!.add(word);
        }

        final categories = grouped.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final catWords = grouped[category] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.30),
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...catWords.map(
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
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  word.meaning,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: theme.colorScheme.error),
                            onPressed: () async {
                              try {
                                await context
                                    .read<VocabularyProvider>()
                                    .deleteWord(word.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Deleted'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
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
          },
        );
      },
    );
  }

  // =========================
  // TAB 2: TRANSLATION (API + Save to Firestore)
  // =========================
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
                      color: theme.colorScheme.primary,
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
                    if (_translationController.text.trim().isEmpty) return;

                    setState(() => _isTranslating = true);
                    try {
                      final provider = Provider.of<VocabularyProvider>(context,
                          listen: false);

                      // UPDATED: matches the updated provider code
                      final result = await provider.translateToChineseAndPinyin(
                        _translationController.text,
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
            ),
          ),
          const SizedBox(height: 24),
          if (_translationResult != null)
            Card(
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
                      _translationResult!['character'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translationResult!['pinyin'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.copy, color: Colors.white),
                          label: const Text(
                            'COPY',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                          ),
                          onPressed: () async {
                            final textToCopy =
                                '${_translationResult!['character']}\n${_translationResult!['pinyin']}';
                            await Clipboard.setData(
                              ClipboardData(text: textToCopy),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('SAVE TO VOCAB'),
                          onPressed: () async {
                            await _showSaveFromTranslationDialog();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // DIALOGS
  // =========================

  Future<void> _showManualAddDialog() async {
    final characterCtrl = TextEditingController();
    final meaningCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Daily Conversation');
    final pinyinCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Vocabulary (Manual)'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: characterCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Character (汉字)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: meaningCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Meaning (English/Malay)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinyinCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Pinyin (optional)',
                    hintText: 'Leave empty to auto-generate',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<VocabularyProvider>().addWordManual(
                        character: characterCtrl.text,
                        meaning: meaningCtrl.text,
                        category: categoryCtrl.text,
                        pinyin: pinyinCtrl.text,
                      );
                  if (mounted) Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    characterCtrl.dispose();
    meaningCtrl.dispose();
    categoryCtrl.dispose();
    pinyinCtrl.dispose();
  }

  Future<void> _showSaveFromTranslationDialog() async {
    final meaningCtrl =
        TextEditingController(text: _translationController.text.trim());
    final categoryCtrl = TextEditingController(text: 'Daily Conversation');

    final character = _translationResult?['character'] ?? '';
    final pinyin = _translationResult?['pinyin'] ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save to Vocabulary'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Character: $character'),
                const SizedBox(height: 6),
                Text('Pinyin: $pinyin'),
                const SizedBox(height: 16),
                TextField(
                  controller: meaningCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Meaning',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<VocabularyProvider>().addWordManual(
                        character: character,
                        pinyin: pinyin,
                        meaning: meaningCtrl.text,
                        category: categoryCtrl.text,
                      );
                  if (mounted) Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved to vocabulary'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    meaningCtrl.dispose();
    categoryCtrl.dispose();
  }
}


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

// class _VocabularyScreenState extends State<VocabularyScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _translationController = TextEditingController();
//   Map<String, String>? _translationResult;
//   bool _isTranslating = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<VocabularyProvider>(context, listen: false).fetchWords();
//     });
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
//         Map<String, List<WordModel>> grouped = {};
//         for (var word in provider.words) {
//           if (!grouped.containsKey(word.category)) {
//             grouped[word.category] = [];
//           }
//           grouped[word.category]!.add(word);
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: grouped.keys.length,
//           itemBuilder: (context, index) {
//             String category = grouped.keys.elementAt(index);
//             List<WordModel> words = grouped[category]!;
            
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
//                   ),
//                   child: Text(
//                     category,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.primary,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 ...words.map((word) => Card(
//                   elevation: 2,
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 60,
//                           height: 60,
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color: theme.colorScheme.primary,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             word.character,
//                             style: const TextStyle(
//                               fontSize: 28,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 word.pinyin,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                   fontStyle: FontStyle.italic,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 word.meaning,
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.volume_up_rounded, color: theme.colorScheme.primary),
//                           onPressed: () {
//                             // Audio placeholder
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Audio playing...'), duration: Duration(seconds: 1)),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 )),
//                 const SizedBox(height: 16),
//               ],
//             );
//           },
//         );
//       },
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
//                       color: theme.colorScheme.primary,
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
//             onPressed: _isTranslating ? null : () async {
//               if (_translationController.text.isEmpty) return;
//               setState(() => _isTranslating = true);
//               try {
//                 final provider = Provider.of<VocabularyProvider>(context, listen: false);
//                 final result = await provider.translateText(_translationController.text);
//                 setState(() => _translationResult = result);
//               } catch (e) {
//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//                 }
//               } finally {
//                 if (mounted) setState(() => _isTranslating = false);
//               }
//             },
//             icon: _isTranslating 
//               ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
//               : const Icon(Icons.translate),
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
