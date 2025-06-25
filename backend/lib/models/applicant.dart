import 'package:json_annotation/json_annotation.dart';

part 'applicant.g.dart';

@JsonSerializable()
class Applicant {
  final String id;
  final String userId;
  final String fullName;
  final String passportNumber;
  final String passportSeries;
  final String faculty;
  final String specialization;
  final List<String> documentUrls;
  final Map<String, String> additionalDocuments; // Map of document type to URL
  final DateTime createdAt;
  final DateTime updatedAt;

  Applicant({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.passportNumber,
    required this.passportSeries,
    required this.faculty,
    required this.specialization,
    required this.documentUrls,
    required this.additionalDocuments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) => _$ApplicantFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicantToJson(this);
} 