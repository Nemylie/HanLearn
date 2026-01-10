import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/auth_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel;
    final theme = Theme.of(context);

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
        title: const Text('My Progress', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Header with Profile
            ClipPath(
              clipper: _ProgressHeaderClipper(),
              child: Container(
                padding: const EdgeInsets.only(top: 100, bottom: 40, left: 20, right: 20),
                color: theme.primaryColor,
                width: double.infinity,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 32, color: theme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level Progress Card
                  Card(
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
                              Text('Level ${user.level}', 
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_getRankName(user.level), 
                                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          LinearPercentIndicator(
                            lineHeight: 25.0,
                            percent: (user.totalScore % 100) / 100,
                            center: Text(
                              "${user.totalScore % 100} / 100 XP",
                              style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            barRadius: const Radius.circular(15),
                            progressColor: theme.primaryColor,
                            backgroundColor: Colors.grey.shade200,
                            animation: true,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${100 - (user.totalScore % 100)} XP to next level',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Stats Grid
                  GridView.count(
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
                        '${user.totalScore}', 
                        Icons.emoji_events, 
                        Colors.amber
                      ),
                      _buildStatItem(
                        context, 
                        'Words Learned', 
                        '${user.wordsLearned}', 
                        Icons.school, 
                        Colors.blue
                      ),
                      _buildStatItem(
                        context, 
                        'Current Level', 
                        '${user.level}', 
                        Icons.star, 
                        Colors.purple
                      ),
                      _buildStatItem(
                        context, 
                        'Next Goal', 
                        '${(user.level + 1) * 100} XP', 
                        Icons.flag, 
                        Colors.red
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRankName(int level) {
    if (level < 5) return 'Novice';
    if (level < 10) return 'Apprentice';
    if (level < 20) return 'Scholar';
    if (level < 50) return 'Master';
    return 'Legend';
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
