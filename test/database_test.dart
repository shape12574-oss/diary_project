import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:diary_project/database/database_helper.dart';
import 'package:diary_project/models/diary_entry.dart';

void main() {

  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Unit Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper();
    });

    test('Insert Diary', () async {
      final diary = DiaryEntry(
        title: 'Test Journey',
        content: 'This is a test diary entry',
        latitude: 22.3,
        longitude: 114.2,
        address: 'Hong Kong',
        activity: 'walking',
        photoPath: '/test/path.jpg',
        aiTags: ['building', 'street'],
        createdAt: DateTime.now(),
      );

      final id = await dbHelper.insertDiary(diary);
      expect(id, greaterThan(0));
    });

    test('Read all Diaries', () async {
      final diaries = await dbHelper.getAllDiaries();
      expect(diaries, isA<List<DiaryEntry>>());
      expect(diaries.length, greaterThanOrEqualTo(0));
    });

    test('Update Diary', () async {

      final diary = DiaryEntry(
        title: 'Original Title',
        content: 'Original content',
        latitude: 22.3,
        longitude: 114.2,
        address: 'Hong Kong',
        activity: 'walking',
        photoPath: '/test/path.jpg',
        aiTags: ['building'],
        createdAt: DateTime.now(),
      );

      final id = await dbHelper.insertDiary(diary);


      final updatedDiary = DiaryEntry(
        id: id,
        title: 'Updated Title',
        content: diary.content,
        latitude: diary.latitude,
        longitude: diary.longitude,
        address: diary.address,
        activity: diary.activity,
        photoPath: diary.photoPath,
        aiTags: diary.aiTags,
        createdAt: diary.createdAt,
      );

      final count = await dbHelper.updateDiary(updatedDiary);
      expect(count, equals(1));
    });

    test('Delete Diary', () async {

      final diary = DiaryEntry(
        title: 'Delete me',
        content: 'This will be deleted',
        latitude: 22.3,
        longitude: 114.2,
        address: 'Hong Kong',
        activity: 'walking',
        photoPath: '/test/path.jpg',
        aiTags: ['temp'],
        createdAt: DateTime.now(),
      );

      final id = await dbHelper.insertDiary(diary);


      final count = await dbHelper.deleteDiary(id);
      expect(count, equals(1));


      final diaries = await dbHelper.getAllDiaries();
      expect(diaries.any((d) => d.id == id), isFalse);
    });
  });
}