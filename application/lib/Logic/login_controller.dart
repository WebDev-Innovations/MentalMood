import 'package:application/Repositories/user_repository.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final UserRepository userRepository;

  LoginController({required this.userRepository});

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    // Start loading state and clear previous errors
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI to show loading indicator if present

    try {
      // Security: trim username to avoid accidental spaces leading to login failure
      final user = await userRepository.getUserByUsername(username.trim());

      // Security: Use BCrypt to safely compare the provided password with the stored hash
      // This prevents timing attacks and ensures plain-text passwords are never compared
      if (user != null && BCrypt.checkpw(password, user.password)) {
        _isLoading = false;
        notifyListeners();
        return true; // Login successful
      } else {
        // Generic error message for security (don't reveal if user exists or password is wrong)
        _errorMessage = 'Invalid username or password.';
      }
    } catch (e) {
      // Log error internally if needed, but show a safe message to the user
      _errorMessage = 'An error occurred. Please try again later.';
    }

    // Reset loading and notify UI of the error
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
