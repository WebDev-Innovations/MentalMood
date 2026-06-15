import 'package:application/DataBase/database.dart';
import 'package:application/Logic/register_controller.dart';
import 'package:application/Repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late RegisterController registerController;
  late MockUserRepository mockUserRepository;

  setUpAll(() {
    registerFallbackValue(UserCompanion());
  });

  setUp(() {
    mockUserRepository = MockUserRepository();
    registerController = RegisterController(userRepository: mockUserRepository);
  });

  group('RegisterController Tests', () {
    test('Registration success when username is available', () async {
      const username = 'newuser';
      
      when(() => mockUserRepository.getUserByUsername(username))
          .thenAnswer((_) async => null);
      
      when(() => mockUserRepository.createUser(any()))
          .thenAnswer((_) async => 1);

      final result = await registerController.register(
        username: username,
        name: 'New',
        surname: 'User',
        password: 'securePassword123',
        birthDate: DateTime(2000, 1, 1),
      );

      expect(result, true);
      expect(registerController.errorMessage, null);
      verify(() => mockUserRepository.createUser(any())).called(1);
    });

    test('Registration fails when username already taken', () async {
      const username = 'existinguser';
      
      final existingUser = UserData(
        id: 1,
        username: username,
        name: 'Existing',
        surname: 'User',
        password: 'hashed',
        birthDate: DateTime.now(),
      );

      when(() => mockUserRepository.getUserByUsername(username))
          .thenAnswer((_) async => existingUser);

      final result = await registerController.register(
        username: username,
        name: 'Test',
        surname: 'User',
        password: 'password',
        birthDate: DateTime.now(),
      );

      expect(result, false);
      expect(registerController.errorMessage, "Username already taken.");
      verifyNever(() => mockUserRepository.createUser(any()));
    });
  });
}
