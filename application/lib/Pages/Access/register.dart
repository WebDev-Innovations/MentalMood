import 'package:application/Logic/register_controller.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 18));

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Provider.of<RegisterController>(context, listen: false);
    final success = await controller.register(
      username: _usernameController.text,
      name: _nameController.text,
      surname: _surnameController.text,
      password: _passwordController.text,
      birthDate: _selectedDate,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Welcome to MentalMood.'),
          backgroundColor: AppTheme.primarySage,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RegisterController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join MentalMood',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your mood and improve your mental well-being.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: 'Username *',
                      prefixIcon: Icon(Icons.alternate_email_outlined),
                      counterText: "",
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                    ],
                    validator: (value) => (value == null || value.length < 3) ? 'Min 3 chars' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            counterText: "",
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          ],
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _surnameController,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            labelText: 'Surname *',
                            counterText: "",
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          ],
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    maxLength: 128,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock_outline),
                      counterText: "",
                    ),
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 6) ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Date of Birth',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: AppTheme.primarySage.withAlpha((0.05 * 255).round()),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.primarySage),
                      title: Text(
                        "${_selectedDate.toLocal()}".split(' ')[0],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      trailing: TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('CHANGE', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  if (controller.errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: controller.isLoading ? null : _handleRegister,
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
