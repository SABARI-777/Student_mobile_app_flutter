
class Student {
  // SQLite ID
  final int? localId;

  // Frappe ID, for example STD-00001
  final String? name;

  final String studentName;
  final String emailId;
  final String mobileNo;
  final String department;
  final String academicYear;
  final String status;
  final String? dateOfBirth;

  // pending_create, pending_update, pending_delete, synced
  final String syncStatus;

  const Student({
    this.localId,
    this.name,
    required this.studentName,
    required this.emailId,
    required this.mobileNo,
    required this.department,
    required this.academicYear,
    required this.status,
    this.dateOfBirth,
    this.syncStatus = 'synced',
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      localId: json['local_id'] as int?,
      name: json['name']?.toString(),
      studentName: json['student_name']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      academicYear: json['academic_year']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString(),
      syncStatus: json['sync_status']?.toString() ?? 'synced',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_name': studentName,
      'email_id': emailId,
      'mobile_no': mobileNo,
      'department': department,
      'academic_year': academicYear,
      'status': status,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
    };
  }
}
