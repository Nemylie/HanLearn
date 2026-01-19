import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/auth_provider.dart';
//user dashboard to track learning journey,
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppAuthProvider>(context).userModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view progress')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // title: const Text('My Progress', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Curved Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380, // Extended height for the layout
            child: ClipPath(
              clipper: _ProgressHeaderClipper(),
              child: Container(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 100, bottom: 40),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Text
                  const Text(
                    'You are currently',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level ${user.level}!', //retrieve THAT user level
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Big Level Icon
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.transparent, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(_getLevelImagePath(user.level)), //show diff icon based on level
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Badge Name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          _getRankName(user.level),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress Bar Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      surfaceTintColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('XP Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('${user.totalScore % 100} / 100 XP', //??/100xp
                                    style: TextStyle(
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.white
                                            : theme.primaryColor,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearPercentIndicator(
                              lineHeight: 20.0,
                              percent: (user.totalScore % 100) / 100,
                              barRadius: const Radius.circular(10),
                              progressColor: theme.primaryColor,
                              backgroundColor: Colors.grey.shade200,
                              animation: true,
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${100 - (user.totalScore % 100)} XP to next level', //xp left to upgrade
                              style: TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Motivational Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      _getMotivationalMessage(user.level),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const SizedBox(height: 24),
                  
                  // Statistics Grid
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text('Statistics',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatItem(
                            context,
                            'Total Score',
                            '${user.totalScore}', //get user total score
                            Icons.emoji_events,
                            Colors.amber),
                        _buildStatItem(context, 'Words Learned',
                            '${user.wordsLearned}', Icons.school, Colors.blue), //get yser total words learned
                        _buildStatItem(context, 'Current Level', '${user.level}', //get user level
                            Icons.star, Colors.purple),
                        _buildStatItem(
                            context,
                            'Next Goal',
                            '${(user.level + 1) * 100} XP', //get next level xp goal
                            Icons.flag,
                            isDark ? theme.colorScheme.primary : Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelImagePath(int level) {
    if (level <= 1) return 'assets/images/Level1.png';
    if (level == 2) return 'assets/images/Level2.png';
    if (level == 3) return 'assets/images/Level3.png';
    return 'assets/images/Level4.png';
  }
//5 ranks
  String _getRankName(int level) {
    if (level <= 4) return 'Bronze Scholar';
    if (level <= 9) return 'Silver Master';
    if (level <= 19) return 'Gold Legend';
    if (level <= 29) return 'Diamond Expert';
    return 'Grandmaster';
  }

  String _getMotivationalMessage(int level) {
    if (level == 1) return "You are just beginning! Keep doing exercises to unlock your potential.";
    if (level == 2) return "Great job! You're building a habit. Keep learning new words every day.";
    if (level == 3) return "You're doing amazing! Your vocabulary is growing fast.";
    if (level == 4) return "Impressive progress! You're becoming a pro at this.";
    return "You are unstoppable! The sky is the limit for your learning journey.";
  }

  Widget _buildStatItem(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black),
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
