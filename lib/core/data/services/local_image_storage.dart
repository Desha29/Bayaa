import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Copies user-selected images into app-managed storage and returns the
/// persistent path that can safely be stored in SQLite.
class LocalImageStorage {
  const LocalImageStorage._();

  static Future<String> persist({
    required String sourcePath,
    required String collection,
    required String key,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Selected image no longer exists', sourcePath);
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final directory = Directory(
      path.join(supportDirectory.path, 'Bayaa', 'media', collection),
    );
    await directory.create(recursive: true);

    final safeKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final extension = path.extension(sourcePath).toLowerCase();
    final safeExtension = extension.isEmpty ? '.jpg' : extension;
    final destination = path.join(
      directory.path,
      '${safeKey}_${DateTime.now().microsecondsSinceEpoch}$safeExtension',
    );

    if (path.equals(path.normalize(sourcePath), path.normalize(destination))) {
      return sourcePath;
    }
    return (await source.copy(destination)).path;
  }
}
