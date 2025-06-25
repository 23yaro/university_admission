import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class RankingScreen extends StatelessWidget {
   RankingScreen({super.key});

  // Моковые данные для ранжированного списка
  final List<Map<String, dynamic>> _mockRankingList = [
    {
      'fullName': 'Иванов Иван Иванович',
      'faculty': 'Инженерный факультет',
      'program': 'Информационные технологии',
      'studyForm': 'Очная',
      'score': 95,
      'status': 'Рекомендован к зачислению',
    },
    {
      'fullName': 'Петров Петр Петрович',
      'faculty': 'Инженерный факультет',
      'program': 'Информационные технологии',
      'studyForm': 'Очная',
      'score': 92,
      'status': 'Рекомендован к зачислению',
    },
    {
      'fullName': 'Сидоров Сидор Сидорович',
      'faculty': 'Инженерный факультет',
      'program': 'Информационные технологии',
      'studyForm': 'Очная',
      'score': 88,
      'status': 'В списке ожидания',
    },
    {
      'fullName': 'Смирнова Анна Ивановна',
      'faculty': 'Инженерный факультет',
      'program': 'Информационные технологии',
      'studyForm': 'Очная',
      'score': 85,
      'status': 'В списке ожидания',
    },
    {
      'fullName': 'Козлов Алексей Петрович',
      'faculty': 'Инженерный факультет',
      'program': 'Информационные технологии',
      'studyForm': 'Очная',
      'score': 82,
      'status': 'В списке ожидания',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ранжированный список',
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
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
                          'Инженерный факультет',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Направление: Информационные технологии',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Форма обучения: Очная',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _mockRankingList.length,
                  itemBuilder: (context, index) {
                    final applicant = _mockRankingList[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(applicant['status']),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          applicant['fullName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Баллы: ${applicant['score']}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              applicant['status'],
                              style: TextStyle(
                                color: _getStatusColor(applicant['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Рекомендован к зачислению':
        return Colors.green;
      case 'В списке ожидания':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 