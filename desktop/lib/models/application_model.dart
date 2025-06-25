import 'package:flutter/foundation.dart';

class Passport {
  final String id;
  final String firstName;
  final String lastName;
  final String surName;
  final String passSeries;
  final String passNum;
  final DateTime passProduced;
  final DateTime dob;

  Passport({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.surName,
    required this.passSeries,
    required this.passNum,
    required this.passProduced,
    required this.dob,
  });
}

class AdditionalFile {
  final String name;
  final String path;
  AdditionalFile({required this.name, required this.path});
}

class Application {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String passportPath;
  final String applicationFormPath;
  final String medicalCertificatePath;
  final Passport passport;
  final List<AdditionalFile> additionalFiles;
  bool isReviewed;

  Application({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.passportPath,
    required this.applicationFormPath,
    required this.medicalCertificatePath,
    required this.passport,
    this.additionalFiles = const [],
    this.isReviewed = false,
  });
}

class ApplicationModel extends ChangeNotifier {
  final List<Application> _applications = [
    Application(
      id: '1',
      fullName: 'Иванов Иван Иванович',
      email: 'ivanov@example.com',
      phone: '+7 900 123-45-67',
      passportPath: 'C:/mock_files/passport_ivanov.pdf',
      applicationFormPath: 'C:/mock_files/application_ivanov.pdf',
      medicalCertificatePath: 'C:/mock_files/med_ivanov.pdf',
      passport: Passport(
        id: 'uuid-1',
        firstName: 'Иван',
        lastName: 'Иванов',
        surName: 'Иванович',
        passSeries: '1234',
        passNum: '567890',
        passProduced: DateTime(2015, 5, 20),
        dob: DateTime(1998, 3, 15),
      ),
      additionalFiles: [
        AdditionalFile(name: 'Справка', path: 'C:/mock_files/extra_ivanov_1.pdf'),
        AdditionalFile(name: 'ГТО', path: 'C:/mock_files/extra_ivanov_2.pdf'),
        AdditionalFile(name: 'Портфолио', path: 'C:/mock_files/portfolio_ivanov.pdf'),
        AdditionalFile(name: 'Индивидуальные достижения', path: 'C:/mock_files/olympiad_certificate_ivanov.pdf'),
      ],
      isReviewed: false,
    ),
    Application(
      id: '2',
      fullName: 'Петрова Мария Сергеевна',
      email: 'petrova@example.com',
      phone: '+7 900 765-43-21',
      passportPath: 'C:/mock_files/passport_petrova.pdf',
      applicationFormPath: 'C:/mock_files/application_petrova.pdf',
      medicalCertificatePath: 'C:/mock_files/med_petrova.pdf',
      passport: Passport(
        id: 'uuid-2',
        firstName: 'Мария',
        lastName: 'Петрова',
        surName: 'Сергеевна',
        passSeries: '4321',
        passNum: '098765',
        passProduced: DateTime(2016, 7, 10),
        dob: DateTime(1999, 12, 1),
      ),
      additionalFiles: [],
      isReviewed: true,
    ),
  ];

  List<Application> get applications => _applications;

  void addApplication(Application application) {
    _applications.add(application);
    notifyListeners();
  }

  void toggleReviewStatus(String id) {
    final index = _applications.indexWhere((app) => app.id == id);
    if (index != -1) {
      _applications[index].isReviewed = !_applications[index].isReviewed;
      notifyListeners();
    }
  }

  void removeApplication(String id) {
    _applications.removeWhere((app) => app.id == id);
    notifyListeners();
  }
} 