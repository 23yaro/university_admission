import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'config/database.dart';
import 'middleware/auth_middleware.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final db = DatabaseConfig();
  await db.initialize();

  final pipeline = Pipeline()
      .use(_provideDatabase(db))
      .use(_authMiddleware());

  return serve(pipeline.addHandler(handler), ip, port);
}

Middleware _provideDatabase(DatabaseConfig db) {
  return (handler) {
    return (context) async {
      final updatedContext = context.provide(() => db.connection);
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