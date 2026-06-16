import 'package:application/Logic/login_controller.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MentalMood'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final loginController = Provider.of<LoginController>(context, listen: false);
              
              // Clear the session
              await loginController.logout();
              
              if (!mounted) return;
              
              // Return to the login screen and clear the navigation stack
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_satisfied_alt_outlined, size: 100, color: AppTheme.primarySage),
            const SizedBox(height: 24),
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('Welcome to your personal mood tracker.'),
          ],
        ),
      ),
    );
  }
}
