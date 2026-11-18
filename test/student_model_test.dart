
import 'package:flutter_test/flutter_test.dart';
import 'package:student_management_app/models/student.dart';

void main() {
  test('Convert JSON into Student object', () {
    final json = {
      'name': 'STD-00003',
      'student_name': 'Praveen',
      'email_id': 'praveen@gmail.com',
      'mobile_no': '9876543210',
      'department': 'Computer Science',
      'academic_year': 'Second Year',
      'status': 'Active',
    };

    final student = Student.fromJson(json);

    expect(student.name, 'STD-00003');
    expect(student.studentName, 'Praveen');
    expect(student.emailId, 'praveen@gmail.com');
    expect(student.status, 'Active');
  });
}
