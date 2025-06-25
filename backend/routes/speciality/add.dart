import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final specName = body['specName'] as String?;
    final codeName = body['codeName'] as String?;
    if (specName == null || codeName == null) {
      return Response.json(statusCode: 400, body: {'error': 'specName and codeName required'});
    }

    final db = context.read<PostgreSQLConnection>();
    final exists = await db.mappedResultsQuery(
      'SELECT * FROM speciality WHERE spec_name = @specName OR code_name = @codeName',
      substitutionValues: {'specName': specName, 'codeName': codeName},
    );
    if (exists.isNotEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'Speciality already exists'});
    }

    final specId = const Uuid().v4();
    await db.execute(
      'INSERT INTO speciality (spec_id, spec_name, code_name) VALUES (@specId, @specName, @codeName)',
      substitutionValues: {
        'specId': specId,
        'specName': specName,
        'codeName': codeName,
      },
    );

    return Response.json(
      statusCode: 201,
      body: {'message': 'Speciality added', 'spec_id': specId},
    );
  } catch (e, stack) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid request', 'details': e.toString(), 'stack': stack.toString()},
    );
  }
} 