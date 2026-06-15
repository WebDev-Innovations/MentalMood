import 'package:application/DataBase/database.dart';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/register_controller.dart';
import 'package:application/Pages/Access/login.dart';
import 'package:application/Repositories/drift_user_repository.dart';
import 'package:application/Repositories/user_repository.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDataBase();
  final userRepository = DriftUserRepository(db);

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDataBase>.value(value: db),
        Provider<UserRepository>.value(value: userRepository),
        ChangeNotifierProvider(
          create: (_) => LoginController(userRepository: userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterController(userRepository: userRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Automatically switch based on device settings
        home: const Login(),
      ),
    ),
  );
}
