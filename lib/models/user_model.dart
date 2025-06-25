import '../../desktop/lib/models/application_model.dart';

class UserModel {
  final String id;
  final String loginId;
  final String email;
  final String password;
  final String fullName;
  final String passportSeries;
  final String passportNumber;
  final String passportIssueDate;
  final String birthDate;
  final ApplicationModel application;


  UserModel({
    required this.id,
    required this.loginId,
    required this.email,
    required this.password,
    required this.fullName,
    required this.passportSeries,
    required this.passportNumber,
    required this.passportIssueDate,
    required this.birthDate,
    required this.application,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loginId': loginId,
      'email': email,
      'password': password,
      'fullName': fullName,
      'passportSeries': passportSeries,
      'passportNumber': passportNumber,
      'passportIssueDate': passportIssueDate,
      'birthDate': birthDate,
      'passportCopyUrl': application.passportCopyUrl,
      'certificateCopyUrl': application.certificateCopyUrl,
      'medicalCertificateUrl': application.medicalCertificateUrl,
      'applicationCopyUrl': application.applicationCopyUrl,
      'additionalDocumentsUrls': application.additionalDocumentsUrls,
      'faculty': application.faculty,
      'program': application.program,
      'studyForm': application.studyForm,
      'applicationStatus': application.applicationStatus,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      loginId: map['loginId'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      passportSeries: map['passportSeries'] as String? ?? '',
      passportNumber: map['passportNumber'] as String? ?? '',
      passportIssueDate: map['passportIssueDate'] as String? ?? '',
      birthDate: map['birthDate'] as String? ?? '',
      passportCopyUrl: map['passportCopyUrl'] as String? ?? '',
      certificateCopyUrl: map['certificateCopyUrl'] as String? ?? '',
      medicalCertificateUrl: map['medicalCertificateUrl'] as String? ?? '',
      applicationCopyUrl: map['applicationCopyUrl'] as String? ?? '',
      additionalDocumentsUrls: List<String>.from(map['additionalDocumentsUrls'] as List? ?? []),
      faculty: map['faculty'] as String? ?? '',
      program: map['program'] as String? ?? '',
      studyForm: map['studyForm'] as String? ?? '',
      applicationStatus: map['applicationStatus'] as String? ?? 'pending',
    );
  }

  UserModel copyWith({
    String? id,
    String? loginId,
    String? email,
    String? password,
    String? fullName,
    String? passportSeries,
    String? passportNumber,
    String? passportIssueDate,
    String? birthDate,
    String? passportCopyUrl,
    String? certificateCopyUrl,
    String? medicalCertificateUrl,
    String? applicationCopyUrl,
    List<String>? additionalDocumentsUrls,
    String? faculty,
    String? program,
    String? studyForm,
    String? applicationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      loginId: loginId ?? this.loginId,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      passportSeries: passportSeries ?? this.passportSeries,
      passportNumber: passportNumber ?? this.passportNumber,
      passportIssueDate: passportIssueDate ?? this.passportIssueDate,
      birthDate: birthDate ?? this.birthDate,
      passportCopyUrl: passportCopyUrl ?? this.passportCopyUrl,
      certificateCopyUrl: certificateCopyUrl ?? this.certificateCopyUrl,
      medicalCertificateUrl: medicalCertificateUrl ?? this.medicalCertificateUrl,
      applicationCopyUrl: applicationCopyUrl ?? this.applicationCopyUrl,
      additionalDocumentsUrls: additionalDocumentsUrls ?? this.additionalDocumentsUrls,
      faculty: faculty ?? this.faculty,
      program: program ?? this.program,
      studyForm: studyForm ?? this.studyForm,
      applicationStatus: applicationStatus ?? this.applicationStatus,
    );
  }
} 