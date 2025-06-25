import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final token = context.read<Map<String, dynamic>>();
    final role = token['role'] as String;

    if (role != 'admin') {
      return Response(
        statusCode: 403,
        body: 'Forbidden',
      );
    }

    final db = context.read<PostgreSQLConnection>();
    final results = await db.mappedResultsQuery(
      '''
      SELECT a.*, u.email
      FROM applicants a
      JOIN users u ON a.user_id = u.id
      ORDER BY a.created_at DESC
      ''',
    );

    final applications = results.map((row) {
      final applicant = row['applicants']!;
      final user = row['users']!;
      return {
        'id': applicant['id'],
        'fullName': applicant['full_name'],
        'email': user['email'],
        'faculty': applicant['faculty'],
        'specialization': applicant['specialization'],
        'createdAt': applicant['created_at'],
        'documentUrls': applicant['document_urls'],
        'additionalDocuments': applicant['additional_documents'],
      };
    }).toList();

    return Response.json(body: applications);
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Failed to fetch applications'},
    );
  }
} 