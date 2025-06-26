// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/index.dart' as index;
import '../routes/speciality/add.dart' as speciality_add;
import '../routes/documents/upload.dart' as documents_upload;
import '../routes/auth/register.dart' as auth_register;
import '../routes/auth/login.dart' as auth_login;
import '../routes/applications/submit.dart' as applications_submit;
import '../routes/applications/index.dart' as applications_index;


void main() async {
  final address = InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  createServer(address, port);
}

Future<HttpServer> createServer(InternetAddress address, int port) async {
  final handler = Cascade().add(buildRootHandler()).handler;
  final server = await serve(handler, address, port);
  print('\x1B[92m✓\x1B[0m Running on http://${server.address.host}:${server.port}');
  return server;
}

Handler buildRootHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..mount('/applications', (context) => buildApplicationsHandler()(context))
    ..mount('/auth', (context) => buildAuthHandler()(context))
    ..mount('/documents', (context) => buildDocumentsHandler()(context))
    ..mount('/speciality', (context) => buildSpecialityHandler()(context))
    ..mount('/', (context) => buildHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildApplicationsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/submit', (context) => applications_submit.onRequest(context,))..all('/', (context) => applications_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/register', (context) => auth_register.onRequest(context,))..all('/login', (context) => auth_login.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildDocumentsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/upload', (context) => documents_upload.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildSpecialityHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/add', (context) => speciality_add.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => index.onRequest(context,));
  return pipeline.addHandler(router);
}

