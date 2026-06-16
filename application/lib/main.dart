import 'package:application/DataBase/database.dart';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/register_controller.dart';
import 'package:application/Pages/Access/login.dart';
import 'package:application/Pages/homePage.dart';
import 'package:application/Repositories/drift_emotion_repository.dart';
import 'package:application/Repositories/drift_user_repository.dart';
import 'package:application/Repositories/emotion_repository.dart';
import 'package:application/Repositories/user_repository.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Necessary for asynchronous initializations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDataBase();
  final userRepository = DriftUserRepository(db);
  final emotionRepository = DriftEmotionRepository(db);
  final loginController = LoginController(userRepository: userRepository);

  // Check if user is already logged in
  final bool loggedIn = await loginController.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDataBase>.value(value: db),
        Provider<UserRepository>.value(value: userRepository),
        Provider<EmotionRepository>.value(value: emotionRepository),
        ChangeNotifierProvider<LoginController>.value(value: loginController),
        ChangeNotifierProvider(
          create: (_) => RegisterController(userRepository: userRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        // If logged in, go to HomePage, else go to Login
        home: loggedIn ? const HomePage() : const Login(),
        // Define routes for easier navigation during logout
        routes: {
          '/login': (context) => const Login(),
          '/home': (context) => const HomePage(),
        },
      ),
    ),
  );
}
