import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/auth_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    if (auth.isAuthenticated && auth.userModel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Progress')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = auth.userModel;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Progress')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login to view progress'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
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
            const Text('Learning Progress'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF800000), width: 3),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Color(0xFF800000)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF800000)),
            ),
            Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),
            
            Card(
              elevation: 4,
              color: const Color(0xFF800000),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                child: Column(
                  children: [
                    const Text('Current Level', style: TextStyle(fontSize: 18, color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      '${user.level}',
                      style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressIndicator(
                  context,
                  percent: (user.totalScore % 100) / 100,
                  value: "${user.totalScore}",
                  label: "Total Score",
                  color: Colors.green,
                ),
                _buildProgressIndicator(
                  context,
                  percent: (user.wordsLearned % 50) / 50,
                  value: "${user.wordsLearned}",
                  label: "Words Learned",
                  color: Colors.blue,
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).primaryColor
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history, color: Colors.amber),
                ),
                title: const Text('Completed Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('General Knowledge'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '+50 pts',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context, {
    required double percent,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 12.0,
          animation: true,
          percent: percent > 1.0 ? 1.0 : percent,
          center: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: color,
          backgroundColor: color.withOpacity(0.1),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
