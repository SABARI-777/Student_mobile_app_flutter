
import 'package:sqflite/sqflite.dart';

import '../core/storage/local_database.dart';
import '../models/student.dart'; 
class StudentLocalDataSource {
  Future<Database> get _db async =>
      LocalDatabase.instance.database;

  // READ
  Future<List<Student>> getStudents() async {
    final db = await _db;

    final rows = await db.query(
      'students',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
    );

    return rows.map((row) {
      return Student.fromJson({
        'local_id': row['id'],
        'name': row['server_id'],
        'student_name': row['student_name'],
        'email_id': row['email_id'],
        'mobile_no': row['mobile_no'],
        'department': row['department'],
        'academic_year': row['academic_year'],
        'status': row['status'],
        'date_of_birth': row['date_of_birth'],
        'sync_status': row['sync_status'],
      });
    }).toList();
  }

  // CREATE
  Future<Student> addStudent(Student student) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert('students', {
      'server_id': student.name,
      'student_name': student.studentName,
      'email_id': student.emailId,
      'mobile_no': student.mobileNo,
      'department': student.department,
      'academic_year': student.academicYear,
      'status': student.status,
      'date_of_birth': student.dateOfBirth,
      'sync_status': 'pending_create',
      'is_deleted': 0,
      'created_at': now,
      'updated_at': now,
    });

    return Student(
      localId: id,
      name: student.name,
      studentName: student.studentName,
      emailId: student.emailId,
      mobileNo: student.mobileNo,
      department: student.department,
      academicYear: student.academicYear,
      status: student.status,
      dateOfBirth: student.dateOfBirth,
      syncStatus: 'pending_create',
    );
  }

  // UPDATE
  Future<Student> updateStudent(Student student) async {
    final db = await _db;

    if (student.localId == null) {
      throw Exception('Local student ID is required');
    }

    final existing = await db.query(
      'students',
      columns: ['sync_status'],
      where: 'id = ?',
      whereArgs: [student.localId],
      limit: 1,
    );

    if (existing.isEmpty) {
      throw Exception('Student not found locally');
    }

    final oldStatus = existing.first['sync_status'] as String;

    final newStatus = oldStatus == 'pending_create'
        ? 'pending_create'
        : 'pending_update';

    await db.update(
      'students',
      {
        'student_name': student.studentName,
        'email_id': student.emailId,
        'mobile_no': student.mobileNo,
        'department': student.department,
        'academic_year': student.academicYear,
        'status': student.status,
        'date_of_birth': student.dateOfBirth,
        'sync_status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [student.localId],
    );

    return Student(
      localId: student.localId,
      name: student.name,
      studentName: student.studentName,
      emailId: student.emailId,
      mobileNo: student.mobileNo,
      department: student.department,
      academicYear: student.academicYear,
      status: student.status,
      dateOfBirth: student.dateOfBirth,
      syncStatus: newStatus,
    );
  }

  // DELETE
  Future<void> deleteStudent(Student student) async {
    final db = await _db;

    if (student.localId == null) {
      throw Exception('Local student ID is required');
    }

    final rows = await db.query(
      'students',
      columns: ['server_id', 'sync_status'],
      where: 'id = ?',
      whereArgs: [student.localId],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception('Student not found locally');
    }

    final serverId = rows.first['server_id'];
    final syncStatus = rows.first['sync_status'];

    if (serverId == null || syncStatus == 'pending_create') {
      // Never synchronized: permanently remove local record.
      await db.delete(
        'students',
        where: 'id = ?',
        whereArgs: [student.localId],
      );
    } else {
      // Already on Frappe: queue a deletion.
      await db.update(
        'students',
        {
          'is_deleted': 1,
          'sync_status': 'pending_delete',
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [student.localId],
      );
    }
  }

Future<void> saveServerStudents(List<Student> students) async {
  final db = await _db;

  await db.transaction((txn) async {
    for (final student in students) {
      if (student.name == null || student.name!.isEmpty) {
        continue;
      }

      // Check whether this student already exists locally.
      final existing = await txn.query(
        'students',
        columns: ['id', 'sync_status'],
        where: 'server_id = ?',
        whereArgs: [student.name],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final syncStatus =
            existing.first['sync_status'] as String;

        // Never overwrite pending offline changes.
        if (syncStatus != 'synced') {
          continue;
        }
      }

      final now = DateTime.now().toIso8601String();

      await txn.insert(
        'students',
        {
          'server_id': student.name,
          'student_name': student.studentName,
          'email_id': student.emailId,
          'mobile_no': student.mobileNo,
          'department': student.department,
          'academic_year': student.academicYear,
          'status': student.status,
          'date_of_birth': student.dateOfBirth,
          'sync_status': 'synced',
          'is_deleted': 0,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  });
}

}
