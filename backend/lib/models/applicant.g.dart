// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applicant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Applicant _$ApplicantFromJson(Map<String, dynamic> json) => Applicant(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      passportNumber: json['passportNumber'] as String,
      passportSeries: json['passportSeries'] as String,
      faculty: json['faculty'] as String,
      specialization: json['specialization'] as String,
      documentUrls: (json['documentUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      additionalDocuments:
          Map<String, String>.from(json['additionalDocuments'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ApplicantToJson(Applicant instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'passportNumber': instance.passportNumber,
      'passportSeries': instance.passportSeries,
      'faculty': instance.faculty,
      'specialization': instance.specialization,
      'documentUrls': instance.documentUrls,
      'additionalDocuments': instance.additionalDocuments,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
