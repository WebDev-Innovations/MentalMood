import 'package:application/DataBase/database.dart';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Repositories/user_repository.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late LoginController loginController;
  late MockUserRepository mockUserRepository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockUserRepository = MockUserRepository();
    loginController = LoginController(userRepository: mockUserRepository);
  });

  group('LoginController Tests', () {
    test('Initial state is correct', () {
      expect(loginController.isLoading, false);
      expect(loginController.errorMessage, null);
    });

    test('Login success with correct credentials', () async {
      const username = 'testuser';
      const password = 'password123';
      // Use exactly what the app uses or a compatible salt
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 10));

      final mockUser = UserData(
        id: 1,
        username: username,
        name: 'Test',
        surname: 'User',
        password: hashedPassword,
        birthDate: DateTime.now(),
      );

      when(() => mockUserRepository.getUserByUsername(username))
          .thenAnswer((_) async => mockUser);

      final result = await loginController.login(username, password);

      if (!result) {
        print("Login failed. Error: ${loginController.errorMessage}");
      }

      expect(result, true);
      expect(loginController.isLoading, false);
      expect(loginController.errorMessage, null);
    });

    test('Login fails with wrong password', () async {
      const username = 'testuser';
      const password = 'password123';
      final hashedPassword = BCrypt.hashpw('different_password', BCrypt.gensalt());

      final mockUser = UserData(
        id: 1,
        username: username,
        name: 'Test',
        surname: 'User',
        password: hashedPassword,
        birthDate: DateTime.now(),
      );

      when(() => mockUserRepository.getUserByUsername(username))
          .thenAnswer((_) async => mockUser);

      final result = await loginController.login(username, password);

      expect(result, false);
      expect(loginController.errorMessage, 'Invalid username or password.');
    });

    test('Login fails when user not found', () async {
      const username = 'nonexistent';
      
      when(() => mockUserRepository.getUserByUsername(username))
          .thenAnswer((_) async => null);

      final result = await loginController.login(username, 'any_password');

      expect(result, false);
      expect(loginController.errorMessage, 'Invalid username or password.');
    });
  });
}
