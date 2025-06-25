import 'package:dart_frog/dart_frog.dart';
import 'package:encrypt/encrypt.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final formData = await context.request.formData();
    final userId = formData.fields['userId'];
    final firstName = formData.fields['firstName'];
    final lastName = formData.fields['lastName'];
    final surName = formData.fields['surName'];
    final passSeries = formData.fields['passSeries'];
    final passNum = formData.fields['passNum'];
    final passProduced = formData.fields['passProduced'];
    final dob = formData.fields['dob'];

    if ([userId, firstName, lastName, surName, passSeries, passNum, passProduced, dob].contains(null)) {
      return Response.json(statusCode: 400, body: {'error': 'Missing required fields'});
    }

    final db = context.read<PostgreSQLConnection>();
    final uuid = const Uuid();

    // Ищем существующую user_data по user_id
    final existingUserData = await db.mappedResultsQuery(
      'SELECT data_id FROM user_data WHERE user_id = @userId',
      substitutionValues: {'userId': userId},
    );
    String dataId;
    if (existingUserData.isNotEmpty) {
      dataId = existingUserData.first['user_data']!['data_id'];
      final oldData = await db.mappedResultsQuery(
        'SELECT * FROM user_data WHERE data_id = @dataId',
        substitutionValues: {'dataId': dataId},
      );
      if (oldData.isNotEmpty) {
        final row = oldData.first['user_data']!;
        final oldPassportId = row['passport_id'];
        final oldStateId = row['state_id'];
        final oldMedId = row['med_id'];
        final oldCertificateId = row['certificate_id'];
        final oldAdditionalId = row['additional_id'];
        // Удаляем passport
        if (oldPassportId != null) {
          await db.execute('UPDATE user_data SET passport_id = NULL WHERE passport_id = @id', substitutionValues: {'id': oldPassportId});
          await db.execute('DELETE FROM passport WHERE passport_id = @id', substitutionValues: {'id': oldPassportId});
        }
        // Удаляем statement_scan
        if (oldStateId != null) {
          final stateScan = await db.mappedResultsQuery('SELECT file_path FROM statement_scan WHERE state_id = @id', substitutionValues: {'id': oldStateId});
          if (stateScan.isNotEmpty) {
            final filePath = stateScan.first['statement_scan']!['file_path'];
            if (filePath != null) { try { File(filePath).deleteSync(); } catch (_) {} }
          }
          await db.execute('UPDATE user_data SET state_id = NULL WHERE state_id = @id', substitutionValues: {'id': oldStateId});
          await db.execute('DELETE FROM statement_scan WHERE state_id = @id', substitutionValues: {'id': oldStateId});
        }
        // Удаляем medical_scan
        if (oldMedId != null) {
          final medScan = await db.mappedResultsQuery('SELECT file_path FROM medical_scan WHERE med_id = @id', substitutionValues: {'id': oldMedId});
          if (medScan.isNotEmpty) {
            final filePath = medScan.first['medical_scan']!['file_path'];
            if (filePath != null) { try { File(filePath).deleteSync(); } catch (_) {} }
          }
          await db.execute('UPDATE user_data SET med_id = NULL WHERE med_id = @id', substitutionValues: {'id': oldMedId});
          await db.execute('DELETE FROM medical_scan WHERE med_id = @id', substitutionValues: {'id': oldMedId});
        }
        // Удаляем certificate_scan
        if (oldCertificateId != null) {
          final certScan = await db.mappedResultsQuery('SELECT file_path FROM certificate_scan WHERE certificate_id = @id', substitutionValues: {'id': oldCertificateId});
          if (certScan.isNotEmpty) {
            final filePath = certScan.first['certificate_scan']!['file_path'];
            if (filePath != null) { try { File(filePath).deleteSync(); } catch (_) {} }
          }
          await db.execute('UPDATE user_data SET certificate_id = NULL WHERE certificate_id = @id', substitutionValues: {'id': oldCertificateId});
          await db.execute('DELETE FROM certificate_scan WHERE certificate_id = @id', substitutionValues: {'id': oldCertificateId});
        }
        // Удаляем additional_scan
        if (oldAdditionalId != null) {
          final addScan = await db.mappedResultsQuery('SELECT file_path FROM additional_scan WHERE additional_id = @id', substitutionValues: {'id': oldAdditionalId});
          if (addScan.isNotEmpty) {
            final filePath = addScan.first['additional_scan']!['file_path'];
            if (filePath != null) { try { File(filePath).deleteSync(); } catch (_) {} }
          }
          await db.execute('UPDATE user_data SET additional_id = NULL WHERE additional_id = @id', substitutionValues: {'id': oldAdditionalId});
          await db.execute('DELETE FROM additional_scan WHERE additional_id = @id', substitutionValues: {'id': oldAdditionalId});
        }
      }
    } else {
      dataId = uuid.v4();
      // Создаём новую user_data и обновляем users.user_data_id
      await db.execute(
        'INSERT INTO user_data (data_id, user_id) VALUES (@dataId, @userId)',
        substitutionValues: {
          'dataId': dataId,
          'userId': userId,
        },
      );
      await db.execute(
        'UPDATE users SET user_data_id = @dataId WHERE user_id = @userId',
        substitutionValues: {
          'dataId': dataId,
          'userId': userId,
        },
      );
    }

    // Паспорт
    final passportId = uuid.v4();
    await db.execute(
      'INSERT INTO passport (passport_id, first_name, last_name, sur_name, pass_series, pass_num, pass_produced, dob) VALUES (@passportId, @firstName, @lastName, @surName, @passSeries, @passNum, @passProduced, @dob)',
      substitutionValues: {
        'passportId': passportId,
        'firstName': firstName,
        'lastName': lastName,
        'surName': surName,
        'passSeries': passSeries,
        'passNum': passNum,
        'passProduced': passProduced,
        'dob': dob,
      },
    );

    // Сканы документов (statement, medical, certificate, additional)
    Future<String?> saveScan(String field, String table, String nameField, String idField) async {
      final file = formData.files[field];
      if (file == null) return null;
      final scanId = uuid.v4();
      final uploadDir = Directory('uploads');
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }
      final fileName = '${scanId}_${file.name}';
      final filePath = path.join(uploadDir.path, fileName);

      final bytes = await file.readAsBytes();
      final key = Key.fromUtf8(String.fromEnvironment('AES_KEY')); // 32 символа
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key));
      final encrypted = encrypter.encryptBytes(bytes, iv: iv);
      await File(filePath).writeAsBytes(encrypted.bytes);

      await db.execute(
        'INSERT INTO $table ($idField, $nameField, file_path) VALUES (@id, @name, @filePath)',
        substitutionValues: {
          'id': scanId,
          'name': file.name,
          'filePath': filePath,
        },
      );
      return scanId;
    }

    final stateId = await saveScan('statementScan', 'statement_scan', 'state_name', 'state_id');
    final medId = await saveScan('medicalScan', 'medical_scan', 'med_name', 'med_id');
    final certificateId = await saveScan('certificateScan', 'certificate_scan', 'certificate_name', 'certificate_id');
    final additionalId = await saveScan('additionalScan', 'additional_scan', 'additional_name', 'additional_id');

    // Обновляем user_data с новыми id документов
    await db.execute(
      'UPDATE user_data SET passport_id = @passportId, state_id = @stateId, med_id = @medId, certificate_id = @certificateId, additional_id = @additionalId WHERE data_id = @dataId',
      substitutionValues: {
        'passportId': passportId,
        'stateId': stateId,
        'medId': medId,
        'certificateId': certificateId,
        'additionalId': additionalId,
        'dataId': dataId,
      },
    );
    //  user_data_id в users всегда актуален
    await db.execute(
      'UPDATE users SET user_data_id = @dataId WHERE user_id = @userId',
      substitutionValues: {
        'dataId': dataId,
        'userId': userId,
      },
    );

    return Response.json(
      statusCode: 201,
      body: {'message': 'Documents uploaded and user_data updated', 'data_id': dataId},
    );
  } catch (e, stack) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid request', 'details': e.toString(), 'stack': stack.toString()},
    );
  }
} 