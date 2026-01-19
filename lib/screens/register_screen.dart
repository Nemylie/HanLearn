import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Display name is required';
    if (v.length < 2) return 'Display name is too short';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,}$');
    if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = (value ?? '');
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final v = (value ?? '');
    if (v.isEmpty) return 'Confirm password is required';
    if (v != passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _onRegisterPressed() async {
    setState(() {
      _submitted = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final auth = Provider.of<AppAuthProvider>(context, listen: false);

    setState(() => _isLoading = true);
    try {
      await auth.register(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
      );

      // AuthWrapper will show Home automatically.
      // Also remove register screen from stack:
      //if (mounted) Navigator.pop(context);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Register failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGooglePressed() async {
    final auth = Provider.of<AppAuthProvider>(context, listen: false);

    setState(() => _isLoading = true);
    try {
      await auth.signInWithGoogle();
      //if (mounted) Navigator.pop(context);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Google sign-in failed: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: CurvedHeaderClipper(),
                  child: Container(
                    height: size.height * 0.45,
                    color: theme.colorScheme.primary,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Prettier icon with border
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/signup.png',
                              height: 170,
                              width: 170,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 0),
                          const Text(
                            'Join HanLearn Now!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: size.height * 0.37, left: 24, right: 24),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _submitted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign Up',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Display Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: _validateName,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: _validateEmail,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() =>
                                        _obscurePassword = !_obscurePassword);
                                  },
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: _validatePassword,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() => _obscureConfirmPassword =
                                        !_obscureConfirmPassword);
                                  },
                                  icon: Icon(_obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ),
                              obscureText: _obscureConfirmPassword,
                              validator: _validateConfirmPassword,
                              textInputAction: TextInputAction.done,
                            ),

                            const SizedBox(height: 20),

                            ElevatedButton(
                              onPressed: _isLoading ? null : _onRegisterPressed,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('REGISTER'),
                            ),

                            const SizedBox(height: 12),

                            // Optional Google sign-up
                            OutlinedButton(
                              onPressed: _isLoading ? null : _onGooglePressed,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/googleicon.png',
                                    height: 20,
                                    width: 20,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.g_mobiledata,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Sign up with Google'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
