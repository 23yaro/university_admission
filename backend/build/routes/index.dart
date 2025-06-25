import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'message': 'University Admission API',
      'endpoints': {
        'auth': {
          'register': 'POST /auth/register',
          'login': 'POST /auth/login',
        },
        'applications': {
          'submit': 'POST /applications/submit',
          'list': 'GET /applications',
        },
      },
    },
  );
} 