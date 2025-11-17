import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  final Function(bool) onThemeChange;
  const LoginScreen({required this.onThemeChange, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtl = TextEditingController();
  final TextEditingController _passCtl = TextEditingController();
  bool loading = false;

  Future<void> _login() async {
    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtl.text.trim(),
        password: _passCtl.text.trim(),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              HomeDashboard(onThemeToggle: (v) => widget.onThemeChange(v)),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 20.0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Welcome Back',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _emailCtl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _passCtl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: loading ? null : _login,
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign In'),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RegisterScreen(onThemeChange: widget.onThemeChange)),
                            );
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
