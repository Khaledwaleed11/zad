import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../domain/entities/audio_recording_entity.dart';
import '../models/audio_recording_model.dart';

abstract class AudioLibraryLocalDataSource {
  Future<AudioRecordingModel?> addRecording({
    required String name,
    required AudioRecordingType type,
    int? surahNumber,
  });

  List<AudioRecordingModel> getRecordings({
    AudioRecordingType? type,
  });

  Future<void> deleteRecording(String id);
}

class AudioLibraryLocalDataSourceImpl
    implements AudioLibraryLocalDataSource {
  static const String _boxName = StorageConstants.audioLibraryBox;
  Box get _box => Hive.box(_boxName);

  static const List<String> _allowedExtensions = [
    'mp3',
    'm4a',
    'aac',
    'wav',
    'ogg',
    'flac',
  ];

  String _generateId() {
    final random = Random.secure();

    return '${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(1000000)}';
  }

  @override
  Future<AudioRecordingModel?> addRecording({
    required String name,
    required AudioRecordingType type,
    int? surahNumber,
  }) async {
    // اختيار ملف صوتي واحد
    final pickedFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    // المستخدم ألغى الاختيار
    if (pickedFile == null) {
      return null;
    }

    final sourcePath = pickedFile.path;

    if (sourcePath == null) {
      throw Exception('تعذر الوصول إلى الملف المحدد');
    }

    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception('الملف المحدد غير موجود');
    }

    final id = _generateId();
    final extension = pickedFile.extension?.toLowerCase() ?? 'mp3';

    final appDirectory = await getApplicationDocumentsDirectory();

    final audioDirectory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}'
          'audio_library${Platform.pathSeparator}${type.name}',
    );

    if (!await audioDirectory.exists()) {
      await audioDirectory.create(recursive: true);
    }

    final destinationPath =
        '${audioDirectory.path}${Platform.pathSeparator}$id.$extension';

    final savedFile = await sourceFile.copy(destinationPath);

    final recording = AudioRecordingModel(
      id: id,
      name: name,
      type: type,
      surahNumber: type == AudioRecordingType.quran
          ? surahNumber
          : null,
      filePath: savedFile.path,
      createdAt: DateTime.now(),
    );

    await _box.put(id, recording.toMap());

    return recording;
  }

  @override
  List<AudioRecordingModel> getRecordings({
    AudioRecordingType? type,
  }) {
    final recordings = _box.values.map((value) {
      return AudioRecordingModel.fromMap(
        Map<dynamic, dynamic>.from(value as Map),
      );
    }).where((recording) {
      return type == null || recording.type == type;
    }).toList();

    recordings.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return recordings;
  }

  @override
  Future<void> deleteRecording(String id) async {
    final storedData = _box.get(id);

    if (storedData == null) return;

    final recording = AudioRecordingModel.fromMap(
      Map<dynamic, dynamic>.from(storedData as Map),
    );

    final file = File(recording.filePath);

    if (await file.exists()) {
      await file.delete();
    }

    await _box.delete(id);
  }
}