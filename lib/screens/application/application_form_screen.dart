import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  
  File? _applicationCopy;
  String? _selectedFaculty;
  String? _selectedProgram;
  String? _selectedStudyForm;
  
  bool _isLoading = false;
  UserModel? _userData;

  final Map<String, List<String>> _facultyPrograms = {
    'Инженерный факультет': [
      'Информационные технологии',
      'Машиностроение',
      'Электротехника',
    ],
    'Экономический факультет': [
      'Менеджмент',
      'Финансы и кредит',
      'Бухгалтерский учет',
    ],
    'Гуманитарный факультет': [
      'Психология',
      'История',
      'Филология',
    ],
  };

  final List<String> _studyForms = [
    'Очная',
    'Заочная',
    'Очно-заочная',
  ];

  bool get _isDirectionSelected => 
    _selectedFaculty != null && 
    _selectedProgram != null && 
    _selectedStudyForm != null;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        if (mounted) {
          setState(() {
            _userData = user;
            if (_facultyPrograms.containsKey(user.faculty)) {
              _selectedFaculty = user.faculty;
              if (_facultyPrograms[_selectedFaculty]?.contains(user.program) ?? false) {
                _selectedProgram = user.program;
              } else {
                _selectedProgram = null;
              }
            } else {
              _selectedFaculty = null;
              _selectedProgram = null;
            }
            if (_studyForms.contains(user.studyForm)) {
              _selectedStudyForm = user.studyForm;
            } else {
              _selectedStudyForm = null;
            }
          });
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

  void _resetApplication() {
    setState(() {
      _applicationCopy = null;
    });
  }

  Future<void> _pickApplication() async {
    if (!_isDirectionSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала выберите направление обучения'),
        ),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _applicationCopy = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выборе файла: $e')),
        );
      }
    }
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      if (!_isDirectionSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, выберите направление обучения'),
          ),
        );
        return;
      }

      if (_applicationCopy == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, загрузите заявление на поступление'),
          ),
        );
        return;
      }

      // Check if required documents are uploaded
      if (_userData!.passportCopyUrl.isEmpty ||
          _userData!.certificateCopyUrl.isEmpty ||
          _userData!.medicalCertificateUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, загрузите все необходимые документы в разделе "Мои документы"'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final user = context.read<AuthService>().currentUser;
        if (user == null) throw Exception('Пользователь не авторизован');

        // Upload application
        final applicationUrl = await _storageService.uploadFile(
          _applicationCopy!,
          user.id,
          'application',
        );

        // Update user data through API
        await context.read<AuthService>().updateProfile(
          fullName: _userData!.fullName,
          passportSeries: _userData!.passportSeries,
          passportNumber: _userData!.passportNumber,
          passportIssueDate: _userData!.passportIssueDate,
          birthDate: _userData!.birthDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заявление успешно подано')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при подаче заявления: $e')),
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
          'Подача заявки',
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
                            'Основная информация',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedFaculty,
                            decoration: const InputDecoration(
                              labelText: 'Факультет',
                              border: OutlineInputBorder(),
                            ),
                            items: _facultyPrograms.keys.map((faculty) {
                              return DropdownMenuItem(
                                value: faculty,
                                child: Text(faculty),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFaculty = value;
                                _selectedProgram = null;
                                _resetApplication();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, выберите факультет';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedProgram,
                            decoration: const InputDecoration(
                              labelText: 'Направление',
                              border: OutlineInputBorder(),
                            ),
                            items: _selectedFaculty != null
                                ? _facultyPrograms[_selectedFaculty]!.map((program) {
                                    return DropdownMenuItem(
                                      value: program,
                                      child: Text(program),
                                    );
                                  }).toList()
                                : [],
                            onChanged: _selectedFaculty != null
                                ? (value) {
                                    setState(() {
                                      _selectedProgram = value;
                                      _resetApplication();
                                    });
                                  }
                                : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, выберите направление';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedStudyForm,
                            decoration: const InputDecoration(
                              labelText: 'Форма обучения',
                              border: OutlineInputBorder(),
                            ),
                            items: _studyForms.map((form) {
                              return DropdownMenuItem(
                                value: form,
                                child: Text(form),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStudyForm = value;
                                _resetApplication();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, выберите форму обучения';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildApplicationUploadSection(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitApplication,
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
                            'Отправить заявку',
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

  Widget _buildApplicationUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Загрузите заполненное заявление на поступление',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (!_isDirectionSelected)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Сначала выберите направление обучения',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isDirectionSelected ? _pickApplication : null,
                icon: Icon(
                  Icons.upload_file,
                  size: 20,
                  color: _isDirectionSelected ? Colors.white : Colors.grey,
                ),
                label: Text(
                  _applicationCopy == null ? 'Загрузить' : 'Изменить',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDirectionSelected ? Colors.white : Colors.grey,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: _isDirectionSelected ? Colors.white : Colors.grey,
                  ),
                  backgroundColor: _isDirectionSelected ? const Color(0xFF4A90E2) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_applicationCopy != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _applicationCopy!.path.split('/').last,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
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
} 