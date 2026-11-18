
import '../models/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getStudents();

  Future<Student> createStudent(Student student);

  Future<Student> updateStudent(Student student);

  Future<void> deleteStudent(Student student);
}
