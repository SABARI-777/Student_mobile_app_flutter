
 
import '../models/student.dart';
import 'student_repository.dart';
import 'student_local_datasource.dart';
import 'frappe_student_repository.dart';

class OfflineFirstStudentRepository implements StudentRepository {
  final StudentLocalDataSource local;
  final FrappeStudentRepository remote;

  OfflineFirstStudentRepository({
    required this.local,
    required this.remote,
  });

  @override
  Future<List<Student>> getStudents() async {
    // Always return locally saved records.
    // Frappe refresh will be added in our sync service.
    return local.getStudents();
  }

  @override
  Future<Student> createStudent(Student student) {
    return local.addStudent(student);
  }

  @override
  Future<Student> updateStudent(Student student) {
    return local.updateStudent(student);
  }

  @override
  Future<void> deleteStudent(Student student) {
    return local.deleteStudent(student);
  }

  Future<List<Student>> refreshFromServer() async {
  final remoteStudents = await remote.getStudents();

  await local.saveServerStudents(remoteStudents);

  return local.getStudents();
}
}
