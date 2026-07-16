import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final user = context.read<LoginController>().currentUser!;
    _nameController = TextEditingController(text: user.name);
    _surnameController = TextEditingController(text: user.surname);
    _selectedDate = user.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<LoginController>();
    final success = await controller.updateProfile(
      name: _nameController.text,
      surname: _surnameController.text,
      birthDate: _selectedDate,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'), backgroundColor: AppTheme.primarySage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginController>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final moodController = context.read<MoodController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Information', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(labelText: 'Surname'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: AppTheme.primarySage.withAlpha(15),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, color: AppTheme.primarySage),
                      title: Text(DateFormat.yMd().format(_selectedDate)),
                      trailing: TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('CHANGE'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleUpdate,
                    child: const Text('UPDATE PROFILE'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text('Data Management', style: theme.textTheme.titleLarge?.copyWith(color: Colors.redAccent)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Clear All History'),
              subtitle: const Text('Delete all your mood recordings permanently'),
              trailing: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onTap: () => _confirmDeleteAll(moodController, user.id),
            ),
            const Divider(),
            ListTile(
              title: const Text('Clear History Older Than...'),
              subtitle: const Text('Keep only recent data'),
              trailing: const Icon(Icons.history, color: Colors.orangeAccent),
              onTap: () => _selectRetentionDate(moodController, user.id),
            ),
            const SizedBox(height: 48),
            Text('Account Actions', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Logout'),
              subtitle: const Text('Sign out of your account'),
              trailing: const Icon(Icons.logout_rounded, color: AppTheme.primarySage),
              onTap: () => _confirmLogout(),
            ),
            const Divider(),
            ListTile(
              title: const Text('Delete Account'),
              subtitle: const Text('Remove your account and all data forever'),
              trailing: const Icon(Icons.person_remove_rounded, color: Colors.red),
              onTap: () => _confirmDeleteAccount(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout?"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("LOGOUT")),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final loginController = context.read<LoginController>();
      await loginController.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _confirmDeleteAccount() async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Account?", style: TextStyle(color: theme.colorScheme.error)),
        content: const Text(
            "This action is permanent. Your profile and all your recorded moods will be deleted forever."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: const Text("DELETE MY ACCOUNT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final loginController = context.read<LoginController>();
      final success = await loginController.deleteAccount();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been deleted. We are sorry to see you go.'),
            backgroundColor: Colors.black87,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _confirmDeleteAll(MoodController controller, int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear all data?"),
        content: const Text("This will remove every single mood you've ever recorded. No undo!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("DELETE ALL", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await controller.clearHistory(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All mood history has been permanently deleted.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _selectRetentionDate(MoodController controller, int userId) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "Select the date: all records BEFORE this will be deleted.",
    );
    if (date != null && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Clear old data?"),
          content: Text("All records before ${DateFormat.yMd().format(date)} will be permanently removed."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("CLEANUP", style: TextStyle(color: Colors.orange))),
          ],
        ),
      );
      if (confirm == true) {
        await controller.clearHistoryBefore(userId, date);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('History before ${DateFormat.yMd().format(date)} has been cleared.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }
}
