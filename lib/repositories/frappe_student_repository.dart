
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/student.dart';
import 'student_repository.dart';

class FrappeStudentRepository implements StudentRepository {
  final Dio dio;

  FrappeStudentRepository(this.dio);

  @override
  Future<List<Student>> getStudents() async {
    try {
      final response = await dio.get(
        '/api/resource/Student',
        queryParameters: {
          'fields': jsonEncode([
            'name',
            'student_name',
            'email_id',
            'mobile_no',
            'department',
            'academic_year',
            'status',
            'date_of_birth',
          ]),
        },
      );

      final List data = response.data['data'];

      return data.map((item) {
        return Student.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

    } on DioException catch (error) {
     debugPrint('HTTP STATUS: ${error.response?.statusCode}');
    debugPrint('SERVER ERROR: ${error.response?.data}');
    debugPrint('REQUEST URL: ${error.requestOptions.uri}');
      rethrow;
    }
  }

@override
Future<Student> createStudent(Student student) async {
  final response = await dio.post(
    '/api/resource/Student',
    data: student.toJson(),
  );

  return Student.fromJson(
    Map<String, dynamic>.from(response.data['data']),
  );
}
@override
Future<Student> updateStudent(Student student) async {
  if (student.name == null || student.name!.isEmpty) {
    throw Exception('Student ID is required for updating');
  }

  final response = await dio.put(
    '/api/resource/Student/${Uri.encodeComponent(student.name!)}',
    data: student.toJson(),
  );

  return Student.fromJson(
    Map<String, dynamic>.from(response.data['data']),
  );
}
@override
Future<void> deleteStudent(Student student) async {
  if (student.name == null || student.name!.isEmpty) {
    throw Exception('Frappe Student ID is required');
  }

  await dio.delete(
    '/api/resource/Student/${Uri.encodeComponent(student.name!)}',
  );
}
}
