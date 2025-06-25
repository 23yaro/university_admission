import 'package:flutter/foundation.dart';
import 'package:university_admission/services/uni_service.dart';

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
  final UniService uniService;
  final List<Application> _applications = [];

  ApplicationModel(this.uniService);

  List<Application> get applications => _applications;

  Future<Application> loadApplications(Application application) async{
   final result = uniService.loadApplications();
   return result;
  }

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
