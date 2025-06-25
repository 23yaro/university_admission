import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final username = body['username'];
    final password = body['password'];
    if (username == null || password == null) {
      return Response.json(statusCode: 400, body: {'error': 'username and password required'});
    }

    final db = context.read<PostgreSQLConnection>();
    final results = await db.mappedResultsQuery(
      'SELECT * FROM login WHERE username = @username',
      substitutionValues: {'username': username},
    );

    if (results.isEmpty) {
      return Response.json(statusCode: 401, body: {'error': 'Invalid credentials'});
    }

    final user = results.first['login']!;
    final passwordHash = user['password_hash'] as String;

    if (!BCrypt.checkpw(password, passwordHash)) {
      return Response.json(statusCode: 401, body: {'error': 'Invalid credentials'});
    }

    // Получаем user_id по login_id
    final loginId = user['login_id'];
    final userRes = await db.mappedResultsQuery(
      'SELECT user_id FROM users WHERE login_id = @loginId',
      substitutionValues: {'loginId': loginId},
    );
    final userId = userRes.isNotEmpty ? userRes.first['users']!['user_id'] : null;

    return Response.json(body: {
      'message': 'Login successful',
      'user': {
        'login_id': user['login_id'],
        'user_id': userId,
        'username': user['username'],
      }
    });
  } catch (e, stack) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid request', 'details': e.toString(), 'stack': stack.toString()},
    );
  }
}

String _generateToken(Map<String, dynamic> user) {
  final payload = {
    'sub': user['id'],
    'email': user['email'],
    'role': user['role'],
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'exp': (DateTime.now().add(const Duration(days: 1))).millisecondsSinceEpoch ~/ 1000,
  };

  // In a real application, you would use a proper JWT library
  // This is a simplified example
  return 'dummy_token_${user['id']}';
} 