import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  final ImagePicker _picker = ImagePicker();
  File? _newImageFile;

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

      if (_newImageFile != null) {
        final currentUser = auth.user;
        if (currentUser != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_avatars')
              .child('${currentUser.uid}.jpg');

          final uploadTask = storageRef.putFile(_newImageFile!);
          final snapshot = await uploadTask;

          if (snapshot.state == TaskState.success) {
            final url = await storageRef.getDownloadURL();
            await auth.updateProfilePhoto(url);
          } else {
            throw Exception('Upload failed with state: ${snapshot.state}');
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appearance updated.')),
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

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() {
        _newImageFile = File(picked.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AppAuthProvider>(context);

    final currentPhoto = auth.userModel?.photoUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Change Appearance')),
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
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _newImageFile != null
                              ? FileImage(_newImageFile!)
                              : (currentPhoto != null &&
                                      currentPhoto.isNotEmpty
                                  ? NetworkImage(currentPhoto)
                                  : null) as ImageProvider<Object>?,
                          child: (_newImageFile == null &&
                                  (currentPhoto == null ||
                                      currentPhoto.isEmpty))
                              ? const Icon(Icons.person,
                                  size: 40, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loading ? null : _pickImage,
                          child: const Text('Change profile picture'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
