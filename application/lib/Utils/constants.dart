import 'package:bcrypt/bcrypt.dart';

class AppConstants {
  // Password "user" criptata con BCrypt (salt round 12 è il default della libreria o comunque sicuro)
  // Il formato è $2b$12$...
  static final String hashedAdminPassword = BCrypt.hashpw('user', BCrypt.gensalt(logRounds: 12));
  static const String adminUsername = 'user';
}
