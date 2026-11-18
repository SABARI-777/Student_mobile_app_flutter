
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Creates a shared courses provider
final coursesProvider =
    NotifierProvider<CoursesNotifier, List<String>>(
  CoursesNotifier.new,
);

// Manages course data and operations
class CoursesNotifier extends Notifier<List<String>> {

  @override
  List<String> build() {
    return [
      'Flutter',
      'Database Management',
      'Computer Networks',
    ];
  }

  // Add a new course
  void addCourse(String course) {
    if (course.trim().isEmpty) return;

    if (state.contains(course.trim())) return;

    state = [...state, course.trim()];
  }

  // Delete a course
  void removeCourse(String course) {
    state = state
        .where((item) => item != course)
        .toList();
  }
}
