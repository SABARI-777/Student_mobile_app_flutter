
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student.dart';
import '../repositories/student_repository.dart';
import '../repositories/student_local_datasource.dart';
import '../repositories/frappe_student_repository.dart';
import '../repositories/offline_first_student_repository.dart';
import 'auth_provider.dart';

final studentLocalDataSourceProvider =
    Provider<StudentLocalDataSource>((ref) {
  return StudentLocalDataSource();
});

final offlineFirstStudentRepositoryProvider =
    Provider<OfflineFirstStudentRepository>((ref) {
  final dio = ref.watch(apiClientProvider).dio;

  return OfflineFirstStudentRepository(
    local: ref.watch(studentLocalDataSourceProvider),
    remote: FrappeStudentRepository(dio),
  );
});

final studentRepositoryProvider =
    Provider<StudentRepository>((ref) {
  return ref.watch(offlineFirstStudentRepositoryProvider);
});

final studentsProvider =
    FutureProvider<List<Student>>((ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getStudents();
});
