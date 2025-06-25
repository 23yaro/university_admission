import 'package:dart_frog/dart_frog.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final request = context.request;
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          statusCode: 401,
          body: 'Unauthorized',
        );
      }

      final token = authHeader.substring(7);
      
      try {
        if (JwtDecoder.isExpired(token)) {
          return Response(
            statusCode: 401,
            body: 'Token expired',
          );
        }

        final decodedToken = JwtDecoder.decode(token);
        final updatedContext = context.provide(() => decodedToken);
        
        return handler(updatedContext);
      } catch (e) {
        return Response(
          statusCode: 401,
          body: 'Invalid token',
        );
      }
    };
  };
} 