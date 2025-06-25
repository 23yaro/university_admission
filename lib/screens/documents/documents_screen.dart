import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  final _fullNameController = TextEditingController();
  final _passportSeriesController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _passportIssueDateController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  File? _passportCopy;
  File? _certificateCopy;
  File? _medicalCertificate;
  List<File> _additionalDocuments = [];
  
  bool _isLoading = false;
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _passportIssueDateController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        if (mounted) {
          setState(() {
            _userData = user;
            _fullNameController.text = user.fullName;
            _passportSeriesController.text = user.passportSeries;
            _passportNumberController.text = user.passportNumber;
            _passportIssueDateController.text = user.passportIssueDate;
            _birthDateController.text = user.birthDate;
          });
          await _loadExistingDocuments(user.id);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при загрузке данных: $e')),
        );
      }
    }
  }

  Future<void> _loadExistingDocuments(String userId) async {
    try {
      final documents = await _storageService.getUserDocuments(userId);
      for (var doc in documents) {
        final filename = doc.path.split('/').last;
        if (filename.startsWith('passport_')) {
          setState(() => _passportCopy = doc);
        } else if (filename.startsWith('certificate_')) {
          setState(() => _certificateCopy = doc);
        } else if (filename.startsWith('medical_')) {
          setState(() => _medicalCertificate = doc);
        } else if (filename.startsWith('additional_')) {
          setState(() => _additionalDocuments.add(doc));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при загрузке документов: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(String documentType) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final file = File(image.path);
        setState(() {
          switch (documentType) {
            case 'passport':
              _passportCopy = file;
              break;
            case 'certificate':
              _certificateCopy = file;
              break;
            case 'medical':
              _medicalCertificate = file;
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выборе изображения: $e')),
        );
      }
    }
  }

  Future<void> _pickAdditionalDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _additionalDocuments.addAll(
            result.files.map((file) => File(file.path!)).toList(),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выборе файлов: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = '${picked.day}.${picked.month}.${picked.year}';
    }
  }

  Future<void> _saveDocuments() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = context.read<AuthService>().currentUser;
        if (user == null) throw Exception('Пользователь не авторизован');

        String? passportUrl;
        String? certificateUrl;
        String? medicalUrl;
        List<String> additionalUrls = [];

        // Upload passport copy
        if (_passportCopy != null) {
          passportUrl = await _storageService.uploadFile(
            _passportCopy!,
            user.id,
            'passport',
          );
        }

        // Upload certificate copy
        if (_certificateCopy != null) {
          certificateUrl = await _storageService.uploadFile(
            _certificateCopy!,
            user.id,
            'certificate',
          );
        }

        // Upload medical certificate
        if (_medicalCertificate != null) {
          medicalUrl = await _storageService.uploadFile(
            _medicalCertificate!,
            user.id,
            'medical',
          );
        }

        // Upload additional documents
        if (_additionalDocuments.isNotEmpty) {
          additionalUrls = await _storageService.uploadMultipleFiles(
            _additionalDocuments,
            user.id,
            'additional',
          );
        }

        // Update user data through API
        await context.read<AuthService>().updateProfile(
          fullName: _fullNameController.text.trim(),
          passportSeries: _passportSeriesController.text.trim(),
          passportNumber: _passportNumberController.text.trim(),
          passportIssueDate: _passportIssueDateController.text.trim(),
          birthDate: _birthDateController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Документы успешно сохранены')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при сохранении документов: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мои документы',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF2C3E50)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Личные данные',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fullNameController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'ФИО',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.person, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, введите ФИО';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _passportSeriesController,
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: 'Серия паспорта',
                                    labelStyle: const TextStyle(color: Colors.grey),
                                    prefixIcon: const Icon(Icons.credit_card, color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите серию';
                                    }
                                    if (value.length != 4) {
                                      return 'Серия должна содержать 4 цифры';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _passportNumberController,
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: 'Номер паспорта',
                                    labelStyle: const TextStyle(color: Colors.grey),
                                    prefixIcon: const Icon(Icons.credit_card, color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите номер';
                                    }
                                    if (value.length != 6) {
                                      return 'Номер должен содержать 6 цифр';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passportIssueDateController,
                            style: const TextStyle(color: Colors.black87),
                            readOnly: true,
                            onTap: () => _selectDate(context, _passportIssueDateController),
                            decoration: InputDecoration(
                              labelText: 'Дата выдачи паспорта',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, выберите дату выдачи паспорта';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _birthDateController,
                            style: const TextStyle(color: Colors.black87),
                            readOnly: true,
                            onTap: () => _selectDate(context, _birthDateController),
                            decoration: InputDecoration(
                              labelText: 'Дата рождения',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.cake, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, выберите дату рождения';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Документы',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDocumentUploadSection(
                            'Копия паспорта',
                            _passportCopy,
                            () => _pickImage('passport'),
                          ),
                          const SizedBox(height: 16),
                          _buildDocumentUploadSection(
                            'Копия аттестата',
                            _certificateCopy,
                            () => _pickImage('certificate'),
                          ),
                          const SizedBox(height: 16),
                          _buildDocumentUploadSection(
                            'Медицинская справка',
                            _medicalCertificate,
                            () => _pickImage('medical'),
                          ),
                          const SizedBox(height: 16),
                          _buildAdditionalDocumentsSection(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveDocuments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4A90E2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                            ),
                          )
                        : const Text(
                            'Сохранить',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadSection(
    String title,
    File? file,
    VoidCallback onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file),
                label: Text(file == null ? 'Загрузить' : 'Изменить'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                  side: const BorderSide(color: Color(0xFF4A90E2)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (file != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  file.path.split('/').last,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дополнительные документы',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickAdditionalDocuments,
          icon: const Icon(Icons.upload_file),
          label: const Text('Добавить документы'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4A90E2),
            side: const BorderSide(color: Color(0xFF4A90E2)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_additionalDocuments.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._additionalDocuments.map((file) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  file.path.split('/').last,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ],
    );
  }
} 