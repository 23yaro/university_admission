class ApplicationModel {
  final String passportCopyUrl;
  final String certificateCopyUrl;
  final String medicalCertificateUrl;
  final String applicationCopyUrl;
  final List<String> additionalDocumentsUrls;
  final String faculty;
  final String program;
  final String studyForm;
  final String applicationStatus;

  ApplicationModel({
    required this.passportCopyUrl,
    required this.certificateCopyUrl,
    required this.medicalCertificateUrl,
    required this.applicationCopyUrl,
    required this.additionalDocumentsUrls,
    required this.faculty,
    required this.program,
    required this.studyForm,
    required this.applicationStatus,
  });
}