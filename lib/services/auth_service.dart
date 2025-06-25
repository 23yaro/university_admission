import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _currentUserKey = 'current_user';
  
  UserModel? _currentUser;
  late SharedPreferences _prefs;

  // Initialize shared preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCurrentUser();
  }

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Auth state changes stream
  Stream<UserModel?> get authStateChanges => Stream.value(_currentUser);

  // Load current user from shared preferences
  void _loadCurrentUser() {
    try {
      final currentUserJson = _prefs.getString(_currentUserKey);
      if (currentUserJson != null) {
        _currentUser = UserModel.fromMap(json.decode(currentUserJson));
      }
    } catch (e) {
      print('Error loading current user: $e');
      _currentUser = null;
    }
  }

  // Save current user to shared preferences
  Future<void> _saveCurrentUser() async {
    if (_currentUser != null) {
      await _prefs.setString(_currentUserKey, json.encode(_currentUser!.toMap()));
    } else {
      await _prefs.remove(_currentUserKey);
    }
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка входа: ${response.body}');
    }

    final responseData = json.decode(response.body);
    final userData = responseData['user'];

    final user = UserModel(
      id: userData['user_id'],
      loginId: userData['login_id'],
      email: userData['username'],
      password: password,
      fullName: '',
      passportNumber: '',
      passportSeries: '',
      passportCopyUrl: '',
      applicationCopyUrl: '',
      certificateCopyUrl: '',
      medicalCertificateUrl: '',
      additionalDocumentsUrls: [],
      faculty: '',
      program: '',
      studyForm: '',
      applicationStatus: 'pending', passportIssueDate: '', birthDate: '',
    );

    _currentUser = user;
    await _saveCurrentUser();
    return user;
  }

  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword(
    String email,
    String password,
    UserModel userData,
  ) async {
    // Validate password
    if (password.length < 6) {
      throw Exception('Пароль должен содержать минимум 6 символов');
    }

    // Send registration request to backend
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Ошибка регистрации: ${response.body}');
    }

    final responseData = json.decode(response.body);
    final registeredUser = UserModel(
      id: responseData['user_id'],
      loginId: responseData['login_id'],
      email: responseData['username'],
      password: password,
      fullName: userData.fullName,
      passportNumber: userData.passportNumber,
      passportSeries: userData.passportSeries,
      passportCopyUrl: '',
      applicationCopyUrl: '',
      certificateCopyUrl: '',
      medicalCertificateUrl: '',
      additionalDocumentsUrls: [],
      faculty: '',
      program: '',
      studyForm: '',
      applicationStatus: 'pending', passportIssueDate: '', birthDate: '',
    );

    _currentUser = registeredUser;
    await _saveCurrentUser();
    return registeredUser;
  }

  // Sign out
  Future<void> signOut() async {
    _currentUser = null;
    await _saveCurrentUser();
  }

  // Update user profile
  Future<void> updateProfile({
    required String fullName,
    required String passportSeries,
    required String passportNumber,
    required String passportIssueDate,
    required String birthDate,
  }) async {
    try {
      final user = _currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      // Обновляем данные пользователя
      final updatedUser = UserModel(
        id: user.id,
        loginId: user.loginId,
        email: user.email,
        password: user.password,
        fullName: fullName,
        passportSeries: passportSeries,
        passportNumber: passportNumber,
        passportIssueDate: passportIssueDate,
        birthDate: birthDate,
        passportCopyUrl: user.passportCopyUrl,
        certificateCopyUrl: user.certificateCopyUrl,
        medicalCertificateUrl: user.medicalCertificateUrl,
        applicationCopyUrl: user.applicationCopyUrl,
        additionalDocumentsUrls: user.additionalDocumentsUrls,
        faculty: user.faculty,
        program: user.program,
        studyForm: user.studyForm,
        applicationStatus: user.applicationStatus,
      );

      // Обновляем локальные данные
      _currentUser = updatedUser;
      await _saveCurrentUser();

      // TODO: Отправка данных на сервер
      // await _api.updateProfile(user.id, {
      //   'fullName': fullName,
      //   'passportSeries': passportSeries,
      //   'passportNumber': passportNumber,
      //   'passportIssueDate': passportIssueDate,
      //   'birthDate': birthDate,
      // });
    } catch (e) {
      throw Exception('Ошибка при обновлении профиля: $e');
    }
  }
}