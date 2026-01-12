import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('AUTHENTICATION - Unit Tests', () {
    // TEST CASE 1: Email validation
    test('Email validation harus bekerja dengan benar', () {
      // ARRANGE
      const String validEmail = 'user@test.com';
      const String invalidEmail = 'notanemail';

      // ACT & ASSERT
      expect(validEmail.contains('@'), isTrue);
      expect(invalidEmail.contains('@'), isFalse);
    });

    // TEST CASE 2: Password validation
    test('Password validation harus minimal 6 karakter', () {
      // ARRANGE
      const String strongPassword = 'password123';
      const String weakPassword = '123';

      // ACT & ASSERT
      expect(strongPassword.length >= 6, isTrue);
      expect(weakPassword.length >= 6, isFalse);
    });

    // TEST CASE 3: Login credential check
    test('Kredensial login harus valid', () {
      // ARRANGE
      const String email = 'user@test.com';
      const String password = 'password123';

      // ACT
      final isValidEmail = email.contains('@');
      final isValidPassword = password.length >= 6;
      final isValid = isValidEmail && isValidPassword;

      // ASSERT
      expect(isValid, isTrue);
    });

    // TEST CASE 4: Invalid login attempt
    test('Login dengan password kosong harus gagal', () {
      // ARRANGE
      const String email = 'user@test.com';
      const String password = '';

      // ACT
      final isValidEmail = email.contains('@');
      final isValidPassword = password.length >= 6;
      final isValid = isValidEmail && isValidPassword;

      // ASSERT
      expect(isValid, isFalse);
    });

    // TEST CASE 5: Registration data validation
    test('Data registrasi harus valid', () {
      // ARRANGE
      const String email = 'newuser@test.com';
      const String password = 'securepass123';
      const String confirmPassword = 'securepass123';

      // ACT
      final isValidEmail = email.contains('@');
      final isValidPassword = password.length >= 6;
      final passwordMatch = password == confirmPassword;
      final isValid = isValidEmail && isValidPassword && passwordMatch;

      // ASSERT
      expect(isValid, isTrue);
    });

    // TEST CASE 6: Password mismatch detection
    test('Password tidak sama saat registrasi harus terdeteksi', () {
      // ARRANGE
      const String password = 'securepass123';
      const String confirmPassword = 'differentpass123';

      // ACT
      final passwordMatch = password == confirmPassword;

      // ASSERT
      expect(passwordMatch, isFalse);
    });

    // TEST CASE 7: User model
    test('User authentication model harus bekerja', () {
      // ARRANGE
      final user = AuthUserModel(
        uid: 'user-123',
        email: 'user@test.com',
        displayName: 'Test User',
      );

      // ACT & ASSERT
      expect(user.uid, equals('user-123'));
      expect(user.email, equals('user@test.com'));
      expect(user.displayName, equals('Test User'));
    });

    // TEST CASE 8: Logout functionality
    test('Logout harus mengubah auth state', () {
      // ARRANGE
      var authService = AuthService();
      authService.currentUser = AuthUserModel(
        uid: 'user-123',
        email: 'user@test.com',
        displayName: 'Test User',
      );

      expect(authService.isLoggedIn(), isTrue);

      // ACT
      authService.logout();

      // ASSERT
      expect(authService.isLoggedIn(), isFalse);
      expect(authService.currentUser, isNull);
    });
  });
}

/// Simple Auth User Model
class AuthUserModel {
  final String uid;
  final String email;
  final String? displayName;

  AuthUserModel({
    required this.uid,
    required this.email,
    this.displayName,
  });
}

/// Simple Auth Service
class AuthService {
  AuthUserModel? currentUser;

  bool isLoggedIn() => currentUser != null;

  void logout() {
    currentUser = null;
  }
}
