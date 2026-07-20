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
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.primarySage,
          behavior: SnackBarBehavior.floating,
        ),
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
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmLogout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: PROFILE (CONSTRUCTIVE) ---
            _buildSectionHeader(context, 'Profile Settings', Icons.person_outline_rounded),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.badge_outlined)),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(labelText: 'Surname', prefixIcon: Icon(Icons.badge_outlined)),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cake_outlined, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Birth Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(DateFormat.yMMMMd().format(_selectedDate), style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_calendar_outlined, color: AppTheme.primarySage),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleUpdate,
                    child: const Text('SAVE CHANGES'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // --- SECTION 2: DATA MANAGEMENT (NEUTRAL/MAINTENANCE) ---
            _buildSectionHeader(context, 'Data Management', Icons.analytics_outlined),
            const SizedBox(height: 12),
            _SettingsTile(
              title: 'Cleanup History',
              subtitle: 'Keep only recent recordings',
              icon: Icons.history_rounded,
              color: Colors.orangeAccent,
              onTap: () => _selectRetentionDate(moodController, user.id),
            ),

            const SizedBox(height: 48),

            // --- SECTION 3: DANGER ZONE (CRITICAL) ---
            _buildSectionHeader(context, 'Danger Zone', Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
              ),
              color: Colors.redAccent.withOpacity(0.05),
              child: Column(
                children: [
                  _SettingsTile(
                    title: 'Wipe All Mood Data',
                    subtitle: 'Permanently delete all logs',
                    icon: Icons.delete_forever_rounded,
                    color: Colors.redAccent,
                    onTap: () => _confirmDeleteAll(moodController, user.id),
                  ),
                  const Divider(indent: 60, endIndent: 20),
                  _SettingsTile(
                    title: 'Delete Account',
                    subtitle: 'Close account and erase everything',
                    icon: Icons.person_remove_rounded,
                    color: Colors.red,
                    onTap: () => _confirmDeleteAccount(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {Color? color}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 22, color: color ?? theme.colorScheme.onSurface.withOpacity(0.7)),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sign Out?"),
        content: const Text("You will need to login again to access your mood journal."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("LOGOUT", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Permanently Delete Account?"),
        content: const Text(
          "This is a destructive action. Your profile and all history will be lost forever. Are you absolutely sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("GO BACK")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("DELETE ACCOUNT"),
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
            content: Text('Account deleted. All data has been erased.'),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
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
        title: const Text("Wipe All History?"),
        content: const Text("This will delete every mood entry you've recorded. This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("DELETE ALL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await controller.clearHistory(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All history has been cleared.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _selectRetentionDate(MoodController controller, int userId) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "Clear records before...",
    );
    if (date != null && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Cleanup Data?"),
          content: Text("Delete all recordings from before ${DateFormat.yMd().format(date)}?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("CLEANUP", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await controller.clearHistoryBefore(userId, date);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('History before ${DateFormat.yMd().format(date)} cleared.'),
              backgroundColor: Colors.orangeAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}
