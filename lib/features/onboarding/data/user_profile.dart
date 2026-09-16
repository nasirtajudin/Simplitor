enum EducationType { university, highschool }

enum StreamType { social, natural }

/// Mutable draft filled in while onboarding runs.
class EducationDraft {
  EducationDraft({this.type = EducationType.university});

  EducationType type;
  String? university;
  String? schoolName;
  int? grade;
  StreamType? stream;

  /// 'economics', 'none' (not decided yet) or null (not chosen yet).
  String? department;
}

/// The final profile, stored at Firestore path users/{uid}.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.age,
    required this.phone,
    required this.educationType,
    this.schoolName,
    this.university,
    this.grade,
    this.stream,
    this.department,
  });

  final String name;
  final int age;
  final String phone;

  final EducationType educationType;

  /// Highschool only.
  final String? schoolName;

  /// University only.
  final String? university;

  /// Highschool only (9-12).
  final int? grade;

  /// University always; highschool only for grades 11-12.
  final StreamType? stream;

  /// 'economics' when the user picked the Economics department.
  /// null for natural science students, highschool students, and social
  /// science students without a department yet.
  final String? department;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'age': age,
        'phone': phone,
        'educationType': educationType.name,
        'schoolName': schoolName ?? '',
        'university': university ?? '',
        'grade': grade ?? 0,
        'stream': stream?.name ?? '',
        'department': department ?? '',
      };
}