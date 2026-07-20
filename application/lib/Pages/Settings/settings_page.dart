import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
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

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<LoginController>();
    final success = await controller.updateProfile(
      name: _nameController.text, surname: _surnameController.text, birthDate: _selectedDate,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully'), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginController>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none, // Ensure hover scale doesn't get cut at the edges
        child: Column(
          children: [
            // User Persona Card
            FadeInSlide(
              duration: 400,
              direction: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${user.name} ${user.surname}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("Personal Journaling Member", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            _buildSectionHeader("Personal Information"),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  FadeInSlide(
                    duration: 500,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "First Name"),
                      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInSlide(
                    duration: 600,
                    child: TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(labelText: "Last Name"),
                      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInSlide(
                    duration: 700,
                    child: HoverEffect(
                      scale: 1.01,
                      child: InkWell(
                        onTap: () async {
                          final p = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(1900), lastDate: DateTime.now());
                          if (p != null) setState(() => _selectedDate = p);
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
                              const Text("Edit", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.sagePrimary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInSlide(
                    duration: 800,
                    child: ElevatedButton(onPressed: _handleUpdate, child: const Text("SAVE CHANGES")),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 56),
            
            _buildSectionHeader("Safe Zone"),
            const SizedBox(height: 16),
            FadeInSlide(
              duration: 900,
              child: HoverEffect(
                scale: 1.01,
                child: _SettingsTile(
                  title: "Generate Sample Data",
                  desc: "Seed your journal for testing",
                  icon: Icons.auto_awesome_rounded,
                  color: Colors.amber,
                  onTap: () async {
                    await context.read<MoodController>().seedMockData(user.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Mock data generated! (60 days)"), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInSlide(
              duration: 1000,
              child: HoverEffect(
                scale: 1.01,
                child: _SettingsTile(
                  title: "Cleanup Journal",
                  desc: "Remove older memories",
                  icon: Icons.history_rounded,
                  color: AppTheme.oliveSecondary,
                  onTap: () => _selectRetentionDate(user.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInSlide(
              duration: 1100,
              child: HoverEffect(
                scale: 1.01,
                child: _SettingsTile(
                  title: "Export Journal",
                  desc: "Download your data as CSV",
                  icon: Icons.ios_share_rounded,
                  color: AppTheme.indigoPrimary,
                  onTap: () {}, // Future impl
                ),
              ),
            ),
            
            const SizedBox(height: 56),

            _buildSectionHeader("Account"),
            const SizedBox(height: 16),
            FadeInSlide(
              duration: 1200,
              child: HoverEffect(
                scale: 1.01,
                child: _SettingsTile(
                  title: "Logout",
                  desc: "Sign out from this device",
                  icon: Icons.logout_rounded,
                  color: theme.colorScheme.primary,
                  onTap: _confirmLogout,
                ),
              ),
            ),

            const SizedBox(height: 48),
            
            _buildSectionHeader("Danger Zone", isDanger: true),
            const SizedBox(height: 16),
            FadeInSlide(
              duration: 1300,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.terracottaError.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppTheme.terracottaError.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      title: "Wipe All Memories",
                      desc: "Irreversible deletion of all logs",
                      icon: Icons.delete_sweep_rounded,
                      color: AppTheme.terracottaError,
                      onTap: () => _confirmDeleteAll(user.id),
                    ),
                    const Divider(indent: 64, endIndent: 20, height: 1),
                    _SettingsTile(
                      title: "Delete My Account",
                      desc: "Close your mindful journey forever",
                      icon: Icons.person_remove_rounded,
                      color: AppTheme.terracottaError,
                      onTap: () => _confirmDeleteAccount(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isDanger = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          fontSize: 11,
          color: isDanger ? AppTheme.terracottaError : Colors.grey.shade400,
        ),
      ),
    );
  }

  void _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Sign Out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<LoginController>().logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Delete account?"),
        content: const Text("This will erase everything you've ever tracked."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Keep it")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracottaError,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete Permanently"),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<LoginController>().deleteAccount();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _confirmDeleteAll(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Wipe journal?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes, Wipe All", style: TextStyle(color: AppTheme.terracottaError))),
        ],
      ),
    );
    if (confirm == true) await context.read<MoodController>().clearHistory(userId);
  }

  void _selectRetentionDate(int userId) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now().subtract(const Duration(days: 30)), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (date != null) await context.read<MoodController>().clearHistoryBefore(userId, date);
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SettingsTile({required this.title, required this.desc, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(desc, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4))),
      trailing: Icon(Icons.chevron_right_rounded, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.1)),
    );
  }
}
