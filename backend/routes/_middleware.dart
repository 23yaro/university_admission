import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

// Глобальное подключение к базе
final db = PostgreSQLConnection(
  'localhost', // host
  5432,        // port
  'university_admission', // database name
  username: 'postgres',
  password: '2308',
);

final Future<void> _dbInit = db.open();

final middleware = (Handler handler) {
  return (context) async {
    await _dbInit; // Ждём открытия соединения
    final updatedContext = context.provide<PostgreSQLConnection>(() => db);
    final response = await handler(updatedContext);
    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
      },
    );
  };
}; 