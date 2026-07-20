import 'package:application/Logic/login_controller.dart';
import 'package:application/Pages/Access/register.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<LoginController>();
    final success = await controller.login(_usernameController.text, _passwordController.text);
    if (success && mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<LoginController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.spa_rounded, size: 64, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 32),
                    Text("MentalMood", style: theme.textTheme.displayLarge),
                    const SizedBox(height: 8),
                    Text(
                      "A calm space for your thoughts.", 
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 16)
                    ),
                    const SizedBox(height: 60),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username", 
                        prefixIcon: Icon(Icons.person_outline_rounded)
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? "Please enter your username" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password", 
                        prefixIcon: Icon(Icons.lock_outline_rounded)
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? "Please enter your password" : null,
                    ),
                    if (controller.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage!, 
                        style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)
                      ),
                    ],
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: controller.isLoading ? null : _handleLogin,
                      child: controller.isLoading 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text("SIGN IN"),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Register())),
                      child: Text(
                        "New here? Create an account", 
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
                      ),
                    ),
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
