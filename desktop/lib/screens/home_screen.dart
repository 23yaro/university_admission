import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/application_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Admission Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Implement refresh functionality
            },
          ),
        ],
      ),
      body: Consumer<ApplicationModel>(
        builder: (context, model, child) {
          if (model.applications.isEmpty) {
            return const Center(
              child: Text('No applications yet'),
            );
          }

          return ListView.builder(
            itemCount: model.applications.length,
            itemBuilder: (context, index) {
              final application = model.applications[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(application.fullName),
                  subtitle: Text(application.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          application.isReviewed
                              ? Icons.check_circle
                              : Icons.pending,
                          color: application.isReviewed
                              ? Colors.green
                              : Colors.orange,
                        ),
                        onPressed: () {
                          model.toggleReviewStatus(application.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          model.removeApplication(application.id);
                        },
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Passport Info Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Passport Info:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text('Фамилия: ${application.passport.lastName}'),
                                Text('Имя: ${application.passport.firstName}'),
                                Text('Отчество: ${application.passport.surName}'),
                                Text('Серия: ${application.passport.passSeries}'),
                                Text('Номер: ${application.passport.passNum}'),
                                Text('Дата выдачи: ${_formatDate(application.passport.passProduced)}'),
                                Text('Дата рождения: ${_formatDate(application.passport.dob)}'),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final uri = Uri(
                                      scheme: 'mailto',
                                      path: application.email,
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Не удалось открыть почтовый клиент')),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.email),
                                  label: const Text('Написать на email'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Documents Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Documents:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                _buildDocumentButton(
                                  context,
                                  'Passport',
                                  application.passportPath,
                                ),
                                _buildDocumentButton(
                                  context,
                                  'Application Form',
                                  application.applicationFormPath,
                                ),
                                _buildDocumentButton(
                                  context,
                                  'Medical Certificate',
                                  application.medicalCertificatePath,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Additional Files Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (application.additionalFiles.isNotEmpty) ...[
                                  const Text(
                                    'Additional Files:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  ...application.additionalFiles.map(
                                    (file) => _buildDocumentButton(
                                      context,
                                      file.name,
                                      file.path,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDocumentButton(
    BuildContext context,
    String label,
    String filePath,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          final uri = Uri.file(filePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open file'),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.file_present),
        label: Text(label),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
} 