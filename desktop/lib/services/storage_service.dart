import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageService {
  Future<String> uploadFile(File file, String userId, String documentType) async {
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final userDir = Directory('${appDir.path}/documents/$userId');
      
      // Create user directory if it doesn't exist
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final filename = '${documentType}_$timestamp$extension';
      final targetPath = '${userDir.path}/$filename';

      // Copy file to target location
      await file.copy(targetPath);

      return targetPath;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<List<String>> uploadMultipleFiles(List<File> files, String userId, String documentType) async {
    try {
      final paths = <String>[];
      for (var file in files) {
        final path = await uploadFile(file, userId, documentType);
        paths.add(path);
      }
      return paths;
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  Future<File?> getFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get file: $e');
    }
  }

  Future<List<File>> getUserDocuments(String userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final userDir = Directory('${appDir.path}/documents/$userId');
      
      if (!await userDir.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = await userDir.list().toList();
      return files.whereType<File>().toList();
    } catch (e) {
      throw Exception('Failed to get user documents: $e');
    }
  }

  Future<void> clearUserDocuments(String userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final userDir = Directory('${appDir.path}/documents/$userId');
      
      if (await userDir.exists()) {
        await userDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to clear user documents: $e');
    }
  }
} 