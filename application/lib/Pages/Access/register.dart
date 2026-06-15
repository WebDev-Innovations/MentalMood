import 'package:application/Logic/register_controller.dart';
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
        const SnackBar(content: Text('Account created!'), backgroundColor: Colors.green),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username *'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                ],
                validator: (value) => (value == null || value.length < 3) ? 'Min 3 chars' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Surname *'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password *'),
                obscureText: true,
                validator: (value) => (value == null || value.length < 6) ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 20),
              const Text('Date of Birth *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text('Selected Date'),
                  subtitle: Text(
                    "${_selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  trailing: TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('CHANGE'),
                  ),
                ),
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(controller.errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 32),
              controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
