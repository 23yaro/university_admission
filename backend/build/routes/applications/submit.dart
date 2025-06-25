import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final userId = body['userId'] as String?;
    final specId = body['specId'] as String?;
    if (userId == null || specId == null) {
      return Response.json(statusCode: 400, body: {'error': 'userId and specId required'});
    }

    final db = context.read<PostgreSQLConnection>();
    // Получаем user_data_id
    final userDataRes = await db.mappedResultsQuery(
      'SELECT user_data_id FROM users WHERE user_id = @userId',
      substitutionValues: {'userId': userId},
    );
    if (userDataRes.isEmpty || userDataRes.first['users']!['user_data_id'] == null) {
      return Response.json(statusCode: 400, body: {'error': 'User has no documents uploaded'});
    }
    final dataId = userDataRes.first['users']!['user_data_id'];

    // Проверяем, есть ли уже заявка на эту специальность
    final exists = await db.mappedResultsQuery(
      'SELECT * FROM user_has_spec WHERE data_id = @dataId AND spec_id = @specId',
      substitutionValues: {'dataId': dataId, 'specId': specId},
    );
    if (exists.isNotEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'Application for this speciality already exists'});
    }

    // Добавляем заявку
    await db.execute(
      'INSERT INTO user_has_spec (data_id, spec_id) VALUES (@dataId, @specId)',
      substitutionValues: {
        'dataId': dataId,
        'specId': specId,
      },
    );

    return Response.json(
      statusCode: 201,
      body: {'message': 'Application submitted for speciality', 'spec_id': specId},
    );
  } catch (e, stack) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid request', 'details': e.toString(), 'stack': stack.toString()},
    );
  }
} 