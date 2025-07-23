class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role; // 'user', 'department', 'employee'
  final String? departmentId;
  final String? departmentName;
  final String? employeeId;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isActive;
  final bool mustChangePassword;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.departmentName,
    this.employeeId,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.isActive = true,
    this.mustChangePassword = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'employeeId': employeeId,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'mustChangePassword': mustChangePassword,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? '',
      departmentId: map['departmentId'],
      departmentName: map['departmentName'],
      employeeId: map['employeeId'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
      mustChangePassword: map['mustChangePassword'] ?? false,
    );
  }
}
