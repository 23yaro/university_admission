import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final username = body['username'] as String?;
    final password = body['password'] as String?;
    if (username == null || password == null) {
      return Response.json(statusCode: 400, body: {'error': 'Username and password required'});
    }

    final db = context.read<PostgreSQLConnection>();
    // Проверка на уникальность username
    final existing = await db.mappedResultsQuery(
      'SELECT * FROM login WHERE username = @username',
      substitutionValues: {'username': username},
    );
    if (existing.isNotEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'Username already exists'});
    }

    final loginId = const Uuid().v4();
    final userId = const Uuid().v4();
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

    await db.execute(
      'INSERT INTO login (login_id, username, password_hash) VALUES (@loginId, @username, @passwordHash)',
      substitutionValues: {
        'loginId': loginId,
        'username': username,
        'passwordHash': passwordHash,
      },
    );
    await db.execute(
      'INSERT INTO users (user_id, login_id, user_data_id) VALUES (@userId, @loginId, NULL)',
      substitutionValues: {
        'userId': userId,
        'loginId': loginId,
      },
    );

    return Response.json(
      statusCode: 201,
      body: {
        'user_id': userId,
        'login_id': loginId,
        'username': username,
      },
    );
  } catch (e, stack) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid request', 'details': e.toString(), 'stack': stack.toString()},
    );
  }
} 