import 'package:application/Logic/login_controller.dart';
import 'package:application/Pages/Access/register.dart';
import 'package:application/Pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Provider.of<LoginController>(context, listen: false);
    final success = await controller.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                ],
                validator: (value) => (value == null || value.isEmpty) ? 'Enter username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty) ? 'Enter password' : null,
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 24),
              controller.isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 16),
                        const Text('or'),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const Register()),
                            );
                          },
                          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                          child: const Text('Register an Account'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
