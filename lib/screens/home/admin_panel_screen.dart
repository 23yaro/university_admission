import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  // Моки пользователей
  List<Map<String, dynamic>> users = [
    {
      'id': '1',
      'fio': 'Иванов Иван Иванович',
      'passport': '1234 567890',
      'dob': '2000-01-01',
      'status': 'В ожидании',
    },
    {
      'id': '2',
      'fio': 'Петров Петр Петрович',
      'passport': '2345 678901',
      'dob': '2001-02-02',
      'status': 'Принято',
    },
    {
      'id': '3',
      'fio': 'Сидорова Анна Сергеевна',
      'passport': '3456 789012',
      'dob': '2002-03-03',
      'status': 'Отклонено',
    },
  ];

  void _changeStatus(int index, String newStatus) {
    setState(() {
      users[index]['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ-панель'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ФИО')),
              DataColumn(label: Text('Паспорт')),
              DataColumn(label: Text('Дата рождения')),
              DataColumn(label: Text('Статус заявки')),
              DataColumn(label: Text('Действия')),
            ],
            rows: List.generate(users.length, (index) {
              final user = users[index];
              return DataRow(cells: [
                DataCell(Text(user['fio'])),
                DataCell(Text(user['passport'])),
                DataCell(Text(user['dob'])),
                DataCell(Text(user['status'])),
                DataCell(
                  DropdownButton<String>(
                    value: user['status'],
                    items: const [
                      DropdownMenuItem(value: 'В ожидании', child: Text('В ожидании')),
                      DropdownMenuItem(value: 'Принято', child: Text('Принято')),
                      DropdownMenuItem(value: 'Отклонено', child: Text('Отклонено')),
                    ],
                    onChanged: (value) {
                      if (value != null) _changeStatus(index, value);
                    },
                  ),
                ),
              ]);
            }),
          ),
        ),
      ),
    );
  }
} 