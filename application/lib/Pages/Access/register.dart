import 'package:application/Logic/register_controller.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 20));

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<RegisterController>();
    final success = await controller.register(
      username: _usernameController.text,
      name: _nameController.text,
      surname: _surnameController.text,
      password: _passwordController.text,
      birthDate: _selectedDate,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Journey started! Please log in."), behavior: SnackBarBehavior.floating)
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<RegisterController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("New Journey"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Start Your Journey", style: theme.textTheme.displayLarge?.copyWith(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  "Begin tracking your mindful growth today.", 
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 16)
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person_outline_rounded)),
                  validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _surnameController,
                        decoration: const InputDecoration(labelText: "Surname"),
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, 
                      initialDate: _selectedDate, 
                      firstDate: DateTime(1900), 
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: theme.copyWith(
                          colorScheme: theme.colorScheme.copyWith(primary: AppTheme.sagePrimary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cake_rounded, color: theme.colorScheme.onSurface.withOpacity(0.3), size: 20),
                        const SizedBox(width: 12),
                        Text(DateFormat.yMMMMd().format(_selectedDate), style: const TextStyle(fontSize: 16)),
                        const Spacer(),
                        Text("Birth Date", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline_rounded)),
                  validator: (v) => (v == null || v.length < 4) ? "At least 4 characters" : null,
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    controller.errorMessage!, 
                    style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)
                  ),
                ],
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: controller.isLoading ? null : _handleRegister,
                  child: controller.isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("CREATE MY ACCOUNT"),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
