import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmText = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmText.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user session found.');
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _password.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      await user.delete();

      // After delete, ensure auth state is clean
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );

      // Pop back to previous screens
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to delete account')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Delete Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: isDark ? 2 : 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'This action is permanent.\nYour account will be deleted and cannot be recovered.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Type DELETE to confirm, then enter your password.',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmText,
                    decoration: const InputDecoration(
                      labelText: 'Type DELETE',
                      prefixIcon: Icon(Icons.warning_amber_rounded),
                    ),
                    validator: (v) {
                      if ((v ?? '').trim().toUpperCase() != 'DELETE') {
                        return 'Please type DELETE';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _loading ? null : _delete,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('DELETE ACCOUNT',
                            style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
