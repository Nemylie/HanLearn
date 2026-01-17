import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UpdateDisplayNameScreen extends StatefulWidget {
  const UpdateDisplayNameScreen({super.key});

  @override
  State<UpdateDisplayNameScreen> createState() =>
      _UpdateDisplayNameScreenState();
}

class _UpdateDisplayNameScreenState extends State<UpdateDisplayNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AppAuthProvider>(context, listen: false);
    _name.text = auth.userModel?.displayName ?? auth.user?.displayName ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AppAuthProvider>(context, listen: false);

    setState(() => _loading = true);
    try {
      await auth.updateDisplayName(_name.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name updated.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Display Name')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Current Name: ${auth.userModel?.displayName ?? auth.user?.displayName ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'New Display Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final val = (v ?? '').trim();
                      if (val.isEmpty) return 'Enter a name';
                      if (val.length < 2) return 'Name too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
