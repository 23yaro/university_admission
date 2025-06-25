import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'middleware/auth_middleware.dart';

final db = PostgreSQLConnection(
  'localhost', // host
  5432,        // port
  'university_admission', // database name
  username: 'postgres',
  password: '2308',
);

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final pipeline = Pipeline()
      .addMiddleware(_provideDatabase(db))
      .addMiddleware(_authMiddleware());

  return serve(pipeline.addHandler(handler), ip, port);
}

Middleware _provideDatabase(PostgreSQLConnection db) {
  return (handler) {
    return (context) async {
      final updatedContext = context.provide(() => db);
      return handler(updatedContext);
    };
  };
}

Middleware _authMiddleware() {
  return (handler) {
    return (context) async {
      final path = context.request.uri.path;
      if (path.startsWith('/auth/')) {
        return handler(context);
      }
      return authMiddleware()(handler)(context);
    };
  };
} 