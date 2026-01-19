import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../providers/auth_provider.dart';
import 'vocabulary_screen.dart';
import 'quiz_screen.dart';
import 'progress_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _funFacts = [
    "Mandarin Chinese is the most spoken native language in the world.",
    "Chinese characters (Hanzi) are one of the oldest writing systems still in use.",
    "Mandarin has 4 main tones. The same syllable can mean completely different things depending on the tone!",
    "There is no alphabet in Chinese. Each character represents a syllable and a meaning.",
    "More than 1 billion people speak Mandarin worldwide.",
    "Pinyin is the official romanization system for Standard Chinese.",
    "Chinese grammar is relatively simple: no verb conjugations, no plurals, and no gender!"
  ];

  late String _dailyFact;

  @override
  void initState() {
    super.initState();
    _dailyFact = _funFacts[Random().nextInt(_funFacts.length)];
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AppAuthProvider>(context);
    final user = auth.userModel;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 28),
            tooltip: 'Sign Out',
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: CurvedHeaderClipper(),
                  child: Container(
                    height: size.height * 0.35,
                    width: double.infinity,
                    color: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: theme.colorScheme.primary,
                                backgroundImage: (user != null && (user.photoUrl?.isNotEmpty ?? false))
                                     ? NetworkImage(user.photoUrl!)
                                     : null,
                                child: (user?.photoUrl?.isNotEmpty ?? false)
                                    ? null
                                    : const Icon(Icons.person,
                                        size: 30, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    user?.displayName ?? 'Learner',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/images/HanLearnLogo.png',
                                height: 70,
                                width: 70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Level ${user?.level ?? 1} • ${user?.totalScore ?? 0} XP',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: size.height * 0.28, left: 16, right: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  color: Colors.amber.shade700, size: 32),
                              const SizedBox(width: 12),
                              Text(
                                'Did You Know?',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _dailyFact,
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.none,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(
                      context,
                      'Vocabulary',
                      Icons.menu_book,
                      Colors.blue.shade100,
                      Colors.blue.shade800,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VocabularyScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      'Translation',
                      Icons.translate,
                      Colors.purple.shade100,
                      Colors.purple.shade800,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const VocabularyScreen(initialTab: 1))),
                    ),
                    _buildMenuCard(
                      context,
                      'Quiz',
                      Icons.quiz,
                      Colors.orange.shade100,
                      Colors.orange.shade800,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const QuizScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      'Progress',
                      Icons.bar_chart,
                      Colors.green.shade100,
                      Colors.green.shade800,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProgressScreen())),
                    ),
                    //add another _buildMenuCard for word bank here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: iconColor),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
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
